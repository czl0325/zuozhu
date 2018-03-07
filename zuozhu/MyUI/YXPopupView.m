//
//  YXPopupView.m
//  zuozhu
//
//  Created by zyhang on 2/17/14.
//  Copyright (c) 2014 zhaoliang.chen. All rights reserved.
//

#import "YXPopupView.h"

@implementation YXPopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithParameter:(NSDictionary*)dic{
    
    config_ = dic;
    NSString *buttonImage = [dic objectForKey:@"button"];
    UIImage *img = getBundleImage(buttonImage);
    
    float x = [[dic objectForKey:@"x"] floatValue];
    float y = [[dic objectForKey:@"y"] floatValue];
    
    self = [self initWithFrame:CGRectMake(x, y, img.size.width, img.size.height)];
    if (self) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.frame = CGRectMake(0, 0, img.size.width, img.size.height);
        [self addSubview:b];
        [b setImage:img forState:UIControlStateNormal];
        [b addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        button_ = b;
    }
    
    
    return self;
}

- (void)click{
    if (popup_) {
    }else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideLeftView" object:nil];
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        v.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [v addGestureRecognizer:tap];
        
        UIImageView *bg = getImageViewByImageName([config_ objectForKey:@"background"]);
        [v addSubview:bg];
        bg.userInteractionEnabled = YES;
        bg.center = CGPointMake(v.width/2+10, v.height/2);
        
        NSString *imgName = [config_ objectForKey:@"content"];
        if (imgName!=nil&& imgName.length>0) {
            UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 10, bg.width, bg.height-20)];
            UIImageView *content = getImageViewByImageName(imgName);
            [scroll addSubview:content];
            content.center= CGPointMake(scroll.width/2, 0);
            content.top = 0;
            content.left = 10;
            scroll.contentSize = CGSizeMake(content.width, content.height+20);
            [bg addSubview:scroll];
            scroll.center = CGPointMake(bg.width/2, bg.height/2);
        }


        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFullScreenView"
                                                            object:v];
        
        popup_ = v;
            popup_.alpha = 0;
        [UIView animateWithDuration:0.2 animations:^(){
            button_.transform = CGAffineTransformMakeRotation(M_PI_2);
            
        } completion:^(BOOL finish){
            [UIView animateWithDuration:0.2 animations:^(){
                popup_.alpha = 1;
                
            }];
            
        }];
        
    }
}

- (void)tap{
    [UIView animateWithDuration:0.2 animations:^(){
        
        popup_.alpha = 0;
    } completion:^(BOOL finish){
        
        [UIView animateWithDuration:0.2 animations:^(){
            
            button_.transform = CGAffineTransformMakeRotation(0);
        }];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideFullScreenView"
                                                            object:nil];
        
        [popup_ removeFromSuperview];
        popup_ = nil;
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
