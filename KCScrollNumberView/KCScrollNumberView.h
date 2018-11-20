//
//  KCScrollNumberView.h
//  KCScrollNumberView
//
//  Created by Fidetro on 2018/8/31.
//  Copyright © 2018年 Fidetro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KCScrollNumberView : UIView
/** 最后显示的值 **/
@property (nonatomic, strong) NSNumber *value;
/** 文本颜色 **/
@property (nonatomic, strong) UIColor *textColor;
/** 字体大小 **/
@property (nonatomic, strong) UIFont *font;
/** 动画持续时间 **/
@property (nonatomic, assign) CFTimeInterval duration;
/** 最小展示位数,不足补零 **/
@property (nonatomic, assign) NSUInteger minLength;
/** 开始执行动画 **/
- (void)startAnimation;
/** 结束执行动画 **/
- (void)stopAnimation;
/** 延迟delay秒执行动画 **/
- (void)startAnimationAfterDelay:(NSTimeInterval)delay;
/** 只改变数字，不执行动画 **/
- (void)unAnimation;
@end
