//
//  SmallImageView.m
//  elle
//
//  Created by lufeng.lin on 1/11/13.
//  Copyright (c) 2013 zyhang. All rights reserved.
//

#import "SmallImageView.h"

@implementation SmallImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithBigImageVIew:(CGRect)frame img:(UIImage *)image{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        sub = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, self.width-10, self.height-10)];
        sub.image = image;
        sub.userInteractionEnabled = YES;
        sub.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:sub];
    }
    return self;
}

-(void)showWhiteBlock{
    self.backgroundColor = [UIColor whiteColor];
}
-(void)hiddenWhiteBlock{
    self.backgroundColor = [UIColor clearColor];
}

-(void)dealloc{
}

@end
