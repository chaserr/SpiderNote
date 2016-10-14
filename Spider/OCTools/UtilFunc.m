//
//  UtilFunc.m
//  Util
//
//  Created by ljj on 14-8-14.
//
//

#import <Accelerate/Accelerate.h>
#import "UtilFunc.h"

#define AMR_MAGIC_NUMBER "#!AMR\n"

static const char* jailbreak_apps[] =
{
    "/Applications/Cydia.app",
    "/Applications/limera1n.app",
    "/Applications/greenpois0n.app",
    "/Applications/blackra1n.app",
    "/Applications/blacksn0w.app",
    "/Applications/redsn0w.app",
    "/Applications/Absinthe.app",
    "/Applications/IAPCrazy.app",
    NULL
};

@implementation UtilFunc

+ (BOOL)isNull:(id)object
{
    // 判断是否为空串
    if ([object isEqual:[NSNull null]])
    {
        return YES;
    }
    else if ([object isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    else if (object == nil)
    {
        return YES;
    }
    return NO;
}

+ (id)checkNull:(id)object
{
    //通过http请求,后台返回json数据,检查返回的字符串是否是"<null>"
    if([UtilFunc isNull:object] == YES)
    {
        return nil;
    }
    else
    {
        return object;
    }
}

+ (BOOL)checkJailBreak
{
    // Now check for known jailbreak apps. If we encounter one, the device is jailbroken.
    for (int i = 0; jailbreak_apps[i] != NULL; ++i)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_apps[i]]])
        {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)checkIAPFree
{
    BOOL result = NO;
    
    NSString *rootAppPath = @"/Applications";
    NSArray *listApp = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootAppPath error:nil];
    
    for (int i = 0; i < [listApp count]; i++)
    {
        NSString * name = [listApp objectAtIndex:i];
        if ([name compare:@"IAPFree.app" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            result = YES;
        }
    }
    
    NSString *substrateAppPath = @"/Library/MobileSubstrate/DynamicLibraries";
    NSArray *substrateListApp = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:substrateAppPath error:nil];
    
    for (int i = 0; i < [substrateListApp count]; i++)
    {
        NSString *name = [substrateListApp objectAtIndex:i];
        if ([name compare:@"iap.dylib" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            result = YES;
        }
    }
    
    return result;
}

+ (VersionChangeState)validateVersionNumber:(NSString *)oldVersionNumber newVersionNumber:(NSString *)newVersionNumber
{
    //默认是相等
    VersionChangeState reslt = VersionChangeStateEqual;
    
    NSArray *oldVersionArr = [oldVersionNumber componentsSeparatedByString:@"."];
    
    NSArray *newVersionArr = [newVersionNumber componentsSeparatedByString:@"."];
    
    NSUInteger oldArrCount = [oldVersionArr count];
    
    NSUInteger newArrCount = [newVersionArr count];

    NSUInteger arrCount = oldArrCount < newArrCount ? oldArrCount : newArrCount;
    
    for (NSUInteger i = 0; i < arrCount; i++) {
        if ([[newVersionArr objectAtIndex:i] intValue] > [[oldVersionArr objectAtIndex:i] intValue]) {
            reslt = VersionChangeStateSmall;
            break;
        } else if ([[newVersionArr objectAtIndex:i] intValue] < [[oldVersionArr objectAtIndex:i] intValue]) {
            reslt = VersionChangeStateLarge;
            break;
        }
    }
    
    if (reslt == VersionChangeStateEqual && newArrCount > oldArrCount) {
        reslt = VersionChangeStateSmall;
    } else if (reslt == VersionChangeStateEqual && newArrCount < oldArrCount) {
        reslt = VersionChangeStateLarge;
    }
    
    return reslt;
}

+ (UIImage*)blurImage:(UIImage*)image withBlurLevel:(CGFloat)blur
{
    if ((blur < 0.0f) || (blur > 1.0f))
    {
        blur = 0.5f;
    }
    
    if (image == nil)
    {
        return nil;
    }
    
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    
    // 第三个中间的缓存区,抗锯齿的效果
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
                               0, 0, boxSize, boxSize, NULL,
                               kvImageEdgeExtend);
    vImageBoxConvolve_ARGB8888(&outBuffer, &outBuffer2, NULL,
                               0, 0, boxSize, boxSize, NULL,
                               kvImageEdgeExtend);
    vImageBoxConvolve_ARGB8888(&outBuffer2, &outBuffer, NULL,
                               0, 0, boxSize, boxSize, NULL,
                               kvImageEdgeExtend);
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);

    CGImageRelease(imageRef);
    
    return returnImage;
}

/*
1、获取一个随机整数范围在：[0,100)包括0，不包括100
               
    int x = arc4random() % 100;
               
2、获取一个随机数范围在：[500,1000），包括500，不包括1000
                               
    int y = (arc4random() % 500) + 500;
 
3、获取一个随机数范围在：[500,1000），包括500，包括1000
 
    int y = (arc4random() % 501) + 500;
*/

// 获取一个随机整数,范围在[from, to], 包括from, 包括to
+ (int)getRandomNumberFrom:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}

/**
 *  根据文件名判断音频格式
 *
 *  @param audioPath 音频文件路径
 *
 *  @return 类型
 */
+ (EYYAudioType)getAudioType:(NSString*)audioPath
{
    NSRange range = [audioPath rangeOfString:@".mp3"];
    if(range.location != NSNotFound)
    {
        return EYYAudioTypeMP3;
    }
    
    range = [audioPath rangeOfString:@".MP3"];
    if(range.location != NSNotFound)
    {
        return EYYAudioTypeMP3;
    }

    range = [audioPath rangeOfString:@".amr"];
    if(range.location != NSNotFound)
    {
        return EYYAudioTypeAMR;
    }
    
    range = [audioPath rangeOfString:@".AMR"];
    if(range.location != NSNotFound)
    {
        return EYYAudioTypeAMR;
    }
    
    range = [audioPath rangeOfString:@".aac"];
    if(range.location != NSNotFound)
    {
        return EYYAudioTypeAAC;
    }
    
    range = [audioPath rangeOfString:@".AAC"];
    if(range.location != NSNotFound)
    {
        return EYYAudioTypeAAC;
    }
    
    return EYYAudioTypeUnknown;
}

/**
 *  根据音频文件二进制流判断是否是amr格式音频
 *
 *  @param audioPath 音频文件路径
 *
 *  @return BOOL
 */
+ (BOOL)isAMR:(NSString*)audioPath
{
    NSData* data = [NSData dataWithContentsOfFile:audioPath];
    const char* rfile = [data bytes];
    
    // 检查amr文件头
    if (strncmp(rfile, AMR_MAGIC_NUMBER, strlen(AMR_MAGIC_NUMBER)) == 0)
    {
        return YES;
    }
    
    return NO;
}

/**
 *  去掉字符串里面尖括号所表示的一些html tag(一般表示超文本链接等)
 *
 *  @param NSString 需要去除这些tag的字符串
 *
 *  @return NSString 去除以后的新字符串
 */
+ (NSString*)deleteBracketInString:(NSString*)str
{
    NSMutableString *string = [NSMutableString stringWithString:str];
    
    // 正则表达式: * 0次或多次, \\S 表示字符串
    NSString *parten1 = @"<a>\\S*</a>";
    NSString *parten2 = @"<a href=\\'\\S*\\'>";
    NSString *parten3 = @"</a>";
    NSString *parten4 = @"<br/>";
    NSError* error = NULL;
    
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten1
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:&error];
    NSString* replacedText = [reg stringByReplacingMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, [string length]) withTemplate:@""];
    
    reg = [NSRegularExpression regularExpressionWithPattern:parten2
                                                    options:NSRegularExpressionCaseInsensitive
                                                      error:&error];
    replacedText = [reg stringByReplacingMatchesInString:replacedText options:NSMatchingReportProgress range:NSMakeRange(0, [replacedText length]) withTemplate:@""];
    
    reg = [NSRegularExpression regularExpressionWithPattern:parten3
                                                    options:NSRegularExpressionCaseInsensitive
                                                      error:&error];
    replacedText = [reg stringByReplacingMatchesInString:replacedText options:NSMatchingReportProgress range:NSMakeRange(0, [replacedText length]) withTemplate:@""];
    
    reg = [NSRegularExpression regularExpressionWithPattern:parten4
                                                    options:NSRegularExpressionCaseInsensitive
                                                      error:&error];
    replacedText = [reg stringByReplacingMatchesInString:replacedText options:NSMatchingReportProgress range:NSMakeRange(0, [replacedText length]) withTemplate:@""];
    
    return replacedText;
}

/**
 *  把一长串文本放在指定宽度的矩形框里面所规范出来的大小
 *
 *  @param size 指定宽度的矩形框
 *  @param text 一长串文本
 *  @param font 文本对应的字体
 *
 *  @return BOOL
 */
+ (CGSize)boundingRectWithSize:(CGSize)size withText:(NSString*)text withFont:(UIFont*)font
{
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize retSize = [text boundingRectWithSize:size options:options attributes:attribute context:nil].size;
    
    return retSize;
}

+ (CGRect)leftRect:(CGRect)rect width:(float)width offset:(float)offset
{
    return CGRectMake(rect.origin.x + offset,
                      rect.origin.y,
                      width,
                      rect.size.height);
}

+ (CGRect)rightRect:(CGRect)rect width:(float)width offset:(float)offset
{
    return CGRectMake(rect.origin.x + rect.size.width - width - offset,
                      rect.origin.y,
                      width,
                      rect.size.height);
}

+ (CGRect)topRect:(CGRect)rect height:(float)height offset:(float)offset
{
    return CGRectMake(rect.origin.x,
                      rect.origin.y + offset,
                      rect.size.width,
                      height);
}

+ (CGRect)bottomRect:(CGRect)rect height:(float)height offset:(float)offset
{
    return CGRectMake(rect.origin.x,
                      rect.origin.y + rect.size.height - height - offset,
                      rect.size.width,
                      height);
}

+ (CGRect)leftTopRect:(CGRect)rect width:(float)width height:(float)height
{
    return CGRectMake(rect.origin.x,
                      rect.origin.y,
                      width,
                      height);
}

+ (CGRect)leftCenterRect:(CGRect)rect width:(float)width height:(float)height offset:(float)offset
{
    return CGRectMake(rect.origin.x + offset,
                      rect.origin.y + (rect.size.height - height) / 2,
                      width,
                      height);
}

+ (CGRect)leftBottomRect:(CGRect)rect width:(float)width height:(float)height
{
    return CGRectMake(rect.origin.x,
                      rect.origin.y + rect.size.height - height,
                      width,
                      height);
}

+ (CGRect)rightTopRect:(CGRect)rect width:(float)width height:(float)height
{
    return CGRectMake(rect.origin.x + rect.size.width - width,
                      rect.origin.y,
                      width,
                      height);
}

+ (CGRect)rightCenterRect:(CGRect)rect width:(float)width height:(float)height offset:(float)offset
{
    return CGRectMake(rect.origin.x + rect.size.width - offset - width,
                      rect.origin.y + (rect.size.height - height) / 2,
                      width,
                      height);
}

+ (CGRect)rightBottomRect:(CGRect)rect width:(float)width height:(float)height
{
    return CGRectMake(rect.origin.x + rect.size.width - width,
                      rect.origin.y + rect.size.height - height,
                      width,
                      height);
}

+ (CGRect)topCenterRect:(CGRect)rect width:(float)width height:(float)height offset:(float)offset
{
    return CGRectMake(rect.origin.x + (rect.size.width - width) / 2,
                      rect.origin.y + offset,
                      width,
                      height);
}

+ (CGRect)centerRect:(CGRect)rect width:(float)width height:(float)height
{
    CGPoint point = {rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2};
    return CGRectMake(point.x - width/2,
                      point.y - height/2,
                      width,
                      height);

}

+ (CGRect)bottomCenterRect:(CGRect)rect width:(float)width height:(float)height offset:(float)offset
{
    return CGRectMake(rect.origin.x + (rect.size.width - width) / 2,
                      rect.origin.y + rect.size.height - offset - height,
                      width,
                      height);
}

//DeflateRectXY

+(CGRect)deflateRectXY:(CGRect)rect X:(float)x Y:(float)y
{
    return CGRectMake(rect.origin.x + x,
                      rect.origin.y + y ,
                      rect.size.width - x - x,
                      rect.size.height - y - y);
}

@end
