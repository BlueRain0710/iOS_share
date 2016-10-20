分享到微信，qq，新浪这三个平台的代码集成。
===
适应项目需求，仅包含分享和登录授权功能，所以远没有那些大公司夹带的一大堆乱七八糟的东西，使用简单方便，快速。视图独立，可以自己根据项目需求迅速修改。
==
源码说明：
FYJShare包含向第三方平台注册，授权，分享，取消授权等方法。
FYJShareContent为封装的微信，qq，新浪内容类型，统一出来，方便在FYJShare直接使用。
FYJShareView为独立出来的显示分享按钮的视图，方便针对项目显示风格做出修改。
==
使用说明：
根据第三方平台接入介绍，填写对应appKey，包含对应框架。
1.向第三方平台注册
#warning    要填写第三方平台分配的对应值
    [FYJShare regestSina:@"" andApiSecert:@"" andRedirectURL:@"http"];
    [FYJShare regestWeChat:@"" andApiSecert:@""];
    [FYJShare regestTencentOauth:@"" andApiSecert:@""];
2.对应app相互调用的回调
   [FYJShare FYJHandleOpenURL:url];
在appDelegate下列方法中使用
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FYJShare FYJHandleOpenURL:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    return [FYJShare FYJHandleOpenURL:url];
}

3.登录授权
    [[FYJShare shared] FYJShareLogin:ThirdLoginTypeWeChat success:^(FYJShareData *userData) {
        
        NSLog(@"授权成功-> openid:%@,accesstoken:%@,昵称:%@头像:%@",userData.openID,userData.accessToken,userData.nickName,userData.userPic);
        
    } failed:^(NSString *failinfo) {
        NSLog(@"授权失败: %@",failinfo);
    }];
4.不显示视图直接分享到指定的一个平台：例如qq空间
    [[FYJShare shared] FYJShareInstance:ThirdShareTypeQQSpace withContent:nil success:^(FYJShareContent *content) {
        //
        NSLog(@"分享成功");
        
    } failed:^(NSString *failinfo) {
        NSLog(@"分享失败: %@",failinfo);
    }];
5，显示分享视图，分享到显示的分享列表中用户选择的某一个平台
    NSArray *arr = [FYJShareContent getShareListWithType:ThirdShareTypeQQSpace,ThirdShareTypeQQFriend,ThirdShareTypeWechatSession, nil];
    FYJShareContent *content = [[FYJShareContent alloc] initWitContent:@"分享内容正文" title:@"标题" thumbImage:[UIImage imageNamed:@""] url:@"https://github.com/BlueRain0710/iOS" imageData:nil];
    [[FYJShare shared] FYJSharetypeList:arr withContent:content success:^(FYJShareContent *content) {
        NSLog(@"分享成功");
    } failed:^(NSString *failinfo) {
        NSLog(@"分享失败: %@",failinfo);
    }];
