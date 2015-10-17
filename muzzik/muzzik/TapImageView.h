//
//  TapImageView.h
//  TestLayerImage
//
//  Created by lcc on 14-8-1.
//  Copyright (c) 2014年 lcc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TapImageView;
@protocol TapImageViewDelegate <NSObject>

- (void) tappedWithImage:(TapImageView *) sender;

@end

@interface TapImageView : UIImageView

@property (nonatomic, retain) MuzzikUser *user;
@property (nonatomic, copy) NSString *followType;
@property (nonatomic,weak) id<TapImageViewDelegate> delegate;

@end
