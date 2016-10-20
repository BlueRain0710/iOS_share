//
//  FYJShareView.m
//  weGame
//
//  Created by zy-iOS on 14/10/20.
//  Copyright (c) 2014年 BlueRain. All rights reserved.
//

#import "FYJShareView.h"
# import "AppDelegate.h"
# import "FYJShareContent.h"

@interface FYJShareView(){
    UIControl *backgroundView;//背景蒙层
    UIView *containView;//底部分享按钮和取消按钮的容器
}
@property (nonatomic, strong,readonly) NSArray *array;
@end

# define CON_HEIGHT_MIN 165
# define SHARE_BUTTON_SIZE 60
# define SHARE_LABLE_HEIGHT 20
# define SHARE_TEXTRGB [UIColor colorWithRed:(0)/255.0 green:(0)/255.0 blue:(0)/255.0 alpha:1]/**文本颜色*/
# define SHARE_BACKRGB [UIColor colorWithRed:(247)/255.0 green:(246)/255.0 blue:(245)/255.0 alpha:1]/**背景颜色*/
# define DEVICE_WIDTH [UIScreen mainScreen].bounds.size.width

@implementation FYJShareView

-(id)initWithArray:(NSArray *)shareList withDelegate:(id<FYJShareViewDelegate>)vdelegate
{
    self = [self initWithFrame:[UIScreen mainScreen].bounds];
    if(self){
        _array = shareList;
        _delegate = vdelegate;
        containView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY([UIScreen mainScreen].bounds), DEVICE_WIDTH, CON_HEIGHT_MIN)];
        containView.backgroundColor = SHARE_BACKRGB;
        containView.alpha = 1.0;
        [self addSubview:containView];
        [self setTheShareButtons];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        backgroundView = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [backgroundView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        backgroundView.backgroundColor = [UIColor colorWithRed:59/255.0
                                                         green:59/255.0
                                                          blue:59/255.0
                                                         alpha:0.7];
        //backgroundView.alpha = 0;
        [self addSubview:backgroundView];
    }
    return self;
}

-(void)setTheShareButtons
{
    CGFloat width = DEVICE_WIDTH;
    CGFloat height = CON_HEIGHT_MIN;
    if(self.array.count >= 1)
    {
        height = (_array.count - 1)/3 * (SHARE_BUTTON_SIZE + SHARE_LABLE_HEIGHT) + height;
    }
    CGFloat space = (width - _array.count*SHARE_BUTTON_SIZE)/4;
    containView.frame = CGRectMake(0, CGRectGetMaxY([UIScreen mainScreen].bounds), DEVICE_WIDTH, height);
    
    int x,y;
    int i = 0;
    for (NSNumber *number in self.array) {
        NSInteger num = [number integerValue];
        x = i%3;
        y = i/3;
        
        UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(space + x*(SHARE_BUTTON_SIZE+space), 15 + y*(SHARE_BUTTON_SIZE + SHARE_LABLE_HEIGHT), SHARE_BUTTON_SIZE, SHARE_BUTTON_SIZE)];
        bt.tag = num;
        NSString *iconName = [self shareIconNameWith:[self.array[i] intValue]];
        [bt setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
        [bt addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        [containView addSubview:bt];
        
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(bt.frame.origin.x, CGRectGetMaxY(bt.frame), SHARE_BUTTON_SIZE, SHARE_LABLE_HEIGHT)];
        lb.backgroundColor = [UIColor clearColor];
        lb.font = [UIFont systemFontOfSize:11];
        lb.textColor = SHARE_TEXTRGB;
        lb.textAlignment = NSTextAlignmentCenter;
        NSString *titlBt = [self shareTitleNameWith:[self.array[i] intValue]];
        lb.text = titlBt;
        [containView addSubview:lb];
        //
        i++;
    }
    UIButton *btCance = [[UIButton alloc] initWithFrame:CGRectMake(0, containView.frame.size.height - 35, width+2, 36)];
    btCance.layer.borderWidth = 1.0;
    btCance.layer.borderColor = [[UIColor colorWithRed:229/255 green:229/255 blue:229/255 alpha:0.2] CGColor];
    [btCance setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btCance setTitle:@"取消" forState:UIControlStateNormal];
    [btCance addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [containView addSubview:btCance];
}

- (void)shareAction:(UIButton *)button
{
    if([self.delegate respondsToSelector:@selector(fyjshareViewButton:clickedAtindex:)]){
        [self.delegate fyjshareViewButton:button clickedAtindex:button.tag];
    }
    [self dismiss];
    
}

-(void)show
{
    self.alpha = 1.0;
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    [UIView animateWithDuration:0.1 animations:^{
        CGRect f = containView.frame;
        f.origin.y = CGRectGetMaxY([UIScreen mainScreen].bounds) - f.size.height;
        containView.frame = f;
    }];
}
- (void)dismiss
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        CGRect f = containView.frame;
        f.origin.y = CGRectGetMaxY([UIScreen mainScreen].bounds);
        containView.frame = f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
# pragma mark -
- (NSString *) shareTitleNameWith:(ThirdShareType)type
{
    switch (type) {
        case ThirdShareTypeSinaWeiBo:
            return  @"新浪微博";
            break;
        case ThirdShareTypeQQSpace:
            return  @"QQ空间";
            break;
        case ThirdShareTypeWechatSession:
            return  @"微信好友";
            break;
        case ThirdShareTypeWechatTimeline:
            return  @"微信朋友圈";
            break;
        case ThirdShareTypeQQFriend:
            return  @"QQ好友";
            break;
            
        default:
            break;
    }
    return nil;
}

- (NSString *) shareIconNameWith:(ThirdShareType)type
{
    switch (type) {
        case ThirdShareTypeSinaWeiBo:
            return  @"logo_sinaweibo";
            break;
        case ThirdShareTypeQQSpace:
            return  @"shareqqb";
            break;
        case ThirdShareTypeWechatSession:
            return  @"logo_wechat";
            break;
        case ThirdShareTypeWechatTimeline:
            return  @"logo_wechatmoments";
            break;
        case ThirdShareTypeQQFriend:
            return  @"shareqqb";
            break;
            
        default:
            break;
    }
    return nil;
}
@end
