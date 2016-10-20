//
//  FYJShare.h
//  weGame
//
//  Created by zy-iOS on 14/10/15.
//  Copyright (c) 2014年 BlueRain. All rights reserved.
//41c2a84d

#import <Foundation/Foundation.h>
#import "FYJShareContent.h"

@interface FYJShareData : NSObject

@property (nonatomic,strong) NSString *openID;
@property (nonatomic,strong) NSString *accessToken;
@property (nonatomic,strong) NSString *nickName;
@property (nonatomic,strong) NSString *userPic;
@property (nonatomic,strong) NSString *thirdType;//2:qq,3:sina,4:weChat
@end


typedef void (^ FYJAuthSuccess) (FYJShareData *userData);
typedef void (^ FYJAuthFaile) (NSString *failinfo);
typedef void (^ FYJCanceAuthSuccess) ();
typedef void (^ FYJCanceAuthFaile) (NSString *failinfo);
typedef void (^ FYJShareSuccess) (FYJShareContent *content);
typedef void (^ FYJShareFaile) (NSString *failinfo);


@interface FYJShare : NSObject

@property (nonatomic,strong)FYJAuthSuccess fyjAuthSuccess;
@property (nonatomic,strong)FYJAuthFaile fyjAuthFail;
@property (nonatomic,copy)FYJCanceAuthSuccess fyjCanceAuthSuccess;
@property (nonatomic,copy)FYJCanceAuthFaile fyjCanceAuthFail;
@property (nonatomic,copy)FYJShareSuccess fyjShareSuccess;
@property (nonatomic,copy)FYJShareFaile fyjShareFaile;

+(FYJShare *)shared;

/**
 *注册腾讯开放平台
 */
+ (void) regestTencentOauth:(NSString *)apikey andApiSecert:(id)secret;
/**
 *注册微信开放平台
 */
+ (void) regestWeChat:(NSString *)apikey andApiSecert:(id)secret;
/**
 *注册新浪微博开放平台
 */
+ (void) regestSina:(NSString *)apikey andApiSecert:(id)secret andRedirectURL:(NSString *)redirectURL;
/**
 处理从第三方程序（如：QQ）通过URL启动应用时传递的数据
 */
+ (BOOL) FYJHandleOpenURL:(NSURL *)url;


//实例方法 需要用单例调用
/**
 *第三方登录类型
 */
- (void) FYJShareLogin:(ThirdLoginType)type success:(FYJAuthSuccess)success failed:(FYJAuthFaile)failure;

/**
 *取消第三方授权logout
 */
- (void) FYJShareCanceAuth:(ThirdLoginType)type success:(FYJCanceAuthSuccess)success failed:(FYJCanceAuthFaile)failure;

/**
 *是否已经授权
 */
-(BOOL)isOauthed:(ThirdLoginType)type;

/**
 *是否安装啦该第三方平台客户端
 */
+(BOOL)isInstalledClient:(ThirdLoginType)type;


/**
 *第三方分享(多个平台选择其中一个)
 * typeList 分享类型 @see ThirdShareType
 */
-(void) FYJSharetypeList:(NSArray *)typeList withContent:(FYJShareContent *)cont success:(FYJShareSuccess)success failed:(FYJShareFaile)failure;
/**
 *第三方分享(单个平台直接分享)
 */
-(void) FYJShareInstance:(ThirdShareType)type withContent:(FYJShareContent *)cont success:(FYJShareSuccess)success failed:(FYJShareFaile)failure;


//消息转换 FYJShareContent -> 第三方消息数据

@end
