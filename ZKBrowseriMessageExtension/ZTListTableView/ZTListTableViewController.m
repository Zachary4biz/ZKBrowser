//
//  ZTListTableViewController.m
//  ZKBrowser
//
//  Created by Zac on 2017/4/11.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "ZTListTableViewController.h"
#import "ZTListTableViewCell.h"
@interface ZTListTableViewController ()<UIScrollViewDelegate>

@end

@implementation ZTListTableViewController
static NSString *Identifier = @"cellID";
- (UIImage *)img4cell
{
    if(!_img4cell){
        _img4cell = [UIImage new];
    }
    return _img4cell;
}
- (NSMutableArray *)dataArr
{
    if(!_dataArr){
        _dataArr = [NSMutableArray new];
    }
    return _dataArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ZTListTableViewCell" bundle:nil] forCellReuseIdentifier:Identifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
#pragma mark - 获取灰色图片
-(UIImage *)grayImage:(UIImage *)sourceImage
{
    int bitmapInfo = kCGImageAlphaNone;
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,
                                                  0,
                                                  colorSpace,
                                                  bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), sourceImage.CGImage);
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayImage;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArr.count;
}


- (ZTListTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZTListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier forIndexPath:indexPath];
    cell.dataStr = self.dataArr[indexPath.row];
    cell.img = self.img4cell;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.didSelectCellBlock) {
        ZTListTableViewCell *cell = (ZTListTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
        self.didSelectCellBlock(cell.dataStr);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView==self.tableView) {
        if (self.didScrollBlock) {
            self.didScrollBlock();
        }
    }else{
        
    }
    
}


@end
