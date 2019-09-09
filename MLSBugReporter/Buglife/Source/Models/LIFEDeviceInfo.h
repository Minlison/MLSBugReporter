//
//  LIFEDeviceInfo.h
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

#import <Foundation/Foundation.h>
#import "LIFEDeviceBatteryState.h"

@interface LIFEDeviceInfo : NSObject <NSCoding>

@property (nonatomic, copy) NSString *operatingSystemVersion;
@property (nonatomic, copy) NSString *deviceModel;
@property (nonatomic, copy) NSNumber *fileSystemSizeInBytes;
@property (nonatomic, copy) NSNumber *freeFileSystemSizeInBytes;
@property (nonatomic, copy) NSNumber *freeMemory;
@property (nonatomic, copy) NSNumber *usableMemory;
@property (nonatomic, copy) NSString *identifierForVendor;
@property (nonatomic, copy) NSString *localeIdentifier;
@property (nonatomic, copy) NSString *carrierName;
@property (nonatomic, copy) NSString *currentRadioAccessTechnology;
@property (nonatomic, assign) BOOL wifiConnected;
@property (nonatomic, assign) float batteryLevel;
@property (nonatomic, assign) LIFEDeviceBatteryState batteryState;
@property (nonatomic, assign) BOOL lowPowerMode;

@end
