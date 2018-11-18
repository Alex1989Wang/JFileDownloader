//
//  JMainTableViewController.m
//  JFileDownloader_Example
//
//  Created by JiangWang on 2018/11/15.
//  Copyright © 2018 wangjiang-camera360. All rights reserved.
//

#import "JMainTableViewController.h"
#import "JLargeFileDownloadViewController.h"

typedef NS_ENUM(NSUInteger, JDownloadTestType) {
    JDownloadTestTypeLargeFile = 0,
};

NSString *const kDowloadListTableCellID = @"JDownloadTableCellID";

@interface JMainTableViewController ()
@property (nonatomic, strong) NSDictionary<NSNumber *, NSString *> *downloads;
@end

@implementation JMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"JFileDownloader";
    
    //cell registeration
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDowloadListTableCellID];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloads.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDowloadListTableCellID forIndexPath:indexPath];
    NSString *title = self.downloads[@(indexPath.row)];
    cell.textLabel.text = title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JDownloadTestType type = indexPath.row;
    NSString *title = self.downloads[@(type)];
    switch (type) {
        case JDownloadTestTypeLargeFile: {
            JLargeFileDownloadViewController *testVC =
            [[JLargeFileDownloadViewController alloc] init];
            [self.navigationController pushViewController:testVC animated:YES];
            break;
        }
            
        default:
            NSAssert(NO, @"invalid type");
            break;
    }
}

- (NSDictionary<NSNumber *,NSString *> *)downloads {
    if (!_downloads) {
        _downloads = @{@(JDownloadTestTypeLargeFile): @"Download Large File",
                     };
    }
    return _downloads;
}

@end

