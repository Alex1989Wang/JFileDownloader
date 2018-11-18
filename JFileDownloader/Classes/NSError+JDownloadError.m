//
//  NSError+JDownloadError.m
//  JFileDownloader
//
//  Created by JiangWang on 2018/11/15.
//

#import "NSError+JDownloadError.h"

NSString *kJDownloadErrorDefaultDomain = @"JDownloadErrorDefaultDomain";
NSString *kJDownloadErrorNetworkDomain = @"JDownloadErrorNetworkDomain";

@implementation NSError (JDownloadError)

+ (instancetype)errorWithCode:(JDownloadErrorCode)code {
    return [self errorWithDomain:kJDownloadErrorDefaultDomain code:code];
}

+ (instancetype)errorWithDomain:(NSErrorDomain)domain code:(JDownloadErrorCode)code {
    return [self errorWithDomain:domain code:code userInfo:nil];
}

@end
