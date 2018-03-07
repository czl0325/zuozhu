//
//  TDRotateView.m
//  text
//
//  Created by yanseng.lin on 10/31/13.
//  Copyright (c) 2013 yanseng.lin. All rights reserved.
//

#import "TDRotateView.h"

@implementation TDRotateView

@synthesize prefix, numberOfImages, extension, increment;

- (id)initWithParameter:(NSDictionary *)parameter{
//    NSString *imagecenterx = [parameter objectForKey:@"imagecenterx"];
//    NSString *imagecentery = [parameter objectForKey:@"imagecentery"];
    [self getOldRect:parameter];
    self.userInteractionEnabled = YES;
    NSString *str = [parameter objectForKey:@"increment"];
    increment = [str intValue];
    if ([parameter objectForKey:@"distance"]) {
        distance = [[parameter objectForKey:@"distance"]intValue];
    } else {
        distance = 0;
    }
    NSString *imagecount = [parameter objectForKey:@"imagecount"];
    NSString *imagestr = [parameter objectForKey:@"image"];
    UIImage *img = getBundleImage(imagestr);
    
    self = [super initWithFrame:CGRectMake(0, 0, 1024, 768)];
    
    _bgview = [[UIView alloc]initWithFrame:self.bounds];
    _bgview.backgroundColor = [UIColor whiteColor];
    _bgview.alpha = MYALPHA;
    [self addSubview:_bgview];
    
    imageview = [[UIImageView alloc]initWithImage:img];
    imageview.userInteractionEnabled  = YES;
    if (img.size.width>1024) {
        imageview.size = CGSizeMake(1024, 768);
        imageview.contentMode = UIViewContentModeScaleAspectFit;
    }
    imageview.center = CGPointMake(self.width/2, self.height/2);
    [self addSubview:imageview];
    
    newRect = imageview.frame;
    
    [self setExtension:[parameter objectForKey:@"type"]];
    
	//Set slide prefix prefix
    NSString *imagenamestr = [parameter objectForKey:@"imagename"];
	[self setPrefix:imagenamestr];
	
	//Set number of slides
	[self setNumberOfImages:[imagecount intValue]];
    
    if (self) {
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeself)];
        [self addGestureRecognizer:tap];
        
        _bgview.alpha = 0.0f;
        imageview.frame = oldRect;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onBig)];
        
        _bgview.alpha = MYALPHA;
        imageview.frame = newRect;
        
        [UIView commitAnimations];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    for (UIView* upv in self.subviews) {
        [upv removeFromSuperview];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if (point.x>=imageview.left&&point.x<imageview.right&&point.y>=imageview.top&&point.y<imageview.bottom) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"enable_scroll" object:[NSNumber numberWithBool:NO]];
        return YES;
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"enable_scroll" object:[NSNumber numberWithBool:YES]];
        return NO;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesBegan:touches withEvent:event];
	
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
	
	previous = touchLocation.x;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
	
    if (touchLocation.x>=imageview.left&&touchLocation.x<imageview.right&&touchLocation.y>=imageview.top&&touchLocation.y<imageview.bottom) {
        int location = touchLocation.x;
        
        if(location < (previous-distance)) {
            current += increment;
            previous = location;
        }
        else if (location > (previous+distance)) {
            current -= increment;
            previous = location;
        }        
        
        if(current > numberOfImages)
            current = 1;
        if(current < 1)
            current = numberOfImages;
        
        NSString *imagename = [NSString stringWithFormat:@"%@%d.%@", prefix, current, extension];
        UIImage *img = getBundleImage(imagename);
        [imageview setImage:img];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)removeself {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeMe)];
    
    _bgview.alpha = 0.0f;
    imageview.frame = oldRect;
    
    [UIView commitAnimations];
}

- (void)removeMe {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"enable_scroll" object:[NSNumber numberWithBool:YES]];
    if (self) {
        [self removeFromSuperview];
    }
}

@end
