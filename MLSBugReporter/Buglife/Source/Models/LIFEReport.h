//
//  LIFEReport.h
//  Copyright (C) 2017 Buglife, Inc.
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//       http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//

#import <UIKit/UIKit.h>
#import "LIFEDeviceBatteryState.h"
#import "LIFEAttribute.h"
#import "Buglife.h"

@class LIFEReproStep;
@class LIFEAppInfo;
@class LIFEDeviceInfo;
@class LIFEReportAttachmentImpl;

// Reports are immutable objects, and should be
// created using LIFEReportBuilder
@interface LIFEReport : NSObject <NSCoding>

// WARNING: NONE OF THESE PROPERTIES
// SHOULD BE SET DIRECTLY! Please use
// LIFEReportBuilder to create reports.

@property (nullable, nonatomic, copy) NSString *whatHappened;
@property (nullable, nonatomic, copy) NSString *component;
@property (nullable, nonatomic, strong) NSArray<LIFEReproStep *> *reproSteps;
@property (nullable, nonatomic, copy) NSString *expectedResults;
@property (nullable, nonatomic, copy) NSString *actualResults;
@property (nullable, nonatomic, strong) UIImage *screenshot;
@property (nullable, nonatomic, strong) NSDate *creationDate;
@property (nullable, nonatomic, copy) NSString *logs;
@property (nullable, nonatomic, strong) LIFEAppInfo *appInfo;
@property (nullable, nonatomic, strong) LIFEDeviceInfo *deviceInfo;
@property (nullable, nonatomic, copy) NSString *userIdentifier;
@property (nullable, nonatomic, copy) NSString *userEmail;
@property (nullable, nonatomic, strong) NSArray<LIFEReportAttachmentImpl *> *attachments;
@property (nullable, nonatomic, copy) NSString *timeZoneName;
@property (nullable, nonatomic, copy) NSString *timeZoneAbbreviation;
@property (nonatomic, assign) LIFEInvocationOptions invocationMethod;
@property (nullable, nonatomic, strong) NSDictionary<NSString *, LIFEAttribute *> *attributes;

// Number of attempts to submit this report (default 0).
// This is an NSInteger because NSCoder doesn't handle NSUInteger well
@property (nonatomic, assign) NSInteger submissionAttempts;

- (_Null_unspecified instancetype)init NS_UNAVAILABLE;
- (nonnull NSString *)suggestedFilename;
- (nonnull NSDictionary *)JSONDictionary;

@end
