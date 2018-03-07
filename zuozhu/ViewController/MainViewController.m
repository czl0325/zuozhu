//
//  MainViewController.m
//  zuozhu
//
//  Created by zhaoliang.chen on 13-7-29.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "MainViewController.h"
//#import "TilesView.h"
#import "DWExampleGridViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
//    tilesView = [[TilesView alloc]initWithFrame:CGRectMake(0, 0, self.view.height, self.view.width) withRow:4 withColumn:4];
//    [tilesView setupDatawithRow:4 withColumn:4];
//    [self.view addSubview:tilesView];
    
    //DWgrid = [[DWExampleGridViewController alloc]init];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


@end
