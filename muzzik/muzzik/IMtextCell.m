//
//  ownerTableViewCell.m
//  muzzik
//
//  Created by muzzik on 16/1/6.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "IMTextCell.h"
#import "Utils_IM.h"
#import "UIButton+WebCache.h"
#import "DetaiMuzzikVC.h"
#import "WebViewcontroller.h"
@interface IMTextCell()<YYTextViewDelegate>

@end
@implementation IMTextCell
#define Message_size 15

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}
-(void)setup{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    _headImage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    _headImage.layer.cornerRadius = 20;
    _headImage.layer.masksToBounds = YES;
    [_headImage addTarget:self action:@selector(seeUserImage) forControlEvents:UIControlEventTouchUpInside];
    _timeLabel = [[UILabel alloc] init];
    [_timeLabel setFont:[UIFont fontWithName:Font_Next_Regular size:10]];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [_timeLabel setTextColor:Color_Text_3];
    [_timeLabel setBackgroundColor:[UIColor whiteColor]];
    _timelineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timedivideline"]];
    [_timelineImage setFrame:CGRectMake(SCREEN_WIDTH/2-140, 16, 280, 8)];
    _timelineImage.contentMode = UIViewContentModeScaleAspectFit;
    _messageLabel = [[YYTextView alloc] init];
    _messageLabel.editable = NO;
    _messageLabel.delegate = self;
    _messageLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    [_messageLabel setFont:[UIFont fontWithName:Font_Next_Regular size:Message_size]];
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _resendButton = [[UIButton alloc] init];
    [_resendButton setImage:[UIImage imageNamed:@"resend"] forState:UIControlStateNormal];
    [_resendButton addTarget:self action:@selector(rensendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_activityView];
    [self addSubview:_resendButton];
    
    _messageView = [[UIView alloc] init];
    _messageView.layer.cornerRadius = 5;
    _messageView.layer.masksToBounds = YES;
    [_messageView addSubview:_messageLabel];

    [self addSubview:_messageView];
    [self addSubview:_headImage];
    [self addSubview:_timelineImage];
    [self addSubview:_timeLabel];
}
-(void  ) configureCellWithMessage:(Message *) message{
    self.cellMessage = message;
    CGFloat height = 0;
    if ([message.needsToShowTime boolValue]) {
        [_timelineImage setHidden:NO];
        [_timeLabel setHidden:NO];
        [_timeLabel setBounds:CGRectMake(0, 0, 120, 15)];
        _timeLabel.text = [Utils_IM getStringFromIMDate:message.sendTime];
        [_timeLabel sizeToFit];
        [_timeLabel setFrame:CGRectMake(SCREEN_WIDTH/2 - _timeLabel.frame.size.width/2-5, 16, _timeLabel.frame.size.width+10, 8)];
        height += 40;
    }else{
        [_timeLabel setHidden:YES];
        [_timelineImage setHidden:YES];
        height+=8;
    }
    
    if ([message.messageType isEqualToString:Type_IM_TextMessage]) {
        _messageView.layer.borderWidth = 0;
        [_messageLabel setFrame:CGRectMake(0, 0, SCREEN_WIDTH-151, 1000)];
        _messageLabel.text = message.messageContent;
        [_messageLabel sizeToFit];
        
        if ([message.isOwner boolValue]) {
            
            [_headImage setFrame:CGRectMake(SCREEN_WIDTH-53, height, 40, 40)];
            
            [_messageLabel setFrame:CGRectMake(10, 10, _messageLabel.frame.size.width, _messageLabel.frame.size.height)];
            
            [_messageView setBackgroundColor:Color_Active_Button_2];
            [_messageView setFrame:CGRectMake(SCREEN_WIDTH-83-_messageLabel.frame.size.width, height, _messageLabel.frame.size.width+20,  _messageLabel.frame.size.height+17)];
            
        }else{
            [_headImage setFrame:CGRectMake(13, height, 40, 40)];
            
            
            [_messageLabel setFrame:CGRectMake(10, 10, _messageLabel.frame.size.width, _messageLabel.frame.size.height)];
            [_messageView setBackgroundColor:Color_line_1];
            [_messageView setFrame:CGRectMake(63, height, _messageLabel.frame.size.width+20,  _messageLabel.frame.size.height+17)];
           
        }
        _messageLabel.textAlignment = NSTextAlignmentLeft;
    }
    if ([message.sendStatue isEqualToString:Statue_OK]) {
        [_resendButton setHidden:YES];
        [_activityView stopAnimating];
        [_activityView setHidden:YES];
    }else if ([message.sendStatue isEqualToString:Statue_Sending]){
        [_resendButton setHidden:YES];
        [_activityView setHidden:NO];
        if ([message.isOwner boolValue]) {
            [_activityView setFrame:CGRectMake(_messageView.frame.origin.x-25, _messageView.frame.origin.y, 20, _messageView.frame.size.height)];
            [_activityView startAnimating];
        }else{
            [_activityView setFrame:CGRectMake(_messageView.frame.origin.x+_messageView.frame.size.width+5, _messageView.frame.origin.y, 20, _messageView.frame.size.height)];
            [_activityView startAnimating];
        }
        
    }else{
        [_resendButton setHidden:NO];
        [_activityView stopAnimating];
        [_activityView setHidden:YES];
        if ([message.isOwner boolValue]) {
            [_resendButton setFrame:CGRectMake(_messageView.frame.origin.x-50, _messageView.frame.origin.y, 40, 40)];
            [_activityView setFrame:CGRectMake(_messageView.frame.origin.x-25, _messageView.frame.origin.y, 20, _messageView.frame.size.height)];
        }else{
            [_resendButton setFrame:CGRectMake(_messageView.frame.origin.x+_messageView.frame.size.width+5, _messageView.frame.origin.y, 40, 40)];
        }
    }
    NSLog(@"name:%@   avatar:%@,",message.messageUser.name,message.messageUser.avatar);
    [_headImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,message.messageUser.avatar,Image_Size_Small]] forState:UIControlStateNormal];
}
-(void)seeUserImage{
    CGRect rect = [self convertRect:self.headImage.frame toView:self.imvc.view];
    
    [self.imvc showUserImageWithimageKey:self.cellMessage.messageUser.avatar holdImage:[self.headImage imageForState:UIControlStateNormal] orginalRect:rect];
}

-(void)rensendMessage{
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_resendButton setHidden:YES];
    [_activityView setHidden:NO];
    [_activityView startAnimating];
    RCTextMessage *rctext = [[RCTextMessage alloc] init];
    [rctext setSenderUserInfo:[RCIMClient sharedRCIMClient].currentUserInfo];
    rctext.content = self.cellMessage.messageContent;
    
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:self.imvc.con.targetId content:rctext pushContent:[NSString stringWithFormat:@"%@: %@",self.imvc.con.targetUser.name,self.cellMessage.messageContent] success:^(long messageId) {
        self.cellMessage.sendStatue = Statue_OK;
        [app.managedObjectContext save:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_resendButton setHidden:YES];
            [_activityView stopAnimating];
            [_activityView setHidden:YES];
        });
        
    } error:^(RCErrorCode nErrorCode, long messageId) {
        self.cellMessage.sendStatue = Statue_Failed;
        [app.managedObjectContext save:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_resendButton setHidden:NO];
            [_activityView stopAnimating];
            [_activityView setHidden:YES];
        });
        
    }];
    
}
-(void)textView:(YYTextView *)textView didTapHighlight:(YYTextHighlight *)highlight inRange:(NSRange)characterRange rect:(CGRect)rect{
    NSString *string = [textView.text substringWithRange:characterRange];
    if ([string rangeOfString:@"http://"].location == NSNotFound) {
        string = [NSString stringWithFormat:@"http://%@",string];
    }
    NSURL *url =[NSURL URLWithString: string];
    if (url) {
        WebViewcontroller *webvc = [[WebViewcontroller alloc] init];
        webvc.url = url;
        [self.imvc.navigationController pushViewController:webvc animated:YES];
    }
}
@end
