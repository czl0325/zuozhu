//
//  TDPerspective.h
//  TopDriver
//
//  Created by yanseng.lin on 10/31/13.
//  Copyright (c) 2013 FengKe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXBaseView.h"

@interface TDPerspective : YXBaseView {
    BOOL isupdown;
    NSDictionary* _parameter;
}

@property (nonatomic,strong) UIView *sliderView;

@property (nonatomic,assign) float sliderPosition;

- (void)setSliderPosition:(float)sliderPosition animated:(BOOL)animated;


@end
