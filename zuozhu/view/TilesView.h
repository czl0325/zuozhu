//
//  TilesView.h
//  Test
//
//  Created by zhuang yihang on 5/5/13.
//  Copyright (c) 2013 yx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol TilesViewDelegate <NSObject>

- (void)tileClicked:(UIView *)view;

@end

@interface TilesView : UIView{
    
}

- (id)initWithFrame:(CGRect)frame withRow:(int)row withColumn:(int)column;

- (void)setupDatawithRow:(int)row withColumn:(int)column;

@end
