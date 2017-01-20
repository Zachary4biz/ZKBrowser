//
//  SetUpAboutKeyboard.m
//  iOS_OA_NET
//
//  Created by 周桐 on 16/11/22.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import "SetUpAboutKeyboard.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "UIResponder+FindFirstResponder.h"
@implementation SetUpAboutKeyboard

static int tag4topView = 9527;
static int tag4view2Lift = 1911;
static int height4topView = 30;
static int counter = 0;
#pragma mark 配置关于键盘弹出、收起的设置
-(void)initWithPreparation4KeyboardWithVC:(UIViewController *)targetVC andLiftTheViews:(NSArray *)views2Lift
{
    //初始化一下counter
    counter = 0;
    if (views2Lift) {
        //如果有传入值，表示有需要上移的view
        for (UIView *view in views2Lift)
        {
            view.tag = tag4view2Lift + counter;
            counter++;
        }
        
    }
    //添加一个keyboardAppear的方法
    class_addMethod([targetVC class], @selector(keyboardAppear:), class_getMethodImplementation([self class], @selector(keyboardAppear:)), "v@:@");
    class_addMethod([targetVC class], @selector(keyboardDisappear:), class_getMethodImplementation([self class], @selector(keyboardDisappear:)), "v@:@");
    class_addMethod([targetVC class], @selector(setTextFieldInputAccessoryView), class_getMethodImplementation([self class], @selector(setTextFieldInputAccessoryView)), "v@:");
    class_addMethod([targetVC class], @selector(dealKeyboardHide), class_getMethodImplementation([self class], @selector(dealKeyboardHide)), "v@:");
    
    /*
     *这里是为了让view在willDisappear的时候能够取消键盘
     *避免一些奇葩的问题
     *因为系统只会在DidDisappear之后才自动取消键盘，有时候我希望能在willDis时就取消
     *比如一个页面有输入框，但这个页面是present出来的，那么在它消失时，它会下移，直到消失不见了，键盘才移走
     */

    /*
    Method newMethodAnother = class_getInstanceMethod([self class], @selector(newViewDidDisappearAnother:));
    //向目标VC以"viewDidDisappear"为方法名添-newMethodAnother
    if (!class_addMethod([targetVC class], @selector(viewWillDisappear:), method_getImplementation(newMethodAnother), method_getTypeEncoding(newMethodAnother)))
    {//如果失败说明目标VC已经实现了"viewDidDisappear"，那就进行交换
        //拿到目标VC的方法
        Method targetMethod = class_getInstanceMethod([targetVC class], @selector(viewWillDisappear:));
        //交换时就要改用-newMethod进行交换了，因为考虑到要先跑一边目标自己实现的-WillDisappear
        Method newMethod = class_getInstanceMethod([self class], @selector(newViewDidDisappear:));
        //交换
        method_exchangeImplementations(targetMethod, newMethod);
        NSLog(@"目标已经实现viewWillDisappear，进行交换");
    }else
    {
        //既然直接添加进去了，就没什么了
        NSLog(@"目标没有实现viewWillDisappear，直接添加成功");
    }
     */
    
/*
 *这个不会用，怎么给一个类添加属性？？？？？？？？
    objc_property_attribute_t type = { "T", "@\"UIToolbar\"" };
    objc_property_attribute_t ownership = { "C", "" }; // C = copy
    objc_property_attribute_t backingivar  = { "V", "_privateName" };
    objc_property_attribute_t attrs[] = { type, ownership, backingivar };
    class_addProperty([targetVC class], "topView", attrs, 3);
 */
    //监听键盘出现
    [[NSNotificationCenter defaultCenter] addObserver:targetVC
                                             selector:@selector(keyboardAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    //监听键盘隐藏的通知
    [[NSNotificationCenter defaultCenter] addObserver:targetVC
                                             selector:@selector(keyboardDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardAppear:(NSNotification *)note
{
    NSLog(@"setUpAboutKeyboard收到键盘弹出");
#pragma mark Test About DarkKeyboard In WKWebContentView
    
    
    CGRect rect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //设置键盘上方的指示View
    [self setTextFieldInputAccessoryView];
    [self.aTextField becomeFirstResponder];
    
    UIToolbar *tempView = [self.view.window viewWithTag:tag4topView];
    [UIView animateWithDuration:duration animations:^{
        tempView.transform = CGAffineTransformMakeTranslation(0, -(rect.size.height));
        /*通过counter得知有几个view被做了tag，要上移的，注意这里是小于而不能使小于等于
         *因为counter是从0开始记录的，假如给了2个view要上移，那么counter算完就是2
         *而在给这两个view标记tag的时候是从“tag4view2Lift+counter” counter为0的时候开始的
         *即这两个view的tag分别会是tag4view2Lift+0和tag4view2Lift+1
         */
        for (int i=0; i<counter; i++) {
            UIView *viewWillLift = [self.view viewWithTag:tag4view2Lift+i];
            CGRect tempFrame = viewWillLift.frame;
            tempFrame.origin.y -= rect.size.height+height4topView;
            viewWillLift.frame = tempFrame;
//            viewWillLift.transform = CGAffineTransformMakeTranslation(0, -(rect.size.height+height4topView));
        }
    }];
}
//键盘消失
- (void)keyboardDisappear:(NSNotification *)note
{
    NSLog(@"setUpAboutKeyboard收到键盘消失");
    CGRect rect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIToolbar *tempView = [self.view.window viewWithTag:tag4topView];
    [UIView animateWithDuration:duration
                     animations:^{
                         /*这里不是回到0，创建这个view的时候是用的屏幕高度减去它的高度作为Y创建的
                          *所以要继续下移30（即它的高度）
                          *把它移到屏幕之外，然后remove
                          */
                         tempView.transform = CGAffineTransformMakeTranslation(0, height4topView);
                         for (int i=0; i<counter; i++) {
                             UIView *viewWillLift = [self.view viewWithTag:tag4view2Lift+i];
                             viewWillLift.frame = CGRectMake(viewWillLift.frame.origin.x,
                                                             viewWillLift.frame.origin.y + rect.size.height+height4topView,
                                                             viewWillLift.frame.size.height,
                                                             viewWillLift.frame.size.width);
                             /*
                              *不用transform了是因为可能会影响到到时候用这个包的文件
                              *比如那个文件中有用到transform，结果这里给它回到了Identity就血崩了
                              */
//                             viewWillLift.transform = CGAffineTransformIdentity;
                         }
                     }completion:^(BOOL finished) {
                         [tempView removeFromSuperview];
                     }];
}
//配置键盘上方的指示view
- (void)setTextFieldInputAccessoryView
{
    UIToolbar *tempView = [self.view.window viewWithTag:tag4topView];
    if (!tempView) {
        tempView = [[UIToolbar alloc]initWithFrame:CGRectMake(0,
                                                              [UIScreen mainScreen].bounds.size.height-height4topView,
                                                              [UIScreen mainScreen].bounds.size.width,
                                                              height4topView)];
        [tempView setBarStyle:UIBarStyleDefault];
        
        UIBarButtonItem * spaceBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
        doneBtn.frame = CGRectMake(2, 5, 40, 25);
        [doneBtn addTarget:self action:@selector(dealKeyboardHide) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *doneBtnItem = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
        NSArray * buttonsArray = [NSArray arrayWithObjects:spaceBtn,doneBtnItem,nil];
        [tempView setItems:buttonsArray];
    }
    tempView.tag = tag4topView; //这个目的是为了待会能找到这个view，原因是我不会用class_addproperty，没成功
    [self.view.window addSubview:tempView];
    
}
//点击键盘上方指示栏的完成按钮
- (void)dealKeyboardHide
{
    [self.view.window endEditing:YES];
}


//和目标VC的viewWillDisappaer进行互换
- (void)newViewWillDisappear:(BOOL)animated
{
    [self newViewWillDisappear:animated];
    [self.view endEditing:YES];
    [self.view.window endEditing:YES];
}
//向目标VC以"viewWillDisappear"为方法名添加这个方法
- (void)newViewWillDisappearAnother:(BOOL)animated
{
//    [super performSelector:@selector(viewWillDisappear:) withObject:nil afterDelay:0];
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [self.view.subviews makeObjectsPerformSelector:@selector(resignFirstResponder)];
//    [self.view.window endEditing:YES];
}
@end
