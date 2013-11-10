//
//  TriangleControlView.h
//  TriangleController
//
//  Created by D Mac on 8/9/13.
//  Copyright (c) 2013 D Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TriangleVertextTop,
    TriangleVertextBottomLeft,
    TriangleVertextBottomRight,
} TriangleVertext;

@class DGHTriangleControlView;

typedef void(^ValueChangeListener)(DGHTriangleControlView *traingleControlView);

@protocol TriangleControlViewDelegate <NSObject>

- (void)triangleControlViewDidChangePosition:(DGHTriangleControlView *)triangleControlView;

@end

@interface DGHTriangleControlView : UIView

// ================================
//                *
//               * *
//              *   *
//             *     *
//            *   *   *
//           *   ***   *
//          *     *     *
//         *             *
//        * * * * * * * * *
// ================================

/*
 Draws and equilateral triangle (centered in the frame) and a control ball.
 The triangle sides will = frame.size.width.
 The ballDiameter must be < frame.size.width/2.
 
 // Getting the values - 3 great ways!
 1) Implement the protocol
 2) setValueChangeListener:
 3) setTarget:action:
 TriangleControlView will pass self to all of these methods.
 In each method call -[TriangleControlView valueForVertex:] to retrieve the control values.
 Control values are from 0-1.
 
 Set showGuideShapes = YES to get some visual feedback about what's going on.
 It shows the inset triangle that limits the path of the ball.
 Also, if you drag outside of the inset triangle, it shows
 the line to the triangle center that is used to
 calculate the touch point.
*/

+ (DGHTriangleControlView *)triangleControlViewWithFrame:(CGRect)frame
                                         ballDiameter:(CGFloat)ballDiameter
                                             delegate:(id<TriangleControlViewDelegate>)delegate;

- (float)valueForVertex:(TriangleVertext)vertex;
- (void)addTarget:(id)target action:(SEL)action;
- (void)setValueChangeListener:(ValueChangeListener)listener;

@property (nonatomic, assign) id<TriangleControlViewDelegate>delegate;
@property (nonatomic, assign) BOOL showGuideShapes;
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, strong) UIColor *triangleBackgroundColor;
@property (nonatomic, strong) UIColor *triangleStrokeColor;
@property (nonatomic, strong) UIColor *ballColor;
@property (nonatomic, assign) BOOL roundedCorners;

@end
