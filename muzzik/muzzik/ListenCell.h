//
//  ListenCell.h
//  muzzik
//
//  Created by muzzik on 16/1/31.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMConversationViewcontroller.h"
@interface ListenCell : UITableViewCell
@property (nonatomic,retain) UIButton *headImage;
@property (nonatomic,retain) UIImageView *timelineImage;
@property (nonatomic,retain) UILabel *timeLabel;
@property (nonatomic,retain) UIView *messageView;
@property (nonatomic,retain) UILabel *artistNamel;
@property (nonatomic,retain) UILabel *songName;
@property (nonatomic,retain) Message *cellMessage;
@property (nonatomic,retain) muzzik *playMuzzik;
@property (nonatomic,weak) IMConversationViewcontroller *imvc;

-(void) updateMusicMessage;
@end
