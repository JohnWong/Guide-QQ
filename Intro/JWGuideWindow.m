//
//  JWGuideWindow.m
//  Intro
//
//  Created by John Wong on 6/24/14.
//  Copyright (c) 2014 org.bupt.john. All rights reserved.
//

#import "JWGuideWindow.h"

#define CLOUD_FAR_TIME 150.0
#define CLOUD_NEAR_TIME 40.0

@interface JWGuideWindow()

@property (nonatomic, strong) UIImageView *earthView;
@property (nonatomic, strong) UIView *cloudFarView;
@property (nonatomic, strong) UIView *cloudNearView;
@property (nonatomic, assign) NSInteger step;
@property (nonatomic, strong) NSArray *angleArray;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat pauseTime;
@property (nonatomic, assign) CGFloat touchX;
@property (nonatomic, assign) NSInteger direction;
@property (nonatomic, assign) CGFloat stepDuration;
@property (nonatomic, assign) BOOL isAnimating;

@end

@implementation JWGuideWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.step = 0;
        self.offset = 0;
        self.backgroundColor = HEXCOLOR(0x47525C);
        [self addSubview:self.earthView];
        [self addSubview:self.cloudFarView];
        [self addSubview:self.cloudNearView];
        self.step = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startAnimation)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
        UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(doSwipe:)];
        swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeLeftRecognizer];
        UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(doSwipe:)];
        swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        
        
        [self addGestureRecognizer:swipeRightRecognizer];
    }
    return self;
}

-(NSArray*)angleArray
{
    if (!_angleArray) {
        _angleArray = @[
                        @[@{@"type": @"bg", @"from": @0, @"to": @0, @"duration": @0, @"begin": @0.0}],
                        @[@{@"type": @"bg", @"from": @0, @"to": @-M_PI, @"duration": @1.2, @"begin": @1.8}, @{@"type":@"move", @"property": @"transform.translation.x", @"start": @30, @"end":@240, @"begin": @0, @"duration": @1.8}],
                        @[@{@"type": @"bg", @"from": @-M_PI, @"to": @(M_PI * 112 / 180 - M_PI * 2), @"duration": @0.8, @"begin": @0.0}],
                        @[@{@"type": @"bg", @"from": @(M_PI * 112 / 180 - M_PI * 2), @"to": @(M_PI * 63 / 180 - M_PI * 2), @"duration": @0.8, @"begin": @0.0}]
                      ];
    }
    return _angleArray;
}

-(UIImageView*)earthView
{
    if (!_earthView) {
        _earthView = [[UIImageView alloc] initWithFrame:CGRectMake(-340, 150, 1000, 1000)];
        _earthView.image = [UIImage imageNamed:@"QQGuide_earth"];
    }
    return _earthView;
}

-(void)startAnimation
{
    [self startRotateAnimation:self.cloudFarView.layer.sublayers[0] withDuration:CLOUD_FAR_TIME];
    [self startRotateAnimation:self.cloudNearView.layer.sublayers[0] withDuration:CLOUD_NEAR_TIME];
}

-(void)startRotateAnimation:(CALayer*)layer withDuration:(CFTimeInterval)duration
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.fromValue=[NSNumber numberWithFloat:M_PI];
    animation.toValue=[NSNumber numberWithFloat:-M_PI];
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
    //执行时间
    animation.duration = duration;
    //执行次数
    animation.repeatCount=CGFLOAT_MAX;
    [layer addAnimation:animation forKey:@"rotation"];
}

-(void)pauseAnimation
{
    [self pauseLayer:self.earthView.layer];
    [self pauseLayer:self.cloudFarView.layer];
    [self pauseLayer:self.cloudNearView.layer];
}

-(void)resumeAnimation
{
    [self resumeLayer:self.cloudFarView.layer];
    [self resumeLayer:self.cloudNearView.layer];
    [self resumeLayer:self.earthView.layer];
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
    layer.beginTime = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

-(void)resumeLayerPartial:(CALayer*)layer time: (CGFloat)time
{
    layer.timeOffset = layer.beginTime + time;
}

-(void)resumeAnimationPartial:(CGFloat)time
{
    [self resumeLayerPartial:self.earthView.layer time:time];
    [self resumeLayerPartial:self.cloudFarView.layer time:time];
    [self resumeLayerPartial:self.cloudNearView.layer time:time];
}

-(UIView*)cloudFarView
{
    if (!_cloudFarView) {
        _cloudFarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"QQGuide_cloud1"]];
        _cloudFarView.frame = CGRectMake(-340, 150, 1000, 1000);
    }
    return _cloudFarView;
}

-(UIView*)cloudNearView
{
    if (!_cloudNearView) {
        _cloudNearView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"QQGuide_cloud2"]];
        _cloudNearView.frame = CGRectMake(-133.25, 356.75, 586.5, 586.5);
    }
    return _cloudNearView;
}

-(void)next
{
    if (self.step < 3) {
        self.step = self.step + 1;
        CGFloat from = [self.angleArray[self.step][0][@"from"] floatValue];
        CGFloat to = [self.angleArray[self.step][0][@"to"] floatValue];
        CGFloat duration = [self.angleArray[self.step][0][@"duration"] floatValue];
        
        CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.fromValue= [NSNumber numberWithFloat:from];
        animation.toValue= [NSNumber numberWithFloat:to];
        animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
        animation.duration = duration;
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        
        [self.earthView.layer addAnimation:animation forKey:@"rotation"];
        [self.cloudFarView.layer addAnimation:animation forKey:@"rotation"];
        [self.cloudNearView.layer addAnimation:animation forKey:@"rotation"];

//        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionOverrideInheritedOptions | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear animations:^{
//            CGAffineTransform transform = CGAffineTransformMakeRotation(to);
//            self.earthView.transform = transform;
//            self.cloudFarView.transform = transform;
//            self.cloudNearView.transform = transform;
//        } completion:^(BOOL finished) {
//        }];
    }
}

-(void)prev
{
    if (self.step > 0) {
        self.step = self.step - 1;
        CGFloat angle = [self.angleArray[self.step][0][@"angle"] floatValue];
        CGFloat time = [self.angleArray[self.step + 1][0][@"duration"] floatValue];
        [self pauseAnimation];
        
        
        [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionOverrideInheritedOptions | UIViewAnimationOptionBeginFromCurrentState animations:^{
            CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
            self.earthView.transform = transform;
            self.cloudFarView.transform = transform;
            self.cloudNearView.transform = transform;
        } completion:^(BOOL finished) {
            [self resumeAnimation];
        }];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)doSwipe:(UISwipeGestureRecognizer*)recognizer
{
//    if (self.direction == 0) {
//        switch (recognizer.direction) {
//            case UISwipeGestureRecognizerDirectionLeft:
//                [self next];
//                break;
//            case UISwipeGestureRecognizerDirectionRight:
//                [self prev];
//                break;
//            default:
//                break;
//        }
//    }
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"%d", flag);
    self.isAnimating = NO;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isAnimating) {
        return;
    }
    UITouch *touch = [touches anyObject];
    self.touchX = [touch locationInView:self].x;
    self.direction = 0;
    [self pauseAnimation];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isAnimating) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGFloat x = [touch locationInView:self].x;
    CGFloat progress = (x - self.touchX) / 160;
    if (progress >= 1.0) {
        // prev step
    } else if (progress <= -1.0) {
        // next step
        self.step ++;
        self.direction = 0;
        [self resumeAnimation];
    } else if (progress > 0){
        // prev
        if (self.direction != 1) {
            self.direction = 1;
        }
        
    } else {
        // next
        if (self.direction != 2) {
            self.direction = 2;
            // Add animation
            if (self.step < 3) {
                self.step = self.step + 1;
                CGFloat from = [self.angleArray[self.step][0][@"from"] floatValue];
                CGFloat to = [self.angleArray[self.step][0][@"to"] floatValue];
                CGFloat duration = [self.angleArray[self.step][0][@"duration"] floatValue];
                self.stepDuration = duration;
                
                CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
                animation.fromValue= [NSNumber numberWithFloat:from];
                animation.toValue= [NSNumber numberWithFloat:to];
                animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
                animation.duration = duration;
                animation.fillMode = kCAFillModeForwards;
                animation.removedOnCompletion = NO;
                animation.delegate = self;
                
                [self.earthView.layer addAnimation:animation forKey:@"rotation"];
                [self.cloudFarView.layer addAnimation:animation forKey:@"rotation"];
                [self.cloudNearView.layer addAnimation:animation forKey:@"rotation"];
            }
        } else {
            [self resumeAnimationPartial: - progress * self.stepDuration];
        }

        
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isAnimating) {
        return;
    }
    self.isAnimating = YES;
    [self resumeAnimation];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}
@end
