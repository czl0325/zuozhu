//
//  TDMovieView.m
//  MyUIOne
//
//  Created by zhaoliang.chen on 13-11-1.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "TDMovieView.h"

@implementation TDMovieView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithParameter:(NSDictionary *)parameter {
    btPlay = getButtonByImageName(@"tv_play.png");
    self = [self initWithFrame:CGRectMake([[parameter objectForKey:@"x"]floatValue], [[parameter objectForKey:@"y"]floatValue], btPlay.width, btPlay.height)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        movieURL = [parameter objectForKey:@"url"];
        [btPlay addTarget:self action:@selector(autoplay) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btPlay];
    }
    return self;
}

- (void)onTap:(UITapGestureRecognizer*)sender {
    [self autoplay];
}

- (void)autoplay{
    if (mp) {
        [mp.view removeFromSuperview];
        mp = nil;
    }
    NSString* path = [[NSBundle mainBundle]pathForResource:movieURL ofType:nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"错误信息" message:@"视频文件不存在" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    btPlay.hidden = YES;
    
    NSURL *url = [NSURL fileURLWithPath:path];
    mp =  [[MPMoviePlayerController alloc] initWithContentURL:url];
    mp.controlStyle = MPMovieControlStyleDefault;
    [mp prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerLoadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doneButtonClick:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
}

- (void) moviePlayerLoadStateChanged:(NSNotification*)notification {
	if ([mp loadState] != MPMovieLoadStateUnknown) {
        [[NSNotificationCenter 	defaultCenter]
         removeObserver:self
         name:MPMoviePlayerLoadStateDidChangeNotification
         object:nil];
        
		[[mp view] setFrame:self.bounds];
        [mp view].top = 0;
        [mp view].left = 0;
        
        [self addSubview:[mp view]];
        [mp setFullscreen:YES];
        
		[mp play];
	}
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [mp setFullscreen:NO];
}

- (void)doneButtonClick:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [self performSelectorOnMainThread:@selector(releaseMP) withObject:nil waitUntilDone:YES];
}

- (void)releaseMP {
    if (mp) {
        [mp stop];
        [mp.view removeFromSuperview];
        mp = nil;
        btPlay.hidden = NO;
    }
}

- (void)dealloc {
    [self releaseMP];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
