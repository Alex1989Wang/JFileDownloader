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
    }
    return self;
}

- (void)downloadFileWithUrl:(NSString *)urlString progress:(jDownloadProgressBlock)progress succeeded:(jDownloadSuccessBlock)success failed:(jDownloadFailureBlock)failure {
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        //urlString is nil or malformed RFC 2396
        NSError *urlError = [NSError errorWithDomain:kJDownloadErrorNetworkDomain code:JDownloadErrorCodeNilURL];
        if (failure) {
            failure(urlError);
        }
        return;
    }
    
    NSURL *cachedUrl = [self.defaultCache cachedFileForKey:urlString];
    if (cachedUrl) {
        if (success) {
            success(cachedUrl);
        }
        return;
    }
    
    NSURLSessionDownloadTask *task = [self.sharedSession downloadTaskWithURL:url];
    task.taskDescription = urlString;
    task.j_proressCallback = progress;
    task.j_successCallback = success;
    task.j_failureCallback = failure;
    [task resume];
}

#pragma mark - Private
- (void)callCompletionHandlerForSession:(NSString *)sessionId error:(NSError *)error {
    
}


#pragma mark - NSURLSessionDelegate

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSError *err = nil;
    NSURL *cachedUrl = [self.defaultCache cacheFileAtPath:location.path
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
    NSLog(@"Session %@ download task %@ resumed at offset %lld bytes out of an expected %lld bytes.\n",
          session, downloadTask, fileOffset, expectedTotalBytes);
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
