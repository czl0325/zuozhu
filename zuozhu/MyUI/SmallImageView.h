//
//  SmallImageView.h
//  elle
//
//  Created by lufeng.lin on 1/11/13.
//  Copyright (c) 2013 zyhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmallImageView : UIView{
    UIView *whiteBlock;
    UIImageView *sub;
}
-(id)initWithBigImageVIew:(CGRect)frame img:(UIImage *)image;
-(void)showWhiteBlock;
-(void)hiddenWhiteBlock;
@end
