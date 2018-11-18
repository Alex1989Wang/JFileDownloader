//
//  NSURLSessionDownloadTask+JDownload.m
//  JFileDownloader
//
//  Created by JiangWang on 2018/11/15.
//

#import "NSURLSessionDownloadTask+JDownload.h"
#import <objc/runtime.h>

static const void *kProgressBlockKey = &kProgressBlockKey;
static const void *kSuccessBlockKey = &kSuccessBlockKey;
static const void *kFailureBlockKey = &kFailureBlockKey;

@implementation NSURLSessionTask (JDownload)
@dynamic j_proressCallback;
@dynamic j_successCallback;
@dynamic j_failureCallback;

- (void)setJ_proressCallback:(jDownloadProgressBlock)j_proressCallback {
    [self j_setBlock:j_proressCallback withKey:kProgressBlockKey];
}

- (jDownloadProgressBlock)j_proressCallback {
    return [self j_blockWithKey:kProgressBlockKey];
}

- (void)setJ_successCallback:(jDownloadSuccessBlock)j_successCallback {
    [self j_setBlock:j_successCallback withKey:kSuccessBlockKey];
}

- (jDownloadSuccessBlock)j_successCallback {
    return [self j_blockWithKey:kSuccessBlockKey];
}

- (void)setJ_failureCallback:(jDownloadFailureBlock)j_failureCallback {
    [self j_setBlock:j_failureCallback withKey:kFailureBlockKey];
}

- (jDownloadFailureBlock)j_failureCallback {
    return [self j_blockWithKey:kFailureBlockKey];
}

- (void)j_setBlock:(id _Nullable)block withKey:(const void * _Nonnull)key {
    objc_setAssociatedObject(self, key, block, OBJC_ASSOCIATION_COPY);
}

- (id _Nullable)j_blockWithKey:(const void * _Nonnull)key {
    return objc_getAssociatedObject(self, key);
}

@end

