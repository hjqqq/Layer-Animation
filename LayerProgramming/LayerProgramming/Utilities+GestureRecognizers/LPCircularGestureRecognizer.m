//
//  LPCircularGestureRecognizer.m
//  LayerProgramming
//
//  Created by Mahesh on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LPCircularGestureRecognizer.h"

@interface LPCircularGestureRecognizer()
{
    CGPoint _startPoint;
    CGPoint _endPoint;
    CGPoint _newPoint;
    CGPoint _circleCenter;
    CGFloat _maximumRadius;
    CGFloat _minimumRadius;
    CGFloat _velocity;
    NSTimeInterval _latestUpdate;
    CGFloat _holePortion;
}

- (void)resetData;
- (void)setHolePortion:(CGFloat)holePortion;
- (BOOL)validatePosition:(CGPoint)touchPoint;

@end

@implementation LPCircularGestureRecognizer

#pragma mark - touch Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // check if there are more than one touch if yes
    // cancel the touch
    if([touches count]>1)
    {
        NSLog(@"More than one touch detected");
        [self cancelsTouchesInView];
    }
    
    // there is only one touch 
    _startPoint = [[touches anyObject]locationInView:self.view];
    _latestUpdate = [[touches anyObject]timestamp];
    _newPoint = _startPoint;
    
    // now get the maximun and the minimum radius
    // for a circle to be drawn we need to get the 
    // width or the height wich ever is the smallest
    // so the circle can fit in it and set it to the 
    // maximum radius and 0.3 of the _hole portion to the 
    // holeportion value time the above value
    _maximumRadius = MIN([self view].frame.size.width, [self view].frame.size.height)/2;
    _minimumRadius = _holePortion * _maximumRadius;
    
    // once the radius is obtained get the center of the circle
    _circleCenter = CGPointMake(CGRectGetMidX([self view].frame), CGRectGetMidY([self view].frame));
    
    if(![self validatePosition:_startPoint])
    {
        // loggging error that the point is in side the doughnut
    }
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // get the touch object
    UITouch *_touch = [touches anyObject];
    
    // get the previous and new point
    CGPoint _previousPoint = [_touch previousLocationInView:[self view]];
    CGPoint _newPoint = [_touch locationInView:[self view]];
    
    // here to ge the velocity of the movement, we need the position of the 
    // points with center as the reference.
    
    CGPoint _translateOld = CGPointMake(_previousPoint.x - _circleCenter.x, _previousPoint.y -_circleCenter.y);
    CGPoint _translateNew = CGPointMake(_newPoint.x - _circleCenter.x, _newPoint.y - _circleCenter.y);
    
    // we need to get the angle made by the swipe so that to calculate the 
    // velocity
    CGFloat _newTangentPoint = atan2f(_translateOld.x, _translateOld.y);
    CGFloat _oldTangentPoint = atan2f(_translateNew.x, _translateNew.y);
    
    
    
    
}

#pragma mark - Private Methods
- (void)resetData
{
    // reset the data after the circle is completed
    _startPoint = CGPointZero;
    _endPoint = CGPointZero;
    _maximumRadius = 0.0f;
    _minimumRadius= 0.0f;
    _velocity = 0.0f;
    _latestUpdate = 0.0f;
    _holePortion = 0.3;
    
    // if there are any gesture after the circle is complete then 
    // cancel the gesture
    if(self.state == UIGestureRecognizerStatePossible)
    {
        [self cancelsTouchesInView];
    }
}

- (void)setHolePortion:(CGFloat)holePortion
{
    // check if the hole portion is between 0 and 1 
    // if yes set the hole portion else log an exception 
    // the hole portion is between 1.0 and 0.0
    // Default value is 0.3f 
    if(holePortion >0.0f && holePortion<1.0f)
    {
        _holePortion =holePortion;
    }
    else 
    {
        [NSException exceptionWithName:@"LPCircularGestureRecognizer" reason:@"The hole portion is out value (Unit Scale) " userInfo:nil];
    }
}

- (BOOL)validatePosition:(CGPoint)touchPoint
{
  // get the x and y of the touch point from the center of the circle
    CGFloat _touchX = touchPoint.x - _circleCenter.x;
    CGFloat _touchY = touchPoint.y - _circleCenter.y;
    
    CGFloat _distance = sqrtf(powf(_touchX, 2)+powf(_touchY, 2));
    
    if(_distance > _maximumRadius && _distance < _minimumRadius)
    {
        return true;
    }
    
    return false;
}

@end
