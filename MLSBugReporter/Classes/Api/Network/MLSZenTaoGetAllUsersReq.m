//
//  MLSZenTaoGetAllUsersReq.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/17.
//

#import "MLSZenTaoGetAllUsersReq.h"
#import <hpple/TFHpple.h>
@interface MLSZenTaoGetAllUsersReq ()
@property (nonatomic, strong) NSDictionary *html_json_dict;
@end
@implementation MLSZenTaoGetAllUsersReq
- (NSString *)modlueName {
    return @"bug";
}
- (NSString *)methodName {
    return @"ajaxLoadAllUsers";
}

- (MLSResponseSerializerType)responseSerializerType {
    return MLSResponseSerializerTypeHTTP;
}
- (BOOL)requestCompletePreprocessor {
    if ([super requestCompletePreprocessor]) {
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:self.responseData];
        NSArray <TFHppleElement *>*elements = [doc searchWithXPathQuery:@"//option"];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:elements.count];
        [elements enumerateObjectsUsingBlock:^(TFHppleElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *key = [obj objectForKey:@"value"];
            if (key.length > 0) {
                [dict setObject:[obj text] forKey:key];
            }
        }];
        self.html_json_dict = dict;
        return YES;
    }
    return NO;
}
- (id)responseJSONObject {
    if (self.html_json_dict) {
        return self.html_json_dict;
    }
    return [super responseJSONObject];
}

@end
