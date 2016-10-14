//
//  CALayer+AddUIColor.m
//  Spider
//
//  Created by 童星 on 16/7/14.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

#import "CALayer+AddUIColor.h"
#import <objc/runtime.h>
@implementation CALayer (AddUIColor)

- (UIColor *)borderColorWithUIColor{

    return objc_getAssociatedObject(self, @selector(borderColorWithUIColor));
    
}

- (void)setBorderColorWithUIColor:(UIColor *)borderColorWithUIColor{

    objc_setAssociatedObject(self, @selector(borderColorWithUIColor), borderColorWithUIColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setBoardColorWithUI:borderColorWithUIColor];
}

- (void)setBoardColorWithUI:(UIColor *)color{

    self.borderColor = color.CGColor;
    
}

@end
