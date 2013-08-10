//
//  TriangleControlView.m
//  TriangleController
//
//  Created by D Mac on 8/9/13.
//  Copyright (c) 2013 D Mac. All rights reserved.
//

#import "TriangleControlView.h"

static const CGFloat diameter   = 100.0f;
static const CGFloat lineWidth  = 2.0f;

@interface TriangleControlView() {
    CGPoint _touchPoint;
    CGMutablePathRef _trianglePath;
    CGMutablePathRef _insetTrianglePath;
    CGFloat _radius;
    
    CGFloat _originY;
    CGFloat _distance;
}

@property (nonatomic, assign) CGPoint triangleCenter;
@property (nonatomic, assign) CGPoint topCenter;
@property (nonatomic, assign) CGPoint bottomLeft;
@property (nonatomic, assign) CGPoint bottomRight;
@property (nonatomic, assign) CGPoint insetTopCenter;
@property (nonatomic, assign) CGPoint insetBottomLeft;
@property (nonatomic, assign) CGPoint insetBottomRight;

@end

@implementation TriangleControlView

- (void)dealloc {
    CGPathRelease(_trianglePath);
    CGPathRelease(_insetTrianglePath);
}

- (id)initWithFrame:(CGRect)frame
{
    NSAssert((frame.size.width == frame.size.height), @"frame must be a square");
    
    self = [super initWithFrame:frame];
    if (self) {

        _distance = frame.size.width - lineWidth;
        _radius = diameter/2.0f;
        _touchPoint = self.center;
        

        // draw a triangle
        [self calculateOuterPoints];
        
        _trianglePath = CGPathCreateMutable();
        CGPathMoveToPoint(_trianglePath, NULL, self.bottomLeft.x, self.bottomLeft.y);
        CGPathAddLineToPoint(_trianglePath, NULL, self.topCenter.x, self.topCenter.y);
        CGPathAddLineToPoint(_trianglePath, NULL, self.bottomRight.x, self.bottomRight.y);
        CGPathCloseSubpath(_trianglePath);
        
        [self calculateInsetPoints];
        
        _insetTrianglePath = CGPathCreateMutable();
        // draw a triangle
        CGPathMoveToPoint(_insetTrianglePath, NULL, self.insetBottomLeft.x, self.insetBottomLeft.y);
        CGPathAddLineToPoint(_insetTrianglePath, NULL, self.insetTopCenter.x, self.insetTopCenter.y);
        CGPathAddLineToPoint(_insetTrianglePath, NULL, self.insetBottomRight.x, self.insetBottomRight.y);
        CGPathCloseSubpath(_insetTrianglePath);
    }
    return self;
}

- (CGPoint)triangleCenter {
    return CGPointMake(self.frame.size.width/2.0f,
                       self.frame.size.height/2.0f);
}

- (void)calculateOuterPoints {
    self.bottomRight = CGPointMake(self.frame.size.width - 1.0f,
                                   self.frame.size.height - 1.0f);
    
    self.bottomLeft = CGPointMake(1.0f,
                                  self.frame.size.height - 1.0f - _originY);
    
    [self calculateTopCenter];
    
    _originY = self.topCenter.y/2.0f;
    
    // adjust everything according to _originY;
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
    
    while (calculatedDistance < _distance) {
        // move pointY down a scoche
        y1 -= 0.1f;
        
        // loop until the distance is correct
        CGFloat yPart = powf((y2 - y1), 2.0f);
        calculatedDistance = sqrtf(xPart + yPart);
    }
    
    _topCenter = CGPointMake(x1,
                             y1);
}

- (void)calculateInsetPoints {
    self.insetTopCenter = CGPointMake(self.frame.size.width/2.0f,
                                      self.topCenter.y + diameter + lineWidth);
    
    [self calculateInsetBottomPoints];
}

- (void)calculateInsetBottomPoints {
    
    // distance formula
    // d = sqrt((x2-x1)^2 + (y2-y1)^2)
    
    CGFloat yVal = self.bottomLeft.y - _radius - (lineWidth/2.0f);
    
    // y is constant so just move the x vals until the line segments are ~=
    // distance is linear in this case
    CGFloat rightX  = self.insetTopCenter.x;
    CGFloat leftX   = self.insetTopCenter.x;
    
    CGFloat line1Length = FLT_MAX;
    CGFloat line2Length = 0.0f;
    while (fabsf(line1Length - line2Length) > 0.1f) {
        rightX  += 0.1f;
        leftX   -= 0.1f;
        
        // bottom line segment
        line1Length = rightX - leftX;
        
        // now calculate insetTopCenter to bottom right
        const CGPoint bottomRightPoint = CGPointMake(rightX, yVal);
        const CGFloat xPart = powf((self.insetTopCenter.x - bottomRightPoint.x), 2.0f);
        const CGFloat yPart = powf((self.insetTopCenter.y - bottomRightPoint.y), 2.0f);
        line2Length = sqrtf(xPart + yPart);
    }
    
    self.insetBottomLeft = CGPointMake(leftX, yVal);
    self.insetBottomRight = CGPointMake(rightX, yVal);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
    
    // white background
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, rect);
    
    
    // draw triangle
    CGContextSaveGState(ctx);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextAddPath(ctx, _trianglePath);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    // draw inset triangle
    CGContextSaveGState(ctx);
    CGContextSetLineWidth(ctx, 1);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextAddPath(ctx, _insetTrianglePath);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    // draw a circle around touch point
    CGContextSaveGState(ctx);
    CGPoint topLeftPoint = CGPointMake(_touchPoint.x - _radius, _touchPoint.y - _radius);
    CGRect boundingRectForDot = CGRectMake(topLeftPoint.x, topLeftPoint.y, diameter, diameter);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.0f green:0.0f blue:1.0 alpha:0.5f].CGColor);
    CGContextFillEllipseInRect(ctx, boundingRectForDot);
    CGContextRestoreGState(ctx);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouch:touches.anyObject];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouch:touches.anyObject];
}

- (void)handleTouch:(UITouch *)touch {
    CGPoint thisTouchPoint = [touch locationInView:self];
    
    if (CGPathContainsPoint(_insetTrianglePath, NULL, thisTouchPoint, NO)) {
        _touchPoint = thisTouchPoint;
    } else {
        _touchPoint = [self touchPointWithExternalPoint:thisTouchPoint];
    }
    
    [self setNeedsDisplay];
}

- (CGPoint)touchPointWithExternalPoint:(CGPoint)externalPoint {
    // figure out where externalPoint is
    // below, left, or right of center
    
    CGPoint intersectPoint = CGPointZero;
    if (externalPoint.y > self.insetBottomRight.y) {
        NSLog(@"Below");
        // below, so use bottom line of the inset triangle
        intersectPoint = [self intersectionOfLineFrom:self.insetBottomLeft to:self.insetBottomRight withLineFrom:externalPoint to:self.triangleCenter];
    } else {
        // is it left of center or right of center
        if (externalPoint.x <= self.triangleCenter.x) {
            NSLog(@"above Left");
            // left of center
            intersectPoint = [self intersectionOfLineFrom:self.insetBottomLeft to:self.insetTopCenter withLineFrom:externalPoint to:self.triangleCenter];
        } else {
            NSLog(@"above right");
            // right of center
            intersectPoint = [self intersectionOfLineFrom:self.insetBottomRight to:self.insetTopCenter withLineFrom:externalPoint to:self.triangleCenter];
        }
    }
    
    if (CGPointEqualToPoint(intersectPoint, CGPointZero)) {
        NSLog(@"Fuck");
    }
    
    return intersectPoint;
}

- (CGPoint)intersectionOfLineFrom:(CGPoint)p1 to:(CGPoint)p2 withLineFrom:(CGPoint)p3 to:(CGPoint)p4
{
    CGFloat d = (p2.x - p1.x)*(p4.y - p3.y) - (p2.y - p1.y)*(p4.x - p3.x);
    if (d == 0)
        return CGPointZero; // parallel lines
    CGFloat u = ((p3.x - p1.x)*(p4.y - p3.y) - (p3.y - p1.y)*(p4.x - p3.x))/d;
    CGFloat v = ((p3.x - p1.x)*(p2.y - p1.y) - (p3.y - p1.y)*(p2.x - p1.x))/d;
    
    if (u < 0.0) {
        u = 0.0;
    } else if (u > 1.0) {
        u = 1.0;
    }
    
    if (v < 0.0) {
        v = 0.0;
    } else if (v > 1.0) {
        v = 1.0;
    }

//    if (u < 0.0 || u > 1.0)
//        return CGPointZero; // intersection point not between p1 and p2
//    if (v < 0.0 || v > 1.0)
//        return CGPointZero; // intersection point not between p3 and p4
    CGPoint intersection;
    intersection.x = p1.x + u * (p2.x - p1.x);
    intersection.y = p1.y + u * (p2.y - p1.y);
    
    return intersection;
}

@end
