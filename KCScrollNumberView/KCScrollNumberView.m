//
//  KCScrollNumberView.m
//  KCScrollNumberView
//
//  Created by Fidetro on 2018/8/31.
//  Copyright © 2018年 Fidetro. All rights reserved.
//

#import "KCScrollNumberView.h"
static NSString *const kAniamtionKey = @"KCScrollNumberViewAniamtionKey";
static NSString *const kFallLayerName = @"kFallLayerName";
static NSString *const kAscendLayerName = @"kAscendLayerName";
static NSString *const kNormalLayerName = @"kNormalLayerName";
@interface KCScrollNumberView ()
@property (nonatomic, strong) NSMutableArray *numbersText;
@property (nonatomic, strong) NSMutableArray *lastNumbersText;
@property (nonatomic, strong) NSMutableArray *scrollLayers;
@property (nonatomic, strong) NSMutableArray *scrollLabels;
@property (nonatomic, strong) NSMutableArray *originLabels;
@property (nonatomic, strong) NSNumber *lastValue;
@property (nonatomic, assign) BOOL isCycle;
@property (nonatomic, assign) BOOL isStop;
@end
@implementation KCScrollNumberView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.duration = 0.1;
    self.minLength = 0;
    
    self.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    self.textColor = [UIColor blackColor];
    
    self.originLabels = [NSMutableArray new];
    self.numbersText = [NSMutableArray new];
    self.lastNumbersText = [NSMutableArray new];
    self.scrollLayers = [NSMutableArray new];
    self.scrollLabels = [NSMutableArray new];
    
}

- (void)setValue:(NSNumber *)value
{
    if (_value != nil)
    {
        self.lastValue = _value;
    }
    _value = value;
    
    [self prepareAnimations];
}

- (void)startAnimation
{
    self.isCycle = NO;
    self.isStop = NO;
    [self prepareAnimations];
    if (self.scrollType == KCScrollTypeQueue) {
        [self createSortAnimationsWithIndex:self.scrollLayers.count-1 scrollLayers:[self.scrollLayers mutableCopy]];
    }else{
        for (int i = 0; i<self.scrollLayers.count; i++) {
            @autoreleasepool {
                [self createSortAnimationsWithIndex:i scrollLayers:[self.scrollLayers mutableCopy]];
            }
        }
    }
}

- (void)randomCycleAnimation
{
    NSAssert(self.scrollType == KCScrollTypeSync,@"随机滚动，仅在 KCScrollTypeSync 滚动模式才有用");
    self.isStop = NO;
    self.isCycle = YES;
    [self prepareAnimations];
    for (int i = 0; i<self.scrollLayers.count; i++) {
        @autoreleasepool {
            [self createSortAnimationsWithIndex:i scrollLayers:[self.scrollLayers mutableCopy]];
        }
    }
}

- (void)unAnimation
{
    self.lastValue = self.value;
    [self startAnimation];
}

- (void)startAnimationAfterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(startAnimation) withObject:nil afterDelay:delay];
}
- (void)stopAnimation
{
    self.isStop = YES;
    for(CALayer *layer in self.scrollLayers){
        @autoreleasepool {
            [layer removeAnimationForKey:kAniamtionKey];
        }
    }
}

- (void)prepareAnimations
{
    for(CALayer *layer in self.scrollLayers) {
        @autoreleasepool {
            [layer removeFromSuperlayer];
        }
    }
    
    for (UILabel *label in self.originLabels) {
        @autoreleasepool {
            [label removeFromSuperview];
        }
    }
    
    [self.numbersText removeAllObjects];
    [self.lastNumbersText removeAllObjects];
    [self.scrollLayers removeAllObjects];
    [self.scrollLabels removeAllObjects];
    [self.originLabels removeAllObjects];
    [self createNumbersText];
    [self createScrollLayers];
}

- (void)createNumbersText
{
    NSString *textValue = [self.value stringValue];
    NSString *lastTextValue = [self.lastValue stringValue];
    for(NSInteger i = 0; i < (NSInteger)self.minLength - (NSInteger)[textValue length]; ++i) {
        @autoreleasepool {
            [self.numbersText addObject:@"0"];
        }
    }
    
    for(NSUInteger i = 0; i < [textValue length]; ++i) {
        @autoreleasepool {
            [self.numbersText addObject:[textValue substringWithRange:NSMakeRange(i, 1)]];
        }
    }
    
    for(NSUInteger i = 0; i < [lastTextValue length]; ++i) {
        @autoreleasepool {
            [self.lastNumbersText addObject:[lastTextValue substringWithRange:NSMakeRange(i, 1)]];
        }
    }
    for(NSUInteger i = [lastTextValue length]; i < self.numbersText.count; ++i) {
        @autoreleasepool {
            NSString *numString = [self.numbersText fa_objectAtIndexSafe:i];
            NSString *checkedNumString = [numString stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
            if ([checkedNumString length] > 0) {
                [self.lastNumbersText fa_insertObjectSafe:numString atIndex:0];
            } else {
                [self.lastNumbersText fa_insertObjectSafe:@"0" atIndex:0];
            }
        }
    }
}

- (void)createScrollLayers
{
    CGFloat width = roundf(CGRectGetWidth(self.frame) / self.numbersText.count);
    CGFloat height = CGRectGetHeight(self.frame);
    
    for(NSUInteger i = 0; i < self.numbersText.count; ++i) {
        @autoreleasepool {
            CAScrollLayer *layer = [CAScrollLayer layer];
            layer.frame = CGRectMake(roundf(i * width), 0, width, height);
            [self.scrollLayers addObject:layer];
            [self.layer addSublayer:layer];
        }
    }
    
    for(NSUInteger i = 0; i < self.numbersText.count; ++i) {
        @autoreleasepool {
            CAScrollLayer *layer = self.scrollLayers[i];
            NSString *numberText = self.numbersText[i];
            NSString *lastNumbersText = self.lastNumbersText[self.lastNumbersText.count-self.numbersText.count+i];
            [self createContentForLayer:layer withNumberText:numberText lastNumberText:lastNumbersText];
            UILabel *label = [[UILabel alloc] init];
            label.font = self.font;
            label.textColor = self.textColor;
            label.text = lastNumbersText;
            label.textAlignment = NSTextAlignmentCenter;
            [self.originLabels addObject:label];
            [self addSubview:label];
            label.frame = CGRectMake(roundf(i * width), 0, width, height);
        }
    }
}


- (void)createContentForLayer:(CAScrollLayer *)scrollLayer withNumberText:(NSString *)numberText lastNumberText:(NSString *)lastNumberText
{
    NSInteger number = [numberText integerValue];
    NSInteger lastNumber = [lastNumberText integerValue];
    NSMutableArray *textForScroll = [NSMutableArray new];
    
    if (number>lastNumber)
    {
        [textForScroll addObject:numberText];
        
        for(NSInteger i = number-1; i >= lastNumber; i--)
        {
            @autoreleasepool {
                [textForScroll addObject:[NSString stringWithFormat:@"%ld", i % 10]];
            }
        }
        scrollLayer.hidden = YES;
        scrollLayer.name = kFallLayerName;
    }else if (number<lastNumber)
    {
        for(NSInteger i = lastNumber;number<=i; i--)
        {
            @autoreleasepool {
                [textForScroll insertObject:[NSString stringWithFormat:@"%ld", i % 10] atIndex:0];
            }
        }
        
        scrollLayer.name = kFallLayerName;
        scrollLayer.hidden = YES;
    }else{
        [textForScroll addObject:numberText];
        scrollLayer.hidden = NO;
        scrollLayer.name = kNormalLayerName;
    }
    
    
    
    
    CGFloat height = 0;
    for(NSString *text in textForScroll) {
        @autoreleasepool {
            UILabel * textLabel = [self createLabel:text];
            textLabel.frame = CGRectMake(0, height, CGRectGetWidth(scrollLayer.frame), CGRectGetHeight(scrollLayer.frame));
            [scrollLayer addSublayer:textLabel.layer];
            [self.scrollLabels addObject:textLabel];
            height = CGRectGetMaxY(textLabel.frame);
        }
    }
}

- (UILabel *)createLabel:(NSString *)text
{
    UILabel *view = [UILabel new];
    view.textColor = self.textColor;
    view.font = self.font;
    view.textAlignment = NSTextAlignmentCenter;
    view.text = text;
    return view;
}

- (void)createSortAnimationsWithIndex:(NSInteger)index scrollLayers:(NSArray *)scrollLayers
{
    if (index < 0) {
        return;
    }
    UILabel *label =  self.originLabels[index];
    label.hidden = YES;
    CALayer *scrollLayer = scrollLayers[index];
    scrollLayer.hidden = NO;
    
    if ([scrollLayer.name isEqualToString:kNormalLayerName])
    {
        return;
    }
    
    CFTimeInterval duration = [scrollLayer.sublayers count] * self.duration;
    
    CGFloat maxY = [[scrollLayer.sublayers lastObject] frame].origin.y;
    [CATransaction begin];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.y"];
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    if ([scrollLayer.name isEqualToString:kAscendLayerName])
    {
        animation.fromValue = @0;
        animation.toValue = [NSNumber numberWithFloat:-maxY];
        //设置动画不还原
        animation.fillMode = @"forwards";
        animation.removedOnCompletion = NO;
    }else{
        animation.fromValue = [NSNumber numberWithFloat:-maxY];
        animation.toValue = @0;
    }
    __weak typeof(self) weakself = self;
    [CATransaction setCompletionBlock:^{
        if (self.scrollType == KCScrollTypeQueue)
        {
            [self createSortAnimationsWithIndex:index-1 scrollLayers:scrollLayers];
        }else
        {
            if (weakself.isCycle == YES)
            {
                [weakself createSortAnimationsWithIndex:index scrollLayers:scrollLayers];
            }
        }
    }];
    [scrollLayer addAnimation:animation forKey:kAniamtionKey];
    [CATransaction commit];
}

@end
