//
//  JFileDownloader.h
//  JFileDownloader
//
//  Created by JiangWang on 2018/11/15.
//

#import <Foundation/Foundation.h>
#import "JDownloadDefines.h"

@class JFileCache;

NS_ASSUME_NONNULL_BEGIN

@interface JFileDownloader : NSObject
@property (nonatomic, strong) JFileCache *downloadsCache;

/**
 The shared downloader used to download files.

 @return the shared downloader
 */
+ (instancetype)sharedDownloader;

- (void)downloadFileWithUrl:(NSString *)urlString
                   progress:(jDownloadProgressBlock)progress
                  succeeded:(jDownloadSuccessBlock)success
                     failed:(jDownloadFailureBlock)failure;

- (void)cancelDownloadUrl:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
