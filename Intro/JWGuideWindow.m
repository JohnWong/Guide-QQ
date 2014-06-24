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
@property (nonatomic, strong) UIImageView *cloudFarView;
@property (nonatomic, strong) UIImageView *cloudNearView;
@property (nonatomic, assign) NSInteger step;
@property (nonatomic, strong) NSArray *angleArray;
@property (nonatomic, assign) CGFloat offset;

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
        
    }
    return self;
}

-(NSArray*)angleArray
{
    if (!_angleArray) {
        _angleArray = @[
                        @[@0.0, @1.0],
                        @[@M_PI, @1.0],
                        @[@(M_PI*116/180), @1.0],
                        @[@(M_PI*64/180), @1.0]];
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
    cloudFarAnimation.duration = CLOUD_FAR_TIME;
    //执行次数
    cloudFarAnimation.repeatCount=CGFLOAT_MAX;
    [self.cloudFarView.layer addAnimation:cloudFarAnimation forKey:@"change"];
    
    CABasicAnimation *cloudNearAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    cloudNearAnimation.fromValue=[NSNumber numberWithFloat:M_PI];
    cloudNearAnimation.toValue=[NSNumber numberWithFloat:-M_PI];
    //执行时间
    cloudNearAnimation.duration = CLOUD_NEAR_TIME;
    //执行次数
    cloudNearAnimation.repeatCount=CGFLOAT_MAX;
    [self.cloudNearView.layer addAnimation:cloudNearAnimation forKey:@"change"];
}

-(void)pauseAnimation
{
    [self pauseLayer:self.cloudFarView.layer];
//    [self pauseLayer:self.cloudNearView.layer];
}

-(void)resumeAnimation
{
    [self resumeLayer:self.cloudFarView.layer];
//    [self resumeLayer:self.cloudNearView.layer];
}

-(void)resumeLayer:(CALayer*)layer
{
    CGFloat time = [self.angleArray[self.step][1] floatValue];
    CGFloat angle = [self.angleArray[self.step][0] floatValue];
    
    layer.speed = 1.0;
    CFTimeInterval currentTime = CACurrentMediaTime();
    layer.beginTime = currentTime;
    layer.timeOffset = currentTime + time * (angle / M_2_PI - 1) * 1;
    NSLog(@"johnwong: %f %f", currentTime + time * (angle / M_2_PI - 1) * 1, self.offset);
    
}

-(void)pauseLayer:(CALayer*)layer
{
    CGFloat time = [self.angleArray[self.step][1] floatValue];
    CGFloat angle = [self.angleArray[self.step][0] floatValue];
    
    layer.speed = angle / M_2_PI;
    CFTimeInterval currentTime = CACurrentMediaTime();
    layer.beginTime = currentTime;
    layer.timeOffset = currentTime + self.offset;
    self.offset += time * (angle / M_2_PI - 1);
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
        CGFloat angle = [self.angleArray[self.step][0] floatValue];
        CGFloat time = [self.angleArray[self.step][1] floatValue];
        [self pauseAnimation];
        [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionOverrideInheritedOptions | UIViewAnimationOptionBeginFromCurrentState animations:^{
            CGAffineTransform earthTransform = CGAffineTransformMakeRotation(angle);
            self.earthView.transform = earthTransform;
        } completion:^(BOOL finished) {
            [self resumeAnimation];
        }];
    }
}

-(void)prev
{
    if (self.step > 0) {
        [self pauseAnimation];
        self.step = self.step - 1;
        CGFloat angle = [self.angleArray[self.step][0] floatValue];
        CGFloat time = [self.angleArray[self.step][1] floatValue];
        [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionOverrideInheritedOptions | UIViewAnimationOptionBeginFromCurrentState animations:^{
            CGAffineTransform earthTransform = CGAffineTransformMakeRotation(angle);
            self.earthView.transform = earthTransform;
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
