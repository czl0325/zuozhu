//
//  BaseBigImageView.m
//  XieJin
//
//  Created by zhaoliang.chen on 13-12-6.
//  Copyright (c) 2013年 zyhang. All rights reserved.
//

#import "BaseBigImageView.h"

@implementation BaseBigImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithParameter:(NSDictionary *)parameter {
    self = [self initWithFrame:CGRectMake(0, 0, 1024, 768)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _bgview = [[UIView alloc]initWithFrame:self.bounds];
        _bgview.backgroundColor = [UIColor whiteColor];
        _bgview.alpha = 0.0f;
        [self addSubview:_bgview];
        
        //点击手势
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [tapRecognizer setDelegate:self];
        [_bgview addGestureRecognizer:tapRecognizer];
        
        [self getOldRect:parameter];
        _bigImageView = [[UIImageView alloc]initWithFrame:oldRect];
        
        UIImage* bigImg = getBundleImage([parameter objectForKey:@"bigimage"]);
        if (!bigImg) {
            return self;
        }
        _bigImageView.image = bigImg;
        _bigImageView.alpha = 0.0f;
        
        float radio = _bigImageView.image.size.width/_bigImageView.image.size.height;
        float w,h;
        if (_bigImageView.image.size.width>=_bigImageView.image.size.height) {
            if ([parameter objectForKey:@"noFit"]) {
                if (_bigImageView.image.size.width >= 1024) {
                    w = _bgview.width;
                } else {
                    w = _bigImageView.image.size.width;
                }
            } else {
                w = 1024;
            }
            h = w/radio;
        } else {
            if ([parameter objectForKey:@"noFit"]) {
                if (_bigImageView.image.size.height >= 768) {
                    h = _bgview.height;
                } else {
                    h = _bigImageView.image.size.height;
                }
            } else {
                h = 768;
            }
            w = h*radio;
        }
        [self addSubview:_bigImageView];
        _bigImageView.userInteractionEnabled = YES;
        //添加手势响应
        //点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [tapRecognizer setDelegate:self];
        [_bigImageView addGestureRecognizer:tap];
        //缩放手势
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
        [pinchRecognizer setDelegate:self];
        [_bigImageView addGestureRecognizer:pinchRecognizer];
//        //旋转手势
        //UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
        //[rotationRecognizer setDelegate:self];
        //[_bigImageView addGestureRecognizer:rotationRecognizer];
        //平移手势
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:2];
        [panRecognizer setDelegate:self];
        [_bigImageView addGestureRecognizer:panRecognizer];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onBig)];
        
        _bgview.alpha = MYALPHA;
        _bigImageView.alpha = 1.0f;
        _bigImageView.frame = CGRectMake(_bgview.width/2-w/2, _bgview.height/2-h/2, w, h);
        
        [UIView commitAnimations];
    }
    return self;
}

- (void)onBig {
    
}

-(void)tap:(id)sender {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeSelf)];
    
    _bigImageView.frame = oldRect;
    _bgview.alpha = 0.0f;
    
    [UIView commitAnimations];
}

-(void)scale:(id)sender {
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        lastScale = 1.0;
        totalScale_ = 0.0;
    }
    
    if ([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        CGFloat scale = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
        
        totalScale_ += (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
        
        CGAffineTransform currentTransform = _bigImageView.transform;
        //Scale的仿射变换，只改变缩放比例，其他仿射变换底下会说
        CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
        [_bigImageView setTransform:newTransform];
        lastScale = [(UIPinchGestureRecognizer*)sender scale];
        
    }
    
    if ([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        if (totalScale_>0.0) {
            [UIView animateWithDuration:0.2 animations:^(){
                [_bigImageView setTransform:CGAffineTransformIdentity];
                totalScale_ = 0.0;
            }];
        }
    }
}


-(void)rotate:(id)sender {
    if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        currentRotate = 0;
    }
    
    if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        currentRotate += lastRotate;
        
        lastRotate = 0.0;
        
        [UIView animateWithDuration:0.3 animations:^(){
            CGAffineTransform currentTransform = _bigImageView.transform;;
            CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,-currentRotate);
            [_bigImageView setTransform:newTransform];
            currentRotate = 0;
        }];
        
        return;
    }
    
    CGFloat rotation = 0.0 - (lastRotate - [(UIRotationGestureRecognizer*)sender rotation]);
    //设定旋转的仿射变换
    CGAffineTransform currentTransform = _bigImageView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
    [_bigImageView setTransform:newTransform];
    lastRotate = [(UIRotationGestureRecognizer*)sender rotation];
}

-(void)move:(id)sender {
    //这里记录图片中心点坐标，不是通过改变frame来位移
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self];
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        lastX = [_bigImageView center].x;
        lastY = [_bigImageView center].y;
    }
    
    translatedPoint = CGPointMake(lastX+translatedPoint.x, lastY+translatedPoint.y);
    [_bigImageView setCenter:translatedPoint];
}

//returen YES,这样才可以让多手势并存，否则只会相应一种手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


@end
