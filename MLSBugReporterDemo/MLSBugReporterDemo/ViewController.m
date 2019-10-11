//
//  ViewController.m
//  MLSBugReporterDemo
//
//  Created by yuanhang on 2019/9/9.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "ViewController.h"
#import <Matrix/MatrixTester.h>
#import <MLSNetwork/MLSNetwork.h>
@interface TestContact : NSObject

@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *signature;

@end

@implementation TestContact

- (id)init
{
    self = [super init];
    if (self) {
        self.nickName = @"Don Shirley";
        self.sex = @"Man";
        self.country = @"U.S.A";
        self.state = @"New York";
        self.city = @"New York City";
        self.signature = @"You never win with violence. You only win when you maintain your dignity.- Don Shirley (Green Book) \
        It takes courage to change people’s hearts. - Oleg (Green Book) \
        The world's full of lonely people afraid to make the first move. - Tony Lip (Green Book)";
    }
    return self;
}

@end

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)notFoundSelectorCrash {
    [[[MatrixTester alloc] init] notFoundSelectorCrash];
}
- (IBAction)wrongFormatCrash{
    [[[MatrixTester alloc] init] wrongFormatCrash];
}
- (IBAction)deadSignalCrash{
    [[[MatrixTester alloc] init] deadSignalCrash];
}
- (IBAction)nsexceptionCrash{
    [[[MatrixTester alloc] init] nsexceptionCrash];
}
- (IBAction)cppexceptionCrash{
    [[[MatrixTester alloc] init] cppexceptionCrash];
}
- (IBAction)cppToNsExceptionCrash{
    [[[MatrixTester alloc] init] cppToNsExceptionCrash];
}
- (IBAction)childNsexceptionCrash{
    [[[MatrixTester alloc] init] childNsexceptionCrash];
}
- (IBAction)overflowCrash{
    [[[MatrixTester alloc] init] overflowCrash];
    
}
- (IBAction)generateMainThreadLagLog {
    [[[MatrixTester alloc] init] generateMainThreadLagLog];
}
- (IBAction)generateMainThreadBlockToBeKilledLog {
    [[[MatrixTester alloc] init] generateMainThreadBlockToBeKilledLog];
}
- (IBAction)costCPUALot {
    [[[MatrixTester alloc] init] costCPUALot];
}
- (IBAction)oom {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *array = [NSMutableArray array];
        while (1) {
            TestContact *contact = [[TestContact alloc] init];
            [array addObject:contact];
        }
    });
}
- (IBAction)sendNetworkRequest:(id)sender {
    MLSNetworkRequest *request = [MLSNetworkRequest requestWithParam:nil];
    request.requestUrl = @"https://www.baidu.com";
    request.requestMethod = MLSRequestMethodGET;
    [request startWithCompletionBlockWithSuccess:^(__kindof MLSBaseRequest *request) {
        
    } failure:^(__kindof MLSBaseRequest *request) {
        NSLog(@"%@",request.error);
    }];
}
- (IBAction)logConsole:(id)sender {
    for (int i = 0; i < 10; i++) {
        NSLog(@"使用 NSLog 打印日志 %d",i);
    }
}


@end
