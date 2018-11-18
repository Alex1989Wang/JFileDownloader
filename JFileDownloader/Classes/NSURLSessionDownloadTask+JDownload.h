//
//  NSURLSessionDownloadTask+JDownload.h
//  JFileDownloader
//
//  Created by JiangWang on 2018/11/15.
//

#import <Foundation/Foundation.h>
#import "JDownloadDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSessionTask (JDownload)

@property (nonatomic, copy, nullable) jDownloadProgressBlock j_proressCallback;
@property (nonatomic, copy) jDownloadSuccessBlock j_successCallback;
@property (nonatomic, copy) jDownloadFailureBlock j_failureCallback;

@end

NS_ASSUME_NONNULL_END
