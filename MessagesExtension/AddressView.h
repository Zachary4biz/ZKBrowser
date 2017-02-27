//
//  AddressView.h
//  ZKBrowser
//
//  Created by 周桐 on 16/12/10.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    Bing = 0,
    Baidu,
    Google,
    Ask,
    Naver,
    Duckduckgo,
    Yandex,
    Yahoo,
} SearchEngineType;

typedef enum : NSUInteger {
    Favorite,
    Cancel,
} FunctionType;

@interface AddressView : UIView<UITextFieldDelegate>
#pragma mark UI界面
/**
 搜索引擎按钮
 */
@property (nonatomic, strong)UIButton *searchEngineBtn;
/**
 搜索内容或URL输入
 */
@property (nonatomic, strong)UITextField *urlTextField;
/**
 右边功能按钮
 */
@property (nonatomic, strong)UIButton *functionalBtn;

@property (nonatomic, strong)UIButton *shareBtn;
/**
 textField的清除按钮自定义（清除和刷新用）
 */
//@property (nonatomic, strong)UIButton *refreshAndDeleteBtn;

#pragma mark 响应用block
/**
 搜索内容或URL输入框点击搜索后的block
 */
@property (nonatomic, strong)void (^textFieldRetrunBlock)(id object);

///**
// 开始编辑时的block
// */
//@property (nonatomic, strong)void (^textFieldBeginEditingBlock)(id object);

/**
 点击搜索引擎按钮的block，希望的效果见APUS Browser
 */
@property (nonatomic, strong)void (^clickSearchEngineBtnBlock)(id object);

/**
 点击功能按钮，判断一下类型，是Cancel还是Favorite然后执行
 */
@property (nonatomic, strong)void (^clickFunctionalBtnBlock)(id object);

@property (nonatomic, strong)void (^clickShareBtnBlock)(id object);
/**
 点击textField的右边清除（刷新）按钮响应block
 */
//@property (nonatomic, strong)void (^clickRefreshAndDeleteBtnBlock)(id object);


#pragma mark 一些方法
/**
 初始化地址栏View

 @param aFrame            地址栏的Frame
 @param aColor            地址栏的背景色（地址textField和按钮等都为白色)
 @param aSearchEngineType 搜索引擎的类型
 @param aFunctionType     右边功能键的类型

 @return 返回view
 */
- (instancetype)initWithFrame:(CGRect)aFrame Color:(UIColor *)aColor SearchEngine:(SearchEngineType)aSearchEngineType functionaType:(FunctionType)aFunctionType;

/**
 初始化地址栏View，默认Frame为(0, 20, [UIScreen mainScreen].bounds.size.width, 44)

 @param aColor            地址栏颜色
 @param aSearchEngineType 左边搜索引擎类型
 @param aFunctionType     右边功能键类型

 @return 返回view
 */
- (instancetype)initWithColor:(UIColor *)aColor SearchEngine:(SearchEngineType)aSearchEngineType functionaType:(FunctionType)aFunctionType;

- (void)showall:(BOOL)all;
@end
