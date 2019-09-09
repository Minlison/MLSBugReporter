//
//  MLSBaseModel.m
//  Pods-MLSModel
//
//  Created by MinLison on 2018/5/8.
//

#import "MLSBaseModel.h"
#import <objc/runtime.h>
@implementation MLSBaseModel
- (BOOL)isValid {
    return YES;
}
- (NSError *)validError {
    return nil;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {};

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    if (!dic) {
        return dic;
    }
    
    NSDictionary <NSString *,id>*nonnullDict = [self nonnullDefaultValueProperties];
    
    if (!nonnullDict) {
        return dic;
    }
    
    NSMutableDictionary *orangleDict = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    for (NSString *key in nonnullDict.allKeys) {
        if ([orangleDict objectForKey:key] == nil) {
            [orangleDict setObject:[nonnullDict objectForKey:key] forKey:key];
        }
    }
    return orangleDict;
}

- (NSString *)description {
    return [self mls_modelDescription];
}
- (NSString *)debugDescription {
    return [self mls_modelDescription];
}
- (nullable NSDictionary <NSString *,id>*)nonnullDefaultValueProperties {
    return nil;
}
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return nil;
}
+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return nil;
}
@end

#pragma GCC diagnostic ignored "-Wgnu"
static NSString *const MLSAutocodingException = @"MLSAutocodingException";
@implementation MLSBaseModel (AutoCoding)

+ (BOOL)supportsSecureCoding {
    return YES;
}
+ (instancetype)mls_objectWithContentsOfFile:(NSString *)filePath {
    //load the file
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    //attempt to deserialise data as a plist
    id object = nil;
    if (data)
    {
        NSPropertyListFormat format;
        object = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:&format error:NULL];
        //success?
        if (object)
        {
            //check if object is an NSCoded unarchive
            if ([object respondsToSelector:@selector(objectForKey:)] && [(NSDictionary *)object objectForKey:@"$archiver"])
            {
                object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
        }
        else
        {
            //return raw data
            object = data;
        }
    }
    //return object
    return object;
}
- (BOOL)mls_writeToFile:(NSString *)filePath atomically:(BOOL)useAuxiliaryFile {
    //note: NSData, NSDictionary and NSArray already implement this method
    //and do not save using NSCoding, however the objectWithContentsOfFile
    //method will correctly recover these objects anyway
    //archive object
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [data writeToFile:filePath atomically:useAuxiliaryFile];
}
+ (NSDictionary *)mls_codableProperties {
    //deprecated
    SEL deprecatedSelector = NSSelectorFromString(@"codableKeys");
    if ([self respondsToSelector:deprecatedSelector] || [self instancesRespondToSelector:deprecatedSelector])
    {
        NSLog(@"AutoCoding Warning: codableKeys method is no longer supported. Use codableProperties instead.");
    }
    deprecatedSelector = NSSelectorFromString(@"uncodableKeys");
    if ([self respondsToSelector:deprecatedSelector] || [self instancesRespondToSelector:deprecatedSelector])
    {
        NSLog(@"AutoCoding Warning: uncodableKeys method is no longer supported. Use ivars, or synthesize your properties using non-KVC-compliant names to avoid coding them instead.");
    }
    deprecatedSelector = NSSelectorFromString(@"uncodableProperties");
    NSArray *uncodableProperties = nil;
    if ([self respondsToSelector:deprecatedSelector] || [self instancesRespondToSelector:deprecatedSelector])
    {
        uncodableProperties = [self valueForKey:@"uncodableProperties"];
        NSLog(@"AutoCoding Warning: uncodableProperties method is no longer supported. Use ivars, or synthesize your properties using non-KVC-compliant names to avoid coding them instead.");
    }
    unsigned int propertyCount;
    __autoreleasing NSMutableDictionary *codableProperties = [NSMutableDictionary dictionary];
    objc_property_t *properties = class_copyPropertyList(self, &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++)
    {
        //get property name
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        __autoreleasing NSString *key = @(propertyName);
        //check if codable
        if (![uncodableProperties containsObject:key])
        {
            //get property type
            Class propertyClass = nil;
            char *typeEncoding = property_copyAttributeValue(property, "T");
            switch (typeEncoding[0])
            {
                case '@':
                {
                    if (strlen(typeEncoding) >= 3)
                    {
                        char *className = strndup(typeEncoding + 2, strlen(typeEncoding) - 3);
                        __autoreleasing NSString *name = @(className);
                        NSRange range = [name rangeOfString:@"<"];
                        if (range.location != NSNotFound)
                        {
                            name = [name substringToIndex:range.location];
                        }
                        propertyClass = NSClassFromString(name) ?: [NSObject class];
                        free(className);
                    }
                    break;
                }
                case 'c':
                case 'i':
                case 's':
                case 'l':
                case 'q':
                case 'C':
                case 'I':
                case 'S':
                case 'L':
                case 'Q':
                case 'f':
                case 'd':
                case 'B':
                {
                    propertyClass = [NSNumber class];
                    break;
                }
                case '{':
                {
                    propertyClass = [NSValue class];
                    break;
                }
            }
            free(typeEncoding);
            if (propertyClass)
            {
                //check if there is a backing ivar
                char *ivar = property_copyAttributeValue(property, "V");
                if (ivar)
                {
                    //check if ivar has KVC-compliant name
                    __autoreleasing NSString *ivarName = @(ivar);
                    if ([ivarName isEqualToString:key] || [ivarName isEqualToString:[@"_" stringByAppendingString:key]])
                    {
                        //no setter, but setValue:forKey: will still work
                        codableProperties[key] = propertyClass;
                    }
                    free(ivar);
                }
                else
                {
                    //check if property is dynamic and readwrite
                    char *dynamic = property_copyAttributeValue(property, "D");
                    char *readonly = property_copyAttributeValue(property, "R");
                    if (dynamic && !readonly)
                    {
                        //no ivar, but setValue:forKey: will still work
                        codableProperties[key] = propertyClass;
                    }
                    free(dynamic);
                    free(readonly);
                }
            }
        }
    }
    free(properties);
    return codableProperties;
}
- (NSDictionary *)mls_codableProperties {
    __autoreleasing NSDictionary *codableProperties = objc_getAssociatedObject([self class], _cmd);
    if (!codableProperties)
    {
        codableProperties = [NSMutableDictionary dictionary];
        Class subclass = [self class];
        while (subclass != [NSObject class])
        {
            [(NSMutableDictionary *)codableProperties addEntriesFromDictionary:[subclass mls_codableProperties]];
            subclass = [subclass superclass];
        }
        codableProperties = [NSDictionary dictionaryWithDictionary:codableProperties];
        //make the association atomically so that we don't need to bother with an @synchronize
        objc_setAssociatedObject([self class], _cmd, codableProperties, OBJC_ASSOCIATION_RETAIN);
    }
    return codableProperties;
}
- (NSDictionary *)mls_dictionaryRepresentation {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (__unsafe_unretained NSString *key in [self mls_codableProperties])
    {
        id value = [self valueForKey:key];
        if (value) dict[key] = value;
    }
    return dict;
}
- (void)mls_setWithCoder:(NSCoder *)aDecoder {
    BOOL secureAvailable = [aDecoder respondsToSelector:@selector(decodeObjectOfClass:forKey:)];
    BOOL secureSupported = [[self class] supportsSecureCoding];
    NSDictionary *properties = [self mls_codableProperties];
    for (NSString *key in properties)
    {
        id object = nil;
        Class propertyClass = properties[key];
        if (secureAvailable)
        {
            object = [aDecoder decodeObjectOfClass:propertyClass forKey:key];
        }
        else
        {
            object = [aDecoder decodeObjectForKey:key];
        }
        if (object)
        {
            if (secureSupported && ![object isKindOfClass:propertyClass])
            {
                [NSException raise:MLSAutocodingException format:@"Expected '%@' to be a %@, but was actually a %@", key, propertyClass, [object class]];
            }
            [self setValue:object forKey:key];
        }
    }
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    [self mls_setWithCoder:aDecoder];
    return self;
}
#pragma clang diagnostic pop
- (void)encodeWithCoder:(NSCoder *)aCoder {
    for (NSString *key in [self mls_codableProperties])
    {
        id object = [self valueForKey:key];
        if (object) [aCoder encodeObject:object forKey:key];
    }
}
@end
