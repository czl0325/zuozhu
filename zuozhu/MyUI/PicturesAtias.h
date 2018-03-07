//
//  PicturesAtias.h
//  elle
//
//  Created by lufeng.lin on 1/11/13.
//  Copyright (c) 2013 zyhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXBaseView.h"

@interface PicturesAtias : YXBaseView<UIScrollViewDelegate>{
    UIScrollView *bottomScroll;
    int currentPage;
    UIScrollView *mainScroll;
    UIView *backView;
    NSMutableArray *clearImgNames;
    NSMutableArray *fuzzyImgNames;
    NSMutableArray *smallImgNames;
}

@property (nonatomic, retain) NSMutableArray *pictureElemArray;
@property (nonatomic, retain) NSMutableArray *smallViewArray;

-(void)setupInterface;
- (id)initWithParameter:(NSDictionary *)parameter;

@end
