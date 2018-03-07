//
//  TDImageScrollView.m
//  TopDriver
//
//  Created by zhuang yihang on 9/5/13.
//  Copyright (c) 2013 FengKe. All rights reserved.
//

#import "TDImageScrollView.h"

@interface TDImageScrollView()<UIScrollViewDelegate>{
    UIScrollView *_scrollView;
    UIImageView *_tip;
}

@end

@implementation TDImageScrollView

@synthesize contentHeight;
@synthesize myImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = NO;
    }
    return self;
}

- (id)initWithImageUI:(UIImage*)image {
    self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noTip:) name:@"noTip" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tipSize:) name:@"tipSize" object:nil];
        myImage = image;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:_scrollView];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        UIImageView *imageV = [[UIImageView alloc] initWithImage:image];
        [_scrollView addSubview:imageV];
        
        _scrollView.width = self.width;
        _scrollView.left = 0;
        imageV.left = 0;
        _scrollView.contentSize = CGSizeMake(0, imageV.height);
        
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
        
        [_scrollView flashScrollIndicators];
        
        _tip = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page_scrollIndicator.png"]];
        [self addSubview:_tip];
        _tip.center = CGPointMake(imageV.width/2, 0);
        _tip.top = _scrollView.bottom+5;
        
        contentHeight = _scrollView.contentSize.height;
    }
    return self;
}

- (id)initWithParameter:(NSDictionary *)parameter{    
    float width = 0;
    float height = 0;
    NSString *x = [parameter objectForKey:@"x"];
    NSString *y = [parameter objectForKey:@"y"];
    
    NSString *imageName = [parameter objectForKey:@"image"];
    UIImage *image = getBundleImage(imageName);
    
    if ([parameter objectForKey:@"width"]) {
        width = [[parameter objectForKey:@"width"] floatValue];
    } else {
        width = image.size.width;
    }
    
    if ([parameter objectForKey:@"height"]) {
        height = [[parameter objectForKey:@"height"] floatValue];
    } else {
        height = image.size.height;
    }
    
    self  = [self initWithFrame:CGRectMake([x floatValue], [y floatValue], width, height)];
    if (self) {
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:_scrollView];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        UIImageView *imageV = [[UIImageView alloc] initWithImage:image];
        [_scrollView addSubview:imageV];
        
        
        self.width = imageV.width+5;
        _scrollView.width = self.width;
        _scrollView.left = 0;
        imageV.left = 0;
        _scrollView.contentSize = CGSizeMake(0, imageV.height);

        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
        
        [_scrollView flashScrollIndicators];
        
//        _tip = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page_scrollIndicator.png"]];
//        [self addSubview:_tip];
//        _tip.center = CGPointMake(imageV.width/2, 0);
//        _tip.top = _scrollView.bottom+5;

    }
    
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView.contentOffset.y + scrollView.height >= scrollView.contentSize.height) {
        
        [_tip setHidden:YES];
    }else
    {
        [_tip setHidden:NO];
    }
    
}

- (void)noTip:(NSNotification*)sender {
    return ;
    UIImage* image = (UIImage*)sender.object;
    if (image == myImage) {
        if (_tip) {
            [_tip removeFromSuperview];
            _tip = nil;
        }
    }
}

- (void)tipSize:(NSNotification*)sender {
    if ((UIImage*)sender.object == myImage) {
        if (_tip) {
            [_tip removeFromSuperview];
            _tip = nil;
        }
        _tip = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page_scrollIndicator.png"]];
        [self addSubview:_tip];
        _tip.center = CGPointMake(self.width/2, 0);
        _tip.top = self.bottom+5;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
