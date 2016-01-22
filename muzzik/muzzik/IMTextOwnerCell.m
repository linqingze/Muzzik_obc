#import "IMTextOwnerCell.h"
#import "Utils_IM.h"
#import "UIButton+WebCache.h"
#import "DetaiMuzzikVC.h"
#import "WebViewcontroller.h"
@interface IMTextOwnerCell()<YYTextViewDelegate>

@end
@implementation IMTextOwnerCell
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
    _messageLabel.textColor = [UIColor whiteColor];
    _messageLabel.editable = NO;
    _messageLabel.delegate = self;
    _messageLabel.layer.cornerRadius = 5;
    _messageLabel.textContainerInset = UIEdgeInsetsMake(9, 10, 9, 10);
    _messageLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    [_messageLabel setFont:[UIFont fontWithName:Font_Next_Regular size:Message_size]];
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _resendButton = [[UIButton alloc] init];
    [_resendButton setImage:[UIImage imageNamed:@"resend"] forState:UIControlStateNormal];
    [_resendButton addTarget:self action:@selector(rensendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_activityView];
    [self addSubview:_resendButton];
    
    
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
        [_timeLabel sizeToFit];
        [_timeLabel setFrame:CGRectMake(SCREEN_WIDTH/2 - _timeLabel.frame.size.width/2-5, 16, _timeLabel.frame.size.width+10, 8)];
        height += 40;
    }else{
        [_timeLabel setHidden:YES];
        [_timelineImage setHidden:YES];
        height+=8;
    }
    
    if ([message.messageType isEqualToString:Type_IM_TextMessage]) {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:message.messageContent];
        text.yy_font = [UIFont fontWithName:Font_Next_Regular size:Message_size];
        text.yy_color = [UIColor whiteColor];
        _messageLabel.attributedText = text;
        CGSize labelsize = [_messageLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH-151, 2000)];
        
        [_headImage setFrame:CGRectMake(SCREEN_WIDTH-53, height, 40, 40)];
        
        [_messageLabel setFrame:CGRectMake(SCREEN_WIDTH-73-labelsize.width, height, labelsize.width, labelsize.height)];
        [_messageLabel setTextColor:[UIColor whiteColor]];
        [_messageLabel setBackgroundColor:Color_Active_Button_2];
        _messageLabel.textAlignment = NSTextAlignmentLeft;
    }
    if ([message.sendStatue isEqualToString:Statue_OK]) {
        [_resendButton setHidden:YES];
        [_activityView stopAnimating];
        [_activityView setHidden:YES];
    }else if ([message.sendStatue isEqualToString:Statue_Sending] && ![Utils_IM checkLimitedTime:[NSDate date] oldDate:message.sendTime] ){
        [_resendButton setHidden:YES];
        [_activityView setHidden:NO];
        [_activityView setFrame:CGRectMake(_messageLabel.frame.origin.x-43, _messageLabel.frame.origin.y + 8, 24, 24)];
        [_activityView startAnimating];
        
    }else{
        [_resendButton setHidden:NO];
        [_activityView stopAnimating];
        [_activityView setHidden:YES];
        [_resendButton setFrame:CGRectMake(_messageLabel.frame.origin.x-50, _messageLabel.frame.origin.y, 40, 40)];
        [_activityView setFrame:CGRectMake(_messageLabel.frame.origin.x-43, _messageLabel.frame.origin.y + 8, 24, 24)];
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