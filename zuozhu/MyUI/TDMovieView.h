//
//  TDMovieView.h
//  MyUIOne
//
//  Created by zhaoliang.chen on 13-11-1.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TDMovieView : UIView {
    MPMoviePlayerController *mp;
    NSString* movieURL;
    UIButton* btPlay;
}

- (id)initWithParameter:(NSDictionary *)parameter;

@end
