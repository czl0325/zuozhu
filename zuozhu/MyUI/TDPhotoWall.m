//
//  TDPhotoWall.m
//  MyUIOne
//
//  Created by zhaoliang.chen on 13-11-1.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "TDPhotoWall.h"

@implementation TDPhotoWall

#define IMGTAG  1000

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isBig = NO;
        isChange = NO;
        isBigPic = NO;
    }
    return self;
}

- (id)initWithParameter:(NSDictionary *)parameter {
    NSDictionary* dicScroll = [parameter objectForKey:@"scrollview"];
    if ([dicScroll objectForKey:@"width"]) {
        self = [self initWithFrame:CGRectMake([[dicScroll objectForKey:@"x"]floatValue], [[dicScroll objectForKey:@"y"]floatValue], [[dicScroll objectForKey:@"width"]floatValue], [[dicScroll objectForKey:@"height"]floatValue])];
    } else {
        self = [self initWithFrame:CGRectMake(0,0,1024,768)];
    }
    if (self) {
        self.contentSize = CGSizeZero;
        self.bounces = NO;
        self.userInteractionEnabled = YES;
        
        subArray = [NSMutableArray array];
        
        // Initialization code
        picArray = [parameter objectForKey:@"picarray"];
        
        self.bounces = NO;
        self.userInteractionEnabled = YES;
        
        rope = createImageViewByImage([parameter objectForKey:@"rope"]);
        rope.left = 0;
        rope.top = [[parameter objectForKey:@"ropeY"]floatValue];
        [self addSubview:rope];
        
        for (int i=0; i<picArray.count; i++) {
            NSDictionary* dic = [picArray objectAtIndex:i];
            UIImageView* v = createImageViewByImage([dic objectForKey:@"pic"]);
            v.left = [[dic objectForKey:@"x"]floatValue];
            v.top = [[dic objectForKey:@"y"]floatValue];
            NSString* w = [dic objectForKey:@"w"];
            NSString* h = [dic objectForKey:@"h"];
            if (w!=nil) {
                v.width = [w floatValue];
                v.height = [h floatValue];
            }
            v.userInteractionEnabled = YES;
            v.tag = IMGTAG+i;
            if ([dic objectForKey:@"angle"]) {
                v.transform = CGAffineTransformMakeRotation([[dic objectForKey:@"angle"]floatValue]/180*M_PI);
            }
            [self addSubview:v];
            UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
            [v addGestureRecognizer:panRecognizer];
            panRecognizer.maximumNumberOfTouches = 1;
            panRecognizer.delegate = self;
            UITapGestureRecognizer  *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
            [v addGestureRecognizer:tap];
            
            int z = [[dic objectForKey:@"z"] intValue];
            if (z<0) {
                [subArray addObject:v];
            }
        }
        
        clip = createImageViewByImage([parameter objectForKey:@"clip"]);
        clip.left = [[parameter objectForKey:@"clipX"]floatValue];
        clip.top = [[parameter objectForKey:@"clipY"]floatValue];
        [self addSubview:clip];

        
        self.contentSize = CGSizeMake(rope.right,self.height);
    }
    return self;
}

#pragma mark -UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    if (isChange) {
        return;
    }
    CGPoint location = [recognizer locationInView:self];
    UIImageView* imgView = (UIImageView*)recognizer.view;
    if (imgView != m_ImageView && m_ImageView) {
        return ;
    }
    [self bringSubviewToFront:imgView];
    
    if(recognizer.state == UIGestureRecognizerStateBegan){
        m_ImageView = imgView;
        NSDictionary* dic = [picArray objectAtIndex:imgView.tag-IMGTAG];
        if ([dic objectForKey:@"angle"]) {
            m_ImageView.transform = CGAffineTransformMakeRotation(0);
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        m_ImageView.alpha = 0.4;
        m_ImageView.centerX = location.x;//+self.contentOffset.x;
        m_ImageView.centerY = location.y;
    } else if(recognizer.state == UIGestureRecognizerStateEnded) {
        isChange = YES;
        if (!isBig) {
            self.scrollEnabled = NO;
            NSDictionary* dic = [picArray objectAtIndex:imgView.tag-IMGTAG];
            UIImage* img = getBundleImage([dic objectForKey:@"pic"]);
            
            if (!m_ImageView) {
                m_ImageView = imgView;
                NSDictionary* dic = [picArray objectAtIndex:imgView.tag-IMGTAG];
                if ([dic objectForKey:@"angle"]) {
                    m_ImageView.transform = CGAffineTransformMakeRotation(0);
                }
            }
            m_ImageView.height =  (700.0/m_ImageView.width)*img.size.height;
            m_ImageView.width = 700;
            m_ImageView = [self adjustSize:imgView];
            m_ImageView.centerX = self.contentOffset.x+location.x;
            m_ImageView.centerY = location.y;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop)];
            m_ImageView.centerX = self.contentOffset.x+self.width/2;
            m_ImageView.centerY = self.height/2;
            [UIView commitAnimations];
        } else {
            self.scrollEnabled = NO;
            NSDictionary* dic = [picArray objectAtIndex:m_ImageView.tag-IMGTAG];
            CGRect rc;
            NSString* w = [dic objectForKey:@"w"];
            NSString* h = [dic objectForKey:@"h"];
            if (w!=nil) {
                rc = CGRectMake([[dic objectForKey:@"x"]floatValue], [[dic objectForKey:@"y"]floatValue], [w floatValue], [h floatValue]);
            } else {
                UIImage* img = getBundleImage([dic objectForKey:@"pic"]);
                rc = CGRectMake([[dic objectForKey:@"x"]floatValue], [[dic objectForKey:@"y"]floatValue], img.size.width, img.size.height);
            }
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.4];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(onRestore)];
            m_ImageView.frame = rc;
            [UIView commitAnimations];
        }
    }
}

-(void)animationDidStop{
    m_ImageView.alpha = 1;
    NSDictionary* dic = [picArray objectAtIndex:m_ImageView.tag-IMGTAG];
    if ([dic objectForKey:@"bigpic"]) {
        m_ImageView.image = getBundleImage([dic objectForKey:@"bigpic"]);
        isBigPic = YES;
    }
    [self bringSubviewToFront:m_ImageView];
    isBig = YES;
    isChange = NO;
}

-(void)tap:(UITapGestureRecognizer*)recognizer{
    if (isChange || !isBig) {
        return;
    }
    UIImageView* imgView = (UIImageView*)recognizer.view;
    if (imgView != m_ImageView && m_ImageView) {
        return ;
    }
    isChange = YES;
    NSDictionary* dic = [picArray objectAtIndex:imgView.tag-IMGTAG];
    if (!m_ImageView) {
        m_ImageView = imgView;
    }
    CGRect rc;
    NSString* w = [dic objectForKey:@"w"];
    NSString* h = [dic objectForKey:@"h"];
    if (w!=nil) {
        rc = CGRectMake([[dic objectForKey:@"x"]floatValue], [[dic objectForKey:@"y"]floatValue], [w floatValue], [h floatValue]);
    } else {
        UIImage* img = getBundleImage([dic objectForKey:@"pic"]);
        rc = CGRectMake([[dic objectForKey:@"x"]floatValue], [[dic objectForKey:@"y"]floatValue], img.size.width, img.size.height);
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(onRestore)];
    imgView.frame = rc;
    [UIView commitAnimations];
}

- (void)onRestore {
    m_ImageView.alpha = 1;
    self.scrollEnabled = YES;
    NSDictionary* dic = [picArray objectAtIndex:m_ImageView.tag-IMGTAG];
    if (isBigPic) {
        m_ImageView.image = getBundleImage([dic objectForKey:@"pic"]);
    }
    isBigPic = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(onRotateStop)];
    if ([dic objectForKey:@"angle"]) {
        m_ImageView.transform = CGAffineTransformMakeRotation([[dic objectForKey:@"angle"]floatValue]/180*M_PI);
    }
    [UIView commitAnimations];
}

- (void)onRotateStop {
    isBig = NO;
    isChange = NO;
    [self sendSubviewToBack:m_ImageView];
    for (UIView *v in subArray) {
        [self sendSubviewToBack:v];
    }
    [self sendSubviewToBack:rope];
    m_ImageView = nil;
}

- (UIImageView*)adjustSize:(UIImageView*)imageView {
    float radio = imageView.width/imageView.height;
    if (imageView.width>self.width) {
        imageView.width = self.width-100;
        imageView.height = imageView.width/radio;
        if (imageView.height>self.height) {
            imageView.height = self.height-100;
            imageView.width = imageView.height*radio;
        }
    } else if (imageView.height>self.height) {
        imageView.height = self.height-100;
        imageView.width = imageView.height*radio;
        if (imageView.width>self.width) {
            imageView.width = self.width-100;
            imageView.height = imageView.width/radio;
        }
    }
    return imageView;
}

@end
