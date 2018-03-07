//
//  TDPerspective.m
//  TopDriver
//
//  Created by yanseng.lin on 10/31/13.
//  Copyright (c) 2013 FengKe. All rights reserved.
//

#import "TDPerspective.h"
#import <QuartzCore/QuartzCore.h>

#define SLIDE_ANIMATION_DURATION 0.2

@interface TDPerspective ()
@property (nonatomic,assign) BOOL isSliderTouched;
@property (nonatomic,strong) UIImageView *leftImageView;
@property (nonatomic,strong) UIImageView *rightImageView;
@end

@implementation TDPerspective

- (id)initWithParameter:(NSDictionary *)parameter{
    _parameter = parameter;
    NSString *car1str = [parameter objectForKey:@"car1"];
    NSString *car2str = [parameter objectForKey:@"car2"];
    UIImage *leftImage = getBundleImage(car1str);
    UIImage *rightImage = getBundleImage(car2str);
    NSString *isupdownstr = [parameter objectForKey:@"isupdown"];
    if ([isupdownstr isEqualToString:@"1"]) {
        isupdown=YES;
    } else {
        isupdown=NO;
    }
    if (self) {
        self = [super initWithFrame:CGRectMake(0, 0, 1024, 768)];
        [self getOldRect:parameter];

        _leftImageView = [[UIImageView alloc] initWithFrame:oldRect];
        if (isupdown==YES) {
            _leftImageView.contentMode = UIViewContentModeLeft;
        } else {
            _leftImageView.contentMode = UIViewContentModeTop;
        }
        _leftImageView.clipsToBounds = YES;
        _leftImageView.image = leftImage;
        
        _rightImageView = [[UIImageView alloc] initWithFrame:oldRect];
        if (isupdown==YES) {
            _rightImageView.contentMode = UIViewContentModeRight;
        } else {
            _rightImageView.contentMode = UIViewContentModeBottom;
        }
        _rightImageView.image = rightImage;
        _rightImageView.clipsToBounds = YES;
            
        [self addSubview:_leftImageView];
        [self addSubview:_rightImageView];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onBig)];
        
        _leftImageView.frame = self.bounds;
        _rightImageView.frame = self.bounds;
        
        [UIView commitAnimations];
    }
    return self;
}

- (void)onBig {
    NSString *sliderstr = [_parameter objectForKey:@"slider"];
    UIImage *sliderimage = getBundleImage(sliderstr);
    UIImageView *slider = [[UIImageView alloc] initWithImage:sliderimage];
    
    if (isupdown==YES) {
        self.sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, slider.frame.size.width, self.frame.size.height)];
        [self.sliderView addSubview:slider];
        self.sliderView.contentMode = UIViewContentModeCenter;
        self.sliderPosition = self.centerX;
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 4, self.frame.size.height)];
        line.centerX = self.sliderView.width/2;
        [self.sliderView addSubview:line];
        NSString *colorRstr = [_parameter objectForKey:@"linecolorR"];
        NSString *colorGstr = [_parameter objectForKey:@"linecolorG"];
        NSString *colorBstr = [_parameter objectForKey:@"linecolorB"];
        float R=[colorRstr floatValue];
        float G=[colorGstr floatValue];
        float B=[colorBstr floatValue];
        line.backgroundColor = [UIColor colorWithRed:R green:G blue:B alpha:1.0];
        slider.center = CGPointMake(slider.center.x, self.sliderView.center.y);
    }
    else
    {
        self.sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, slider.frame.size.height)];
        [self.sliderView addSubview:slider];
        self.sliderView.contentMode = UIViewContentModeCenter;
        self.sliderPosition = self.centerY;
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 4)];
        line.backgroundColor = [UIColor whiteColor];
        line.centerY = self.sliderView.height/2;
        [self.sliderView addSubview:line];
        NSString *colorRstr = [_parameter objectForKey:@"linecolorR"];
        NSString *colorGstr = [_parameter objectForKey:@"linecolorG"];
        NSString *colorBstr = [_parameter objectForKey:@"linecolorB"];
        float R=[colorRstr floatValue];
        float G=[colorGstr floatValue];
        float B=[colorBstr floatValue];
        line.backgroundColor = [UIColor colorWithRed:R green:G blue:B alpha:1.0];
        slider.center = CGPointMake(self.sliderView.center.x, slider.center.y);
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSliderView:(UIView *)sliderView
{
    [_sliderView removeFromSuperview];
    
    _sliderView = sliderView;
    _sliderView.left = 0;
    _sliderView.top = 0;
    
    [self addSubview:_sliderView];
}

- (void)setSliderPosition:(float)sliderPosition animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:SLIDE_ANIMATION_DURATION delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.sliderPosition = sliderPosition;
        } completion:nil];
        
    } else {
        self.sliderPosition = sliderPosition;
    }
}

- (void)setSliderPosition:(float)sliderPosition
{
    if (isupdown==YES) {
        if ((sliderPosition < self.frame.size.width) && (sliderPosition > self.bounds.origin.x)) {
            _sliderPosition = sliderPosition;
            
            if (self.sliderView) {
                self.sliderView.center = CGPointMake(sliderPosition, self.sliderView.center.y);
            }
            
            CGRect leftImageRect = self.leftImageView.frame;
            leftImageRect.size.width = sliderPosition;
            self.leftImageView.frame = leftImageRect;
            
            CGRect rightImageRect = self.rightImageView.frame;
            rightImageRect.origin.x = sliderPosition;
            rightImageRect.size.width = self.frame.size.width - sliderPosition;
            self.rightImageView.frame = rightImageRect;
            
        }
    }
    else
    {
        if ((sliderPosition < self.frame.size.height) && (sliderPosition > self.bounds.origin.y)) {
            _sliderPosition = sliderPosition;
            
            if (self.sliderView) {
                self.sliderView.center = CGPointMake(self.sliderView.center.x, sliderPosition);
            }
            
            CGRect leftImageRect = self.leftImageView.frame;
            leftImageRect.size.height = sliderPosition;
            self.leftImageView.frame = leftImageRect;
            
            CGRect rightImageRect = self.rightImageView.frame;
            rightImageRect.origin.y = sliderPosition;
            rightImageRect.size.height = self.frame.size.height - sliderPosition;
            self.rightImageView.frame = rightImageRect;
            
        }
    }
}
- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPoint = [touch locationInView:self.sliderView];
    
    if (CGRectContainsPoint(self.sliderView.bounds, currentPoint)) {
        self.isSliderTouched = YES;
    }
    
    if ([touch tapCount] ==2) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(removeSelf)];
        
        _leftImageView.frame = oldRect;
        _rightImageView.frame = oldRect;
        
        [UIView commitAnimations];
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isSliderTouched) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"enable_scroll" object:[NSNumber numberWithBool:NO]];
        UITouch *touch = [touches anyObject];
        
        CGPoint currentPoint = [touch locationInView:self];
        if (isupdown==YES) {
            if (currentPoint.x >= self.sliderView.bounds.size.width/2 && currentPoint.x <= self.bounds.size.width - self.sliderView.bounds.size.width/2) {
                self.sliderPosition = currentPoint.x;
            }
        }
        else
        {
            if (currentPoint.y >= self.sliderView.bounds.size.height/2 && currentPoint.y <= self.bounds.size.height - self.sliderView.bounds.size.height/2) {
                self.sliderPosition = currentPoint.y;
            }
        }
        
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"enable_scroll" object:[NSNumber numberWithBool:YES]];
    if (self.isSliderTouched == NO) {
        
        UITouch *touch = [touches anyObject];
        
        CGPoint currentPoint = [touch locationInView:self];
        if (isupdown==YES) {
            [self setSliderPosition:currentPoint.x animated:YES];
        }
        else
        {
            [self setSliderPosition:currentPoint.y animated:YES];
        }
    }
    
    self.isSliderTouched = NO;
}

@end
