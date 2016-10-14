//
//  APPIdentificationManage.h
//  zhijia
//
//  Created by 童星 on 16/6/12.
//  Copyright © 2016年 Beijing tongxing Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APPIdentificationManage : NSObject

+ (APPIdentificationManage*)sharedInstance;

- (NSString *)readUUID;


@end
