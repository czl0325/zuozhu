//
//  TDRotateView.h
//  text
//
//  Created by yanseng.lin on 10/31/13.
//  Copyright (c) 2013 yanseng.lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXBaseView.h"
@interface TDRotateView : YXBaseView
{
    NSString *prefix;
	int numberOfImages;
	int current;
	int previous;
	NSString *extension;
	int increment;
    UIImageView *imageview;
    int distance;
    CGRect newRect;
}
@property (readwrite) int increment;
@property (readwrite, copy) NSString *extension;
@property (readwrite, copy) NSString *prefix;
@property (readwrite) int numberOfImages;

- (id)initWithParameter:(NSDictionary *)parameter;

@end
