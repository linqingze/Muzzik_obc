//
//  RJTextView.m
//  RJTextViewDemo
//
//  Created by Rylan on 3/11/15.
//  Copyright (c) 2015 ArcSoft. All rights reserved.
//

#import "RJTextView.h"

#define TEST_CENTER_ALIGNMENT   0
#define PEN_ICON_SIZE           36
#define EDIT_BOX_LINE           1.0
#define MAX_FONT_SIZE           500
#define MAX_TEXT_LETH           50

#define IS_IOS_7 ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f)

@implementation CTextView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if ( action == @selector(paste:)     ||
         action == @selector(cut:)       ||
         action == @selector(copy:)      ||
         action == @selector(select:)    ||
         action == @selector(selectAll:) ||
         action == @selector(delete:) )
    {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

@end

@interface RJTextView () <UITextViewDelegate>
{
    BOOL _isDeleting;
    CGPoint touchLocation;
    CGPoint beginningPoint;
    CGPoint beginningCenter;
    BOOL allowPan;
    CGRect beginBounds;
    CAShapeLayer *border;
}
@property (assign, nonatomic) BOOL        isEditting;

@property (retain, nonatomic) CTextView   *textView;
@property (retain, nonatomic) UIImageView *indicatorView;
@property (retain, nonatomic) UIImageView *scaleView;
@property (retain, nonatomic) UIColor     *tColor;
@property (assign, nonatomic) CGPoint     textCenter;
@property (assign, nonatomic) CGSize      minSize;
@property (assign, nonatomic) CGFloat     minFontSize;


@end

@implementation RJTextView

- (id)initWithFrame:(CGRect)frame
        defaultText:(NSString *)text
               font:(UIFont *)font
              color:(UIColor *)color
            minSize:(CGSize)minSize
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Custom initialization
        BOOL sExtend = frame.size.height <=0 || frame.size.width <=0;
        BOOL oExtend = frame.origin.x    < 0 || frame.origin.y   < 0;
        
        if (sExtend || oExtend /*|| ![text length]*/) return nil;
        
        [self setBackgroundColor:[UIColor clearColor]];
        self.fontsize = font.pointSize;
        self.tColor = color; self.curFont = font; self.minFontSize = font.pointSize;
        [self createTextViewWithFrame:CGRectZero text:nil font:nil];

        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [closeButton setBackgroundImage:[UIImage imageNamed:@"undoImage"]
                              forState:UIControlStateNormal];
        //[editButton setBackgroundImage:[UIImage imageNamed:@"pe_pen_icon_push"]
        //                     forState:UIControlStateHighlighted];
        [closeButton addTarget:self action:@selector(closeTextView)
             forControlEvents:UIControlEventTouchUpInside];
        [closeButton setExclusiveTouch:YES]; [self addSubview:closeButton];
        [self setCloseButton:closeButton];
        UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGesture:)];
        [self addGestureRecognizer:moveGesture];
        UIImageView *sView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [sView setImage:[UIImage imageNamed:@"scalingImage"]];
        [sView setUserInteractionEnabled:YES];
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(scaleTextView:)];
        [sView addGestureRecognizer:panGes];
        
        [sView setExclusiveTouch:YES]; [self addSubview:sView];
        [self setScaleView:sView];
        
        [self layoutSubViewWithFrame:frame]; self.isEditting = YES;

        // temp init setting, replace later
        CGFloat cFont = 1; self.textView.text = text; self.minSize = minSize;
        
        if (minSize.height >  frame.size.height ||
            minSize.width  >  frame.size.width  ||
            minSize.height <= 0 || minSize.width <= 0)
        {
            self.minSize = CGSizeMake(frame.size.width/3.f, frame.size.height/3.f);
        }
        CGSize  tSize = IS_IOS_7?[self textSizeWithFont:cFont text:[text length]?nil:@"A"]:CGSizeZero;

        do
        {
            if (IS_IOS_7)
            {
                tSize = [self textSizeWithFont:++cFont text:[text length]?nil:@"A"];
            }
            else
            {
                [self.textView setFont:[self.curFont fontWithSize:++cFont]];
            }
        }
        while (![self isBeyondSize:tSize] && cFont < MAX_FONT_SIZE);
    
        if (cFont < /*self.minFontSize*/0) return nil;
        
        cFont = (cFont < MAX_FONT_SIZE) ? cFont : self.minFontSize;
        [self.textView setFont:[self.curFont fontWithSize:--cFont]];
        self.minFontSize = cFont;
        self.textCenter = CGPointMake(frame.origin.x+frame.size.width/2.f,
                                      frame.origin.y+frame.size.height/2.f);
        
        #if TEST_CENTER_ALIGNMENT
        self.indicatorView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        [self.indicatorView setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.5]];
        [self addSubview:self.indicatorView];
        #else
        // ...
        #endif
        
        [self centerTextVertically];
       
    }
    return self;
}

- (void)createTextViewWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font
{
    [border removeFromSuperlayer];
    CTextView *textView = [[CTextView alloc] initWithFrame:frame];
    
    textView.scrollEnabled = NO; [textView setDelegate:self];
    //textView.keyboardType  = UIKeyboardTypeASCIICapable;
    textView.returnKeyType = UIReturnKeyDone;
    textView.textAlignment = NSTextAlignmentCenter;
    //textView.selectable = NO;
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setTextColor:self.tColor];
    [textView setText:text];
    [textView setFont:font];
    [textView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self addSubview:textView]; [self sendSubviewToBack:textView];
    
    if (IS_IOS_7)
    {
        textView.textContainerInset = UIEdgeInsetsZero;
    }
    else
    {
        textView.contentOffset = CGPointZero;
    }
    
    [self setTextView:textView];
    
    border = [CAShapeLayer layer];
    border.strokeColor = [UIColor redColor].CGColor;
    border.fillColor = nil;
    border.lineWidth = 2.0f;
    border.lineDashPattern = @[@3, @3];
    [_textView.layer addSublayer:border];
}

- (void)layoutSubViewWithFrame:(CGRect)frame
{
    CGRect tRect = frame;
    
    tRect.size.width  = self.frame.size.width -PEN_ICON_SIZE-EDIT_BOX_LINE;
    tRect.size.height = self.frame.size.height-PEN_ICON_SIZE-EDIT_BOX_LINE;
    
    tRect.origin.x = (self.frame.size.width -tRect.size.width) /2.;
    tRect.origin.y = (self.frame.size.height-tRect.size.height)/2.;
    
    [self.textView setFrame:tRect];
    border.path = [UIBezierPath bezierPathWithRect:_textView.bounds].CGPath;
    border.frame = _textView.bounds;
    [self.closeButton setFrame:CGRectMake(0, 0,
                                         PEN_ICON_SIZE, PEN_ICON_SIZE)];
    [self.scaleView  setFrame:CGRectMake(self.frame.size.width-PEN_ICON_SIZE,
                                         self.frame.size.height-PEN_ICON_SIZE, PEN_ICON_SIZE, PEN_ICON_SIZE)];
}

-(void)moveGesture:(UIPanGestureRecognizer *)recognizer
{

    touchLocation = [recognizer locationInView:self.superview];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        beginningPoint = touchLocation;
        beginningCenter = self.center;
        allowPan = YES;
        //        if (CGRectGetMinX(self.frame) >= 0  && CGRectGetMinY(self.frame) >= 0 && CGRectGetMaxY(self.frame)<=CGRectGetMaxY([self superview].frame)-64 && CGRectGetMaxX(self.frame)<=SCREEN_WIDTH)
        //        {
        //            allowPan = YES;
        //        }
        
        //        [self setCenter:CGPointMake(beginningCenter.x+(touchLocation.x-beginningPoint.x), beginningCenter.y+(touchLocation.y-beginningPoint.y))];
        
        beginBounds = self.bounds;
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged && allowPan == YES)
    {
        // 移动的操作
        CGPoint translation = [recognizer translationInView:self];
        self.center = CGPointMake(self.center.x + translation.x,
                                  self.center.y + translation.y);
        //判断左边超过区域
        if ((self.center.x-CGRectGetWidth(self.frame)/2)<0) {
            self.frame = CGRectMake(0, CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        }
        //判断上部超过区域
        if ((self.center.y-CGRectGetHeight(self.frame)/2)<0) {
            self.frame = CGRectMake(CGRectGetMinX(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        }
        //判断上部和左边超过区域
        if ((self.center.x-CGRectGetWidth(self.frame)/2)<0 && (self.center.y-CGRectGetHeight(self.frame)/2)<0) {
            self.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        }
        //判断下部超过区域
        if ((self.center.y+CGRectGetHeight(self.frame)/2)>CGRectGetMaxY([self superview].frame)) {
            self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMaxY([self superview].frame)-CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        }
        //判断下部和左边超过区域
        if ((self.center.y+CGRectGetHeight(self.frame)/2)>CGRectGetMaxY([self superview].frame)-64 && (self.center.x-CGRectGetWidth(self.frame)/2)<0) {
            self.frame = CGRectMake(0, CGRectGetMaxY([self superview].frame)-64-CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        }
        //判断右边超过区域
        if ((self.center.x+CGRectGetWidth(self.frame)/2)>SCREEN_WIDTH) {
            self.frame = CGRectMake(SCREEN_WIDTH-CGRectGetWidth(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        }
        //判断右边和上部超过区域
        if ((self.center.x+CGRectGetWidth(self.frame)/2)>SCREEN_WIDTH && (self.center.y-CGRectGetHeight(self.frame)/2)<0) {
            self.frame = CGRectMake(SCREEN_WIDTH-CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        }
        //判断右边和下部超过区域
        if ((self.center.x+CGRectGetWidth(self.frame)/2)>SCREEN_WIDTH && (self.center.y+CGRectGetHeight(self.frame)/2)>CGRectGetMaxY([self superview].frame)-64) {
            self.frame = CGRectMake(SCREEN_WIDTH-CGRectGetWidth(self.frame), CGRectGetMaxY([self superview].frame)-64-CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        }
        
        [recognizer setTranslation:CGPointZero
                            inView:self];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        // [self setCenter:CGPointMake(beginningCenter.x+(touchLocation.x-beginningPoint.x), beginningCenter.y+(touchLocation.y-beginningPoint.y))];
        allowPan = NO;
    }
}

- (void)closeTextView
{
    [self.textView removeFromSuperview];
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(closeLabel:)]) {
        [self.delegate closeLabel:self];
    }
}

- (void)hideTextViewBox
{
    [self.closeButton setHidden:YES];
    [self.scaleView  setHidden:YES];
    [border removeFromSuperlayer];
    [self endEditing:YES]; self.isEditting = NO;    
    self.hideView = YES; [self setNeedsDisplay];
}

- (void)showTextViewBox
{
    [self.closeButton setHidden:NO];
    [self.scaleView  setHidden:NO];

    [_textView.layer addSublayer:border];

    

    self.hideView = NO;  [self setNeedsDisplay];
}

- (void)scaleTextView:(UIPanGestureRecognizer *)panGes
{
    if (panGes.state == UIGestureRecognizerStateBegan)
    {
        [self endEditing:YES]; self.isEditting = NO;
        self.textCenter = self.center; [self.scaleView setHighlighted:YES];
    }
    
    if (panGes.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [panGes translationInView:self];
        //-  CGFloat y = -translation.y
        CGFloat x = translation.x; CGFloat y = translation.y;

        
        CGFloat wScale = x / self.frame.size.width +1;
        CGFloat hScale = y / self.frame.size.height+1;
        
        CGRect  tempRect = self.frame;
        tempRect.size.width  *= wScale;
        tempRect.size.height *= hScale;
        
        if (x > 0.f && y > 0.f) // zoom out
        {
            CGFloat cX = self.superview.frame.size.width -tempRect.size.width;
            CGFloat cY = self.superview.frame.size.height-tempRect.size.height;
            
            if (cX > 0 && cY < 0)
            {
                CGFloat scale = tempRect.size.width/tempRect.size.height;
                tempRect.size.height += cY;
                tempRect.size.width   = tempRect.size.height*scale;
            }
            else if (cX < 0 && cY > 0)
            {
                CGFloat scale = tempRect.size.height/tempRect.size.width;
                tempRect.size.width += cX;
                tempRect.size.height = tempRect.size.width*scale;
            }
            else if (cX < 0 && cY < 0)
            {
                if (cX < cY)
                {
                    CGFloat scale = tempRect.size.height/tempRect.size.width;
                    tempRect.size.width += cX;
                    tempRect.size.height = tempRect.size.width*scale;
                }
                else
                {
                    CGFloat scale = tempRect.size.width/tempRect.size.height;
                    tempRect.size.height += cY;
                    tempRect.size.width   = tempRect.size.height*scale;
                }
            }
        }
        
        if (x < 0 && tempRect.size.width <self.minSize.width) tempRect.size = CGSizeMake(self.minSize.width, tempRect.size.height);
        if (y<0  &&  tempRect.size.height<self.minSize.height) tempRect.size = CGSizeMake(tempRect.size.width, self.minSize.height);
        tempRect.origin.x = self.textCenter.x- tempRect.size.width/2;
        tempRect.origin.y = self.textCenter.y-tempRect.size.height/2;
        
        if (tempRect.origin.x < 0)
        {
            CGPoint pC = self.textCenter;
            
            pC.x = tempRect.size.width/2.f;  self.textCenter = pC;
        }
        
        if (tempRect.origin.y < 0)
        {
            CGPoint pC = self.textCenter;
            
            pC.y = tempRect.size.height/2.f; self.textCenter = pC;
        }
        
        
        
        [self setFrame:tempRect]; [self setCenter:self.textCenter];
        
        [self layoutSubViewWithFrame:tempRect];
        
        if (IS_IOS_7)
        {
            self.textView.textContainerInset = UIEdgeInsetsZero;
        }
        else
        {
            self.textView.contentOffset = CGPointZero;
        }
        
        if ([self.textView.text length])
        {
            CGFloat cFont = self.textView.font.pointSize;
            CGSize  tSize = IS_IOS_7?[self textSizeWithFont:cFont text:nil]:CGSizeZero;
            
            if (x > 0.f && y > 0.f)
            {
                do
                {
                    if (IS_IOS_7)
                    {
                        tSize = [self textSizeWithFont:++cFont text:nil];
                    }
                    else
                    {
                        [self.textView setFont:[self.curFont fontWithSize:++cFont]];
                    }
                }
                while (![self isBeyondSize:tSize] && cFont < MAX_FONT_SIZE);
                
                cFont = (cFont < MAX_FONT_SIZE) ? cFont : self.minFontSize;
                [self.textView setFont:[self.curFont fontWithSize:--cFont]];
                self.minFontSize = cFont;
                self.fontsize = cFont;
            }
            else
            {
                while ([self isBeyondSize:tSize] && cFont > 0)
                {
                    if (IS_IOS_7)
                    {
                        tSize = [self textSizeWithFont:--cFont text:nil];
                    }
                    else
                    {
                        [self.textView setFont:[self.curFont fontWithSize:--cFont]];
                    }
                }
                
                [self.textView setFont:[self.curFont fontWithSize:cFont]];
                self.fontsize = cFont;
            }
        }
        
        if (!IS_IOS_7) // solve strange bugs for iOS 6
        {
            NSString *text = self.textView.text; UIFont *font = self.textView.font;
            CGRect frame = self.textView.frame; [self.textView removeFromSuperview];
            
            [self createTextViewWithFrame:frame text:text font:font];
        }
        
        [self centerTextVertically]; [self setNeedsDisplay];
        [panGes setTranslation:CGPointZero inView:self];
        
    }

    if (panGes.state == UIGestureRecognizerStateEnded     ||
        panGes.state == UIGestureRecognizerStateCancelled ||
        panGes.state == UIGestureRecognizerStateFailed    )
    {
        [self.scaleView setHighlighted:NO]; [self centerTextVertically];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [self endEditing:YES];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidEndEditing:)])
        {
            [self.delegate textViewDidEndEditing:self];
        }
        return NO;
    }
    
    _isDeleting = (range.length >= 1 && text.length == 0);

    
    return YES;
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [self showTextViewBox ];
    
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView{
    NSLog(@"%@",textView.text);
    CGFloat height = [MuzzikItem heightForTextView:textView WithText:textView.text];
    if (height>self.textView.frame.size.height) {
        [self.textView setFrame:CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, self.textView.frame.size.height+self.textView.textContainer.lineFragmentPadding+self.textView.font.pointSize)];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height+self.textView.textContainer.lineFragmentPadding+self.textView.font.pointSize)];
        [self layoutSubViewWithFrame:self.frame];
        [self setNeedsDisplay];
    }else if (height+self.textView.textContainer.lineFragmentPadding+self.textView.font.pointSize<self.textView.frame.size.height) {
        [self.textView setFrame:CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, self.textView.frame.size.height-self.textView.textContainer.lineFragmentPadding-self.textView.font.pointSize)];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height-self.textView.textContainer.lineFragmentPadding-self.textView.font.pointSize)];
        [self layoutSubViewWithFrame:self.frame];
    }
    if ([self.delegate respondsToSelector:@selector(textViewDidChanged:)]) {
        [self.delegate textViewDidChanged:textView];
    }
}
//- (void)textViewDidChange:(UITextView *)textView
//{
//    NSString *calcStr = textView.text;
//    
//    if (![textView.text length]) [self.textView setText:@"A"];
//    
//    CGFloat cFont = self.textView.font.pointSize;
//    CGSize  tSize = IS_IOS_7?[self textSizeWithFont:cFont text:nil]:CGSizeZero;
//    
//    if (IS_IOS_7)
//    {
//        self.textView.textContainerInset = UIEdgeInsetsZero;
//    }
//    else
//    {
//        self.textView.contentOffset = CGPointZero;
//    }
//    
//    if (_isDeleting)
//    {
//        do
//        {
//            if (IS_IOS_7)
//            {
//                tSize = [self textSizeWithFont:++cFont text:nil];
//            }
//            else
//            {
//                [self.textView setFont:[self.curFont fontWithSize:++cFont]];
//            }
//        }
//        while (![self isBeyondSize:tSize] && cFont < MAX_FONT_SIZE);
//        
//        cFont = (cFont < MAX_FONT_SIZE) ? cFont : self.minFontSize;
//        [self.textView setFont:[self.curFont fontWithSize:--cFont]];
//    }
//    else
//    {
//        while ([self isBeyondSize:tSize] && cFont > 0)
//        {
//            if (IS_IOS_7)
//            {
//                tSize = [self textSizeWithFont:--cFont text:nil];
//            }
//            else
//            {
//                [self.textView setFont:[self.curFont fontWithSize:--cFont]];
//            }
//        }
//        
//        [self.textView setFont:[self.curFont fontWithSize:cFont]];
//    }
//    
//    [self centerTextVertically]; [self.textView setText:calcStr];
//}

- (CGSize)textSizeWithFont:(CGFloat)font text:(NSString *)string
{
    NSString *text = string ? string : self.textView.text;
    CGFloat pO = self.textView.textContainer.lineFragmentPadding * 2;
    CGFloat cW = self.textView.frame.size.width - pO;
    
    CGSize  tH = [text sizeWithFont:[self.curFont fontWithSize:font]
                  constrainedToSize:CGSizeMake(cW, MAXFLOAT)
                      lineBreakMode:NSLineBreakByWordWrapping];
    return  tH;
}

- (BOOL)isBeyondSize:(CGSize)size
{
    if (IS_IOS_7)
    {
        CGFloat ost = _textView.textContainerInset.top + _textView.textContainerInset.bottom;
        
        return size.height + ost > self.textView.frame.size.height;
    }
    else
    {
        return self.textView.contentSize.height > self.textView.frame.size.height;
    }
}

- (void)centerTextVertically
{
//    if (IS_IOS_7)
//    {
//        CGSize  tH     = [self textSizeWithFont:self.textView.font.pointSize text:nil];
//        CGFloat offset = (self.textView.frame.size.height - tH.height)/2.f;
//        
//        self.textView.textContainerInset = UIEdgeInsetsMake(offset, 0, offset, 0);
//    }
//    else
//    {
//        CGFloat fH = self.textView.frame.size.height;
//        CGFloat cH = self.textView.contentSize.height;
//        
//        [self.textView setContentOffset:CGPointMake(0, (cH-fH)/2.f)];
//    }
//    
//    #if TEST_CENTER_ALIGNMENT
//    [self.indicatorView setFrame:CGRectMake(0, offset, self.frame.size.width, tH.height)];
//    #else
//    // ...
//    #endif
}

//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetRGBStrokeColor(context, 1, 1, 1, !_hideView);
//    CGContextSetLineWidth(context, EDIT_BOX_LINE);
//    
//    CGRect drawRect       = self.textView.frame;
//    drawRect.size.width  += EDIT_BOX_LINE;
//    drawRect.size.height += EDIT_BOX_LINE;
//    drawRect.origin.x     = (self.frame.size.width-drawRect.size.width)/2.f;
//    drawRect.origin.y     = (self.frame.size.height-drawRect.size.height)/2.f;
//
//    CGContextAddRect(context, drawRect);
//    
//    CGContextStrokePath(context);
//}


@end
