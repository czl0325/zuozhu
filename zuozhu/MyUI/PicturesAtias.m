//
//  PicturesAtias.m
//  elle
//
//  Created by lufeng.lin on 1/11/13.
//  Copyright (c) 2013 zyhang. All rights reserved.
//

#import "PicturesAtias.h"
#import "SmallImageView.h"
#import "PictureElem.h"

@implementation PicturesAtias
@synthesize pictureElemArray;
@synthesize smallViewArray;

#define SMALLHEIGHT 180

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithParameter:(NSDictionary *)parameter {
    self = [super initWithFrame:CGRectMake(0, 0, 1024, 768)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        currentPage = 0;
        [self getOldRect:parameter];
        
        backView = [[UIView alloc]initWithFrame:self.bounds];
        backView.backgroundColor = [UIColor colorWithRed:182/255.0 green:182/255.0 blue:182/255.0 alpha:1.0f];
        backView.clipsToBounds = YES;
        [self addSubview:backView];
        
        int total = [[parameter objectForKey:@"image_num"]intValue];
        clearImgNames = [NSMutableArray new];
        smallImgNames = [NSMutableArray new];
        for (int i=0; i<total; i++) {
            NSString* big = [NSString stringWithFormat:[parameter objectForKey:@"image_prefix"],i+1];
            [clearImgNames addObject:big];
            if ([parameter objectForKey:@"smalls"]) {
                NSString* small = [NSString stringWithFormat:[parameter objectForKey:@"smalls"],i+1];;
                [smallImgNames addObject:small];
            } else {
                [smallImgNames addObject:big];
            }
        }
        self.clipsToBounds = YES;
        self.smallViewArray = [NSMutableArray array];
        self.pictureElemArray = [NSMutableArray array];
        mainScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height-SMALLHEIGHT)];
        mainScroll.pagingEnabled = YES;
        mainScroll.backgroundColor = [UIColor clearColor];
        mainScroll.contentSize = CGSizeMake(self.width*clearImgNames.count, self.height-SMALLHEIGHT);
        mainScroll.delegate = self;
        [backView addSubview:mainScroll];
        
        [self setupInterface];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClose:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

-(void)tap:(UITapGestureRecognizer *)recognizer{
    for (int i=0; i<self.smallViewArray.count; i++) {
        SmallImageView *s = [self.smallViewArray objectAtIndex:i];
        if (i == recognizer.view.tag) {
            [s showWhiteBlock];
        }else{
            [s hiddenWhiteBlock];
        }
    }
    currentPage = recognizer.view.tag;
    mainScroll.contentOffset = CGPointMake(mainScroll.width*currentPage, 0);
    [self loadPictureElemResource:mainScroll];
}

-(void)setupInterface{
    for (int i=0; i<clearImgNames.count; i++) {
        NSString *fileClear = [clearImgNames objectAtIndex:i];
        PictureElem *p = [[PictureElem alloc]initWithClear:mainScroll.bounds image:fileClear];
        p.left = i*p.width;
        [self.pictureElemArray addObject:p];
//        if (i==0) {
//            [p loadClearImg];
//        }else{
//            [p replaceThumbImg];
//        }
        [mainScroll addSubview:p];
    }
    
    bottomScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.height-SMALLHEIGHT, self.width, SMALLHEIGHT)];
    bottomScroll.backgroundColor = [UIColor colorWithRed:182/255.0 green:182/255.0 blue:182/255.0 alpha:1.0f];//[UIColor colorWithRed:215.0/255.0 green:226.0/255.0 blue:232.0/255.0 alpha:1.0];
    bottomScroll.showsHorizontalScrollIndicator = NO;
    bottomScroll.userInteractionEnabled = YES;
    [backView addSubview:bottomScroll];
    
    for (int i=0; i<smallImgNames.count; i++) {
        NSString *file = [smallImgNames objectAtIndex:i];
        SmallImageView *imgVSmall = [[SmallImageView alloc]initWithBigImageVIew:CGRectMake(i*SMALLHEIGHT, 0, SMALLHEIGHT, SMALLHEIGHT) img:getBundleImage(file)];
        imgVSmall.userInteractionEnabled = YES;
        imgVSmall.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [imgVSmall addGestureRecognizer:tap];
        [self.smallViewArray addObject:imgVSmall];
        if (i==0) {
            [imgVSmall showWhiteBlock];
        }
        [bottomScroll addSubview:imgVSmall];
        bottomScroll.contentSize = CGSizeMake(imgVSmall.right, bottomScroll.height);
    }
    
    [self loadPictureElemResource:bottomScroll];
    
    backView.frame = oldRect;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    
    backView.frame = self.bounds;
    
    [UIView commitAnimations];
}

- (void)loadPictureElemResource:(UIScrollView *)scrollView{
    int page = scrollView.contentOffset.x/scrollView.width;
    
    int idx = 0;
    for (PictureElem *p in self.pictureElemArray) {
        if (idx == page || idx == page-1 || idx == page+1) {
            [p loadClearImg];
        }else{
            [p replaceThumbImg];
        }
        idx++;
    }
}

#pragma mark - UIScrollVIewDelegate
-(void)scrollViewDidScroll:(UIScrollView*)scrollView{
    if (scrollView == mainScroll) {
        if (currentPage == (int)scrollView.contentOffset.x/scrollView.width) {
            return;
        }
        
        currentPage = scrollView.contentOffset.x/scrollView.width;
        for (int i=0; i<self.smallViewArray.count; i++) {
            SmallImageView *s = [self.smallViewArray objectAtIndex:i];
            if (i == currentPage) {
                [s showWhiteBlock];
            }else{
                [s hiddenWhiteBlock];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        
        if (scrollView == mainScroll) {
            [self loadPictureElemResource:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView == mainScroll) {
        [self loadPictureElemResource:scrollView];
        
        currentPage = scrollView.contentOffset.x/scrollView.width;
        SmallImageView *s = [self.smallViewArray objectAtIndex:currentPage];
        float offset = bottomScroll.contentOffset.x;
        if (s.screenViewX>=1024) {
            [bottomScroll setContentOffset:CGPointMake(s.screenViewX-1024+s.width+offset, 0) animated:YES];
        } else if (s.screenViewX<=0) {
            [bottomScroll setContentOffset:CGPointMake(offset-fabs(s.screenViewX), 0) animated:YES];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    if (scrollView == mainScroll) {
        [self loadPictureElemResource:scrollView];
    }
}

- (void)onClose:(UITapGestureRecognizer*)sender {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeSelf)];
    
    backView.frame = oldRect;
    
    [UIView commitAnimations];
}

-(void)dealloc{
    for (SmallImageView *v  in self.smallViewArray) {
        [v removeFromSuperview];
    }
    self.smallViewArray = nil;
    self.pictureElemArray = nil;
}

@end
