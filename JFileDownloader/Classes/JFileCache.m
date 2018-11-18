//
//  JFileCache.m
//  JFileDownloader
//
//  Created by JiangWang on 2018/11/18.
//

#import "JFileCache.h"
#import <CommonCrypto/CommonDigest.h>

@interface JFileCache()
@property (nonatomic, strong) NSString *cacheDirectory;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) dispatch_queue_t fileIoQueue;
@end

@implementation JFileCache

#pragma mark - Initialization
- (instancetype)init {
    return [self initWithNameSpace:nil];
}

- (instancetype)initWithNameSpace:(NSString *)nameSpace {
    NSString *defaultPath = [self cacheDirectoryPath];
    return [self initWithNameSpace:nameSpace
               customDirectoryPath:defaultPath];
}

- (instancetype)initWithNameSpace:(NSString *)nameSpace customDirectoryPath:(NSString *)directory {
    self = [super init];
    if (self) {
        //custom path
        if (!directory || directory.length == 0) {
            directory = [self cacheDirectoryPath];
        }
        
        //name space
        if (!nameSpace || nameSpace.length == 0) {
            nameSpace = @"default";
        }
        
        NSParameterAssert(directory && directory.length);
        NSParameterAssert(nameSpace && nameSpace.length);
        NSString *cacheDirectory = [directory stringByAppendingPathComponent:@"com.jFileDownloader"];
        _cacheDirectory = [cacheDirectory stringByAppendingPathComponent:nameSpace];
        
        _fileManager = [[NSFileManager alloc] init];
        _fileIoQueue = dispatch_queue_create("com.jFileDownloader.fileIo", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Public
- (NSURL *)cacheFileAtPath:(NSString *)originalPath forKey:(NSString *)fileKey error:(NSError * _Nullable __autoreleasing *)error {
    __block NSURL *cachedUrl = nil;
    if (!originalPath || originalPath.length == 0) {
        return nil;
    }
    
    dispatch_sync(self.fileIoQueue, ^{
        NSString *fileName = [self fileNameWithKey:fileKey];
        NSString *filePath = [self.cacheDirectory stringByAppendingPathComponent:fileName];
        //create cache directory if needed.
        if (![self.fileManager fileExistsAtPath:self.cacheDirectory]) {
            [self.fileManager createDirectoryAtPath:self.cacheDirectory
                        withIntermediateDirectories:YES
                                         attributes:nil
                                              error:NULL];
        }
        BOOL cached = [self.fileManager moveItemAtPath:originalPath
                                                toPath:filePath
                                                 error:error];
        cachedUrl = (cached) ? [NSURL URLWithString:filePath] : nil;
    });
    return cachedUrl;
}

- (BOOL)fileExistsForKey:(NSString *)fileKey {
    __block BOOL cached = NO;
    if (!fileKey || fileKey.length == 0) {
        return cached;
    }
    
    dispatch_sync(self.fileIoQueue, ^{
        NSString *fileName = [self fileNameWithKey:fileKey];
        NSString *filePath = [self.cacheDirectory stringByAppendingPathComponent:fileName];
        cached = [self.fileManager fileExistsAtPath:filePath];
    });
    return cached;
}

- (NSURL *)cachedFileForKey:(NSString *)fileKey {
    if (!fileKey || fileKey.length == 0) {
        return nil;
    }
    
    __block NSURL *fileUrl = nil;
    dispatch_sync(self.fileIoQueue, ^{
        NSString *fileName = [self fileNameWithKey:fileKey];
        NSString *filePath = [self.cacheDirectory stringByAppendingPathComponent:fileName];
        fileUrl = [self.fileManager fileExistsAtPath:filePath] ? [NSURL fileURLWithPath:filePath] : nil;
    });
    return fileUrl;
}

#pragma mark - Private
- (NSString *)cacheDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

- (NSString *)fileNameWithKey:(NSString *)fileKey {
    const char *cStr = [fileKey UTF8String];
    if (cStr == NULL) {
        cStr = "";
    }
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
