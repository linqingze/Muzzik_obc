//
//  SelectionLabel.h
//  muzzik
//
//  Created by muzzik on 15/6/19.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SelectionLabel;
@protocol SelectionLabelDelegate <NSObject>

- (void) tappedWithObject:(SelectionLabel*) sender;
@end

@interface SelectionLabel : UILabel
@property (nonatomic,weak) id<SelectionLabelDelegate> delegate;
@property (nonatomic,retain) NSDictionary *genre;
@property (nonatomic,assign) BOOL isSelected;
@end
