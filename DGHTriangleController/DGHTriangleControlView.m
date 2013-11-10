//
//  TriangleControlView.m
//  TriangleController
//
//  Created by D Mac on 8/9/13.
//  Copyright (c) 2013 D Mac. All rights reserved.
//

#import "DGHTriangleControlView.h"

static const CGFloat defaultLineWidth  = 2.0f;

@interface DGHTriangleControlView() {
    CGPoint _touchPoint;
    CGMutablePathRef _trianglePath;
    CGMutablePathRef _insetTrianglePath;
    CGFloat _radius;
    
    CGFloat _originY;
    CGFloat _distance;
    
    BOOL _outOfBounds;
}

@property (nonatomic, assign) CGPoint triangleCenter;
@property (nonatomic, assign) CGPoint topCenter;
@property (nonatomic, assign) CGPoint bottomLeft;
@property (nonatomic, assign) CGPoint bottomRight;
@property (nonatomic, assign) CGPoint insetTopCenter;
@property (nonatomic, assign) CGPoint insetBottomLeft;
@property (nonatomic, assign) CGPoint insetBottomRight;
@property (nonatomic, strong) ValueChangeListener valueChangeListener;
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL action;

- (id)initWithFrame:(CGRect)frame
       ballDiameter:(CGFloat)diameter
           delegate:(id<TriangleControlViewDelegate>)delegate;

@end

@implementation DGHTriangleControlView

#pragma mark - Initialization/setup

+ (DGHTriangleControlView *)triangleControlViewWithFrame:(CGRect)frame
                                         ballDiameter:(CGFloat)ballDiameter
                                             delegate:(id<TriangleControlViewDelegate>)delegate {
    
    return [[DGHTriangleControlView alloc] initWithFrame:frame
                                         ballDiameter:ballDiameter
                                             delegate:delegate];
}

- (void)dealloc {
    CGPathRelease(_trianglePath);
    CGPathRelease(_insetTrianglePath);
}

- (id)initWithFrame:(CGRect)frame
       ballDiameter:(CGFloat)diameter
           delegate:(id<TriangleControlViewDelegate>)delegate
{
    NSAssert((frame.size.width == frame.size.height), @"DGHTriangleControlView: frame must be a square");
    
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.delegate = delegate;
        
        [self setDefaults];
        
        [self updateCalculations];
        
        self.ballDiameter = diameter;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    NSAssert((frame.size.width == frame.size.height), @"DGHTriangleControlView: frame must be a square");
    
    [self updateCalculations];
}

- (void)setBallDiameter:(CGFloat)ballDiameter {
    NSAssert((ballDiameter < self.frame.size.width/2.0f), @"DGHTriangleControlView: ball diameter is too big, must be less than half the width");
    _ballDiameter = ballDiameter;
}

- (void)addTarget:(id)target action:(SEL)action {
    self.target = target;
    self.action = action;
}

- (void)setValueChangeListener:(ValueChangeListener)listener {
    _valueChangeListener = listener;
}

- (void)setDefaults {
    self.backgroundColor = [UIColor clearColor];
    self.triangleStrokeWidth = defaultLineWidth;
    self.triangleBackgroundColor = [UIColor lightGrayColor];
    self.triangleStrokeColor = [UIColor blackColor];
    self.ballColor = [UIColor redColor];
}

- (void)setTriangleStrokeWidth:(CGFloat)lineWidth {
    _triangleStrokeWidth = lineWidth;
    [self updateCalculations];
}

#pragma mark - Setup
/**
 We know the bottom left and bottom right points of the outer triangle,
 since frame.size.width is the length of a triangle side.
 Once bottomLeft and bottomRight are set, we calculate topCenter.
 This starts with the X midpoint between bottomRight and bottomLeft,
 then we loop incrementing the y value of the midpoint down
 until the distance between bottomRight and topCenter are the same (or slightly greater than).
 
 We use a similar technique to calculate the inner/guide triangle vertices.
 
 Also, during this process we center the drawing of the triangle in the frame
 and calculate the center point of the triangle.
 
 These calculations are pretty brute force, but they only get called when self.frame or self.strokeWidth changes.
 Someone should definitely mathify them.
*/
- (void)updateCalculations {
    _distance = self.frame.size.width - self.triangleStrokeWidth;
    _radius = self.ballDiameter/2.0f;
    
    // draw outer triangle
    [self calculateOuterPoints];
    
    if (_trianglePath != NULL) {
        CGPathRelease(_trianglePath);
    }
    _trianglePath = CGPathCreateMutable();
    CGPathMoveToPoint(_trianglePath, NULL, self.bottomLeft.x, self.bottomLeft.y);
    CGPathAddLineToPoint(_trianglePath, NULL, self.topCenter.x, self.topCenter.y);
    CGPathAddLineToPoint(_trianglePath, NULL, self.bottomRight.x, self.bottomRight.y);
    CGPathCloseSubpath(_trianglePath);
    
    [self calculateTriangleCenter];
    _touchPoint = self.triangleCenter;
    
    // draw inner triangle
    [self calculateInsetPoints];
    
    if (_insetTrianglePath != NULL) {
        CGPathRelease(_insetTrianglePath);
    }
    _insetTrianglePath = CGPathCreateMutable();
    CGPathMoveToPoint(_insetTrianglePath, NULL, self.insetBottomLeft.x, self.insetBottomLeft.y);
    CGPathAddLineToPoint(_insetTrianglePath, NULL, self.insetTopCenter.x, self.insetTopCenter.y);
    CGPathAddLineToPoint(_insetTrianglePath, NULL, self.insetBottomRight.x, self.insetBottomRight.y);
    CGPathCloseSubpath(_insetTrianglePath);
}

- (void)calculateOuterPoints {
    self.bottomLeft = CGPointMake((self.triangleStrokeWidth/2.0f),
                                  self.frame.size.height - (self.triangleStrokeWidth/2.0f));

    self.bottomRight = CGPointMake(self.frame.size.width - (self.triangleStrokeWidth/2.0f),
                                   self.frame.size.height - (self.triangleStrokeWidth/2.0f));
    
    [self calculateTopCenter];
    
    _originY = self.topCenter.y/2.0f;
    
    // adjust everything according to _originY,
    // so the triangle is centered in the frame
    self.bottomRight = CGPointMake(self.bottomRight.x, self.bottomRight.y - _originY);
    self.bottomLeft = CGPointMake(self.bottomLeft.x, self.bottomLeft.y - _originY);
    self.topCenter = CGPointMake(self.topCenter.x, self.topCenter.y - _originY);
}

- (void)calculateTopCenter {
    CGFloat calculatedDistance = 0.0f;
    
    // distance formula
    // d = sqrt((x2-x1)^2 + (y2-y1)^2)
    
    // these are constant for the loop
    const CGFloat x2 = self.bottomLeft.x;
    const CGFloat x1 = self.bottomLeft.x + (_distance/2.0f);
    const CGFloat xPart = powf((x2 - x1), 2.0f);
    const CGFloat y2 = self.bottomLeft.y;
    
    // this will change each loop iteration
    CGFloat y1 = self.bottomRight.y;
    
    while (calculatedDistance <= _distance) {
        // move pointY down a scoche
        y1 -= 0.1f;
        
        // loop until the distance is correct
        CGFloat yPart = powf((y2 - y1), 2.0f);
        calculatedDistance = sqrtf(xPart + yPart);
    }
    
    _topCenter = CGPointMake(x1, y1);
}

- (void)calculateInsetPoints {
    self.insetTopCenter = CGPointMake(self.frame.size.width/2.0f,
                                      self.topCenter.y + self.ballDiameter + self.triangleStrokeWidth);
    
    [self calculateInsetBottomPoints];
}

- (void)calculateInsetBottomPoints {
    
    const CGFloat yVal = self.bottomLeft.y - _radius - (self.triangleStrokeWidth/2.0f);
    
    // y is constant so just move the x vals until the line segments are ~=
    // distance is linear in this case
    CGFloat rightX  = self.insetTopCenter.x;
    CGFloat leftX   = self.insetTopCenter.x;
    
    float acceptableDiff = 0.1f;
    
    float line1Length = FLT_MAX;
    float line2Length = 0.0f;
    float diff = fabsf(line1Length - line2Length);
    while (diff > acceptableDiff) {
        // move the x of each point out a little
        rightX  += 0.1f;
        leftX   -= 0.1f;
        
        // bottom line segment
        line1Length = rightX - leftX;
        
        // now calculate insetTopCenter to bottom right (or bottom left)
        const CGPoint bottomRightPoint = CGPointMake(rightX, yVal);
        line2Length = distanceBetweenPoints(self.insetTopCenter, bottomRightPoint);
        
        // update the diff
        diff = fabsf(line1Length - line2Length);
    }
    
    self.insetBottomLeft = CGPointMake(leftX, yVal);
    self.insetBottomRight = CGPointMake(rightX, yVal);
}

- (void)calculateTriangleCenter {
    // calculate two lines until they are the same length
    // only need to calculate two since this is equilateral
    float segmentFromTop, segmentFromBottomLeft;
    
    CGFloat iterationVal = 0.1f;
    CGFloat acceptableDiff = 0.1f;
    CGFloat yVal = self.topCenter.y;
    
    BOOL allEqual = NO;
    while (!allEqual) {
        yVal += iterationVal;
        CGPoint centerPoint = CGPointMake(self.topCenter.x, yVal);
        
        segmentFromTop = distanceBetweenPoints(centerPoint, self.topCenter);
        segmentFromBottomLeft = distanceBetweenPoints(centerPoint, self.bottomLeft);
        float diff = fabs(segmentFromTop - segmentFromBottomLeft);
        if (diff < acceptableDiff) {
            allEqual = YES;
            self.triangleCenter = centerPoint;
        }
    }

}

#pragma mark - Draw
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
    
    // white background
    CGContextSetFillColorWithColor(ctx, self.backgroundColor.CGColor);
    CGContextFillRect(ctx, rect);
    
    
    // draw triangle
    [self drawTriangleInContext:ctx];
    
    // draw a circle around touch point
    [self drawCircleInContext:ctx];
    
    if (self.showGuideShapes) {
        [self drawGuideShapesInContext:ctx];
    }
    
    if ([self.delegate respondsToSelector:@selector(triangleControlViewDidChangePosition:)]) {
        [self.delegate triangleControlViewDidChangePosition:self];
    }
    if (self.valueChangeListener != nil) {
        self.valueChangeListener(self);
    }
    if (self.target != nil && self.action != NULL) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.action withObject:self];
#pragma clang diagnostic pop
    }
}

- (void)drawTriangleInContext:(CGContextRef)ctx {
    CGContextSaveGState(ctx);
    CGContextSetLineWidth(ctx, self.triangleStrokeWidth);
    CGContextSetLineCap(ctx, self.triangleRoundedCorners ? kCGLineCapRound : 0);
    CGContextSetLineJoin(ctx, self.triangleRoundedCorners ? kCGLineJoinRound : 0);
    CGContextSetFillColorWithColor(ctx, self.triangleBackgroundColor.CGColor);
    CGContextSetStrokeColorWithColor(ctx, self.triangleStrokeColor.CGColor);
    CGContextAddPath(ctx, _trianglePath);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    CGContextRestoreGState(ctx);
}

- (void)drawCircleInContext:(CGContextRef)ctx {
    CGContextSaveGState(ctx);
    CGPoint topLeftPoint = CGPointMake(_touchPoint.x - _radius, _touchPoint.y - _radius);
    CGRect boundingRectForDot = CGRectMake(topLeftPoint.x, topLeftPoint.y, self.ballDiameter, self.ballDiameter);
    CGContextSetFillColorWithColor(ctx, self.ballColor.CGColor);
    CGContextFillEllipseInRect(ctx, boundingRectForDot);
    CGContextRestoreGState(ctx);
}

- (void)drawGuideShapesInContext:(CGContextRef)ctx {
    // draw inset triangle
    CGContextSaveGState(ctx);
    CGContextSetLineWidth(ctx, 1);
    UIColor *innerTriangleColor = [self.triangleBackgroundColor isEqual:[UIColor redColor]] ? [UIColor blueColor] : [UIColor redColor];
    CGContextSetStrokeColorWithColor(ctx, innerTriangleColor.CGColor);
    CGContextAddPath(ctx, _insetTrianglePath);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);

    // if we are out of bounds, show the intersect
    if (_outOfBounds) {
        drawLine(ctx,
                 _touchPoint,
                 self.triangleCenter,
                 [UIColor greenColor].CGColor,
                 1.0f,
                 YES,
                 0);
    }
}

#pragma mark - Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouchPoint:[touches.anyObject locationInView:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouchPoint:[touches.anyObject locationInView:self]];
}

- (void)handleTouchPoint:(CGPoint)point {
    
    _outOfBounds = !CGPathContainsPoint(_insetTrianglePath, NULL, point, NO);
    if (!_outOfBounds) {
        _touchPoint = point;
    } else {
        // calculate the touch point
        // this will be the closest intersection with the path
        _touchPoint = [self touchPointWithExternalPoint:point];
    }
    
    [self setNeedsDisplay];
}

- (CGPoint)touchPointWithExternalPoint:(CGPoint)externalPoint {
    // we could do this a different (more mathy) way, but this works
    // and the performance gain is probably minimal to nonexistent
    
    // figure out where externalPoint is w/r/t the triangle
    // below, left, or right of center
    // then find the closest intersection with the path (_insetTrianglePath)
    
    CGPoint intersectPoint = CGPointZero;
    if (externalPoint.y > self.insetBottomRight.y) {
        // below, so use bottom line of the inset triangle
        intersectPoint = [self tryBelowWithExternalPoint:externalPoint];
        
        // if the point is below the bottom line but far enough to the left of right of the traingle
        // the intersection will actually be with one of the sides, not the bottom line
        // if below failed, i.e. return CGPointZero
        // try above; it should always work
        if (CGPointEqualToPoint(intersectPoint, CGPointZero)) {
            intersectPoint = [self tryAboveWithExternalPoint:externalPoint];
        }
    } else {
        intersectPoint = [self tryAboveWithExternalPoint:externalPoint];
    }
    
    return intersectPoint;
}

- (CGPoint)tryBelowWithExternalPoint:(CGPoint)externalPoint {
    // intersection of triangle bottom line segment
    // with line from externalPoint to triangleCenter
    return [self intersectionOfLineFrom:self.insetBottomLeft to:self.insetBottomRight withLineFrom:externalPoint to:self.triangleCenter];
}

- (CGPoint)tryAboveWithExternalPoint:(CGPoint)externalPoint {
    CGPoint intersectPoint = CGPointZero;
    // is it left of center or right of center
    if (externalPoint.x <= self.triangleCenter.x) {
        // left of center
        intersectPoint = [self intersectionOfLineFrom:self.insetBottomLeft to:self.insetTopCenter withLineFrom:externalPoint to:self.triangleCenter];
    } else {
        // right of center
        intersectPoint = [self intersectionOfLineFrom:self.insetBottomRight to:self.insetTopCenter withLineFrom:externalPoint to:self.triangleCenter];
    }
    return intersectPoint;
}

#pragma mark - Math
// http://stackoverflow.com/questions/15690103/intersection-between-two-lines-in-coordinates
- (CGPoint)intersectionOfLineFrom:(CGPoint)p1 to:(CGPoint)p2 withLineFrom:(CGPoint)p3 to:(CGPoint)p4
{
    CGFloat d = (p2.x - p1.x)*(p4.y - p3.y) - (p2.y - p1.y)*(p4.x - p3.x);
    if (d == 0)
        return CGPointZero; // parallel lines
    CGFloat u = ((p3.x - p1.x)*(p4.y - p3.y) - (p3.y - p1.y)*(p4.x - p3.x))/d;
    CGFloat v = ((p3.x - p1.x)*(p2.y - p1.y) - (p3.y - p1.y)*(p2.x - p1.x))/d;

    if (u < 0.0 || u > 1.0)
        return CGPointZero; // intersection point not between p1 and p2
    if (v < 0.0 || v > 1.0)
        return CGPointZero; // intersection point not between p3 and p4
    CGPoint intersection;
    intersection.x = p1.x + u * (p2.x - p1.x);
    intersection.y = p1.y + u * (p2.y - p1.y);
    
    return intersection;
}

float distanceBetweenPoints(CGPoint point1, CGPoint point2) {
    // distance formula
    // d = sqrt((x2-x1)^2 + (y2-y1)^2)
    
    float xPart = powf((point1.x - point2.x), 2.0f);
    float yPart = powf((point1.y - point2.y), 2.0f);
    
    float distance = sqrtf(xPart + yPart);
    
    return distance;
}

void drawLine(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color, CGFloat width, BOOL dashed, int lineCap)
{
    CGContextSaveGState(context);
    CGContextSetLineCap(context, lineCap);
    if (dashed) {
        CGFloat dashArray[] = {3, 1};
        CGContextSetLineDash(context, 0, dashArray, 2);
    }
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, width);
    CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
    CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

#pragma mark - Control values
- (float)valueForVertex:(TriangleVertext)vertex {
    // calculate the distance of touchPoint from vertext
    // return 1 - x/maxDistance
    // maxDistance is the length of one side of the inner triangle
    
    CGPoint vertextPoint;
    switch (vertex) {
        case TriangleVertextTop:
            vertextPoint = self.insetTopCenter;
            break;
        case TriangleVertextBottomLeft:
            vertextPoint = self.insetBottomLeft;
            break;
        case TriangleVertextBottomRight:
            vertextPoint = self.insetBottomRight;
            break;
            
        default:
            break;
    }
    
    float triangleSideLength = self.insetBottomRight.x - self.insetBottomLeft.x;
    float distance = distanceBetweenPoints(_touchPoint, vertextPoint);
    float fraction = distance/triangleSideLength;
    
    // limit to 1
    fraction = MIN(fraction, 1.0f);
    
    return 1.0f - fraction;
}

@end
