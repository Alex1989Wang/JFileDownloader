//
//  NSError+JDownloadError.m
//  JFileDownloader
//
//  Created by JiangWang on 2018/11/15.
//

#import "NSError+JDownloadError.h"

NSString *kJDownloadErrorDefaultDomain = @"JDownloadErrorDefaultDomain";
NSString *kJDownloadErrorNetworkDomain = @"JDownloadErrorNetworkDomain";
NSString *kJDownloadErrorCacheDomain = @"JDownloadErrorCacheDomain";

@implementation NSError (JDownloadError)

+ (instancetype)j_errorWithCode:(JDownloadErrorCode)code {
    return [self j_errorWithDomain:kJDownloadErrorDefaultDomain code:code];
}

+ (instancetype)j_errorWithDomain:(NSErrorDomain)domain code:(JDownloadErrorCode)code {
    return [self errorWithDomain:domain code:code userInfo:nil];
}

@end
