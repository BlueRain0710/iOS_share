//
//  FYJShareContent.h
//  weGame
//
//  Created by zy-iOS on 14/10/20.
//  Copyright (c) 2014年 BlueRain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kSinaSDKOAuthDomain @"sinasdkoauthdomain"
#define kSinaKeychainUserID @"sinaUserID"
#define kSinaKeychainAccessToken @"sinaaccesstoken"
#define kSinaKeychainExpireTime @"sinaexpiretime"

#define kTencentSDKOAuthDomain @"tencentoauthdomain"
#define kTencentKeychainUserID @"tencentUserID"
#define kTencentKeychainAccessToken @"tencentaccesstoken"
#define kTencentKeychainExpireTime @"tencentexpiretime"

#define kWeChatSDKOAuthDomain @"wechatsdkoauthdomain"
#define kWeChatKeychainUserID @"wechatUserID"
#define kWeChatKeychainAccessToken @"wechataccesstoken"
#define kWeChatKeychainExpireTime @"wechatexpiretime"
#define kWeChatKeychainRefreshToken @"wechatrefreshtoken"
/**
 * 登录类型
 */
typedef NS_ENUM(NSInteger, ThirdLoginType){
    ThirdLoginTypeQQ = 1,       /**< QQ登录*/
    ThirdLoginTypeSina = 2,      /**< sina登录*/
    ThirdLoginTypeWeChat = 3     /**< 微信登录*/
};


/**
 * 分享类型
 */
typedef NS_ENUM(NSInteger, ThirdShareType) {
    ThirdShareTypeQQSpace = 1,          /**< QQ空间*/
    ThirdShareTypeSinaWeiBo = 2,        /**< 新浪微博*/
    ThirdShareTypeWechatSession = 3,    /**< 微信好友*/
    ThirdShareTypeWechatTimeline = 4,    /**< 微信朋友圈*/
    ThirdShareTypeQQFriend = 5          /**< QQ好友*/
};

@interface FYJShareContent : NSObject

@property (nonatomic,copy) NSString *title;//分享条目标题
@property (nonatomic,copy) NSString *content;//分享条目的正文
@property (nonatomic,copy) NSString *url;//分享出去后点击内容跳转的连接
@property (nonatomic,strong) NSData *thumbImgData;//分享出去的条目展示的那张小图
@property (nonatomic, strong) NSData *imgData;//单独分享图片到指定平台的图片
/**
 *
 *  @param imgData   NSData 大小<10M 如果有数据，则为分享图片，否则为普通新闻分享
 *
 */
- (instancetype) initWitContent:(NSString *)pContent title:(NSString *)pTitle thumbImage:(UIImage *)pThumbImage url:(NSString *)pUrl imageData:(NSData *)imgData;

/**
 *  获取要支持的分享列表
 *
 *  @param shareType 社会化平台类型
 *
 *  @return 分享列表
 */
+ (NSArray *)getShareListWithType:(ThirdShareType)shareType, ... NS_REQUIRES_NIL_TERMINATION;
@end
