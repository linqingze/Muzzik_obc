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
#import "HPGrowingTextView.h"
#import "IBActionSheet.h"
#import "JSImagePickerViewController.h"
#import "NLImageCropperView.h"
#import "ASIFormDataRequest.h"
#define view_padding 13
@interface MessageStepViewController ()<UITextViewDelegate,UIActionSheetDelegate, IBActionSheetDelegate,HPGrowingTextViewDelegate,JSImagePickerViewControllerDelegate,NLImageCropperViewDelegate>{
    UILabel *charaterLabel;
    UIView *actionView;
    UIButton *atButton;
    UIButton *privateButton;
    HPGrowingTextView *hpTextview;
    UILabel *songName;
    UILabel *artist;
    BOOL isPrivate;
    UITextField *_textfield;
    UIButton *AtButton;
    UILabel *addMusicTipsLabel;
    IBActionSheet *actionSheet;
    UIScrollView *mainScroll;
    
    UIView *headerView;
    UIImageView *headImage;
    UILabel * notifyLabel;
    UIImage *userImage;
    NLImageCropperView* _imageCropper;
    UIButton *closeButton;
    UIView *separateLineUp;
    
    UIView *separateLineDown;
    
    muzzik *newmuzzik;
    BOOL isSending;
}
@end

@implementation MessageStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"编辑信息" leftBtn:Constant_backImage rightBtn:5];
    UIButton *topicButton = [[UIButton alloc] initWithFrame:CGRectMake(view_padding, 16, 80, 20)];
    topicButton.layer.cornerRadius = 3;
    topicButton.clipsToBounds = YES;
    [topicButton setBackgroundImage:[MuzzikItem createImageWithColor:Color_Active_Button_1] forState:UIControlStateNormal];
    [topicButton setTitle:@"#添加话题#" forState:UIControlStateNormal];
    [topicButton addTarget:self action:@selector(getTopic) forControlEvents:UIControlEventTouchUpInside];
    [topicButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    topicButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    topicButton.titleLabel.textColor = [UIColor whiteColor];
    mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-124)];
    [self.view addSubview:mainScroll];
    [mainScroll addSubview:topicButton];
    privateButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-120, 16, 90, 20)];
    [privateButton setImage:[UIImage imageNamed:Image_visibleImage] forState:UIControlStateNormal];
    [privateButton addTarget:self action:@selector(changePrivateAction) forControlEvents:UIControlEventTouchUpInside];
    charaterLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-25, 16, 20, 20)];
    charaterLabel.text = @"140";
    charaterLabel.textColor = Color_Additional_5;
    charaterLabel.font = [UIFont boldSystemFontOfSize:9];
    [mainScroll addSubview:charaterLabel];
    [mainScroll addSubview:privateButton];
    hpTextview = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(view_padding, 48, SCREEN_WIDTH-26, 70)];
    hpTextview.delegate = self;
    //hpTextview.backgroundColor = Color_Theme_3;
    hpTextview.textColor = Color_Text_2;
    hpTextview.font = [UIFont systemFontOfSize:15];
    hpTextview.tintColor = Color_Active_Button_1;
    [hpTextview setReturnKeyType:UIReturnKeyDone];
    hpTextview.placeholderColor = Color_Text_2;
    hpTextview.maxHeight= 250;
    hpTextview.maxNumberOfLines = 8;
    hpTextview.placeholder = @"这一刻你想到了什么...";
    [mainScroll addSubview:hpTextview];
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(hpTextview.frame)+10, SCREEN_WIDTH, SCREEN_WIDTH-2*view_padding)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    UIImageView *defaultImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-25,SCREEN_WIDTH/2-2*view_padding-60 , 50, 50)];
    [defaultImage setImage:[UIImage imageNamed:@"ThumbnailsImage"]];
    [headerView addSubview:defaultImage];
    UILabel *add = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH/2-22, SCREEN_WIDTH, 15)];
    [add setTextColor:[UIColor colorWithHexString:@"555555"]];
    [add setFont:[UIFont systemFontOfSize:14]];
    [add setText:@"添加图片"];
    add.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:add];
    
    
    
    UILabel *add1 = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH/2+4, SCREEN_WIDTH, 15)];
    [add1 setTextColor:[UIColor colorWithHexString:@"777777"]];
    [add1 setFont:[UIFont systemFontOfSize:12]];
    [add1 setText:@"（上传图片，丰富你的Muzzik）"];
    add1.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:add1];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getPicture)];
    [headerView addGestureRecognizer:tap];
    [mainScroll addSubview:headerView];
    
    headImage = [[UIImageView alloc] initWithFrame:CGRectMake(view_padding, 0, SCREEN_WIDTH-2*view_padding, SCREEN_WIDTH-2*view_padding)];
    headImage.layer.cornerRadius = 3;
    headImage.layer.masksToBounds = YES;
    headImage.contentMode = UIViewContentModeScaleAspectFit;
    [headerView addSubview:headImage];
    separateLineUp = [[UIView alloc] initWithFrame:CGRectMake(view_padding, 0, SCREEN_WIDTH-26, 1)];
    [separateLineUp setBackgroundColor:Color_underLine];
    
    
    closeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-view_padding-25, -5, 30, 30)];
    [closeButton setImage:[UIImage imageNamed:@"editdeletepicImage"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeImage) forControlEvents:UIControlEventTouchUpInside];
    
    
    separateLineDown = [[UIView alloc] initWithFrame:CGRectMake(view_padding, SCREEN_WIDTH-2*view_padding, SCREEN_WIDTH-2*view_padding, 1)];
    [separateLineDown setBackgroundColor:Color_underLine];
    
    [headerView addSubview:separateLineDown];
    [headerView addSubview:separateLineUp];
    
    _imageCropper = [[NLImageCropperView alloc] initWithFrame:self.view.bounds];
    _imageCropper.delegate = self;

    
    
    UIView *selectMusic = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-124, SCREEN_WIDTH, 60)];
//    [selectMusic setBackgroundColor:Color_line_2];
//    selectMusic.layer.borderColor = Color_line_1.CGColor;
    [selectMusic addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changsongAction:)]];
    UIButton *changSongButton = [[UIButton alloc] initWithFrame:CGRectMake(13,10, 40, 40)];
    [changSongButton setImage:[UIImage imageNamed:Image_add_Song] forState:UIControlStateNormal];
    
    [changSongButton addTarget:self action:@selector(changsongAction:) forControlEvents:UIControlEventTouchUpInside];
    [selectMusic addSubview:changSongButton];
    UIView *separateLine = [[UIView alloc] initWithFrame:CGRectMake(60, 10, 1, 40)];
    [separateLine setBackgroundColor:Color_line_1];
    [selectMusic addSubview:separateLine];
    
    addMusicTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(changSongButton.frame)+23, 10, 150, 40)];
    [addMusicTipsLabel setFont:[UIFont systemFontOfSize:14]];
    [addMusicTipsLabel setTextColor:Color_Text_2];
    addMusicTipsLabel.text = @"添加歌曲";
    [selectMusic addSubview:addMusicTipsLabel];
    
    songName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(changSongButton.frame)+23, CGRectGetMidY(changSongButton.frame)-20, SCREEN_WIDTH-CGRectGetMaxX(changSongButton.frame)-33, 20)];
    songName.textColor = Color_Theme_5;
    songName.font = [UIFont fontWithName:Font_Next_Bold size:15];
    [selectMusic addSubview:songName];
    
    artist = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(changSongButton.frame)+23, CGRectGetMidY(changSongButton.frame)+2, SCREEN_WIDTH-CGRectGetMaxX(changSongButton.frame)-33, 20)];
    artist.textColor = Color_Theme_5;
    artist.font = [UIFont fontWithName:Font_Next_Bold size:12];
    [selectMusic addSubview:artist];
    [self.view addSubview: selectMusic];
    
    AtButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100, 20, 44, 44)];
    [AtButton setImage:[UIImage imageNamed:Image_At_button] forState:UIControlStateNormal];
    [AtButton addTarget:self action:@selector(AtFriend) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tapOnview = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapOnview];
    //草稿箱进入的文本复制
    if ([self.message length]>0) {
        hpTextview.text = self.message;
    }
     [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH,CGRectGetMaxY(hpTextview.frame)+SCREEN_WIDTH-2*view_padding+15)];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    MuzzikObject *mobject = [MuzzikObject shareClass];
    mobject.isMessageVCOpen = YES;
    if (mobject.music ) {
        songName.text = mobject.music.name;
        artist.text = mobject.music.artist;
        [addMusicTipsLabel setHidden:YES];
//        [MuzzikItem getLyricByMusic:mobject.music];
    }
    if (mobject.image) {
        [headImage setImage:mobject.image];
        userImage = mobject.image;
    }
    if ([mobject.tempmessage length]>0) {
        hpTextview.text = [hpTextview.text stringByAppendingString:mobject.tempmessage];
        charaterLabel.text = [NSString stringWithFormat:@"%lu",140 - hpTextview.text.length];
        mobject.tempmessage = nil;
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController.view addSubview:AtButton];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [AtButton removeFromSuperview];
}
#pragma textView Delegate

-(void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height{
    CGRect rect = headerView.frame;
    if (growingTextView.frame.size.height >=80) {
        rect.origin.y = growingTextView.frame.size.height+growingTextView.frame.origin.y+10;
        headerView.frame = rect;
        [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH, rect.origin.y+SCREEN_WIDTH-2*view_padding+15)];
    }
}

-(BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [growingTextView resignFirstResponder];
        return NO;
    }
    if (range.location+range.length>=140 && ![text isEqualToString:@""]) {
        return NO;
    }else{
        return YES;
    }
}
-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    charaterLabel.text = [NSString stringWithFormat:@"%lu",140 - growingTextView.text.length];
    if ([growingTextView.text length]>140) {
        growingTextView.text = [growingTextView.text substringToIndex:140];
    }
}
#pragma -mark action

-(void)setPoMuzzikMessage:(NSDictionary *)dic{
    userInfo *user = [userInfo shareClass];
    MuzzikObject *mobject = [MuzzikObject shareClass];
    newmuzzik = [muzzik new];
    newmuzzik.muzzik_id = [dic objectForKey:@"_id"];
    newmuzzik.ismoved = NO;
    newmuzzik.date = [dic objectForKey:@"date"];
    newmuzzik.message = [dic objectForKey:@"message"];
    if ([mobject.imageKey length]>0 ) {
        newmuzzik.image = mobject.imageKey;
    }
    
    newmuzzik.topics = [dic objectForKey:@"topics"];
    newmuzzik.users = [dic objectForKey:@"users"];
    newmuzzik.type = [dic objectForKey:@"type"];
    newmuzzik.onlytext = [[dic objectForKey:@"onlyText"] boolValue];
    newmuzzik.isReposted = NO;
    newmuzzik.reposts = [dic objectForKey:@"reposts"];
    newmuzzik.shares = [dic objectForKey:@"shares"];
    newmuzzik.comments = [dic objectForKey:@"comments"];
    newmuzzik.color = [dic objectForKey:@"color"];
    newmuzzik.moveds = [dic objectForKey:@"moveds"];
    newmuzzik.isprivate = [[dic objectForKey:@"private"] boolValue];
    newmuzzik.plays = [dic objectForKey:@"plays"];
    newmuzzik.repostID = [dic objectForKey:@"repostID"];
    newmuzzik.title = [dic objectForKey:@"title"];
    newmuzzik.repostDate = [dic objectForKey:@"repostDate"];
    newmuzzik.reposter = [MuzzikUser new];
    newmuzzik.reposter.name = [[dic objectForKey:@"repostUser"] objectForKey:@"name"];
    newmuzzik.reposter.user_id = [[dic objectForKey:@"repostUser"] objectForKey:@"_id"];
    newmuzzik.reposter.avatar = [[dic objectForKey:@"repostUser"] objectForKey:@"avatar"];
    newmuzzik.reposter.gender = [[dic objectForKey:@"repostUser"] objectForKey:@"gender"];
    
    newmuzzik.MuzzikUser = [MuzzikUser new];
    newmuzzik.MuzzikUser.avatar = user.avatar;
    newmuzzik.MuzzikUser.user_id = user.uid;
    newmuzzik.MuzzikUser.gender = user.gender;
    newmuzzik.MuzzikUser.name = user.name;
    newmuzzik.MuzzikUser.isFollow = NO;
    newmuzzik.MuzzikUser.isFans = NO;
    newmuzzik.music = [music new];
    newmuzzik.music.music_id = mobject.music.music_id;
    newmuzzik.music.artist = mobject.music.artist;
    newmuzzik.music.key = mobject.music.key;
    newmuzzik.music.name = mobject.music.name;
    [[NSNotificationCenter defaultCenter] postNotificationName:String_SendNewMuzzikDataSource_update object:newmuzzik];
}

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

-(void) changsongAction:(UITapGestureRecognizer *)gesture{
    ChooseMusicVC *choosevc = [[ChooseMusicVC alloc] init];
    [self.navigationController pushViewController:choosevc animated:YES];
}

-(void)AtFriend{
    FriendVC *friendvc = [[FriendVC alloc] init];
    MuzzikObject *mobject = [MuzzikObject shareClass];
    mobject.atFriendFrom = At_From_Message;
    [self.navigationController pushViewController:friendvc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)rightBtnAction:(UIButton *)sender{
    if (!isSending) {
        isSending = YES;
        userInfo *user = [userInfo shareClass];
        MuzzikObject *mobject = [MuzzikObject shareClass];
        if ([hpTextview.text length]>0) {
            mobject.message = hpTextview.text;
        }else{
            mobject.message = @"I Love This Muzzik!";
        }
        
        mobject.isPrivate = isPrivate;
        if (headImage.image) {
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@%@",BaseURL,URL_Upload_Image]]];
            
            [requestForm addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@    %@",[weakrequest originalURL],[weakrequest requestHeaders]);
                NSLog(@"%@",[weakrequest responseHeaders]);
                NSLog(@"%@",[weakrequest responseString]);
                NSLog(@"%d",[weakrequest responseStatusCode]);
                if ([weakrequest responseStatusCode] == 200) {
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                    
                    ASIFormDataRequest *interRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[dic objectForKey:@"url"]]];
                    [ASIFormDataRequest clearSession];
                    [interRequest setPostFormat:ASIMultipartFormDataPostFormat];
                    [interRequest setPostValue:[[dic objectForKey:@"data"] objectForKey:@"token"] forKey:@"token"];
                    NSData *imageData = UIImageJPEGRepresentation(headImage.image, 1);
                    [interRequest addData:imageData forKey:@"file"];
                    __weak ASIFormDataRequest *form = interRequest;
                    [interRequest buildRequestHeaders];
                    NSLog(@"header:%@",interRequest.requestHeaders);
                    [interRequest setCompletionBlock:^{
                        NSDictionary *keydic = [NSJSONSerialization JSONObjectWithData:[form responseData] options:NSJSONReadingMutableContainers error:nil];
                        mobject.imageKey = [keydic objectForKey:@"key"];
                        ASIHTTPRequest *shareRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_new]]];
                        NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
                        if (mobject.isPrivate) {
                            [requestDic setObject:[NSNumber numberWithBool:YES] forKey:Parameter_private];
                        }
                        if ([mobject.imageKey length]>0) {
                            [requestDic setObject:mobject.imageKey forKey:Parameter_image_key];
                        }
                        if ([mobject.message length]>0) {
                            [requestDic setObject:mobject.message forKey:Parameter_message];
                        }else{
                            [requestDic setObject:@"I Love This Muzzik!" forKey:Parameter_message];
                        }
                        NSDictionary *musicDic = [NSDictionary dictionaryWithObjectsAndKeys:mobject.music.key,@"key",mobject.music.name,@"name",mobject.music.artist,@"artist", nil];
                        [requestDic setObject:musicDic forKey:@"music"];
                        [shareRequest addBodyDataSourceWithJsonByDic:requestDic Method:PutMethod auth:YES];
                        __weak ASIHTTPRequest *weakShare = shareRequest;
                        [shareRequest setCompletionBlock:^{
                            NSLog(@"data:%@",[weakShare responseString]);
                            if ([weakShare responseStatusCode] == 200) {
                                isSending = NO;
                                
                                NSDictionary *muzzikDic = [NSJSONSerialization JSONObjectWithData:[weakShare responseData] options:NSJSONReadingMutableContainers error:nil];
                                [self setPoMuzzikMessage:muzzikDic];
                                [mobject clearObject];
                                [self.navigationController popToViewController:user.poController animated:YES];
                                user.poController = nil;
                            }
                        }];
                        [shareRequest setFailedBlock:^{
                            isSending = NO;
                            [MuzzikItem showNotifyOnView:self.view text:@"muzzik发送失败，请确认网络状态再次重试"];
                        }];
                        [shareRequest startAsynchronous];
                    }];
                    [interRequest setFailedBlock:^{
                        isSending = NO;
                        [MuzzikItem showNotifyOnView:self.view text:@"图片上传请求失败，请确认网络状态再次重试"];
                    }];
                    [interRequest startAsynchronous];
                }
            }];
            [requestForm setFailedBlock:^{
                isSending = NO;
                [MuzzikItem showNotifyOnView:self.view text:@"图片上传地址请求失败，请确认网络状态再次重试"];
            }];
            [requestForm startAsynchronous];
        }
        else{
            ASIHTTPRequest *shareRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_new]]];
            NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
            if (mobject.isPrivate) {
                [requestDic setObject:[NSNumber numberWithBool:YES] forKey:Parameter_private];
            }
            if ([mobject.message length]>0) {
                [requestDic setObject:mobject.message forKey:Parameter_message];
            }else{
                [requestDic setObject:@"I Love This Muzzik!" forKey:Parameter_message];
            }
            NSDictionary *musicDic = [NSDictionary dictionaryWithObjectsAndKeys:mobject.music.key,@"key",mobject.music.name,@"name",mobject.music.artist,@"artist", nil];
            [requestDic setObject:musicDic forKey:@"music"];
            [shareRequest addBodyDataSourceWithJsonByDic:requestDic Method:PutMethod auth:YES];
            __weak ASIHTTPRequest *weakShare = shareRequest;
            [shareRequest setCompletionBlock:^{
                NSLog(@"data:%@",[weakShare responseString]);
                if ([weakShare responseStatusCode] == 200) {
                    isSending = NO;
                    
                    NSDictionary *muzzikDic = [NSJSONSerialization JSONObjectWithData:[weakShare responseData] options:NSJSONReadingMutableContainers error:nil];
                    [self setPoMuzzikMessage:muzzikDic];
                    [mobject clearObject];
                    [self.navigationController popToViewController:user.poController animated:YES];
                    user.poController = nil;
                }
            }];
            [shareRequest setFailedBlock:^{
                isSending = NO;
                [MuzzikItem showNotifyOnView:self.view text:@"muzzik发送失败，请确认网络状态再次重试"];
            }];
            [shareRequest startAsynchronous];
        }

    }
    
    
}
-(void)tapAction:(UITapGestureRecognizer *)tap{
    [hpTextview resignFirstResponder];
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
        NSDictionary *dic;
        if (userImage) {
            dic = [NSDictionary dictionaryWithObjectsAndKeys:hpTextview.text,@"message",[dateformatter stringFromDate:senddate],@"lastdate",mobject.music.music_id,@"music_id",mobject.music.name,@"music_name",mobject.music.artist,@"music_artist",mobject.music.key,@"music_key",UIImagePNGRepresentation(userImage) ,@"image", nil];
        }else{
            dic = [NSDictionary dictionaryWithObjectsAndKeys:hpTextview.text,@"message",[dateformatter stringFromDate:senddate],@"lastdate",mobject.music.music_id,@"music_id",mobject.music.name,@"music_name",mobject.music.artist,@"music_artist",mobject.music.key,@"music_key", nil];
        }
        if ([muzzikDrafts count] == 0) {
            muzzikDrafts = @[dic];
        }else{
            NSMutableArray *mutableArr = [muzzikDrafts mutableCopy];
            [mutableArr insertObject:dic atIndex:0];
            muzzikDrafts = [mutableArr copy];
        }
        [MuzzikItem addMuzzikDraftsToLocal:muzzikDrafts];
        [mobject clearObject];
        
        [self.navigationController popViewControllerAnimated:YES];
    }else if(buttonIndex == 1){
        MuzzikObject *mobject = [MuzzikObject shareClass];
        [mobject clearObject];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
-(void) getPicture{
    JSImagePickerViewController *imagePicker = [[JSImagePickerViewController alloc] init];
    imagePicker.delegate = self;
    [imagePicker showImagePickerInController:self animated:YES];
    
    
}
-(void)closeImage{
    userImage = nil;
    [headImage setImage:nil];
    [headerView addSubview:separateLineDown];
    [headerView addSubview:separateLineUp];
    [closeButton removeFromSuperview];
}
#pragma mark - JSImagePikcerViewControllerDelegate

- (void)imagePickerDidSelectImage:(UIImage *)image {
    [_imageCropper setImage:image];
    CGFloat minLength = image.size.width <image.size.height ? image.size.width : image.size.height;
    [_imageCropper setCropRegionRect:CGRectMake(0,0, minLength, minLength)];
    [separateLineUp removeFromSuperview];
    [separateLineDown removeFromSuperview];
    [self.navigationController.view addSubview:_imageCropper];
}
-(void)userCropImage:(UIImage *)image{
    [headerView addSubview:closeButton];
    userImage = image;
    [headImage setImage:image];
    notifyLabel.alpha = 0;
    [self.view addSubview:notifyLabel];
    [UIView animateWithDuration:0.3 animations:^{
        [notifyLabel setAlpha:1];
    }];
}
-(NSAttributedString *)formatAttrItem:(NSString *)content color:(UIColor *)color font:(UIFont *)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.maximumLineHeight = 25.f;
    paragraphStyle.minimumLineHeight = 15.f;
    paragraphStyle.lineHeightMultiple = 20.f;
    
    NSDictionary *attrDict = @{NSParagraphStyleAttributeName: paragraphStyle,
                               NSForegroundColorAttributeName:color,
                               NSFontAttributeName:font};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]
                                          initWithString: content
                                          attributes:attrDict];
    return attrStr;
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
