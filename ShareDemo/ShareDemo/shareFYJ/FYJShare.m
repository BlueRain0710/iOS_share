//
//  FYJShare.m
//  weGame
//
//  Created by zy-iOS on 14/10/15.
//  Copyright (c) 2014年 BlueRain. All rights reserved.
//

#import "FYJShare.h"
# import <TencentOpenAPI/TencentOAuth.h>
# import <TencentOpenAPI/QQApiInterface.h>
# import "WXApi.h"
# import "WeiboSDK.h"

#import "FYJShareView.h"

@implementation FYJShareData

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

@end


@interface FYJShare ()<TencentLoginDelegate,TencentSessionDelegate,QQApiInterfaceDelegate,WeiboSDKDelegate,WBHttpRequestDelegate,WXApiDelegate,FYJShareViewDelegate>

@property (nonatomic,strong) FYJShareContent *shareContent;
@property(nonatomic,strong)TencentOAuth *tencentOauth;

@end


@implementation FYJShare

NSString *tencentApikey;
NSString *sinaRedirectURL;
NSString *wechatApikey;
NSString *wechatSecret;


+(FYJShare *)shared {
    
    static FYJShare *shareFYJ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareFYJ = [[FYJShare alloc] init];
    });
    return shareFYJ;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (void) regestTencentOauth:(NSString *)apikey andApiSecert:(id)secret
{
    tencentApikey = apikey;
    [FYJShare shared].tencentOauth = [[TencentOAuth alloc] initWithAppId:tencentApikey andDelegate:[FYJShare shared]];
}

+ (void) regestWeChat:(NSString *)apikey andApiSecert:(id)secret
{
    wechatApikey = apikey;
    wechatSecret = secret;
    [WXApi registerApp:apikey];
}

+ (void) regestSina:(NSString *)apikey andApiSecert:(id)secret andRedirectURL:(NSString *)redirectURL
{
    sinaRedirectURL = redirectURL;
    [WeiboSDK registerApp:apikey];
}

+ (BOOL) FYJHandleOpenURL:(NSURL *)url
{
    NSString *strUrl = [url scheme];
    if([strUrl hasPrefix:@"wx"])
    {
        return [WXApi handleOpenURL:url delegate:[FYJShare shared]];
    }
    else if([strUrl hasPrefix:@"QQ"] || [strUrl hasPrefix:@"tencent"])
    {
        if([strUrl hasPrefix:@"QQ"])
        {
            return [QQApiInterface handleOpenURL:url delegate:[FYJShare shared]];
        }
        return [TencentOAuth HandleOpenURL:url];
    }
    else if ([strUrl hasPrefix:@"wb"])
    {
        return [WeiboSDK handleOpenURL:url delegate:[FYJShare shared]];
    }
    else
    {
        return YES;
    }
}

- (void) FYJShareLogin:(ThirdLoginType)type success:(void (^)(FYJShareData *))success failed:(FYJAuthFaile)failure
{
    _fyjAuthSuccess = success;
    _fyjAuthFail = failure;
    if(type == ThirdLoginTypeQQ)
    {
        NSArray *permissions=[NSArray arrayWithObjects:
                              kOPEN_PERMISSION_GET_USER_INFO,
                              kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                              kOPEN_PERMISSION_ADD_ONE_BLOG,
                              kOPEN_PERMISSION_ADD_TOPIC,
                              kOPEN_PERMISSION_ADD_SHARE,
                              kOPEN_PERMISSION_ADD_TOPIC,
                              kOPEN_PERMISSION_GET_INFO,
                              kOPEN_PERMISSION_GET_OTHER_INFO,
                              nil];
        //_tencentOauth = [[TencentOAuth alloc] initWithAppId:tencentApikey andDelegate:self];
        [_tencentOauth authorize:permissions inSafari:YES];
    }
    else if (type == ThirdLoginTypeSina)
    {
        WBAuthorizeRequest *request = [WBAuthorizeRequest request];
        request.redirectURI = sinaRedirectURL;
        request.scope = @"all";
        request.userInfo =nil;
        [WeiboSDK sendRequest:request];
    }
    else if (type == ThirdLoginTypeWeChat)
    {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"fyj";
        //[WXApi sendAuthReq:req viewController:nil delegate:[FYJShare shared]];
        [WXApi sendReq:req];
    }
}

-(void) FYJShareCanceAuth:(ThirdLoginType)type success:(FYJCanceAuthSuccess)success failed:(FYJCanceAuthFaile)failure
{
    if(![self isOauthed:type])
    {
        return;
    }
    _fyjCanceAuthSuccess = success;
    _fyjCanceAuthFail = failure;
    
    switch (type) {
        case ThirdLoginTypeSina:
        {
            NSDictionary *userStandDic = [[NSUserDefaults standardUserDefaults] objectForKey:kSinaSDKOAuthDomain];
            NSString *accesstoken = [userStandDic objectForKey:kSinaKeychainAccessToken];
            [WeiboSDK logOutWithToken:accesstoken delegate:self withTag:nil];
            break;
        }
        case ThirdLoginTypeQQ:
        {
            [_tencentOauth logout:self];
            break;
        }
        case ThirdLoginTypeWeChat:
        {
            //TODO:微信暂无取消授权
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWeChatSDKOAuthDomain];
            if(_fyjCanceAuthSuccess)
            {
                _fyjCanceAuthSuccess();
            }
            break;
        }
        default:
            break;
    }
}

-(void) FYJSharetypeList:(NSArray *)typeList withContent:(FYJShareContent *)cont success:(FYJShareSuccess)success failed:(FYJShareFaile)failure
{
    if(typeList.count <= 0)
    {
        return;
    }
    _fyjShareSuccess = success;
    _fyjShareFaile = failure;
    
    [FYJShare shared].shareContent = cont;
    NSMutableArray *actionList = [NSMutableArray array];
    for (NSNumber *number in typeList) {
        int num = [number intValue];
        switch (num) {
            case ThirdShareTypeQQSpace:
                [actionList addObject:@(ThirdShareTypeQQSpace)];
                break;
            case ThirdShareTypeSinaWeiBo:
                [actionList addObject:@(ThirdShareTypeSinaWeiBo)];
                break;
            case ThirdShareTypeWechatSession:
                [actionList addObject:@(ThirdShareTypeWechatSession)];
                break;
            case ThirdShareTypeWechatTimeline:
                [actionList addObject:@(ThirdShareTypeWechatTimeline)];
                break;
            case ThirdShareTypeQQFriend:
                [actionList addObject:@(ThirdShareTypeQQFriend)];
                break;

            default:
                break;
        }
    }
    FYJShareView *shareView = [[FYJShareView alloc] initWithArray:actionList withDelegate:self];
    [shareView show];
    
}

-(void) FYJShareInstance:(ThirdShareType)type withContent:(FYJShareContent *)cont success:(FYJShareSuccess)success failed:(FYJShareFaile)failure
{
    _fyjShareSuccess = success;
    _fyjShareFaile = failure;
    [FYJShare shared].shareContent = cont;
    switch (type) {
        case ThirdShareTypeQQSpace:
        {
            QQApiObject *qqObject = [FYJShare qqMessageFrom:cont];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:qqObject];
            QQApiSendResultCode sent;
            sent = [QQApiInterface SendReqToQZone:req];
            break;
        }
        case ThirdShareTypeQQFriend:
        {
            QQApiObject *qqObject = [FYJShare qqMessageFrom:cont];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:qqObject];
            QQApiSendResultCode sent;
            sent = [QQApiInterface sendReq:req];
            break;
        }
        case ThirdShareTypeSinaWeiBo:
        {
            if([WeiboSDK isWeiboAppInstalled])
            {
                WBMessageObject *newsObject = [FYJShare sinaMessageFrom:cont];
                WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:newsObject];
                [WeiboSDK sendRequest:request];
            }
            else
            {
                if(_fyjShareFaile)
                {
                    _fyjShareFaile(@"尚未安装微博客户端");
                }
            }
            break;
        }
        case ThirdShareTypeWechatSession:
        {
            if([WXApi isWXAppInstalled])
            {
                SendMessageToWXReq *wechatReq = [[SendMessageToWXReq alloc] init];
                WXMediaMessage *message = [FYJShare weChatMessageFrom:cont];
                wechatReq.message = message;
                wechatReq.bText = NO;
                wechatReq.scene = WXSceneSession;
                [WXApi sendReq:wechatReq];
            }
            else
            {
                if(_fyjShareFaile)
                {
                    _fyjShareFaile(@"尚未安装微信客户端");
                }
            }
            break;
        }
        case ThirdShareTypeWechatTimeline:
        {
            if([WXApi isWXAppInstalled])
            {
                SendMessageToWXReq *wechatReq = [[SendMessageToWXReq alloc] init];
                WXMediaMessage *message = [FYJShare weChatMessageFrom:cont];
                wechatReq.message = message;
                wechatReq.bText = NO;
                wechatReq.scene = WXSceneTimeline;
                [WXApi sendReq:wechatReq];
            }
            else
            {
                if(_fyjShareFaile)
                {
                    _fyjShareFaile(@"尚未安装微信客户端");
                }
            }
            break;
        }
            
        default:
            break;
    }
}
+(BOOL)isInstalledClient:(ThirdLoginType)type
{
    BOOL isInstalled = NO;
    switch (type) {
        case ThirdLoginTypeQQ:
        {
            isInstalled = [QQApiInterface isQQInstalled];
        }
            break;
        case ThirdLoginTypeSina:
        {
            isInstalled = [WeiboSDK isWeiboAppInstalled];
        }
            break;
        case ThirdLoginTypeWeChat:
        {
            isInstalled = [WXApi isWXAppInstalled];
        }
            break;
        default:
            isInstalled = NO;
            break;
    }
    return  isInstalled;
}
-(BOOL)isOauthed:(ThirdLoginType)type
{
    BOOL isAuth = NO;
    switch (type) {
        case ThirdLoginTypeQQ:
        {
            NSDictionary *userStandDic = [[NSUserDefaults standardUserDefaults] objectForKey:kTencentSDKOAuthDomain];
            NSString *userid = [userStandDic objectForKey:kTencentKeychainUserID];
            NSString *accesstoken = [userStandDic objectForKey:kTencentKeychainAccessToken];
            NSDate *expireTime = [userStandDic objectForKey:kTencentKeychainExpireTime];
            if(userid && accesstoken && expireTime)
            {
                NSDate *now = [NSDate date];
                if([now compare:expireTime] == NSOrderedAscending)
                {
                    isAuth = YES;
                }
                else
                {
                    isAuth = NO;
                }
            }
            else
            {
                isAuth = NO;
            }
            break;
        }
        case ThirdLoginTypeSina:
        {
            NSDictionary *userStandDic = [[NSUserDefaults standardUserDefaults] objectForKey:kSinaSDKOAuthDomain];
            NSString *userid = [userStandDic objectForKey:kSinaKeychainUserID];
            NSString *accesstoken = [userStandDic objectForKey:kSinaKeychainAccessToken];
            NSDate *expireTime = [userStandDic objectForKey:kSinaKeychainExpireTime];
            if(userid && accesstoken && expireTime)
            {
                NSDate *now = [NSDate date];
                if([now compare:expireTime] == NSOrderedAscending)
                {
                    isAuth = YES;
                }
                else
                {
                    isAuth = NO;
                }
            }
            else
            {
                isAuth = NO;
            }
            break;
        }
        case ThirdLoginTypeWeChat:
        {
            NSDictionary *userStandDic = [[NSUserDefaults standardUserDefaults] objectForKey:kWeChatSDKOAuthDomain];
            NSString *userid = [userStandDic objectForKey:kWeChatKeychainUserID];
            NSString *accesstoken = [userStandDic objectForKey:kWeChatKeychainAccessToken];
            NSDate *expireTime = [userStandDic objectForKey:kWeChatKeychainExpireTime];
            if(userid && accesstoken && expireTime)
            {
                NSDate *now = [NSDate date];
                if([now compare:expireTime] == NSOrderedAscending)
                {
                    isAuth = YES;
                }
                else
                {
                    isAuth = NO;
                }
            }
            else
            {
                isAuth = NO;
            }
            break;
        }
        default:
            break;
    }
    return isAuth;
}

#pragma mark - 消息转换 FYJShareContent －> 第三方消息数据
+(QQApiObject *)qqMessageFrom:(FYJShareContent *)content
{
    if(content.imgData)
    {
        QQApiImageObject *imgObj = [QQApiImageObject objectWithData:content.imgData previewImageData:content.thumbImgData title:content.title description:content.description];
        return imgObj;
    }
    else
    {
        NSData *imageData;
        if(content.thumbImgData){
            imageData = content.thumbImgData;
        }
        QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:content.url] title:content.title description:content.content previewImageData:imageData];
        return newsObj;
    }
}
+(WBMessageObject *)sinaMessageFrom:(FYJShareContent *)content
{
    WBMessageObject *message = [WBMessageObject message];
    message.text = [NSString stringWithFormat:@"%@ %@ %@",content.title,content.content,content.url];
    if(message.text.length >140){
        NSString *str = [NSString stringWithFormat:@"%@ %@",content.title,content.content];
        if(str.length > 140-content.url.length){
            message.text = [NSString stringWithFormat:@"%@ %@",[str substringToIndex:140-content.url.length],content.url];
        }else{
            message.text = [message.text substringToIndex:139];
        }
    }
    if(content.imgData)
    {
        WBImageObject *imageObject = [WBImageObject object];
        imageObject.imageData = content.imgData;
        message.imageObject = imageObject;
    }
    else
    {
        WBImageObject *imageObject = [WBImageObject object];
        imageObject.imageData = content.thumbImgData;
        message.imageObject = imageObject;
    }
    return message;
}
+(WXMediaMessage *)weChatMessageFrom:(FYJShareContent *)content
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = content.title;
    message.description = content.content;
    if(content.thumbImgData){
        [message setThumbData:content.thumbImgData];
    }
    if(content.imgData)
    {
        WXImageObject *imgObject = [WXImageObject object];
        imgObject.imageData = content.imgData;
        message.mediaObject = imgObject;
    }
    else
    {
        WXWebpageObject *webpageObject = [WXWebpageObject object];
        webpageObject.webpageUrl = content.url;
        message.mediaObject = webpageObject;
    }
    
    return message;
}
#pragma mark -  FYJShareView delegate
-(void)fyjshareViewButton:(UIButton *)sender clickedAtindex:(NSInteger)index
{
    ThirdShareType type = index;
    switch (type) {
        case ThirdShareTypeQQSpace:
            [self FYJShareInstance:ThirdShareTypeQQSpace withContent:[FYJShare shared].shareContent success:[FYJShare shared].fyjShareSuccess failed:[FYJShare shared].fyjShareFaile];
            break;
        case ThirdShareTypeSinaWeiBo:
            [self FYJShareInstance:ThirdShareTypeSinaWeiBo withContent:[FYJShare shared].shareContent success:[FYJShare shared].fyjShareSuccess failed:[FYJShare shared].fyjShareFaile];
            break;
        case ThirdShareTypeWechatSession:
            [self FYJShareInstance:ThirdShareTypeWechatSession withContent:[FYJShare shared].shareContent success:[FYJShare shared].fyjShareSuccess failed:[FYJShare shared].fyjShareFaile];
            break;
        case ThirdShareTypeWechatTimeline:
            [self FYJShareInstance:ThirdShareTypeWechatTimeline withContent:[FYJShare shared].shareContent success:[FYJShare shared].fyjShareSuccess failed:[FYJShare shared].fyjShareFaile];
            break;
        case ThirdShareTypeQQFriend:
            [self FYJShareInstance:ThirdShareTypeQQFriend withContent:[FYJShare shared].shareContent success:[FYJShare shared].fyjShareSuccess failed:[FYJShare shared].fyjShareFaile];
            break;
            
        default:
            break;
    }
}

#pragma mark - SinaWeiBo delegate
-(void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        if(response.statusCode==0)
        {
            WBAuthorizeResponse *authResponse = (WBAuthorizeResponse *)response;
            
            //NSDictionary *dicUserSina=[response userInfo];
            NSString *strAccessToken = authResponse.accessToken;//[dicUserSina objectForKey:@"access_token"];
            NSString *strOpenid = authResponse.userID;//[dicUserSina objectForKey:@"uid"];
            
            NSError *jsonErr;
            NSString *strSinaURL=@"https://api.weibo.com/2/users/show.json?";
            NSString *strFinalURL=[NSString stringWithFormat:@"%@access_token=%@&uid=%@",strSinaURL,strAccessToken,strOpenid];
            NSLog(@"get请求信息:%@",strFinalURL);
            NSURL *url=[NSURL URLWithString:[strFinalURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSURLRequest *request=[[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
            NSURLResponse *response=[[NSURLResponse alloc]init];
            NSError *err=[[NSError alloc]init];
            NSData *data;
            data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
            //NSString *string_returnSoapXML=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"返回的请求信息:%@",string_returnSoapXML);
            NSDictionary *dicSinaUserInfo;
            if(data.length!=0)
            {
                dicSinaUserInfo=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonErr];
            }
            NSLog(@"sina用户信息：%@",dicSinaUserInfo);
            
 
            NSDate *sinaExpireTime = authResponse.expirationDate;
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:strOpenid,kSinaKeychainUserID,strAccessToken,kSinaKeychainAccessToken,sinaExpireTime,kSinaKeychainExpireTime, nil];
            [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kSinaSDKOAuthDomain];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString *strNick = [dicSinaUserInfo objectForKey:@"screen_name"];
            NSString *strPicUrl = [dicSinaUserInfo objectForKey:@"profile_image_url"];
            if(_fyjAuthSuccess)
            {
                FYJShareData *da = [[FYJShareData alloc] init];
                da.nickName = strNick;
                da.accessToken = strAccessToken;
                da.openID = strOpenid;
                da.userPic = strPicUrl;
                da.thirdType = @"3";
                
                _fyjAuthSuccess(da);
            }
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"授权失败" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alert show];
            if(_fyjAuthFail)
            {
                _fyjAuthFail(@"授权失败");
            }
        }
    }
    else if([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        if(response.statusCode == 0)
        {
            if(_fyjShareSuccess)
            {
                _fyjShareSuccess([FYJShare shared].shareContent);
            }
        }
        else
        {
            if(_fyjShareFaile)
            {
                if(response.statusCode == WeiboSDKResponseStatusCodeUserCancel)
                {
                    _fyjShareFaile(@"用户取消发送");
                }
                else if(response.statusCode == WeiboSDKResponseStatusCodeSentFail)
                {
                    _fyjShareFaile(@"发送失败");
                }
                else if(response.statusCode == WeiboSDKResponseStatusCodeAuthDeny)
                {
                    _fyjShareFaile(@"授权失败");
                }
                else
                {
                    _fyjShareFaile([NSString stringWithFormat:@"错误状态码:%ld",(long)response.statusCode]);
                }
            }
        }
    }
}
-(void)didReceiveWeiboRequest:(WBBaseRequest *)request
{}

/**
 收到一个来自微博Http请求失败的响应
 
 @param error 错误信息
 */
- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
    if(_fyjAuthFail)
    {
        _fyjAuthFail(@"取消授权失败");
    }
}
/**
 收到一个来自微博Http请求的网络返回
 
 @param result 请求返回结果
 */
- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    //暂未根据result来判断是否成功。。。  result = {"result":"true"}
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSinaSDKOAuthDomain];
    if(_fyjCanceAuthSuccess)
    {
        _fyjCanceAuthSuccess();
    }
}

#pragma mark - Tencent delegate
-(void)tencentDidLogin
{
    NSString *strOpenid = [_tencentOauth openId];
    NSString *accessToken = [_tencentOauth accessToken];
    NSDate *expireTime = [_tencentOauth expirationDate];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:strOpenid,kTencentKeychainUserID,accessToken,kTencentKeychainAccessToken,expireTime,kTencentKeychainExpireTime, nil];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kTencentSDKOAuthDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_tencentOauth getUserInfo];
}
-(void)tencentDidNotLogin:(BOOL)cancelled
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"取消认证" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
    [alert show];
    if(_fyjAuthFail)
    {
        _fyjAuthFail(@"取消认证");
    }
}
-(void)tencentDidNotNetWork
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"网络连接失败" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
    [alert show];
    if(_fyjAuthFail)
    {
        _fyjAuthFail(@"网络连接失败");
    }
}
//获取用户个人信息回调
- (void)getUserInfoResponse:(APIResponse*) response
{
    if(_fyjAuthSuccess)
    {
        NSDictionary *dUser = [response jsonResponse];
        NSString *avata = [dUser objectForKey:@"figureurl_qq_2"];
        NSString *nick = [dUser objectForKey:@"nickname"];
        NSString *openID = [_tencentOauth openId];
        NSString *accessToken = [_tencentOauth accessToken];
        FYJShareData *da = [[FYJShareData alloc] init];
        da.nickName = nick;
        da.accessToken = accessToken;
        da.openID = openID;
        da.userPic = avata;
        da.thirdType = @"2";
        
        _fyjAuthSuccess(da);
    }
}
//退出登录的回调
- (void)tencentDidLogout
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTencentSDKOAuthDomain];
    if(_fyjCanceAuthSuccess)
    {
        _fyjCanceAuthSuccess();
    }
}
/**
 处理来至QQ的请求
 */
- (void)onReq:(QQBaseReq *)req;
{
    NSLog(@"QQBaseReq:  %@",req);
}
/**
 处理来至QQ的响应//微信的回调和qq的名称一样，需要在内部判断
 */
- (void)onResp:(QQBaseResp *)resp
{
    NSString *sC = NSStringFromClass(resp.class);
    NSLog(@"resp : %@",sC);
    if([resp isKindOfClass:SendMessageToWXResp.class])
    {
        BaseResp  *wxResp = (BaseResp *)resp;
        if(wxResp.errCode == 0)
        {
            //NSLog(@"微信分享成功");
            if(_fyjShareSuccess)
            {
                _fyjShareSuccess([FYJShare shared].shareContent);
            }
        }
        else
        {
            if(_fyjShareFaile)
            {
                if (wxResp.errCode == -2) {
                    _fyjShareFaile(@"取消分享");
                }else{
                    _fyjShareFaile(wxResp.errStr);
                }
            }
        }
    }
    else if([resp isKindOfClass:SendAuthResp.class])
    {
        SendAuthResp *wxResp = (SendAuthResp *)resp;
        if(wxResp.errCode == 0)
        {
            //NSLog(@"微信授权成功");
            [self wxGetOpenid:wxResp];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"授权失败" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alert show];
            if(_fyjAuthFail)
            {
                _fyjAuthFail(@"授权失败");
            }
        }
    }
    else
    {
        if((resp.type == ESENDMESSAGETOQQRESPTYPE) && [resp.result isEqualToString:@"0"])
        {
            //NSLog(@"QQ空间分享成功");
            if(_fyjShareSuccess)
            {
                _fyjShareSuccess([FYJShare shared].shareContent);
            }
        }
        else if(resp.type == ESENDMESSAGETOQQRESPTYPE)
        {
            if(_fyjShareFaile)
            {
                _fyjShareFaile(resp.errorDescription);
            }
        }
    }
}

/**
 处理QQ在线状态的回调
 */
- (void)isOnlineResponse:(NSDictionary *)response;
{
    NSLog(@"isOnlineResponse:  %@",response);
}
#pragma mark WeChat Http get
//通过code获取微信openid
-(void)wxGetOpenid:(SendAuthResp *)resp
{
   NSString *strFinalURL = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",wechatApikey,wechatSecret,resp.code];
    NSDictionary *dic = [self wxHttpRequest:strFinalURL];
    if([dic objectForKey:@"access_token"])
    {
        NSString *strOpenid = [dic objectForKey:@"openid"];
        NSString *accessToken = [dic objectForKey:@"access_token"];
        double expireDuration = [[dic objectForKey:@"expires_in"] doubleValue];
        NSString *refreshToken = [dic objectForKey:@"refresh_token"];
        NSDate *expireTime = [NSDate dateWithTimeInterval:expireDuration sinceDate:[NSDate date]];
        NSDictionary *dicDomain = [NSDictionary dictionaryWithObjectsAndKeys:
                                   strOpenid,kWeChatKeychainUserID,
                                   accessToken,kWeChatKeychainAccessToken,
                                   expireTime,kWeChatKeychainExpireTime,
                                   refreshToken,kWeChatKeychainRefreshToken, nil];
        [[NSUserDefaults standardUserDefaults] setObject:dicDomain forKey:kWeChatSDKOAuthDomain];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self wxUserInfo];
        
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"授权失败" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
        if(_fyjAuthFail)
        {
            _fyjAuthFail(@"授权失败");
        }
    }
}
//刷新微信用户token
-(void)wxRefreshToken
{
    NSDictionary *userStandDic = [[NSUserDefaults standardUserDefaults] objectForKey:kWeChatSDKOAuthDomain];
    NSString *refrshtoken = [userStandDic objectForKey:kWeChatKeychainRefreshToken];
    NSString *strFinalURL = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@",wechatApikey,refrshtoken];
    NSDictionary *dic = [self wxHttpRequest:strFinalURL];
    if([dic objectForKey:@"access_token"])
    {
        NSString *strOpenid = [dic objectForKey:@"openid"];
        NSString *accessToken = [dic objectForKey:@"access_token"];
        double expireDuration = [[dic objectForKey:@"expires_in"] doubleValue];
        NSString *refreshToken = [dic objectForKey:@"refresh_token"];
        NSDate *expireTime = [NSDate dateWithTimeInterval:expireDuration sinceDate:[NSDate date]];
        NSDictionary *dicDomain = [NSDictionary dictionaryWithObjectsAndKeys:
                                   strOpenid,kWeChatKeychainUserID,
                                   accessToken,kWeChatKeychainAccessToken,
                                   expireTime,kWeChatKeychainExpireTime,
                                   refreshToken,kWeChatKeychainRefreshToken, nil];
        [[NSUserDefaults standardUserDefaults] setObject:dicDomain forKey:kWeChatSDKOAuthDomain];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
    }
}
//获取微信用户信息
-(id)wxUserInfo
{
    NSDictionary *userStandDic = [[NSUserDefaults standardUserDefaults] objectForKey:kWeChatSDKOAuthDomain];
    NSString *userid = [userStandDic objectForKey:kWeChatKeychainUserID];
    NSString *accesstoken = [userStandDic objectForKey:kWeChatKeychainAccessToken];
    
    NSString *strFinalURL = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accesstoken,userid];
    NSDictionary *dic = [self wxHttpRequest:strFinalURL];
    if([dic objectForKey:@"openid"])
    {
        if(_fyjAuthSuccess)
        {
            NSString *avata = [dic objectForKey:@"headimgurl"];
            NSString *nick = [dic objectForKey:@"nickname"];
            
            NSString *openID = userid;
            NSString *accessToken = accesstoken;
            FYJShareData *da = [[FYJShareData alloc] init];
            da.nickName = nick;
            da.accessToken = accessToken;
            da.openID = openID;
            da.userPic = avata;
            da.thirdType = @"4";
            
            _fyjAuthSuccess(da);
        }
    }
    else
    {
        if(_fyjAuthFail)
        {
            _fyjAuthFail(@"获取用户信息失败");
        }
    }
    return dic;
}

-(id)wxHttpRequest:(NSString *)strUrl
{
    NSError *jsonErr;
    NSURL *url=[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    NSURLResponse *response=[[NSURLResponse alloc]init];
    NSError *err=[[NSError alloc]init];
    NSData *data;
    data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSDictionary *dicSinaUserInfo;
    if(data.length!=0)
    {
        dicSinaUserInfo=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonErr];
    }
    return dicSinaUserInfo;
}
@end
