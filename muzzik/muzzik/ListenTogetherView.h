//
//  ListenTogetherView.h
//  muzzik
//
//  Created by muzzik on 16/2/16.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#define Status_NoMusic      0
#define Status_Music        1
#define Status_together     2
@protocol ListenViewDelegate <NSObject>

- (void) listenActionInStatue:(NSInteger) status;
@end

@interface ListenTogetherView : UIView
@property(nonatomic,copy) NSString *leftAvatarString;
@property(nonatomic,copy) NSString *rightAvatarString;
@property(nonatomic,retain) Message *listenMessage;
@property(nonatomic,assign) NSInteger status;
@property(nonatomic,weak) id<ListenViewDelegate> delegate;
@end
