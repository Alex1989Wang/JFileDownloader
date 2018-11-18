//
//  JLargeFileDownloadViewController.m
//  JFileDownloader_Example
//
//  Created by JiangWang on 2018/11/15.
//  Copyright © 2018 wangjiang-camera360. All rights reserved.
//

#import "JLargeFileDownloadViewController.h"
#import <JFileDownloader/JFileDownloader.h>

@interface JLargeFileDownloadViewController ()
@property (nonatomic, strong) NSString *fileUrl;
@end

@implementation JLargeFileDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //8.9m
    self.fileUrl = @"https://github.com/Alex1989Wang/JFileDownloader/blob/master/TestFiles/3486842841_d78a545ff2_o.jpg?raw=true";
}

- (IBAction)clickToDownload {
    [[JFileDownloader sharedDownloader] downloadFileWithUrl:self.fileUrl
                                                   progress:
     ^(CGFloat progress) {
         NSLog(@"%02f", progress);
     } succeeded:^(NSURL *fileUrl) {
         NSLog(@"%@", fileUrl);
     } failed:^(NSError *error) {
         NSLog(@"%@", error);
     }];
}

@end
