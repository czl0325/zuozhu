//
//  DetailScrollView.h
//  zuozhu
//
//  Created by zhaoliang.chen on 13-11-8.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDImageScrollView.h"

typedef enum{
    eContainerStatus_Init,
    eContainerStatus_Appear,
    eContainerStatus_Disappear,
    eContainerStatus_Release,
}eContainerStatus;

@interface DetailScrollView : UIView
<UIScrollViewDelegate>{
    UIImageView* _imgView1;
    UIImageView* _imgView2;
    UIButton* btCollect;
    
    UILabel* _cnLabel;
    UILabel* _jpLabel;
    UILabel* _enLabel;
    
    UIButton* btChina;
    UIButton* btJapan;
    UIButton* btEnglish;
    UIScrollView* _imgText;
    UIScrollView* _scroll1;
    NSMutableArray* _arrayScroll1;
    
    NSArray* _detailArray;
    NSDictionary* _detaildic;
    
    UIButton* btChina2;
    UIButton* btJapan2;
    UIButton* btEnglish2;
    UIScrollView* _imgText2;
    UIScrollView* _scroll2;
    NSMutableArray* _arrayScroll2;
    
    BOOL uiSetup_;
    UIScrollView* _picScrollView;
    
    BOOL isCollect;
    int lineType;
    int textDistance;
    
    UIImageView* _tip;
    int selectTag1;
    int selectTag2;
}

@property (nonatomic, assign) eContainerStatus status_;
@property (nonatomic, assign) int _seq;

- (id)initWithData:(CGRect)frame withNum:(int)seq;

@end
