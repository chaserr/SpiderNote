//
//  FileUtil.m
//  YouYuan
//
//  Created by phoenix on 14-10-10.
//  Copyright (c) 2014年 SEU. All rights reserved.
//

#import "FileUtil.h"
#import <CommonCrypto/CommonDigest.h>
#define APP_PATH @"APPData"

@interface FileUtil ()
{
    
}

@end
@implementation FileUtil
static FileUtil *s_feilUtil;

- (void)dealloc
{
    
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self createPath:APP_PATH];
    }
    return self;
}

+ (FileUtil *)getFileUtil
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_feilUtil = [[FileUtil alloc] init];
    });
    return s_feilUtil;
}

- (NSString *)getDocmentPath
{
    NSArray *userPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [userPaths objectAtIndex:0];
}

- (NSString *)getLibraryPath
{
    NSArray *userPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [userPaths objectAtIndex:0];
}

- (NSString *)getAppDataPath
{
    return [[self getLibraryPath] stringByAppendingPathComponent:APP_PATH];
}

- (NSString *)getTempPath
{
    return NSTemporaryDirectory();
}

- (NSString *)getHomePath
{
    return NSHomeDirectory();
}

- (NSString *)getDocPathWithFileName:(NSString *)fileName
{
    NSString *destFileFullPath = [self getDocmentPath];
    return [destFileFullPath stringByAppendingPathComponent:fileName];
}

- (NSString *)getTmpPathWithFileName:(NSString *)fileName
{
    NSString *destFileFullPath = [self getTempPath];
    return [destFileFullPath stringByAppendingPathComponent:fileName];
}

- (void)createPath:(NSString*)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path])
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:[NSDictionary dictionaryWithObject:NSFileProtectionNone forKey:NSFileProtectionKey] error:nil];
    }
}

- (void)createFile:(NSString*)file
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:file])
    {
        [fileManager createFileAtPath:file contents:nil attributes:[NSDictionary dictionaryWithObject:NSFileProtectionNone forKey:NSFileProtectionKey]];
    }
}

- (void)createFilePath:(NSString*)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath])
    {
        [self createPath:[filePath stringByDeletingLastPathComponent]];
        [self createFile:filePath];
    }
}

- (BOOL)deleteFileInDocFolder:(NSString *)fileName
{
    return [self deleteFileInFolder:[self getDocmentPath] withFileName:fileName];
}

- (void)deleteFileWithPath:(NSString *)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

- (BOOL)deleteFileInFolder:(NSString *)folder withFileName:(NSString *)fileName
{
    NSString *destFileFullPath = [folder stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:destFileFullPath])
    {
        return NO;
    }
    return [fileManager removeItemAtPath:destFileFullPath error:nil];
}

- (BOOL)deleteFolder:(NSString *)folderPath
{
    return [self deleteFileInFolder:folderPath withFileName:@""];
}

- (NSArray *)getAllFilesAtFolder:(NSString *)folderPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager contentsOfDirectoryAtPath:folderPath error:nil];
}

- (BOOL)isFileExist:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return ([fileManager fileExistsAtPath:filePath]);
}

- (BOOL)saveToFile:(id)object filePath:(NSString *)filePath atomically:(BOOL)atomically
{
    BOOL isOk = NO;
    [self createPath:[filePath stringByDeletingLastPathComponent]];
    isOk = [object writeToFile:filePath atomically:atomically];
    if (isOk)
    {
        [[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionNone forKey:NSFileProtectionKey] ofItemAtPath:filePath error:nil];
    }
    return isOk;
}

- (id)getObjectWithClassString:(Class)aClass aFilePath:(NSString *)aFilePath
{
    __autoreleasing id object = [[NSClassFromString([aClass description]) alloc] initWithContentsOfFile:aFilePath];
    return object;
}

- (int)getFileSize:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *dic = [fileManager attributesOfItemAtPath:filePath error:nil];
    NSNumber *fileSize = [dic objectForKey:NSFileSize];
    return [fileSize intValue];
}

- (int)getFolderSize:(NSString *)folderPath
{
    int iFolderSize = 0;
    
    NSArray* fileArray = [self getAllFilesAtFolder:folderPath];
    
    for (NSString *file in fileArray)
    {
        NSString *fullPath = [folderPath stringByAppendingPathComponent:file];
        
        if([file.pathExtension length] > 0)
        {
            iFolderSize += [self getFileSize:fullPath];
        }
        else
        {
            iFolderSize += [self getFolderSize:fullPath];
        }
    }
    
    return iFolderSize;
}

- (NSString*)fileMD5:(NSString*)path
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if( handle== nil ) return @"ERROR GETTING FILE MD5"; // file didnt exist
    
    CC_MD5_CTX md5;
    
    CC_MD5_Init(&md5);
    
    BOOL done = NO;
    while(!done)
    {
        NSData* fileData = [handle readDataOfLength: 256 ];
        CC_MD5_Update(&md5, [fileData bytes], (unsigned int)[fileData length]);
        if( [fileData length] == 0 ) done = YES;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    return s;
}

- (NSString *)getFilePathWithMainBundle:(NSString *)fileName;
{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
}

- (BOOL)copyFile:(NSString *)srcPath toPath:(NSString *)toPath
{
    BOOL isOk = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:toPath])
    {
        NSError *error = nil;
        [self createPath:[toPath stringByDeletingLastPathComponent]];
        [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:toPath error:&error];
        [[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionNone forKey:NSFileProtectionKey] ofItemAtPath:toPath error:&error];
        if (error)
        {
            isOk = NO;
        }
    }
    return isOk;
}

- (NSInteger)getSizeOfDirectoryPath:(NSString *)directoryPath{

    // 获取文件管理者
    NSFileManager *mgr = [NSFileManager defaultManager];
    // 判断是否是文件夹
    BOOL isDirectory = NO;
    BOOL isExist = [mgr fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    if (!isExist || !isDirectory) {
        NSException *exception = [NSException exceptionWithName:@"FileError" reason:@"传错了路径，只能传文件夹路径，并且要存在" userInfo:nil];
        
        [exception raise];
    }
    
    // 获取文件夹里面所有文件全路径
    NSArray *subpaths = [mgr subpathsAtPath:directoryPath];
    NSInteger totalSize = 0;
    for (NSString *subPath in subpaths) {
        // 获取文件全路径
        NSString *filePath = [directoryPath stringByAppendingPathComponent:subPath];
        // 如果是隐藏文件 或者 文件夹 不需要计算 优化
        if ([filePath containsString:@".DS"]) continue;
        
        // 判断是否是文件夹
        BOOL isDirectory = NO;
        BOOL isExist = [mgr fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        if (!isExist || isDirectory) continue;
        
        // 获取文件尺寸
        NSInteger fileSize = [[mgr attributesOfItemAtPath:filePath error:nil] fileSize];
        totalSize += fileSize;
        
    }
    
    return totalSize;
}

- (void)removeDirectoryPath:(NSString *)directoryPath{

    NSFileManager *mgr = [NSFileManager defaultManager];
    
    // 判断是否传入进来 是不是文件夹路径
    // 判断是否是文件夹
    BOOL isDirectory = NO;
    BOOL isExist = [mgr fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    if (!isExist || !isDirectory) {
        // 直接报错
        // name:异常名字
        // reason:异常原因
        NSException *exception = [NSException exceptionWithName:@"FileError" reason:@"传错了路径，只能传文件夹路径，并且要存在" userInfo:nil];
        
        [exception raise];
    }
    
    // 获取文件夹里面所有子文件,只能获取下一级
    NSArray *subPaths = [mgr contentsOfDirectoryAtPath:directoryPath error:nil];
    
    for (NSString *subPath in subPaths) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:subPath];
        [mgr removeItemAtPath:filePath error:nil];
    }
}


@end
