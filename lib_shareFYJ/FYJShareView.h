//
//  FYJShareView.h
//  weGame
//
//  Created by zy-iOS on 14/10/20.
//  Copyright (c) 2014年 BlueRain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class FYJShareView;
@protocol FYJShareViewDelegate <NSObject>

@required
- (void)fyjshareViewButton:(UIButton *)sender clickedAtindex:(NSInteger) index;

@end

@interface FYJShareView : UIView
@property (nonatomic,weak) id<FYJShareViewDelegate> delegate;

-(id)initWithArray:(NSArray *)sharetypeList withDelegate:(id<FYJShareViewDelegate>)vdelegate;
-(void)show;
@end
