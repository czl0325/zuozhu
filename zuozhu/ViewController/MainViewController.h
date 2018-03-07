//
//  MainViewController.h
//  zuozhu
//
//  Created by zhaoliang.chen on 13-7-29.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class TilesView;
@class DWExampleGridViewController;
@interface MainViewController : UIViewController {
    TilesView *tilesView;
    DWExampleGridViewController * DWgrid;
}

@end
