DGHTriangleControlView
======================

An iOS UIControl(ish) object. Drag a ball around a triangle - use distance from ball center to each vertex as a control value.

Check out the included example project and documentation. Simple, fun, and easy. Anyone can do it!

Usage:<br>
Import the DGHTriangleControlView.h and .m file into your project (no external dependencies).<br>
Use the convenience constructor:
```
+ (DGHTriangleControlView *)triangleControlViewWithFrame:(CGRect)frame
                                            ballDiameter:(CGFloat)ballDiameter
                                                delegate:(id<TriangleControlViewDelegate>)delegate;
```

Listen for value changes using the delegate:
```
- (void)triangleControlViewDidChangePosition:(DGHTriangleControlView *)triangleControlView;
```
block:
```
- (void)setValueChangeListener:(ValueChangeListener)listener;
```
or a target/action pair:
```
- (void)addTarget:(id)target action:(SEL)action;
```


Customize the triangle and the ball via properties:
```
 @property (nonatomic, assign) CGFloat ballDiameter;\n
 @property (nonatomic, assign) CGFloat triangleStrokeWidth;
 @property (nonatomic, strong) UIColor *triangleBackgroundColor;
 @property (nonatomic, strong) UIColor *triangleStrokeColor;
 @property (nonatomic, strong) UIColor *ballColor;
 @property (nonatomic, assign) BOOL triangleRoundedCorners;  // this is just a switch on/off, uses CGLineCap
```
Any of these properties can be updated at any time.<br>
<br>
To get some visual feedback about what's going on set showGuideShapes = YES.
