//
//  ViewController.m
//  MLSBugReporterDemo
//
//  Created by yuanhang on 2019/9/9.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "ViewController.h"
#import <Matrix/MatrixTester.h>
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


@end
