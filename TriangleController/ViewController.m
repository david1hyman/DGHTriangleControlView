//
//  ViewController.m
//  TriangleController
//
//  Created by D Mac on 8/9/13.
//  Copyright (c) 2013 D Mac. All rights reserved.
//

#import "ViewController.h"

#import "TriangleControlView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat size = 300.0f;
    CGFloat originX = (self.view.frame.size.width - size)/2.0f;
    TriangleControlView *tcv = [[TriangleControlView alloc] initWithFrame:CGRectMake(originX, 100.0f, size, size)];
    [self.view addSubview:tcv];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
