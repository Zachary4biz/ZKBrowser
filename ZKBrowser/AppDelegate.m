//
//  AppDelegate.m
//  ZKBrowser
//
//  Created by 周桐 on 16/12/10.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import "AppDelegate.h"
#import "WebVC.h"
#import "SpotlightUtil.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    WebVC *webVC = [WebVC sharedInstance];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"dict4SaveURLOfWebView.archiver"];
    NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    if (dict) {
        webVC.dictUnarchived = dict;
        [webVC loadLocalWKWebViews];
    }
    
    self.window.rootViewController = webVC;
    [self.window makeKeyAndVisible];
    
    
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"app did enter background");
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
    NSLog(@"app will terminate");
    
}

#pragma mark - 点击spotlight之后的响应方法
- (BOOL)application:(UIApplication *)application
continueUserActivity:(nonnull NSUserActivity *)userActivity
 restorationHandler:(nonnull void (^)(NSArray * _Nullable))restorationHandler
{
    if ([[userActivity activityType] isEqualToString:CSSearchableItemActionType]) {
        NSString *uniqueIdentifier = [userActivity.userInfo objectForKey:CSSearchableItemActivityIdentifier];
        //接受事先定义好的竖直，如果是多个参数可以使用Json转成string传递过来，然后再把string转回去
        //这个就是spotlightUtil的spotlightInfo
        NSLog(@"传递过来的值是%@",uniqueIdentifier);
        WebVC *theWebVC = [WebVC sharedInstance];
        theWebVC.spotlightParam = uniqueIdentifier;
        [theWebVC requestWithSpotlightParam:uniqueIdentifier];
    }else{
        NSLog(@"not Equal");
        NSLog(@"userActivityType %@",[userActivity activityType]);
        NSLog(@"CSSearchableItemActionType %@",CSSearchableItemActionType);
    }
    return YES;
}

#pragma mark - iMessageApp拓展进来
- (BOOL)application:(UIApplication *)application openURL:(NSURL * _Nonnull)url sourceApplication:(NSString * _Nullable)sourceApplication annotation:(id _Nonnull)annotation
{
//    NSString *prefix = @"ZKBrowser://action=";
//    
//    if ([[url absoluteString] rangeOfString:prefix].location!= NSNotFound) {
//        NSString *action = [[url absoluteString] substringFromIndex:prefix.length];
//        if ([action isEqualToString:@"iMessage"]) {
//
//        }
//    };
    NSString *prefix = @"ZKBrowser://";
    NSString *str = url.absoluteString;
    
    NSURL *iMessageURL;
    if ([str rangeOfString:prefix].location != NSNotFound) {
        str = [str substringFromIndex:prefix.length];
        if ([str rangeOfString:@"action="].location != NSNotFound) {
            //获取 action 对应的参数
            NSUInteger rangEnd = [str rangeOfString:@"&"].location;
            NSUInteger rangBegin = NSMaxRange([str rangeOfString:@"action="]);
            NSString *actionStr = [str substringWithRange:NSMakeRange(rangBegin, rangEnd-rangBegin)];
            NSLog(@"actionStr is %@",actionStr);
            //判断 action 对应得参数是什么
            if ([actionStr isEqualToString:@"iMessage"]) {
                NSLog(@"from iMessage");
                NSUInteger rangBegin4URL = NSMaxRange([str rangeOfString:@"url="]);
                iMessageURL = [NSURL URLWithString:[str substringFromIndex:rangBegin4URL]];
            }
            if ([actionStr isEqualToString:@"Today"]) {
                NSLog(@"from Today");
            }
        }
    }
    if (iMessageURL) {
        NSLog(@"iMessageURL is %@",iMessageURL);
        WebVC *theWebVC = [WebVC sharedInstance];
        [theWebVC requestWithiMessageURL:iMessageURL];
    }
    return YES;
}

@end
