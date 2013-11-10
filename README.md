DGHTriangleControlView
======================

An iOS UIControl(ish) object. Drag a ball around a triangle - use distance from ball center to each vertex as a control value.

Usage:
There are no external dependencies.
Import the DGHTriangleControlView.h and .m file into your project.
Use the convenience constructor:
+ (DGHTriangleControlView *)triangleControlViewWithFrame:(CGRect)frame
                                            ballDiameter:(CGFloat)ballDiameter
                                                delegate:(id<TriangleControlViewDelegate>)delegate;

Listen for value changes using the delegate, a block, or a target:action: pair.

Customize the triange and the ball via properties:
@property (nonatomic, assign) CGFloat ballDiameter;
@property (nonatomic, assign) CGFloat triangleStrokeWidth;
@property (nonatomic, strong) UIColor *triangleBackgroundColor;
@property (nonatomic, strong) UIColor *triangleStrokeColor;
@property (nonatomic, strong) UIColor *ballColor;
@property (nonatomic, assign) BOOL triangleRoundedCorners;  // this is just a switch on/off, uses CGLineCap

Any of these properties can be updated at any time.
