//
//  JFileCache.h
//  JFileDownloader
//
//  Created by JiangWang on 2018/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFileCache : NSObject
/**
 create a file cache instance

 @param nameSpace the name space used to create the cache folder
 @return a file cache instance
 */
- (instancetype)initWithNameSpace:(NSString *_Nullable)nameSpace;

/**
 create a file cache instance

 @param nameSpace the name space used to create the cache folder
 @param directory The custom directory used to store the cached files
 @return a file cache instance
 */
- (instancetype)initWithNameSpace:(NSString *_Nullable)nameSpace
              customDirectoryPath:(NSString *_Nullable)directory NS_DESIGNATED_INITIALIZER;


- (NSURL *)cacheFileAtPath:(NSString *)originalPath forKey:(NSString *)fileKey error:(NSError **)error;
- (NSURL *)cacheData:(NSData *)fileData forKey:(NSString *)fileKey error:(NSError **)error;
- (BOOL)fileExistsForKey:(NSString *)fileKey;

- (NSURL *)cachedFileForKey:(NSString *)fileKey;

- (void)clearCache;

@end

NS_ASSUME_NONNULL_END
