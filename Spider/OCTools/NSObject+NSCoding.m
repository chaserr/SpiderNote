/*
//
//  NSObject+NSCoding.m
//  OpenStack
//
//  Created by Michael Mayo on 3/4/11.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>
#import "NSObject+NSCoding.h"
#import <objc/runtime.h>


@implementation NSObject (NSCoding)

- (NSMutableDictionary *)propertiesForClass:(Class)klass {
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        
        NSString *pname = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *pattrs = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        
        pattrs = [[pattrs componentsSeparatedByString:@","] objectAtIndex:0];
        pattrs = [pattrs substringFromIndex:1];
        
        [results setObject:pattrs forKey:pname];
    }
    free(properties);
    
    if ([klass superclass] != [NSObject class]) {
        [results addEntriesFromDictionary:[self propertiesForClass:[klass superclass]]];
    }
    
    return results;
}

- (NSDictionary *)properties {
    return [self propertiesForClass:[self class]];
}

- (void)autoEncodeWithCoder:(NSCoder *)coder {
    NSDictionary *properties = [self properties];
    for (NSString *key in properties) {
        NSString *type = [properties objectForKey:key];
        id value;
        unsigned long long ullValue;
        BOOL boolValue;
        float floatValue;
        double doubleValue;
        NSInteger intValue;
        unsigned long ulValue;
		long longValue;
		unsigned unsignedValue;
		short shortValue;
        NSString *className;
		
        NSMethodSignature *signature = [self methodSignatureForSelector:NSSelectorFromString(key)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:NSSelectorFromString(key)];
        [invocation setTarget:self];
        
        switch ([type characterAtIndex:0]) {
            case '@':   // object
                if ([[type componentsSeparatedByString:@"\""] count] > 1) {
                    className = [[type componentsSeparatedByString:@"\""] objectAtIndex:1];
                    Class class = NSClassFromString(className);
                    
#warning UIImage类型的属性不归档  add by yhy
                    if ([className isEqualToString:@"UIImage"]) {
                        //如果属性是UIImage类型的，不进行归档
                        break;
                    }
                    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    value = [self performSelector:NSSelectorFromString(key)];
#pragma clang diagnostic pop
					
                    // only decode if the property conforms to NSCoding
                    if([class conformsToProtocol:@protocol(NSCoding)]){
                        [coder encodeObject:value forKey:key];
                    }
                }
                break;
            case 'c':   // bool
                [invocation invoke];
                [invocation getReturnValue:&boolValue];
                [coder encodeObject:[NSNumber numberWithBool:boolValue] forKey:key];
                break;
            case 'f':   // float
                [invocation invoke];
                [invocation getReturnValue:&floatValue];
                [coder encodeObject:[NSNumber numberWithFloat:floatValue] forKey:key];
                break;
            case 'd':   // double
                [invocation invoke];
                [invocation getReturnValue:&doubleValue];
                [coder encodeObject:[NSNumber numberWithDouble:doubleValue] forKey:key];
                break;
            case 'i':   // int
                [invocation invoke];
                [invocation getReturnValue:&intValue];
                [coder encodeObject:[NSNumber numberWithInt:intValue] forKey:key];
                break;
            case 'L':   // unsigned long
                [invocation invoke];
                [invocation getReturnValue:&ulValue];
                [coder encodeObject:[NSNumber numberWithUnsignedLong:ulValue] forKey:key];
                break;
            case 'Q':   // unsigned long long
                [invocation invoke];
                [invocation getReturnValue:&ullValue];
                [coder encodeObject:[NSNumber numberWithUnsignedLongLong:ullValue] forKey:key];
                break;
            case 'l':   // long
                [invocation invoke];
                [invocation getReturnValue:&longValue];
                [coder encodeObject:[NSNumber numberWithLong:longValue] forKey:key];
                break;
            case 's':   // short
                [invocation invoke];
                [invocation getReturnValue:&shortValue];
                [coder encodeObject:[NSNumber numberWithShort:shortValue] forKey:key];
                break;
            case 'I':   // unsigned
                [invocation invoke];
                [invocation getReturnValue:&unsignedValue];
                [coder encodeObject:[NSNumber numberWithUnsignedInt:unsignedValue] forKey:key];
                break;
            default:
                break;
        }
    }
}

- (void)autoDecode:(NSCoder *)coder {
    NSDictionary *properties = [self properties];
    for (NSString *key in properties) {
        NSString *type = [properties objectForKey:key];
        id value;
        NSNumber *number;
        NSInteger i;
        CGFloat f;
        BOOL b;
        double d;
        unsigned long ul;
        unsigned long long ull;
		long longValue;
		unsigned unsignedValue;
		short shortValue;
        
        NSString *className;
        
        switch ([type characterAtIndex:0]) {
            case '@':   // object
                if ([[type componentsSeparatedByString:@"\""] count] > 1) {
                    className = [[type componentsSeparatedByString:@"\""] objectAtIndex:1];
                    Class class = NSClassFromString(className);
                    
#warning UIImage类型的属性不归档  add by yhy
                    if ([className isEqualToString:@"UIImage"]) {
                        //如果属性是UIImage类型的，不进行反归档
                        break;
                    }

                    // only decode if the property conforms to NSCoding
                    if ([class conformsToProtocol:@protocol(NSCoding )]){
                        value = [coder decodeObjectForKey:key];
                        [self setValue:value forKey:key];
                    }
                }
                break;
            case 'c':   // bool
                number = [coder decodeObjectForKey:key];
                b = [number boolValue];
                [self setValue:@(b) forKey:key];
                break;
            case 'f':   // float
                number = [coder decodeObjectForKey:key];
                f = [number floatValue];
                [self setValue:@(f) forKey:key];
                break;
            case 'd':   // double
                number = [coder decodeObjectForKey:key];
                d = [number doubleValue];
                [self setValue:@(d) forKey:key];
                break;
            case 'i':   // int
                number = [coder decodeObjectForKey:key];
                i = [number intValue];
                [self setValue:@(i) forKey:key];
                break;
            case 'L':   // unsigned long
                number = [coder decodeObjectForKey:key];
                ul = [number unsignedLongValue];
                [self setValue:@(ul) forKey:key];
                break;
            case 'Q':   // unsigned long long
                number = [coder decodeObjectForKey:key];
                ull = [number unsignedLongLongValue];
                [self setValue:@(ull) forKey:key];
                break;
			case 'l':   // long
                number = [coder decodeObjectForKey:key];
                longValue = [number longValue];
                [self setValue:@(longValue) forKey:key];
                break;
            case 'I':   // unsigned
                number = [coder decodeObjectForKey:key];
                unsignedValue = [number unsignedIntValue];
                [self setValue:@(unsignedValue) forKey:key];
                break;
            case 's':   // short
                number = [coder decodeObjectForKey:key];
                shortValue = [number shortValue];
                [self setValue:@(shortValue) forKey:key];
                break;
            default:
                break;
        }
    }
}


@end*/

//
//  NSObject+NSCoding.m
//
//  Created by shjborage on 2/17/14.
//  Copyright (c) 2014 Saick. All rights reserved.
//

/*
 unsigned int methodCount = 0;
 Method *methods = class_copyMethodList([self class], &methodCount);
 for (int j=0; j<methodCount; j++) {
 Method mt = methods[j];
 NSString *methodName = NSStringFromSelector(method_getName(mt));
 NSLog(@"method:%@", methodName);
 if ([methodName isEqualToString:name]) {
 id value = method_invoke(self, mt);
 NSLog(@"value:%@", value);
 break;
 }
 }
 free(methods);
 
 //    id value = objc_msgSend(self, selector);
 //    int value = ((int(*)(id, SEL))objc_msgSend)(self, selector);
 */

#import "NSObject+NSCoding.h"

#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (NSCoding)

/**
 *  @author 童星, 16-07-26 10:07:30
 *
 *  @brief 不知道为什么，检测不了Int性的属性
 */
- (void)encodeAutoWithCoder:(NSCoder *)aCoder class:(Class)class
{
    unsigned int outCount = 0;
    objc_property_t *pt = class_copyPropertyList(class, &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = pt[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        
        SEL selector = NSSelectorFromString(name);
        Method mt = class_getInstanceMethod(class, selector);
        if (mt != NULL) {
            NSString *returnType = [class getMethodReturnType:mt];
            if ([returnType isEqualToString:@"i"] ||
                [returnType isEqualToString:@"q"] ||
                [returnType isEqualToString:@"Q"])
            {
                int intValue = ((int(*)(id, Method))method_invoke)(self, mt);
#if kNSCodingDebugLoging
                NSLog(@"Encode %@ %@ int value:%d", NSStringFromClass(class), name, intValue);
#endif
                [aCoder encodeInteger:intValue forKey:name];
            } else if ([returnType isEqualToString:@"I"]) {
                unsigned intValue = ((unsigned(*)(id, Method))method_invoke)(self, mt);
#if kNSCodingDebugLoging
                NSLog(@"Encode %@ %@ int value:%d", NSStringFromClass(class), name, intValue);
#endif
                [aCoder encodeInteger:intValue forKey:name];
            } else if ([returnType isEqualToString:@"f"] ||
                       [returnType isEqualToString:@"d"])
            {
                double doubleValue = ((double(*)(id, Method))method_invoke)(self, mt);
#if kNSCodingDebugLoging
                NSLog(@"Encode %@ %@ double value:%.f", NSStringFromClass(class), name, doubleValue);
#endif
                
                [aCoder encodeDouble:doubleValue forKey:name];
            } else if ([returnType isEqualToString:@"c"] ||
                       [returnType isEqualToString:@"B"])
            {   // char 一般为BOOL, property不用char即可
                BOOL boolValue = ((char(*)(id, Method))method_invoke)(self, mt);
#if kNSCodingDebugLoging
                NSLog(@"Encode %@ %@ BOOL value:%d", NSStringFromClass(class), name, boolValue);
#endif
                [aCoder encodeBool:boolValue forKey:name];
            } else {
                @try {
                    id value = ((id(*)(id, Method))method_invoke)(self, mt);
#if kNSCodingDebugLoging
                    NSLog(@"Encode %@ %@  value:%@", NSStringFromClass(class), name, value);
#endif
                    [aCoder encodeObject:value forKey:name];
                }
                @catch (NSException *exception) {
#if kNSCodingDebugLoging
                    NSLog(@"Encode Return Value Type undefined in %@", NSStringFromClass(class));
#endif
                }
                @finally {
                }
            } // end of } else {
        } // end of if (mt != NULL) {
    }
    free(pt);
}

- (void)encodeAutoWithCoder:(NSCoder *)aCoder
{
    [self encodeAutoWithCoder:aCoder class:[self class]];
}

- (void)decodeAutoWithAutoCoder:(NSCoder *)aDecoder class:(Class)class
{
    unsigned int outCount = 0;
    objc_property_t *pt = class_copyPropertyList(class, &outCount);
    for (int i = 0; i< outCount; i++) {
        objc_property_t property = pt[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        
        SEL selector = NSSelectorFromString([class getSetMethodName:name]);
        Method mt = class_getInstanceMethod(class, selector);
        if (mt != NULL) {
            NSString *argumentType = [class getMethodArgumentType:mt index:2];
            if ([argumentType isEqualToString:@"i"] ||
                [argumentType isEqualToString:@"q"] ||
                [argumentType isEqualToString:@"Q"])
            {
                NSInteger intValue = [aDecoder decodeIntegerForKey:name];
                void (*method_invokeTyped)(id self, Method mt, NSInteger value) = (void*)method_invoke;
                method_invokeTyped(self, mt, intValue);
#if kNSCodingDebugLoging
                NSLog(@"Decode %@ %@  intValue:%ld", NSStringFromClass(class), name, (long)intValue);
#endif
            } else if ([argumentType isEqualToString:@"I"]) {
                NSUInteger uIntValue = [aDecoder decodeIntegerForKey:name];
                void (*method_invokeTyped)(id self, Method mt, NSUInteger value) = (void*)method_invoke;
                method_invokeTyped(self, mt, uIntValue);
#if kNSCodingDebugLoging
                NSLog(@"Decode %@ %@   unsigned intValue:%lu", NSStringFromClass(class), name, (unsigned long)uIntValue);
#endif
            } else if ([argumentType isEqualToString:@"f"] || [argumentType isEqualToString:@"d"]) {
                double doubleValue = [aDecoder decodeDoubleForKey:name];
                void (*method_invokeTyped)(id self, Method mt, double value) = (void*)method_invoke;
                method_invokeTyped(self, mt, doubleValue);
#if kNSCodingDebugLoging
                NSLog(@"Decode %@ %@  doubleValue:%f", NSStringFromClass(class), name, doubleValue);
#endif
            } else if ([argumentType isEqualToString:@"c"] ||
                       [argumentType isEqualToString:@"B"])
            {   // char 一般为BOOL, property不用char即可
                BOOL boolValue = [aDecoder decodeBoolForKey:name];
                void (*method_invokeTyped)(id self, Method mt, BOOL value) = (void*)method_invoke;
                method_invokeTyped(self, mt, boolValue);
#if kNSCodingDebugLoging
                NSLog(@"Decode %@ %@  boolValue:%d", NSStringFromClass(class), name, boolValue);
#endif
            } else if ([argumentType isEqualToString:@"@"]) {
                NSString *value = [aDecoder decodeObjectForKey:name];
                void (*method_invokeTyped)(id self, Method mt, NSString *value) = (void*)method_invoke;
                method_invokeTyped(self, mt, value);
#if kNSCodingDebugLoging
                NSLog(@"Decode %@ %@  strValue:%@", NSStringFromClass(class), name, value);
#endif
            } else {
                @try {
                    id value = [aDecoder decodeObjectForKey:name];
                    if (value != nil){
                        void (*method_invokeTyped)(id self, Method mt, NSString *value) = (void*)method_invoke;
                        method_invokeTyped(self, mt, value);
                    }
#if kNSCodingDebugLoging
                    NSLog(@"Decode %@ %@  value:%@", NSStringFromClass(class), name, value);
#endif
                }
                @catch (NSException *exception) {
#if kNSCodingDebugLoging
                    NSLog(@"Decode Argument Value Type undefined in %@", NSStringFromClass(class));
#endif
                }
                @finally {
                }
            } // end of } else {
        } // end of if (mt != NULL) {
    }
    free(pt);
}

- (void)decodeAutoWithAutoCoder:(NSCoder *)aDecoder
{
    [self decodeAutoWithAutoCoder:aDecoder class:[self class]];
}

#pragma mark - private

+ (NSString *)getMethodReturnType:(Method)mt
{
    char dstType[10] = {0};
    size_t dstTypeLen = 10;
    method_getReturnType(mt, dstType, dstTypeLen);
    return [NSString stringWithUTF8String:dstType];
}

+ (NSString *)getMethodArgumentType:(Method)mt index:(NSInteger)index
{
    char dstType[10] = {0};
    size_t dstTypeLen = 10;
    method_getArgumentType(mt, (unsigned)index, dstType, dstTypeLen);
    return [NSString stringWithUTF8String:dstType];
}

+ (NSString *)getSetMethodName:(NSString *)propertyName
{
    if ([propertyName length] == 0)
        return @"";
    
    NSString *firstChar = [propertyName substringToIndex:1];
    firstChar = [firstChar uppercaseString];
    NSString *lastName = [propertyName substringFromIndex:1];
    return [NSString stringWithFormat:@"set%@%@:", firstChar, lastName];
}

@end
