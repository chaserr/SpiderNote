//
//  NSTimer+Ext.m
//  YouYuanClient
//
//  Created by phoenix on 15-5-18.
//  Copyright (c) 2015年 SEU. All rights reserved.
//

#import "NSTimer+Ext.h"
#import <objc/runtime.h>
@implementation NSTimer (IdentifierAddition)

+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats {
    
    void (^block)() = [inBlock copy];
    id ret = [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(executeSimpleBlock:) userInfo:block repeats:inRepeats];
    
    return ret;
}

+(id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats {
    
    void (^block)() = [inBlock copy];
    id ret = [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(executeSimpleBlock:) userInfo:block repeats:inRepeats];
    
    return ret;
}

+(void)executeSimpleBlock:(NSTimer *)inTimer {
    
    if ([inTimer userInfo]) {
        void (^block)() = (void (^)())[inTimer userInfo];
        block();
    }
}

static NSString *const NSTimerPauseDate = @"NSTimerPauseDate";
static NSString *const NSTimerPreviousFireDate = @"NSTimerPreviousFireDate";

-(void)pauseTimer
{
    objc_setAssociatedObject(self, (__bridge const void *)(NSTimerPauseDate), [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, (__bridge const void *)(NSTimerPreviousFireDate), self.fireDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.fireDate = [NSDate distantFuture];
}

-(void)resumeTimer
{
    NSDate *pauseDate = objc_getAssociatedObject(self, (__bridge const void *)NSTimerPauseDate);
    NSDate *previousFireDate = objc_getAssociatedObject(self, (__bridge const void *)NSTimerPreviousFireDate);
    
    const NSTimeInterval pauseTime = -[pauseDate timeIntervalSinceNow];
    self.fireDate = [NSDate dateWithTimeInterval:pauseTime sinceDate:previousFireDate];
}

@end