//
//  SpotlightUtil.h
//  ZKBrowser
//
//  Created by Zac on 2017/1/23.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/MobileCoreServices.h>
@interface SpotlightUtil : NSObject
/**
 获得图片的NSData格式，因为Spotlight里面要求是NSData

 @param aImage UIImage
 @return NSData
 */
+ (NSData *)getNSDataOfUIImage:(UIImage *)aImage;

/**
 初始化得到一个可以被spotlight搜索到的item
 1.创建可以被spotlight搜索到的item对象的属性
 2.依据这个属性创建可检索条目即这个item对象
 @param aTitle NSString
 @param aKeywordArr NSArray
 @param aContentDescription NSString
 @param aThumbnailData NSData 缩略图
 @param aSpotlightInfo 这个是到时候点击spotlight的搜索结果会传过去的值
 @param aDomainID  标记这个Item的ID
 @return CSSearchableItem 一个可以被spotlight搜索到的对象
 */
+ (CSSearchableItem *)getItemWithTitle:(NSString *)aTitle
                            keywordArr:(NSArray *)aKeywordArr
                    contentDescription:(NSString *)aContentDescription
                         thumbnailData:(NSData *)aThumbnailData
                         spotlightInfo:(NSString *)aSpotlightInfo
                              domainID:(NSString *)aDomainID;

/**
 3.创建（添加）到spotlight的检索中

 @param anItemsArr 数组里面保存了有所有希望添加到检索中的item
 */
+ (void)setUpSpotlightWithItemsArr:(NSArray *)anItemsArr;
/**
 删除所有spotlight
 */
+ (void)deleteAllSpotlight;

/**
 删除指定的item

 @param aDomainID 指定item的ID
 */
+ (void)deleteSpotlightItemWithDomainID:(NSString *)aDomainID;


@end
