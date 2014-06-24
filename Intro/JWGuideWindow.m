//
//  JWGuideWindow.m
//  Intro
//
//  Created by John Wong on 6/24/14.
//  Copyright (c) 2014 org.bupt.john. All rights reserved.
//

#import "JWGuideWindow.h"

@interface JWGuideWindow()

@property (nonatomic, strong) UIImageView *earthView;
@property (nonatomic, strong) UIImageView *cloudFarView;
@property (nonatomic, strong) UIImageView *cloudNearView;
@property (nonatomic, assign) NSInteger step;
@property (nonatomic, strong) NSArray *angleArray;
//@property (nonatomic, assign) BOOL isAnimation;

@end

@implementation JWGuideWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.isAnimation = NO;
        self.step = 0;
        self.backgroundColor = HEXCOLOR(0x47525C);
        [self addSubview:self.earthView];
        [self addSubview:self.cloudFarView];
        [self addSubview:self.cloudNearView];
        self.step = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startAnimation)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
        
    }
    return self;
}

-(NSArray*)angleArray
{
    if (!_angleArray) {
        _angleArray = @[@0, @M_PI, @(M_PI*116/180), @(M_PI*64/180)];
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
    CABasicAnimation *cloudFarAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    cloudFarAnimation.fromValue=[NSNumber numberWithFloat:M_PI];
    cloudFarAnimation.toValue=[NSNumber numberWithFloat:-M_PI];
    //执行时间
    cloudFarAnimation.duration = 150.0;
    //执行次数
    cloudFarAnimation.repeatCount=CGFLOAT_MAX;
    [self.cloudFarView.layer addAnimation:cloudFarAnimation forKey:@"change"];
    
    CABasicAnimation *cloudNearAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    cloudNearAnimation.fromValue=[NSNumber numberWithFloat:M_PI];
    cloudNearAnimation.toValue=[NSNumber numberWithFloat:-M_PI];
    //执行时间
    cloudNearAnimation.duration = 40.0;
    //执行次数
    cloudNearAnimation.repeatCount=CGFLOAT_MAX;
    [self.cloudNearView.layer addAnimation:cloudNearAnimation forKey:@"change"];
}

-(void)pauseAnimation
{
    [self pauseLayer:self.cloudFarView.layer];
    [self pauseLayer:self.cloudNearView.layer];
}

-(void)resumeAnimation
{
    [self resumeLayer:self.cloudFarView.layer];
    [self resumeLayer:self.cloudNearView.layer];
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

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(UIImageView*)cloudFarView
{
    if (!_cloudFarView) {
        _cloudFarView = [[UIImageView alloc] initWithFrame:CGRectMake(-340, 150, 1000, 1000)];
        _cloudFarView.image = [UIImage imageNamed:@"QQGuide_cloud1"];
        
    }
    return _cloudFarView;
}

-(UIImageView*)cloudNearView
{
    if (!_cloudNearView) {
        _cloudNearView = [[UIImageView alloc] initWithFrame:CGRectMake(-133.25, 356.75, 586.5, 586.5)];
        _cloudNearView.image = [UIImage imageNamed:@"QQGuide_cloud2"];
    }
    return _cloudNearView;
}

-(void)next
{
    if (self.step < 3) {
        CGAffineTransform transform = self.cloudFarView.transform;
        NSLog(@"johnwong: %f %f %f %f %f %f", transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);
        self.step = self.step + 1;
//        [self pauseAnimation];
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionOverrideInheritedOptions | UIViewAnimationOptionBeginFromCurrentState animations:^{
            CGAffineTransform earthTransform = CGAffineTransformMakeRotation([self.angleArray[self.step] floatValue]);
            self.earthView.transform = earthTransform;
//            self.cloudFarView.transform = earthTransform;
//            self.cloudNearView.transform = earthTransform;
        } completion:^(BOOL finished) {
//            [self resumeAnimation];
        }];
    }
}

-(void)prev
{
    if (self.step > 0) {
        [self pauseAnimation];
        self.step = self.step - 1;
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionOverrideInheritedOptions | UIViewAnimationOptionBeginFromCurrentState animations:^{
            CGAffineTransform earthTransform = CGAffineTransformMakeRotation([self.angleArray[self.step] floatValue]);
            self.earthView.transform = earthTransform;
//            self.cloudFarView.transform = earthTransform;
//            self.cloudNearView.transform = earthTransform;
        } completion:^(BOOL finished) {
            [self resumeAnimation];
        }];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
