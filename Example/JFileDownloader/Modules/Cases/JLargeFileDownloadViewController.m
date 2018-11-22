//
//  JLargeFileDownloadViewController.m
//  JFileDownloader_Example
//
//  Created by JiangWang on 2018/11/15.
//  Copyright © 2018 wangjiang-camera360. All rights reserved.
//

#import "JLargeFileDownloadViewController.h"
#import <JFileDownloader/JFileDownloader.h>
#import <JFileDownloader/JFileCache.h>

@interface JLargeFileDownloadViewController ()
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (nonatomic, strong) NSString *fileUrl;
@end

@implementation JLargeFileDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //8.9m
    self.fileUrl = @"https://github.com/Alex1989Wang/JFileDownloader/blob/master/TestFiles/3486842841_d78a545ff2_o.jpg?raw=true";
    
    [self setupRightNavigationItem];
}

- (IBAction)clickToDownload {
    __weak typeof(self) weakSelf = self;
    [[JFileDownloader sharedDownloader] downloadFileWithUrl:self.fileUrl
                                                   progress:
     ^(CGFloat progress) {
         __strong typeof(weakSelf) strSelf = weakSelf;
         strSelf.progressLabel.text = [NSString stringWithFormat:@"Progress: %00f", progress * 100];
     } succeeded:^(NSURL *fileUrl) {
         NSLog(@"%@", fileUrl);
     } failed:^(NSError *error) {
         NSLog(@"%@", error);
     }];
}

- (IBAction)clickToCancel {
    [[JFileDownloader sharedDownloader] cancelDownloadUrl:self.fileUrl];
}

- (IBAction)clickToResume {
    __weak typeof(self) weakSelf = self;
    [[JFileDownloader sharedDownloader] downloadFileWithUrl:self.fileUrl progress:^(CGFloat progress) {
         __strong typeof(weakSelf) strSelf = weakSelf;
        strSelf.progressLabel.text = [NSString stringWithFormat:@"Progress: %00f", progress * 100];
    } succeeded:^(NSURL *fileUrl) {
        NSLog(@"file url: %@", fileUrl);
    } failed:^(NSError *error) {
         NSLog(@"%@", error);
    }];
}

#pragma mark - Private
- (void)setupRightNavigationItem {
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearCache)];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)clearCache {
    [[JFileDownloader sharedDownloader].downloadsCache clearCache];
}

@end
