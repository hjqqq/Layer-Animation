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
    CGFloat _rotation;
}

- (void)resetData;
- (void)setHolePortion:(CGFloat)holePortion;
- (BOOL)validatePosition:(CGPoint)touchPoint;

@end

@implementation LPCircularGestureRecognizer

@synthesize view=_view;


#pragma mark - Life Cycle

- (id)initWithView:(UIView *)parentView
{
    self = [super init];
    
    if(self)
    {
      // set the parent view to the self.view
      _view=parentView;   
    }
    return self;
}

- (void)dealloc
{
    SL_RELEASE_SAFELY(self.view);
    [super dealloc];
}

#pragma mark - touch Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // check if there are more than one touch if yes
    // cancel the touch
    if([touches count]>1)
    {
        NSLog(@"More than one touch detected");
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
    _maximumRadius = MIN(_view.frame.size.width, _view.frame.size.height)/2;
    _minimumRadius = _holePortion * _maximumRadius;
    
    // once the radius is obtained get the center of the circle
    _circleCenter = CGPointMake(CGRectGetMidX(_view.frame), CGRectGetMidY(_view.frame));
    
    if(![self validatePosition:_startPoint])
    {
        // loggging error that the point is in side the doughnut
        NSLog(@"Inside Circle Touches Began");
    }
    
    NSLog(@"Touches Began");
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    NSLog(@"Touches Cancelled");
    [self resetData];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches Ended");
    [self resetData];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // get the touch object
    UITouch *_touch = [touches anyObject];
    
    // get the previous and new point
    CGPoint _previousTouchPoint = [_touch previousLocationInView:_view];
    CGPoint _newTouchPoint = [_touch locationInView:_view];
    
    // here to ge the velocity of the movement, we need the position of the 
    // points with center as the reference.
    
    CGPoint _translateOld = CGPointMake(_previousTouchPoint.x - _circleCenter.x, _previousTouchPoint.y -_circleCenter.y);
    CGPoint _translateNew = CGPointMake(_newTouchPoint.x - _circleCenter.x, _newTouchPoint.y - _circleCenter.y);
    
    // we need to get the angle made by the swipe so that to calculate the 
    // velocity
    CGFloat _newTangentPoint = atan2f(_translateOld.x, _translateOld.y);
    CGFloat _oldTangentPoint = atan2f(_translateNew.x, _translateNew.y);
    
    // Now let us check if the rotation is in the clock wise of the anticlock wise
    // direction
    
    CGFloat _halfCircle = M_PI;
    
    CGFloat _positiveAngle = M_PI; // the positive half circle
    CGFloat _negativeAngle = M_PI * -1.0f; // the negative half circle
    
    if(((_newTangentPoint < _negativeAngle) && (_oldTangentPoint > _positiveAngle)) || ((_newTangentPoint > _positiveAngle) && (_oldTangentPoint < _negativeAngle)))
    {
        // calculate the angle difference
        CGFloat _firstAngle = _halfCircle - fabs(_newTangentPoint);
        CGFloat _secondAngle =  _halfCircle -fabs(_oldTangentPoint);
        CGFloat _diff = _secondAngle - _firstAngle;
        
        // check if the rotation is in the positive of the negative direction
        // however we need to convert it to positivce
        _rotation = _newTangentPoint<_negativeAngle?fabs(_diff) * -1.0f:fabs(_diff);
    }
    else {
        
            _rotation = _newTangentPoint - _oldTangentPoint;
    }
        
        NSTimeInterval _timeDifference = _touch.timestamp - _latestUpdate;
        
        _velocity = _rotation/_timeDifference;
        _latestUpdate = _touch.timestamp;
        
        
        if([self validatePosition:_newPoint])
        {
          // valid point
            NSLog(@"In the Circle");
            
        }
        else {
            NSLog(@"Not in circle");
        }
    
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
