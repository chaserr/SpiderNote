//
//  APPIdentificationManage.m
//  zhijia
//
//  Created by 童星 on 16/6/12.
//  Copyright © 2016年 Beijing tongxing Technology Development Co., Ltd. All rights reserved.
//

#define KEY_UDID @"KEY_UDID"
#define KEY_IN_KEYCHAIN @"KEY_IN_KEYCHAIN"
#import <Security/Security.h>
#import "APPIdentificationManage.h"
#import <UIKit/UIKit.h>
@interface APPIdentificationManage ()

@property (nonatomic, copy) NSString *uuid;
@end

@implementation APPIdentificationManage


static APPIdentificationManage * navigator = nil;

+ (APPIdentificationManage*)sharedInstance
{
    @synchronized(self)
    {
        if (navigator == nil)
        {
            navigator = [[APPIdentificationManage alloc] init];
        }
    }
    return navigator;
}

#pragma mark -- 获取UDID
- (NSString *)openUDID{

    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    return identifierForVendor;
}

#pragma mark -- 保存UUID到钥匙串
- (void)saveUUID:(NSString *)udid{

    NSMutableDictionary *udidKVPairs = [NSMutableDictionary dictionary];
    [udidKVPairs setObject:udid forKey:KEY_UDID];
    [[APPIdentificationManage sharedInstance] save:KEY_IN_KEYCHAIN data:udidKVPairs];
}

#pragma mark -- 读取UUID
/**
 *先从内存中获取uuid，如果没有再从钥匙串中获取，如果还没有就生成一个新的uuid，并保存到钥匙串中供以后使用
 **/
- (NSString *)readUUID{

    if (_uuid == nil || _uuid.length == 0) {
        NSMutableDictionary *udidKVPairs = (NSMutableDictionary *)[[APPIdentificationManage sharedInstance] load:KEY_IN_KEYCHAIN];
        NSString *uuid = [udidKVPairs objectForKey:KEY_UDID];
        if (uuid == nil || uuid.length == 0) {
            uuid = [self openUDID];
            [self saveUUID:uuid];
        }
        _uuid = uuid;
    }
    return _uuid;
}

#pragma MARK -- 将数据保存在钥匙串
- (void)save:(NSString *)service data:(id)data{

    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge_transfer id)kSecValueData];
    SecItemAdd((__bridge_retained CFDictionaryRef)keychainQuery, NULL);
}

#pragma mark -- 查询钥匙串
- (NSMutableDictionary *)getKeychainQuery:(NSString *)service{

    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge_transfer id)kSecClassGenericPassword,(__bridge_transfer id)kSecClass,
            service, (__bridge_transfer id)kSecAttrService,
            service, (__bridge_transfer id)kSecAttrAccount,
            (__bridge_transfer id)kSecAttrAccessibleAfterFirstUnlock,(__bridge_transfer id)kSecAttrAccessible,
            nil];
}

#pragma mark 加载钥匙串中数据
- (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
    [keychainQuery setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    return ret;
}

#pragma mark 删除UUID
- (void)deleteUUID
{
    [[APPIdentificationManage sharedInstance] delete:KEY_IN_KEYCHAIN];
}

#pragma mark 删除钥匙串中数据
- (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
}

@end
