//
//  FYJShareContent.m
//  weGame
//
//  Created by zy-iOS on 14/10/20.
//  Copyright (c) 2014年 BlueRain. All rights reserved.
//

#import "FYJShareContent.h"

static int MaxLength = 140;

@implementation FYJShareContent
- (instancetype) initWitContent:(NSString *)pContent title:(NSString *)pTitle thumbImage:(UIImage *)pThumbImage url:(NSString *)pUrl imageData:(NSData *)imgData
{
    self = [super init];
    if(self){
        self.content = [NSString string];
        self.title = [NSString string];
        self.thumbImgData = [NSData data];
        self.imgData = [NSData data];
        NSInteger length = pContent.length > MaxLength ? MaxLength :pContent.length;
        self.content = [pContent substringToIndex:length];
        self.title = pTitle;
        self.imgData = imgData;
        
        NSData *da = UIImageJPEGRepresentation(pThumbImage, 1.0);
        if(da.length > 32*1024)
        {
            UIImage *imgReScale = [self scaleToSizeimg:pThumbImage size:CGSizeMake(70, 70)];
            NSData *dddd = UIImageJPEGRepresentation(imgReScale, 1.0);
            if(dddd.length > 32*1024)
            {
                float bili = (float)32*1024/(float)dddd.length;
                NSData *finalyd = UIImageJPEGRepresentation(imgReScale, bili);
                self.thumbImgData = finalyd;
            }
            else
            {
                self.thumbImgData = dddd;
            }
        }
        else
        {
            self.thumbImgData = da;
        }
        if(!pUrl)
        {
            //如果url为nil则转换为qq消息时 分享不会跳转到qq客户端
            self.url = @"http://";
        }
        self.url = pUrl;
    }
    return self;
}

-(UIImage *)scaleToSizeimg:(UIImage *)img size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage  *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (NSArray *)getShareListWithType:(ThirdShareType)shareType, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray *array = [NSMutableArray array];
    ThirdShareType eachObject;
    va_list argmentList;
    if(shareType){
        [array addObject:@(shareType)];
        va_start(argmentList, shareType);
        while( (eachObject = va_arg(argmentList, ThirdShareType))){
            [array addObject:@(eachObject)];
        }
        va_end(argmentList);
    }
    return [array copy];
}
@end
