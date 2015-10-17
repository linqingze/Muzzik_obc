//
//  topicLabel.h
//  muzzik
//
//  Created by muzzik on 15/5/13.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
@class topicLabel;
@protocol TapLabelDelegate <NSObject>

- (void) tappedWithObject:(topicLabel*) sender;

@end
@interface topicLabel : UILabel
@property (nonatomic,weak) id<TapLabelDelegate>delegate;
@property (nonatomic,copy) NSString *tid;
-(void)setText:(NSString *)text font:(UIFont *) font color:(long)color;
@end
