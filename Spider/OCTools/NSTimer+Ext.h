//
//  NSTimer+Ext.h
//  YouYuanClient
//
//  Created by phoenix on 15-5-18.
//  Copyright (c) 2015年 SEU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (IdentifierAddition)

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;
+ (id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;

- (void)pauseTimer;
- (void)resumeTimer;

@end


