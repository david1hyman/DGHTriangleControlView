//
//  ViewController.m
//  TriangleController
//
//  Created by D Mac on 8/9/13.
//  Copyright (c) 2013 D Mac. All rights reserved.
//

#import "ViewController.h"

#import "DGHTriangleControlView.h"

@interface ViewController () <TriangleControlViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat size = self.view.frame.size.width/2.0f;
    CGFloat originX = (self.view.frame.size.width - size)/2.0f;
    CGFloat originY = (self.view.frame.size.height - size)/2.0f;
    CGRect frame = CGRectMake(originX, originY, size, size);
    DGHTriangleControlView *tcv = [DGHTriangleControlView triangleControlViewWithFrame:frame
                                                                    ballDiameter:20.0f
                                                                        delegate:self];
    
    tcv.roundedCorners = YES;
    tcv.strokeWidth = 5.0f;
    tcv.ballColor = [UIColor orangeColor];
    tcv.triangleBackgroundColor = [UIColor redColor];
    tcv.triangleStrokeColor = [UIColor purpleColor];
    tcv.showGuideShapes = YES;
    
    // target:action:
    [tcv addTarget:self action:@selector(triangleControlValueChanged:)];
    
    // block based listener
    [tcv setValueChangeListener:^(DGHTriangleControlView *traingleControlView) {
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }];
    
    [self.view addSubview:tcv];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)triangleControlValueChanged:(DGHTriangleControlView *)tcv {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - TriangleControl delegate

- (void)triangleControlViewDidChangePosition:(DGHTriangleControlView *)triangleControlView {
    NSLog(@"Top = %f", [triangleControlView valueForVertex:TriangleVertextTop]);
    NSLog(@"BottomLeft = %f", [triangleControlView valueForVertex:TriangleVertextBottomLeft]);
    NSLog(@"BottomRight = %f", [triangleControlView valueForVertex:TriangleVertextBottomRight]);
}

@end
