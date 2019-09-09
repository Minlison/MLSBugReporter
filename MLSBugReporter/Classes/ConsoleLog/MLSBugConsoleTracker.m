//
//  MLSBugConsoleTracker.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/26.
//

#import "MLSBugConsoleTracker.h"
#import <sys/time.h>
#import <arpa/inet.h>
#import <stdlib.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>
#import <dlfcn.h>
#import <fcntl.h>
#import <stdatomic.h>
#import <unistd.h>
#import <pthread.h>
#import <dispatch/dispatch.h>
#import <libkern/OSAtomic.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#if !TARGET_OS_IPHONE
#import <CoreServices/CoreServices.h>
#endif
#import "MLSBugLogger.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIDevice.h>
#endif

static pthread_mutex_t MLSDebugConsoleGrabbersMutex = PTHREAD_MUTEX_INITIALIZER;
static int MLSDebugSConsolePipes[4] = { -1, -1, -1, -1 };
static int MLSDebugSSTDOUT = -1, MLSDebugsSSTDERR = -1;
static int MLSDebugSSTDOUThadSIGPIPE, MLSDebugsSTDERRhadSIGPIPE;
static pthread_t MLSDebugsConsoleGrabThread;

static unsigned MLSDebugNumActiveConsoleGrabbers = 0;

static void MLSDebugLoggerLogFromConsole(CFStringRef tag, int fd, int outfd, CFMutableDataRef data)
{
    // protected by `MLSDebugConsoleGrabbersMutex`
    
    const int BUFSIZE = 1000;
    size_t prognameLength = strlen(getprogname());
    
    UInt8 buf[BUFSIZE];
    ssize_t bytes_read = 0;
    while ((bytes_read = read(fd, buf, BUFSIZE-1)) >= 0)
    {
        if (bytes_read == 0)
            continue;
        
        CFDataAppendBytes(data, buf, bytes_read);
        
        if (outfd != -1)
        {
            // output received data to the original fd (so as to keep output in the Xcode console etc)
            //write(outfd, "##", 2); // internal debug stuff to visualize stdout/stderr fragmentation
            write(outfd, buf, (size_t)bytes_read);
        }
        
        for(;;)
        {
            // locate newline, group multiple lines in the same log string
            const unsigned char *bytes = CFDataGetMutableBytePtr(data);
            if (bytes == NULL)    // pointer may be null if data is empty
                break;
            
            NSInteger pos = 0, maxPos = CFDataGetLength(data), lineBreak = -1;
            while (pos < maxPos)
            {
                if (bytes[pos] == '\n')
                    lineBreak = pos;
                pos++;
            }
            if (lineBreak == -1)
                break;
            pos = lineBreak;
            
            // detect and remove NSLog header if any
            NSUInteger offset = 0;
            if (pos > 24 + prognameLength + 2)
            {
                // "yyyy-mm-dd HH:MM:ss.SSS progname[:] "
                if ((bytes[4] == '-') && (bytes[7] == '-') && (bytes[10] == ' ') && (bytes[13] == ':') && (bytes[16] == ':') && (bytes[19] == '.'))
                {
                    if ((bytes[23] == ' ') &&  (bytes[24 + prognameLength] == '['))
                    {
                        const char* found = strnstr((const char *)&bytes[24 + prognameLength + 1], "] ", maxPos - (24 + prognameLength + 1));
                        if (found)
                        {
                            offset = found - (const char *)bytes + 2;
                        }
                    }
                }
            }
            
            // output message to grabbers
            CFStringRef message = CFStringCreateWithBytes(NULL, bytes+offset, pos-offset, kCFStringEncodingUTF8, false);
            if (message != NULL)
            {
                MLSBugLogConsole((__bridge NSString *)message);
                CFRelease(message);
            }
            else
            {
                MLSBugLogConsole(CFSTR("failed extracting string of length %d from fd %d"), pos-offset, fd);
            }
            
            // drop all newlines and move on
            while (++pos < maxPos && (bytes[pos] == '\n' || bytes[pos] == '\r'))
                ;
            CFDataDeleteBytes(data, CFRangeMake(0, pos));
        }
    }
}

static void *MLSDebugLoggerConsoleGrabThread(void *context)
{
#pragma unused (context)
    pthread_mutex_lock(&MLSDebugConsoleGrabbersMutex);
    
    int fdout = MLSDebugSConsolePipes[0];
    fcntl(fdout, F_SETFL, fcntl(fdout, F_GETFL, 0) | O_NONBLOCK);
    
    int fderr = MLSDebugSConsolePipes[2];
    fcntl(fderr, F_SETFL, fcntl(fderr, F_GETFL, 0) | O_NONBLOCK);
    
    CFMutableDataRef stdoutData = CFDataCreateMutable(NULL, 0);
    CFMutableDataRef stderrData = CFDataCreateMutable(NULL, 0);
    
    unsigned activeGrabbers = MLSDebugNumActiveConsoleGrabbers;
    
    pthread_mutex_unlock(&MLSDebugConsoleGrabbersMutex);
    
    while (activeGrabbers != 0)
    {
        fd_set set;
        FD_ZERO(&set);
        FD_SET(fdout, &set);
        FD_SET(fderr, &set);
        
        int ret = select(fderr + 1, &set, NULL, NULL, NULL);
        
        if (ret <= 0)
        {
            // ==0: time expired without activity
            // < 0: error occurred
            break;
        }
        
        pthread_mutex_lock(&MLSDebugConsoleGrabbersMutex);
        
        activeGrabbers = MLSDebugNumActiveConsoleGrabbers;
        if (activeGrabbers != 0)
        {
            if (FD_ISSET(fdout, &set))
                MLSDebugLoggerLogFromConsole(CFSTR("stdout"), fdout, MLSDebugSSTDOUT, stdoutData);
            if (FD_ISSET(fderr, &set ))
                MLSDebugLoggerLogFromConsole(CFSTR("stderr"), fderr, MLSDebugsSSTDERR, stderrData);
        }
        
        pthread_mutex_unlock(&MLSDebugConsoleGrabbersMutex);
    }
    
    CFRelease(stdoutData);
    CFRelease(stderrData);
    return NULL;
}

static void MLSDebugLoggerStartConsoleRedirection()
{
    // protected by `MLSDebugConsoleGrabbersMutex`
    
    // keep the original pipes so we can still forward everything
    // (i.e. to the running IDE that needs to display or interpret console messages)
    // and remember the SIGPIPE settings, as we are going to clear them to prevent
    // the app from exiting when we close the pipes
    if (MLSDebugSSTDOUT == -1)
    {
        MLSDebugSSTDOUThadSIGPIPE = fcntl(STDOUT_FILENO, F_GETNOSIGPIPE);
        MLSDebugSSTDOUT = dup(STDOUT_FILENO);
        MLSDebugsSTDERRhadSIGPIPE = fcntl(STDERR_FILENO, F_GETNOSIGPIPE);
        MLSDebugsSSTDERR = dup(STDERR_FILENO);
    }
    
    // create the pipes
    if (MLSDebugSConsolePipes[0] == -1)
    {
        if (pipe(MLSDebugSConsolePipes) != -1)
        {
            fcntl(MLSDebugSConsolePipes[0], F_SETNOSIGPIPE, 1);
            fcntl(MLSDebugSConsolePipes[1], F_SETNOSIGPIPE, 1);
            dup2(MLSDebugSConsolePipes[1], STDOUT_FILENO);
        }
    }
    
    if (MLSDebugSConsolePipes[2] == -1)
    {
        if (pipe(&MLSDebugSConsolePipes[2]) != -1)
        {
            fcntl(MLSDebugSConsolePipes[0], F_SETNOSIGPIPE, 1);
            fcntl(MLSDebugSConsolePipes[1], F_SETNOSIGPIPE, 1);
            dup2(MLSDebugSConsolePipes[3], STDERR_FILENO);
        }
    }
    
    pthread_create(&MLSDebugsConsoleGrabThread, NULL, &MLSDebugLoggerConsoleGrabThread, NULL);
}

static void MLSDebugLoggerStopConsoleRedirection()
{
    // protected by MLSDebugConsoleGrabbersMutex (see below)
    
    // close the pipes - will force exiting the console logger thread
    // assume the console grabber mutex has been acquired
    dup2(MLSDebugSSTDOUT, STDOUT_FILENO);
    dup2(MLSDebugsSSTDERR, STDERR_FILENO);
    
    close(MLSDebugSSTDOUT);
    close(MLSDebugsSSTDERR);
    
    MLSDebugSSTDOUT = -1;
    MLSDebugsSSTDERR = -1;
    
    // restore sigpipe flag on standard streams
    fcntl(STDOUT_FILENO, F_SETNOSIGPIPE, &MLSDebugSSTDOUThadSIGPIPE);
    fcntl(STDERR_FILENO, F_SETNOSIGPIPE, &MLSDebugsSTDERRhadSIGPIPE);
    
    // close pipes, this will trigger an error in select() and a console grab thread exit
    if (MLSDebugSConsolePipes[0] != -1)
    {
        close(MLSDebugSConsolePipes[0]);
        close(MLSDebugSConsolePipes[1]);
        MLSDebugSConsolePipes[0] = -1;
    }
    if (MLSDebugSConsolePipes[2] != -1)
    {
        close(MLSDebugSConsolePipes[2]);
        close(MLSDebugSConsolePipes[1]);
    }
    MLSDebugSConsolePipes[0] = MLSDebugSConsolePipes[1] = MLSDebugSConsolePipes[2] = MLSDebugSConsolePipes[3] = -1;
    MLSDebugNumActiveConsoleGrabbers = 0;
    
    pthread_mutex_unlock(&MLSDebugConsoleGrabbersMutex);
    pthread_join(MLSDebugsConsoleGrabThread, NULL);
    pthread_mutex_lock(&MLSDebugConsoleGrabbersMutex);
}

static void MLSDebugLoggerStartGrabbingConsole()
{
    pthread_mutex_lock(&MLSDebugConsoleGrabbersMutex);
    
    MLSDebugNumActiveConsoleGrabbers = 1;
    MLSDebugLoggerStartConsoleRedirection();
    
    pthread_mutex_unlock(&MLSDebugConsoleGrabbersMutex);
}

static void MLSDebugLoggerStopGrabbingConsole()
{
    pthread_mutex_lock(&MLSDebugConsoleGrabbersMutex);
    
    MLSDebugLoggerStopConsoleRedirection();
    
    pthread_mutex_unlock(&MLSDebugConsoleGrabbersMutex);
}

@interface MLSBugConsoleTracker ()

@end
@implementation MLSBugConsoleTracker

+ (void)install {
    MLSDebugLoggerStartGrabbingConsole();
}
+ (void)unInstall {
    MLSDebugLoggerStopGrabbingConsole();
}

@end
