//
//  PictureElem.m
//  elle
//
//  Created by lufeng.lin on 1/17/13.
//  Copyright (c) 2013 zyhang. All rights reserved.
//

#import "PictureElem.h"

@implementation PictureElem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (id)initWithClear:(CGRect)frame image:(NSString *)strClear {
    clear = strClear;
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}


- (id)initWithClear:(NSString *)strClear withFuzzy:(NSString *)strFuzzy
{
    clear = strClear;
    fuzzy = strFuzzy;
    UIImageView *v = getImageViewByImageName(strClear);
    if (v.height > 768) {
        float b = v.height/768;
        float c = v.width/b;
        v.frame = CGRectMake(0, 0, 1024, c);
    }
    self = [super initWithFrame:v.frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)loadClearImg{
    if (self.image==nil) {
        UIImage *img = getBundleImage(clear);
        self.image = img;
    }
    
}

-(void)replaceThumbImg{
    //UIImage *img = getBundleImage(fuzzy);
    self.image = nil;
}

@end
