//
//  NSError+JDownloadError.h
//  JFileDownloader
//
//  Created by JiangWang on 2018/11/15.
//

#import <Foundation/Foundation.h>

extern NSString *kJDownloadErrorDefaultDomain;
extern NSString *kJDownloadErrorNetworkDomain;
extern NSString *kJDownloadErrorCacheDomain;

typedef NS_ENUM(NSUInteger, JDownloadErrorCode) {
    //default domain
    JDownloadErrorFileCached = 100000,
    
    //network domain
    JDownloadErrorCodeNilURL = 200000,
    
    //cache domain
    JDownloadErrorCodeNoCacheKey = 300000,
    JDownloadErrorCodeNoCacheData = 300001,
};

NS_ASSUME_NONNULL_BEGIN

@interface NSError (JDownloadError)

/**
 create a JDownloadError instance
 
 @param code error code
 @return error instance
 */
+ (instancetype)j_errorWithCode:(JDownloadErrorCode)code;

/**
 create a JDownloadError instance
 
 @param domain error domain
 @param code error code
 @return error instance
 */
+ (instancetype)j_errorWithDomain:(NSErrorDomain)domain code:(JDownloadErrorCode)code;

@end

NS_ASSUME_NONNULL_END
