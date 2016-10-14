//
//  NSObject+NSCoding.h
//  OpenStack
//
//  Created by Michael Mayo on 3/4/11.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <Foundation/Foundation.h>


//@interface NSObject (NSCoding)
//
//- (void)autoEncodeWithCoder: (NSCoder *)coder;
//- (void)autoDecode:(NSCoder *)coder;
//- (NSDictionary *)properties;
//
//
//@end

#define kNSCodingDebugLoging      0

@interface NSObject (NSCoding)

- (void)encodeAutoWithCoder:(NSCoder *)aCoder;
- (void)decodeAutoWithAutoCoder:(NSCoder *)aDecoder;

- (void)encodeAutoWithCoder:(NSCoder *)aCoder class:(Class)cls;
- (void)decodeAutoWithAutoCoder:(NSCoder *)aDecoder class:(Class)cls;

@end