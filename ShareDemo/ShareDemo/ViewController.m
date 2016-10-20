//
//  ViewController.m
//  ShareDemo
//
//  Created by BlueRain on 16/10/19.
//  Copyright © 2016年 BlueRain. All rights reserved.
//

#import "ViewController.h"
#import "FYJShare.h"
#import "FYJShareView.h"

@interface ViewController ()<FYJShareViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)actionShowShareView:(id)sender {
    
    
    //FYJShareView是一个单独显示分享按钮的view，可以自己修改实现。也可以直接使用。
    //实现FYJShareViewDelegate即可根据按钮类型调用FYJShare的接口分享到对应品台
    NSArray *arr = [FYJShareContent getShareListWithType:ThirdShareTypeQQSpace,ThirdShareTypeQQFriend,ThirdShareTypeWechatSession, nil];
    FYJShareView *shareView = [[FYJShareView alloc] initWithArray:arr withDelegate:self];
    [shareView show];
    //或者调用 -(void) FYJSharetypeList:(NSArray *)typeList withContent:(FYJShareContent *)cont success:(FYJShareSuccess)success failed:(FYJShareFaile)failure;直接显示分享视图，完成显示视图、分享的全部流程
    
    NSLog(@"显示分享视图FYJShareView");
}
- (IBAction)actionShareToQQ:(id)sender {
    
    //FYJShareContent的初始化请参照方法参数说明
    [[FYJShare shared] FYJShareInstance:ThirdShareTypeQQSpace withContent:nil success:^(FYJShareContent *content) {
        //
        NSLog(@"分享成功");
        
    } failed:^(NSString *failinfo) {
        NSLog(@"分享失败: %@",failinfo);
    }];
    NSLog(@"分享到qq空间");
}
- (IBAction)actionWechatAuth:(id)sender {
    
    [[FYJShare shared] FYJShareLogin:ThirdLoginTypeWeChat success:^(FYJShareData *userData) {
        
        NSLog(@"授权成功-> openid:%@,accesstoken:%@,昵称:%@头像:%@",userData.openID,userData.accessToken,userData.nickName,userData.userPic);
        
    } failed:^(NSString *failinfo) {
        NSLog(@"授权失败: %@",failinfo);
    }];
    NSLog(@"微信授权登录");
}

#pragma mark -FYJShareViewDelegate根据index。sender等可以判定在FYJShareView中点击的平台类型
- (void)fyjshareViewButton:(UIButton *)sender clickedAtindex:(NSInteger) index {
    //index对应FYJShareView中按钮的顺序
}
@end
