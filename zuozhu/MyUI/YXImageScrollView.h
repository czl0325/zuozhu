//
//  YXImageScrollView.h
//  XieJin
//
//  Created by zyhang on 12/16/13.
//  Copyright (c) 2013 zyhang. All rights reserved.
//

#import "YXBaseView.h"


//照片集

@interface YXImageScrollView : YXBaseView {
    NSDictionary* config_;
    NSMutableArray* _imageArray;
}

- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated;

@end
