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
    [_headImage setImage:[UIImage imageNamed:@"frame"] forState:UIControlStateNormal];
    [_headImage addTarget:self action:@selector(showUserInfo) forControlEvents:UIControlEventTouchUpInside];
    _timeLabel = [[UILabel alloc] init];
    [_timeLabel setFont:[UIFont fontWithName:Font_Next_Regular size:10]];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [_timeLabel setTextColor:Color_Additional_5];
    [_timeLabel setBackgroundColor:[UIColor whiteColor]];
    _timelineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timedivideline"]];
    [_timelineImage setFrame:CGRectMake(SCREEN_WIDTH/2-140, 16, 280, 8)];
    _timelineImage.contentMode = UIViewContentModeScaleAspectFit;
    _messageLabel = [[YYTextView alloc] init];
    _messageLabel.editable = NO;
    _messageLabel.textColor = Color_Text_1;
    _messageLabel.delegate = self;
    _messageLabel.layer.cornerRadius = 5;
    _messageLabel.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _messageLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    [_messageLabel setFont:[UIFont fontWithName:Font_Next_Regular size:Message_size]];


    [self addSubview:_messageLabel];
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
        
        CGSize size = [_timeLabel sizeThatFits:CGSizeMake(120, 15)];
        [_timeLabel setFrame:CGRectMake(SCREEN_WIDTH/2 -size.width/2-5, 16,size.width+10, 8)];
        height += 48;
    }else{
        [_timeLabel setHidden:YES];
        [_timelineImage setHidden:YES];
        height+=8;
    }
    
    if ([message.messageType isEqualToString:Type_IM_TextMessage]) {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:message.messageContent];
        text.yy_font = [UIFont fontWithName:Font_Next_medium size:Message_size];
        text.yy_color = Color_Text_1;
        _messageLabel.attributedText = text;
        CGSize labelsize = [_messageLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH-151, 2000)];
        
        [_headImage setFrame:CGRectMake(13, height, 40, 40)];
        
        
        [_messageLabel setFrame:CGRectMake(63, height, labelsize.width, labelsize.height)];
//        [_messageLabel setTextColor:[UIColor blackColor]];
        [_messageLabel setBackgroundColor:Color_line_2];
        _messageLabel.textAlignment = NSTextAlignmentLeft;
    }
    [_headImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,message.messageUser.avatar,Image_Size_Small]] forState:UIControlStateNormal];
}
//-(void)seeUserImage{
//    CGRect rect = [self convertRect:self.headImage.frame toView:self.imvc.view];
//    [self.imvc.view resignFirstResponder];
//    [self.imvc showUserImageWithimageKey:self.cellMessage.messageUser.avatar holdImage:[self.headImage imageForState:UIControlStateNormal] orginalRect:rect];
//}
-(void)showUserInfo{
    [self.imvc userDetail:self.cellMessage.messageUser.user_id];
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
