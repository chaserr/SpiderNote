//
//  CALayer+AddUIColor.h
//  Spider
//
//  Created by 童星 on 16/7/14.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
@interface CALayer (AddUIColor)

@property (nonatomic, strong) UIColor *borderColorWithUIColor;

- (void)setBorderColorWithUIColor:(UIColor *)borderColorWithUIColor;

@end
