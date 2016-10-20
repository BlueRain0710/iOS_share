//
//  AppDelegate.m
//  ShareDemo
//
//  Created by BlueRain on 16/10/19.
//  Copyright © 2016年 BlueRain. All rights reserved.
//

#import "AppDelegate.h"
#import "FYJShare.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
#warning    要填写第三方平台分配的对应值才可以
    [FYJShare regestSina:@"" andApiSecert:@"" andRedirectURL:@"http"];
    [FYJShare regestWeChat:@"" andApiSecert:@""];
    [FYJShare regestTencentOauth:@"" andApiSecert:@""];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FYJShare FYJHandleOpenURL:url];;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    return [FYJShare FYJHandleOpenURL:url];
}

@end
