//
//  JFileDownloader.m
//  JFileDownloader
//
//  Created by JiangWang on 2018/11/15.
//

#import "JFileDownloader.h"
#import "NSError+JDownloadError.h"
#import "NSURLSessionDownloadTask+JDownload.h"
#import "JFileCache.h"

@interface JFileDownloader()
<NSURLSessionDelegate,
NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *sharedSession;
@property (nonatomic, strong) NSString *cachePath;
@property (nonatomic, strong) JFileCache *defaultCache;
@property (nonatomic, strong) JFileCache *resumeCache;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSURLSessionDownloadTask *> *runningTasks;
@end

@implementation JFileDownloader

+ (instancetype)sharedDownloader {
    static dispatch_once_t onceToken;
    static JFileDownloader *shared = nil;
    dispatch_once(&onceToken, ^{
        shared = [[JFileDownloader alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLCache *myCache = [[NSURLCache alloc] initWithMemoryCapacity:16384 diskCapacity:268435456 diskPath:self.cachePath];
        defaultConfigObject.URLCache = myCache;
        defaultConfigObject.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        _sharedSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        _defaultCache = [[JFileCache alloc] init];
        _resumeCache = [[JFileCache alloc] initWithNameSpace:@"com.jFileCache.resume"];
        _runningTasks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)downloadFileWithUrl:(NSString *)urlString progress:(jDownloadProgressBlock)progress succeeded:(jDownloadSuccessBlock)success failed:(jDownloadFailureBlock)failure {
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        //urlString is nil or malformed RFC 2396
        NSError *urlError = [NSError j_errorWithDomain:kJDownloadErrorNetworkDomain code:JDownloadErrorCodeNilURL];
        if (failure) {
            failure(urlError);
        }
        return;
    }
    
    NSURL *cachedUrl = [self.downloadsCache cachedFileForKey:urlString];
    if (cachedUrl) {
        if (success) {
            success(cachedUrl);
        }
        return;
    }
    
    //whether resume data has existed
    NSURL *resumeDataUrl = [self.resumeCache cachedFileForKey:urlString];
    NSURLSessionDownloadTask *resumeDownloadTask = nil;
    if (resumeDataUrl) {
        NSData *resumeData = [NSData dataWithContentsOfURL:resumeDataUrl];
        resumeDownloadTask = [self.sharedSession downloadTaskWithResumeData:resumeData];
    }
    
    NSURLSessionDownloadTask *task = (resumeDataUrl && resumeDownloadTask) ?
    resumeDownloadTask : [self.sharedSession downloadTaskWithURL:url];
    
    task.taskDescription = urlString;
    task.j_proressCallback = progress;
    task.j_successCallback = success;
    task.j_failureCallback = failure;
    [task resume];
    [self.runningTasks setObject:task forKey:urlString];
}

- (void)cancelDownloadUrl:(NSString *)urlString {
    if (urlString.length) {
        NSURLSessionDownloadTask *task = [self.runningTasks objectForKey:urlString];
        __weak typeof(self) weakSelf = self;
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            __strong typeof(weakSelf) strSelf = weakSelf;
            if (resumeData.length) {
                NSError *cacheError = nil;
                [strSelf.resumeCache cacheData:resumeData forKey:urlString error:&cacheError];
                if (cacheError) {
                    NSLog(@"cache cancellation gemerated resumed data: %@", cacheError);
                }
            }
        }];
        [self.runningTasks removeObjectForKey:urlString];
    }
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSAssert([task isKindOfClass:[NSURLSessionDownloadTask class]], @"wrong class type.");
    NSLog(@"download task: %@ - completed with error: %@", task, error);
    if (error) {
        jDownloadFailureBlock failure = task.j_failureCallback;
        if (failure) {
            failure(error);
        }
    }
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSError *err = nil;
    NSURL *cachedUrl = [self.downloadsCache cacheFileAtPath:location.path
                                                   forKey:downloadTask.taskDescription
                                                    error:&err];
    
    //error occurred
    if (!cachedUrl || err) {
        jDownloadFailureBlock failure = downloadTask.j_failureCallback;
        if (failure) {
            failure(err);
        }
        return;
    }

    //no error
    jDownloadSuccessBlock success = downloadTask.j_successCallback;
    if (success) {
        success(cachedUrl);
    }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //progress
    jDownloadProgressBlock progress = downloadTask.j_proressCallback;
    if (progress) {
        CGFloat value = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
        progress(value);
    }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"download task: %@ resumed", downloadTask);
    //initail progress
    jDownloadProgressBlock progress = downloadTask.j_proressCallback;
    if (progress) {
        CGFloat value = 1.0 * fileOffset / expectedTotalBytes;
        progress(value);
    }
}

#pragma mark - Accessors
- (JFileCache *)downloadsCache {
    if (_downloadsCache) {
        return _downloadsCache;
    }
    
    return self.defaultCache;
}

#pragma mark - Lazy
- (NSString *)cachePath {
    if (!_cachePath) {
        NSString *cachePath = @"/downloads";
        NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *myPath = [myPathList  objectAtIndex:0];
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *fullCachePath = [[myPath stringByAppendingPathComponent:bundleIdentifier] stringByAppendingPathComponent:cachePath];
        _cachePath = fullCachePath;
    }
    return _cachePath;
}


@end
