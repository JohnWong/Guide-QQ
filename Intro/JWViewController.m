//
//  JWViewController.m
//  Intro
//
//  Created by John Wong on 6/24/14.
//  Copyright (c) 2014 org.bupt.john. All rights reserved.
//

#import "JWViewController.h"
#import "JWGuideWindow.h"

@interface JWViewController ()

@property (nonatomic, strong) JWGuideWindow* guideWindow;
@property (nonatomic, strong) UIPageControl* pageControl;

@end

@implementation JWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self.view addSubview:self.guideWindow];
    [self.view addSubview:self.pageControl];
    
    // Bind gesture
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(doSwipe:)];
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeftRecognizer];
    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(doSwipe:)];
    swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRightRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doSwipe:(UISwipeGestureRecognizer*)recognizer
{
    switch (recognizer.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            [self.guideWindow next];
            break;
        case UISwipeGestureRecognizerDirectionRight:
            [self.guideWindow prev];
            break;
        default:
            break;
    }
}

-(JWGuideWindow*)guideWindow
{
    if (!_guideWindow) {
        _guideWindow = [[JWGuideWindow alloc]initWithFrame:self.view.bounds];
    }
    return _guideWindow;
}

-(UIPageControl*)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.height - 20 - 16, 320, 20)];
        _pageControl.numberOfPages = 4;
        _pageControl.currentPage = 0;
    }
    return _pageControl;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.guideWindow startAnimation];
}

@end
