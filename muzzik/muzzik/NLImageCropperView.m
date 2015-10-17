//
//  NLImageCropperView.m
//  NLImageCropper
//
// Copyright © 2012, Mirza Bilal (bilal@mirzabilal.com)
// All rights reserved.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 1.	Redistributions of source code must retain the above copyright notice,
//       this list of conditions and the following disclaimer.
// 2.	Redistributions in binary form must reproduce the above copyright notice,
//       this list of conditions and the following disclaimer in the documentation
//       and/or other materials provided with the distribution.
// 3.	Neither the name of Mirza Bilal nor the names of its contributors may be used
//       to endorse or promote products derived from this software without specific
//       prior written permission.
// THIS SOFTWARE IS PROVIDED BY MIRZA BILAL "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
// INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MIRZA BILAL BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
// IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
// ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "NLImageCropperView.h"
#import <QuartzCore/QuartzCore.h>

#define MIN_IMG_SIZE 150
#define TOUCH_SPACE  20
@implementation NLImageCropperView

- (void)setCropRegionRect:(CGRect)cropRect
{

    _cropRect = cropRect;
    _translatedCropRect =CGRectMake(cropRect.origin.x/_scalingFactor, cropRect.origin.y/_scalingFactor, cropRect.size.width/_scalingFactor, cropRect.size.height/_scalingFactor);
    [_cropView setCropRegionRect:_translatedCropRect];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    _image = nil;
    if (self) {
        // Initialization code
    }
    [self setBackgroundColor:[UIColor blackColor]];
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _cropView = [[NLCropViewLayer alloc] initWithFrame:_imageView.bounds];
    [_cropView setBackgroundColor:[UIColor clearColor]];

    [self setAutoresizesSubviews:YES];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    cropButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, SCREEN_HEIGHT - 60, 45, 45)];
    cropButton.layer.cornerRadius = 5;
    cropButton.clipsToBounds = YES;
    [cropButton setImage:[UIImage imageNamed:@"picselectedImage"] forState:UIControlStateNormal];
    [cropButton addTarget:self action:@selector(cropImage) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addSubview:_imageView];
    [self addSubview:_cropView];
    [self addSubview:cropButton];
    [self setCropRegionRect:CGRectMake(10, 10, 150, 150)];
    _scalingFactor = 1.0;
    _movePoint = NoPoint;
    _lastMovePoint = CGPointMake(0, 0);
    return self;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_image != nil) {
        [self reLayoutView];
    }
    NSLog(@"Set Frame Called");
}
- (void) setImage:(UIImage*)image
{
    _image = image;

    [self reLayoutView];
    
    [_imageView setImage:_image];    
}

- (void) reLayoutView
{
    float imgWidth = _image.size.width;
    float imgHeight = _image.size.height;
    float viewWidth = self.bounds.size.width ;
    float viewHeight = self.bounds.size.height;
    
    float widthRatio = imgWidth / viewWidth;
    float heightRatio = imgHeight / viewHeight;
    _scalingFactor = widthRatio > heightRatio ? widthRatio : heightRatio;
    
    _imageView.bounds = CGRectMake(0, 0, imgWidth / _scalingFactor, imgHeight/_scalingFactor);
    _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    _imageView.layer.shadowColor = [UIColor blackColor].CGColor;
//    _imageView.layer.shadowOffset = CGSizeMake(3, 3);
//    _imageView.layer.shadowOpacity = 0.6;
//    _imageView.layer.shadowRadius = 1.0;
    
    _cropView.bounds = _imageView.bounds;
    _cropView.frame = _imageView.frame;
    
    [self setCropRegionRect:_cropRect];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
        NSLog(@"Touch Begins");
    [super touchesBegan:touches withEvent:event];

    CGPoint locationPoint = [[touches anyObject] locationInView:_imageView];
    if(locationPoint.x < 0 || locationPoint.y < 0 || locationPoint.x > _imageView.bounds.size.width || locationPoint.y > _imageView.bounds.size.height)
    {
        _movePoint = NoPoint;
        return;
    }
    _lastMovePoint = locationPoint;
    
    if(((locationPoint.x - TOUCH_SPACE) <= _translatedCropRect.origin.x) &&
       ((locationPoint.x + TOUCH_SPACE) >= _translatedCropRect.origin.x))
    {
        if(((locationPoint.y - TOUCH_SPACE) <= _translatedCropRect.origin.y) &&
           ((locationPoint.y + TOUCH_SPACE) >= _translatedCropRect.origin.y))
            _movePoint = LeftTop;
        else if ((locationPoint.y - TOUCH_SPACE) <= (_translatedCropRect.origin.y + _translatedCropRect.size.height) &&
                 (locationPoint.y + TOUCH_SPACE) >= (_translatedCropRect.origin.y + _translatedCropRect.size.height))
            _movePoint = LeftBottom;
        else
            _movePoint = NoPoint;
    }
    else if(((locationPoint.x - TOUCH_SPACE) <= (_translatedCropRect.origin.x + _translatedCropRect.size.width)) &&
            ((locationPoint.x + TOUCH_SPACE) >= (_translatedCropRect.origin.x + _translatedCropRect.size.width)))
    {
        if(((locationPoint.y - TOUCH_SPACE) <= _translatedCropRect.origin.y) &&
           ((locationPoint.y + TOUCH_SPACE) >= _translatedCropRect.origin.y))
            _movePoint = RightTop;
        else if ((locationPoint.y - TOUCH_SPACE) <= (_translatedCropRect.origin.y + _translatedCropRect.size.height) &&
                 (locationPoint.y + TOUCH_SPACE) >= (_translatedCropRect.origin.y + _translatedCropRect.size.height))
            _movePoint = RightBottom;
        else
            _movePoint = NoPoint;
    }
    else if ((locationPoint.x > _translatedCropRect.origin.x) && (locationPoint.x < (_translatedCropRect.origin.x + _translatedCropRect.size.width)) &&
             (locationPoint.y > _translatedCropRect.origin.y) && (locationPoint.y < (_translatedCropRect.origin.y + _translatedCropRect.size.height)))
    {
        _movePoint = MoveCenter;
    }
    else
        _movePoint = NoPoint;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];

    CGPoint locationPoint = [[touches anyObject] locationInView:_imageView];

    NSLog(@"Location Point: (%f,%f)", locationPoint.x, locationPoint.y);
     float x,y;
    CGFloat widthX ;
    CGFloat heightY ;
    CGFloat delta;
    CGFloat minMove ;
    switch (_movePoint) {
        case LeftTop:
            widthX = _translatedCropRect.size.width + (_translatedCropRect.origin.x - locationPoint.x);
            heightY = _translatedCropRect.size.height + (_translatedCropRect.origin.y - locationPoint.y);
            minMove = (_translatedCropRect.origin.x - locationPoint.x) <  (_translatedCropRect.origin.y - locationPoint.y)?
                                (_translatedCropRect.origin.x - locationPoint.x) :  (_translatedCropRect.origin.y - locationPoint.y);
            
            if (locationPoint.x <= _translatedCropRect.origin.x && locationPoint.y <= _translatedCropRect.origin.y && (_translatedCropRect.origin.x - minMove) > 0 && (_translatedCropRect.origin.y - minMove>0) ) {
                delta= widthX<heightY ? widthX:heightY;
                _translatedCropRect = CGRectMake(_translatedCropRect.origin.x-minMove, _translatedCropRect.origin.y - minMove,delta,delta);
                
            }else if ((locationPoint.x >= _translatedCropRect.origin.x && locationPoint.y >= _translatedCropRect.origin.y) ){
                
                delta= widthX>heightY ? widthX:heightY;
                minMove = (locationPoint.x - _translatedCropRect.origin.x) <  (locationPoint.y - _translatedCropRect.origin.y)?
                (locationPoint.x - _translatedCropRect.origin.x) :  (locationPoint.y - _translatedCropRect.origin.y);
                if (delta <= MIN_IMG_SIZE) {
                    _translatedCropRect = CGRectMake(_translatedCropRect.origin.x, _translatedCropRect.origin.y,MIN_IMG_SIZE,MIN_IMG_SIZE);
                }else{
                    _translatedCropRect = CGRectMake(_translatedCropRect.origin.x + minMove, _translatedCropRect.origin.y + minMove,delta,delta);
                }
                
            }
            
            break;
        case LeftBottom:
            if(((locationPoint.x + MIN_IMG_SIZE) >= (_cropRect.origin.x/_scalingFactor + _translatedCropRect.size.width)) ||
               ((locationPoint.y - _translatedCropRect.origin.y) <= MIN_IMG_SIZE))
                return;
            widthX = _translatedCropRect.size.width + (_translatedCropRect.origin.x - locationPoint.x);
            heightY = locationPoint.y - _translatedCropRect.origin.y;
            minMove = (_translatedCropRect.origin.x - locationPoint.x) <  (locationPoint.y - _translatedCropRect.origin.y -_translatedCropRect.size.height)?
            (_translatedCropRect.origin.x - locationPoint.x) : (locationPoint.y - _translatedCropRect.origin.y -_translatedCropRect.size.height);
            
            if (locationPoint.x <= _translatedCropRect.origin.x && locationPoint.y >= _translatedCropRect.origin.y+_translatedCropRect.size.height && (_translatedCropRect.origin.x - minMove) > 0 && (_translatedCropRect.origin.y + minMove + _translatedCropRect.size.height<_cropView.bounds.size.height) ) {
                delta= widthX<heightY ? widthX:heightY;
                _translatedCropRect = CGRectMake(_translatedCropRect.origin.x-minMove, _translatedCropRect.origin.y,delta,delta);
            }else if ((locationPoint.x >= _translatedCropRect.origin.x && locationPoint.y <= _translatedCropRect.origin.y +_translatedCropRect.size.height) ){
                delta= widthX>heightY ? widthX:heightY;
                minMove = (locationPoint.x - _translatedCropRect.origin.x) <  (_translatedCropRect.origin.y +_translatedCropRect.size.height - locationPoint.y)?
                (locationPoint.x - _translatedCropRect.origin.x) : (_translatedCropRect.origin.y +_translatedCropRect.size.height - locationPoint.y);
                
                _translatedCropRect = CGRectMake(_translatedCropRect.origin.x+minMove, _translatedCropRect.origin.y ,delta,delta);
            }
            break;
            
        case RightTop:
            if(((locationPoint.x - _translatedCropRect.origin.x) <= MIN_IMG_SIZE) ||
               ((locationPoint.y + MIN_IMG_SIZE)>= (_translatedCropRect.origin.y + _translatedCropRect.size.height)))
                return;
            widthX = locationPoint.x - _translatedCropRect.origin.x;
            heightY = _translatedCropRect.size.height + (_translatedCropRect.origin.y - locationPoint.y);
            minMove = (locationPoint.x - _translatedCropRect.origin.x - _translatedCropRect.size.width) <  (_translatedCropRect.origin.y -locationPoint.y)?
            (locationPoint.x - _translatedCropRect.origin.x - _translatedCropRect.size.width) : (_translatedCropRect.origin.y -locationPoint.y);
            
            if (locationPoint.x >= _translatedCropRect.origin.x+_translatedCropRect.size.width && locationPoint.y <= _translatedCropRect.origin.y && (_translatedCropRect.origin.x + minMove) <self.frame.size.width && (_translatedCropRect.origin.y - minMove > 0) ) {
                delta= widthX<heightY ? widthX:heightY;
                _translatedCropRect = CGRectMake(_translatedCropRect.origin.x, _translatedCropRect.origin.y-minMove,delta,delta);
            }else if (locationPoint.x <= _translatedCropRect.origin.x+_translatedCropRect.size.width && locationPoint.y >= _translatedCropRect.origin.y){
                delta= widthX>heightY ? widthX:heightY;
                minMove = ( _translatedCropRect.origin.x + _translatedCropRect.size.width-locationPoint.x) <  (locationPoint.y - _translatedCropRect.origin.y)?
                ( _translatedCropRect.origin.x + _translatedCropRect.size.width-locationPoint.x) : (locationPoint.y - _translatedCropRect.origin.y);
                
                _translatedCropRect = CGRectMake(_translatedCropRect.origin.x, _translatedCropRect.origin.y+minMove ,delta,delta);
            }

            break;
        case RightBottom:
            if(((locationPoint.x - _translatedCropRect.origin.x) <= MIN_IMG_SIZE) ||
               ((locationPoint.y - _translatedCropRect.origin.y) <= MIN_IMG_SIZE))
                return;
            widthX = locationPoint.x - _translatedCropRect.origin.x;
            heightY = locationPoint.y - _translatedCropRect.origin.y;
            minMove = (_translatedCropRect.origin.x +_translatedCropRect.size.width- locationPoint.x) <  (_translatedCropRect.origin.y + _translatedCropRect.size.height - locationPoint.y)?
            (_translatedCropRect.origin.x +_translatedCropRect.size.width- locationPoint.x) :  (_translatedCropRect.origin.y + _translatedCropRect.size.height - locationPoint.y);
            
            if (locationPoint.x <= _translatedCropRect.origin.x+_translatedCropRect.size.width && locationPoint.y <= _translatedCropRect.origin.y+_translatedCropRect.size.height ) {
                delta= widthX > heightY ? widthX:heightY;
                _translatedCropRect = CGRectMake(_translatedCropRect.origin.x, _translatedCropRect.origin.y,delta,delta);
            }else if ((locationPoint.x >= _translatedCropRect.origin.x + _translatedCropRect.size.width && locationPoint.y >= _translatedCropRect.origin.y + _translatedCropRect.size.height  &&  _translatedCropRect.origin.x+_translatedCropRect.size.width <= _cropView.bounds.size.width && _translatedCropRect.origin.y + _translatedCropRect.size.height <= _cropView.bounds.size.height) ){
                minMove = (locationPoint.x - _translatedCropRect.origin.x -_translatedCropRect.size.width) <  (locationPoint.y - _translatedCropRect.origin.y - _translatedCropRect.size.height)?
                (_translatedCropRect.origin.x +_translatedCropRect.size.width- locationPoint.x) :  (_translatedCropRect.origin.y + _translatedCropRect.size.height - locationPoint.y);
                delta= widthX<heightY ? widthX:heightY;
                _translatedCropRect = CGRectMake(_translatedCropRect.origin.x , _translatedCropRect.origin.y ,delta,delta);
            }
            break;
        case MoveCenter:

            x = _lastMovePoint.x - locationPoint.x;
            y = _lastMovePoint.y - locationPoint.y;
            _translatedCropRect = CGRectMake(_translatedCropRect.origin.x - x, _translatedCropRect.origin.y - y, _translatedCropRect.size.width, _translatedCropRect.size.height);
            if (_translatedCropRect.origin.x < 0) {
                _translatedCropRect = CGRectMake(0, _translatedCropRect.origin.y, _translatedCropRect.size.width, _translatedCropRect.size.height);
            }else if (_translatedCropRect.origin.x +_translatedCropRect.size.width >self.frame.size.width){
                _translatedCropRect = CGRectMake(self.frame.size.width - _translatedCropRect.size.width, _translatedCropRect.origin.y, _translatedCropRect.size.width, _translatedCropRect.size.height);
            }
            
            if (_translatedCropRect.origin.y < 0) {
                _translatedCropRect = CGRectMake(_translatedCropRect.origin.x, 0, _translatedCropRect.size.width, _translatedCropRect.size.height);
            }else if (_translatedCropRect.origin.y +_translatedCropRect.size.height >_cropView.bounds.size.height){
                _translatedCropRect = CGRectMake(_translatedCropRect.origin.x, _cropView.bounds.size.height - _translatedCropRect.size.height, _translatedCropRect.size.width, _translatedCropRect.size.height);
            }
            
            _lastMovePoint = locationPoint;
            break;
        default: //NO Point
            return;
            break;
    }
    [_cropView setNeedsDisplay];
    _cropRect = CGRectMake(_translatedCropRect.origin.x*_scalingFactor, _translatedCropRect.origin.y*_scalingFactor, _translatedCropRect.size.width*_scalingFactor, _translatedCropRect.size.height*_scalingFactor);
    [self setCropRegionRect:_cropRect];
    
}

- (UIImage *)getCroppedImage {
    
    CGRect imageRect = CGRectMake(_cropRect.origin.x*_image.scale,
                      _cropRect.origin.y*_image.scale,
                      _cropRect.size.width*_image.scale,
                      _cropRect.size.height*_image.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([_image CGImage], imageRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:_image.scale
                                    orientation:_image.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}
-(void)cropImage{
    UIImage *image = [self getCroppedImage];
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(userCropImage:)]) {
        [self.delegate userCropImage:image];
    }
}
@end
