//
//  YXBaseView.m
//  zuozhu
//
//  Created by zhaoliang.chen on 13-12-16.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "YXBaseView.h"

@implementation YXBaseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithParameter:(NSDictionary*)dic {
    self = [self init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)getOldRect:(NSDictionary *)parameter {
    oldRect = CGRectMake([[parameter objectForKey:@"oldX"]floatValue], [[parameter objectForKey:@"oldY"]floatValue], [[parameter objectForKey:@"oldW"]floatValue], [[parameter objectForKey:@"oldH"]floatValue]);
}

-(void)removeSelf {
    if (self) {
        [self removeFromSuperview];
    }
}

@end
