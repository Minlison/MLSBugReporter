//
//  LIFETextFieldCellTableViewCell.h
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


#import <UIKit/UIKit.h>

@class LIFETextFieldCell;

@protocol LIFETextFieldCellDelegate <NSObject>

- (void)textFieldCellDidReturn:(nonnull LIFETextFieldCell *)textFieldCell;
- (void)textFieldCellDidChange:(nonnull LIFETextFieldCell *)textFieldCell;

@end

@class LIFEInputField;

@interface LIFETextFieldCell : UITableViewCell

+ (nonnull NSString *)defaultIdentifier;

@property (nonatomic, weak, nullable) id<LIFETextFieldCellDelegate> delegate;
@property (nonatomic, nonnull, readonly) UITextField *textField;
@property (nonatomic, nullable, strong) LIFEInputField *inputField;

@end
