//
//  TDImageScrollView.h
//  TopDriver
//
//  Created by zhuang yihang on 9/5/13.
//  Copyright (c) 2013 FengKe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDImageScrollView : UIView

- (id)initWithParameter:(NSDictionary *)parameter;
- (id)initWithImageUI:(UIImage*)image;

@property(nonatomic,assign)float contentHeight;
@property(nonatomic,strong)UIImage* myImage;

@end
