//
//  PictureElem.h
//  elle
//
//  Created by lufeng.lin on 1/17/13.
//  Copyright (c) 2013 zyhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureElem : UIImageView{
    NSString *clear;
    NSString *fuzzy;
}

- (id)initWithClear:(CGRect)frame image:(NSString *)strClear;
- (id)initWithClear:(NSString *)strClear withFuzzy:(NSString *)strFuzzy;

-(void)loadClearImg;
-(void)replaceThumbImg;
@end
