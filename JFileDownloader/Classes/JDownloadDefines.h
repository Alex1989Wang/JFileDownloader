//
//  JDownloadDefines.h
//  JFileDownloader
//
//  Created by JiangWang on 2018/11/15.
//

#import <Foundation/Foundation.h>

#pragma mark - block defines
typedef void(^jDownloadProgressBlock)(CGFloat progress);
typedef void(^jDownloadSuccessBlock)(NSURL *fileUrl);
typedef void(^jDownloadFailureBlock)(NSError *error);
