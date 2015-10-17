//
//  PhotoImageView.h
//  muzzik
//
//  Created by muzzik on 15/6/8.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PhotoImageView;
@protocol PhotoImageViewDelegate <NSObject>

- (void) tappedToSave:(PhotoImageView *) sender;
@end

@interface PhotoImageView : UIImageView
@property (nonatomic,weak) id<PhotoImageViewDelegate> delegate;
@end
