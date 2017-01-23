//
//  SpotlightUtil.m
//  ZKBrowser
//
//  Created by Zac on 2017/1/23.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "SpotlightUtil.h"



@interface SpotlightUtil ()

@end

@implementation SpotlightUtil
+ (NSData *)getNSDataOfUIImage:(UIImage *)aImage
{
    NSData *imgData = UIImagePNGRepresentation(aImage);
    return imgData;
}

+ (CSSearchableItem *)getItemWithTitle:(NSString *)aTitle
                            keywordArr:(NSArray *)aKeywordArr
                    contentDescription:(NSString *)aContentDescription
                         thumbnailData:(NSData *)aThumbnailData
                         spotlightInfo:(NSString *)aSpotlightInfo
                              domainID:(NSString *)aDomainID
{
    //1.创建可以被spotlight搜索到的item对象的属性
    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc]initWithItemContentType:(NSString *)kUTTypeImage];
    attributeSet.title = aTitle;
    attributeSet.keywords = aKeywordArr;
    attributeSet.contentDescription = aContentDescription;
    attributeSet.thumbnailData = aThumbnailData;
    
    //2.创建可检索条目即这个item对象
    CSSearchableItem *item = [[CSSearchableItem alloc]initWithUniqueIdentifier:aSpotlightInfo
                                                 domainIdentifier:aDomainID
                                                     attributeSet:attributeSet];
    return item;
}

+ (void)setUpSpotlightWithItemsArr:(NSArray *)anItemsArr
{
    //3.添加检索入口
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:anItemsArr completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"添加检索入口出错 -- %@",error);
            NSLog(@"\n");
            NSLog(@"error.localizedDescription -- %@",error.localizedDescription);
        }
    }];
    
}
+ (void)deleteAllSpotlight
{
    [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"删除所有spotlight出错 -- %@",error);
        }
    }];
}

+ (void)deleteSpotlightItemWithDomainID:(NSArray *)aDomainIDArr
{
    __block NSInteger counter = 0;
    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithDomainIdentifiers:aDomainIDArr completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"删除指定ID：%@ 的item失败 -- %@",aDomainIDArr[counter],error);
        }else{
            counter += 1;
        }
    }];
}











@end
