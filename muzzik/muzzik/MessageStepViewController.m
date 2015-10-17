//
//  MessageStepViewController.m
//  muzzik
//
//  Created by muzzik on 15/4/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "MessageStepViewController.h"
#import "emojiCollectionCell.h"
#import "FriendVC.h"
#import "TopicHotVC.h"
#import "ChooseMusicVC.h"
#import "choosImageVC.h"
#import "HPGrowingTextView.h"
#import "IBActionSheet.h"
@interface MessageStepViewController ()<UITextViewDelegate,UIActionSheetDelegate, IBActionSheetDelegate>{
    UILabel *charaterLabel;
    UIView *actionView;
    UIButton *atButton;
    UIButton *privateButton;
    UITextView *textview;
    UILabel *placeHolder;
    UILabel *songName;
    UILabel *artist;
    BOOL isPrivate;
    UITextField *_textfield;
    UIButton *AtButton;
    UILabel *addMusicTipsLabel;
    IBActionSheet *actionSheet;
}
@end

@implementation MessageStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"编辑信息（1/3）" leftBtn:Constant_backImage rightBtn:2];
    UIButton *topicButton = [[UIButton alloc] initWithFrame:CGRectMake(13, 16, 80, 20)];
    topicButton.layer.cornerRadius = 3;
    topicButton.clipsToBounds = YES;
    [topicButton setBackgroundImage:[MuzzikItem createImageWithColor:Color_Active_Button_1] forState:UIControlStateNormal];
    [topicButton setTitle:@"#添加话题#" forState:UIControlStateNormal];
    [topicButton addTarget:self action:@selector(getTopic) forControlEvents:UIControlEventTouchUpInside];
    [topicButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    topicButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    topicButton.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:topicButton];
    privateButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-120, 16, 90, 20)];
    [privateButton setImage:[UIImage imageNamed:Image_visibleImage] forState:UIControlStateNormal];
    [privateButton addTarget:self action:@selector(changePrivateAction) forControlEvents:UIControlEventTouchUpInside];
    charaterLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-25, 16, 20, 20)];
    charaterLabel.text = @"140";
    charaterLabel.textColor = Color_Additional_5;
    charaterLabel.font = [UIFont boldSystemFontOfSize:9];
    [self.view addSubview:charaterLabel];
    [self.view addSubview:privateButton];
    placeHolder = [[UILabel alloc] initWithFrame:CGRectMake(17, 65, 200, 20)];
    placeHolder.text = @"这一刻你想到了什么...";
    placeHolder.textColor = Color_Text_2;
    placeHolder.font = [UIFont boldSystemFontOfSize:15];
    textview = [[UITextView alloc] initWithFrame:CGRectMake(13, 60, SCREEN_WIDTH-26, SCREEN_WIDTH-60)];
    textview.delegate = self;
    textview.textColor = Color_Text_2;
    textview.font = [UIFont systemFontOfSize:15];
    textview.tintColor = Color_Active_Button_1;
    textview.returnKeyType = UIReturnKeyDone;
    
    [self.view addSubview:textview];
    [self.view addSubview:placeHolder];
    
    UIButton *changSongButton = [[UIButton alloc] initWithFrame:CGRectMake(13,SCREEN_HEIGHT-144, 40, 40)];
    [changSongButton setImage:[UIImage imageNamed:Image_add_Song] forState:UIControlStateNormal];
    [changSongButton addTarget:self action:@selector(changsongAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changSongButton];
    UIView *separateLine = [[UIView alloc] initWithFrame:CGRectMake(60, SCREEN_HEIGHT-144, 1, 40)];
    [separateLine setBackgroundColor:Color_line_1];
    [self.view addSubview:separateLine];
    
    addMusicTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(changSongButton.frame)+23, SCREEN_HEIGHT-144, 150, 40)];
    [addMusicTipsLabel setFont:[UIFont systemFontOfSize:14]];
    [addMusicTipsLabel setTextColor:Color_Text_2];
    addMusicTipsLabel.text = @"添加歌曲";
    [self.view addSubview:addMusicTipsLabel];
    
    songName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(changSongButton.frame)+23, CGRectGetMidY(changSongButton.frame)-20, SCREEN_WIDTH-CGRectGetMaxX(changSongButton.frame)-33, 20)];
    songName.textColor = Color_Theme_5;
    songName.font = [UIFont fontWithName:Font_Next_Bold size:15];
    [self.view addSubview:songName];
    
    artist = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(changSongButton.frame)+23, CGRectGetMidY(changSongButton.frame)+2, SCREEN_WIDTH-CGRectGetMaxX(changSongButton.frame)-33, 20)];
    artist.textColor = Color_Theme_5;
    artist.font = [UIFont fontWithName:Font_Next_Bold size:12];
    [self.view addSubview:artist];
    
    AtButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100, 20, 44, 44)];
    [AtButton setImage:[UIImage imageNamed:Image_At_button] forState:UIControlStateNormal];
    [AtButton addTarget:self action:@selector(AtFriend) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tapOnview = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapOnview];
    //草稿箱进入的文本复制
    if ([self.message length]>0) {
        [placeHolder setHidden:YES];
        textview.text = self.message;
    }
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.view addSubview:AtButton];
    MuzzikObject *mobject = [MuzzikObject shareClass];
    mobject.isMessageVCOpen = YES;
    if (mobject.music ) {
        songName.text = mobject.music.name;
        artist.text = mobject.music.artist;
        [addMusicTipsLabel setHidden:YES];
        [MuzzikItem getLyricByMusic:mobject.music];
    }
    if ([mobject.tempmessage length]>0) {
        [placeHolder setHidden:YES];
        textview.text = [textview.text stringByAppendingString:mobject.tempmessage];
        charaterLabel.text = [NSString stringWithFormat:@"%lu",140 - textview.text.length];
        mobject.tempmessage = nil;
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [AtButton removeFromSuperview];
}
#pragma textView Delegate
-(void)textViewDidChange:(UITextView *)textView{
    if (textview.text.length == 0) {
        [placeHolder setHidden:NO];
    }else{
        [placeHolder setHidden:YES];
        if ([[textview.text substringFromIndex:textview.text.length-1] isEqualToString:@"\n"] ) {
            textview.text =[textview.text substringToIndex:textview.text.length-1];
            [textview resignFirstResponder];
        }
    }
    if (textview.text.length>140) {
        textview.text =[textview.text substringToIndex:140];
    }
    charaterLabel.text = [NSString stringWithFormat:@"%lu",140 - textview.text.length];
    
}
#pragma -mark action
-(void) changePrivateAction{
    if (!isPrivate) {
        [privateButton setImage:[UIImage imageNamed:Image_invisibleImage] forState:UIControlStateNormal];
        
    }else{
        [privateButton setImage:[UIImage imageNamed:Image_visibleImage] forState:UIControlStateNormal];
    }
    isPrivate = !isPrivate;
}

-(void)getTopic{
    TopicHotVC *topicvc = [[TopicHotVC alloc] init];
    [self.navigationController pushViewController:topicvc animated:YES];
}

-(void) changsongAction{
    ChooseMusicVC *choosevc = [[ChooseMusicVC alloc] init];
    [self.navigationController pushViewController:choosevc animated:YES];
}

-(void)AtFriend{
    FriendVC *friendvc = [[FriendVC alloc] init];
    [self.navigationController pushViewController:friendvc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)rightBtnAction:(UIButton *)sender{
    MuzzikObject *mobject = [MuzzikObject shareClass];
    if ([textview.text length]>0) {
        mobject.message = textview.text;
    }else{
        mobject.message = @"I Love This Muzzik!";
    }
    
    mobject.isPrivate = isPrivate;
    choosImageVC *chooseimgevc = [[choosImageVC alloc] init];
    [self.navigationController pushViewController:chooseimgevc animated:YES];
    
}
-(void)tapAction:(UITapGestureRecognizer *)tap{
    [textview resignFirstResponder];
    actionSheet = [[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存至草稿箱",@"不保存", nil];
    [actionSheet showInView:self.view.window];
    [actionSheet setButtonTextColor:Color_Active_Button_1 forButtonAtIndex:1];
    
}
- (void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if(buttonIndex==2){
        return;
    }else if(buttonIndex == 0){
        NSArray *muzzikDrafts = [MuzzikItem muzzikDraftsFromLocal];
        MuzzikObject *mobject = [MuzzikObject shareClass];
        
        NSDate *  senddate=[NSDate date];
        
        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
        
        [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:textview.text,@"message",[dateformatter stringFromDate:senddate],@"lastdate",mobject.music.music_id,@"music_id",mobject.music.name,@"music_name",mobject.music.artist,@"music_artist",mobject.music.key,@"music_key", nil];
        if ([muzzikDrafts count] == 0) {
            muzzikDrafts = @[dic];
        }else{
            NSMutableArray *mutableArr = [muzzikDrafts mutableCopy];
            [mutableArr insertObject:dic atIndex:0];
            muzzikDrafts = [mutableArr copy];
        }
        [MuzzikItem addMuzzikDraftsToLocal:muzzikDrafts];
        mobject.music = nil;
        mobject.isMessageVCOpen = NO;
        mobject.tempmessage = @"";
        [self.navigationController popViewControllerAnimated:YES];
    }else if(buttonIndex == 1){
        MuzzikObject *mobject = [MuzzikObject shareClass];
        mobject.music = nil;
        mobject.isMessageVCOpen = NO;
        mobject.tempmessage = @"";
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
