//
//  DetaiMuzzikVC.m
//  muzzik
//
//  Created by muzzik on 15/5/2.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import "DetaiMuzzikVC.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "TTTAttributedLabel.h"
#import "CommentMuzzikCell.h"
#import "userDetailInfo.h"
#import "HPGrowingTextView.h"
#import "ChooseMusicVC.h"
#import "showUserVC.h"
#import "LoginViewController.h"
#import "FriendVC.h"
#import "TopicDetail.h"
#import "TopicHotVC.h"
#import "Globle.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "PhotoImageView.h"
#import "DialogVC.h"
#import "repostVC.h"
#import "IBActionSheet.h"
#import "MuzzikShareView.h"
#import "IMConversationViewcontroller.h"
@interface DetaiMuzzikVC ()<UITableViewDataSource,UITableViewDelegate,TTTAttributedLabelDelegate,HPGrowingTextViewDelegate,CellDelegate,PhotoImageViewDelegate,UIActionSheetDelegate,IBActionSheetDelegate>{
    NSMutableDictionary *RefreshDic;
    BOOL isforRepost;
    UITableView *muzzikTableView;
    UIView *headView;
    NSMutableArray *commentArray;
    UIView *genresV;
    UIView *cardView;
    int page;
    //评论框
    UIView *commentView;
    HPGrowingTextView *comnentTextView;
    UIButton *musicButton;
    UIButton *privateButton;
    UIButton *sendButton;
    UIView *songView;
    UILabel *songLabel;
    UILabel *artistLabel;
    UIButton *deleButton;
    UIButton *alterButton;
    CGRect tableOriginRect;
    CGRect commentViewRect;
    BOOL firstLoad;
    BOOL isContainMusic;
    muzzik *commentToMuzzik;
    BOOL checkPair;                    //取配对＃和@，防止多次跳转
    NSString *commentText;
    UIView *commentTitle;               //评论头视图
    CGFloat MuzzikViewheight;
    BOOL isComment;                  //评论时，关闭键盘自动滚到表头；
    NSString *lastID;
    UITapGestureRecognizer *tapOnview;
    
    MuzzikShareView *muzzikShareView;
    UIAlertView *TipsAlterView;
    UIImage *saveImage;           //保存图片
    BOOL isPrivate;
    UIImageView *MprivateImage;
    IBActionSheet *commentDeleteSheet;
    IBActionSheet *alertSheet;
    
}
@property (nonatomic,retain) muzzik *localmuzzik;
@property (nonatomic,retain) NSMutableDictionary *profileDic;
@property(nonatomic,retain)UIImageView *headimage;

@property(nonatomic,retain)UIButton *attentionButton;
@property(nonatomic,retain)UILabel *nameLabel;
@property(nonatomic,retain)UIImageView *genderImage;
@property(nonatomic,retain)UILabel *descriptionLabel;
@property(nonatomic,retain)UIImageView *schoolImage;
@property(nonatomic,retain)UILabel *schoolLabel;
@property(nonatomic,retain)UIImageView *birthImage;
@property(nonatomic,retain)UILabel *birthLabel;
@property(nonatomic,retain)UIImageView *constellationImage;
@property(nonatomic,retain)UILabel *constellationLabel;
@property(nonatomic,retain)UIImageView *companyImage;
@property(nonatomic,retain)UILabel *companyLabel;
@property(nonatomic,retain)UIView *genresView;
@property(nonatomic,retain)UILabel *muzzikCount;
@property(nonatomic,retain)UILabel *followCount;
@property(nonatomic,retain)UILabel *fansCount;
@property(nonatomic,retain)UILabel *songCount;
@property(nonatomic,retain)UIImageView *coverImage;

//muzzik
@property (nonatomic,retain) UIView *muzzikView;
@property (nonatomic) UILabel *repostUserName;                 //转发用户名
@property (nonatomic) UIImageView *repostImage;                //muzzik类型图标
@property (nonatomic) UIButton *userImage;                  //用户头像
@property (nonatomic) UILabel *userName;                       //用户名
@property (nonatomic) UILabel *timeStamp;                      //时间
@property (nonatomic) UIProgressView *progress;
@property (nonatomic) UIButton *playButton;
@property (nonatomic) UIButton *likeButton;
@property (nonatomic) TTTAttributedLabel *muzzikMessage;        //muzzik文字
@property (nonatomic) UILabel *musicName;                      //音乐名称
@property (nonatomic) UILabel *musicArtist;                    //音乐家
@property (nonatomic) UIImageView *timeImage;                  //时间图标
@property (nonatomic) UILabel *muzzikRepostText;               //转发文字
@property (nonatomic) UIView *socialView;                      //社交图层
@property (nonatomic) UIImageView *upperLine;
@property (nonatomic) UIImageView *downLine;
@property (nonatomic) UIButton *moves;
@property (nonatomic) UIButton *reposts;
@property (nonatomic) UIButton *shares;
@property (nonatomic) UIButton *comments;
@property (nonatomic) UIButton *deleMuzzikButton;
@property (nonatomic) UIButton *repostButton;
@property (nonatomic) UIButton *shareButton;
@property (nonatomic) UIButton *commentButton;
@property (nonatomic) NSString *colorName;
@property (nonatomic) BOOL isMoved;
@property (nonatomic) BOOL hasLoad;
@property (nonatomic) BOOL isReposted;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) PhotoImageView *poImage;
@property (nonatomic) UIButton *addFriendButton;

@end

@implementation DetaiMuzzikVC

- (void)viewDidLoad {
    [super viewDidLoad];
    RefreshDic = [NSMutableDictionary dictionary];
    self.localmuzzik = [muzzik new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceMuzzikUpdate:) name:String_MuzzikDataSource_update object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceUserUpdate:) name:String_UserDataSource_update object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self initNagationBar:@"详情" leftBtn:Constant_backImage rightBtn:0];
    muzzikShareView = [[MuzzikShareView alloc] initMyShare];
    muzzikShareView.ownerVC = self;
    muzzikTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-119)];
    tableOriginRect = muzzikTableView.frame;
    muzzikTableView.contentInset = UIEdgeInsetsMake(SCREEN_WIDTH/2, 0, 0, 0);
    muzzikTableView.backgroundColor = [UIColor whiteColor];
    muzzikTableView.delegate = self;
    muzzikTableView.dataSource = self;
    muzzikTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:muzzikTableView];
    tapOnview = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    
    [self followScrollView:muzzikTableView];
    commentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-119, SCREEN_WIDTH, 55)];
    
    [commentView setBackgroundColor:Color_line_2];
    [self.view addSubview:commentView];
    [MuzzikItem addLineOnView:commentView heightPoint:0 toLeft:0 toRight:0 withColor:Color_line_1];
    musicButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 55)];
    [musicButton setImage:[UIImage imageNamed:Image_detailaddsongImage] forState:UIControlStateNormal];
    [musicButton addTarget:self action:@selector(selectMusic) forControlEvents:UIControlEventTouchUpInside];
    [commentView addSubview:musicButton];
    comnentTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(36, 10, SCREEN_WIDTH-72, 40)];
    comnentTextView.layer.borderWidth =1;
    comnentTextView.layer.borderColor = Color_line_1.CGColor;
    comnentTextView.layer.cornerRadius = 3;
    comnentTextView.clipsToBounds = YES;
    comnentTextView.delegate = self;
    comnentTextView.maxHeight = 100;
    comnentTextView.font = [UIFont systemFontOfSize:15];
    comnentTextView.textColor = Color_Text_2;
    [comnentTextView setReturnKeyType:UIReturnKeySend];
    comnentTextView.animateHeightChange = NO;
    
    comnentTextView.placeholderColor = Color_Text_4;
    [commentView addSubview:comnentTextView];
    privateButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-36, 0, 36, 55)];
    [privateButton setImage:[UIImage imageNamed:Image_detailvisibleImage] forState:UIControlStateNormal];
    [privateButton addTarget:self action:@selector(PrivateAction) forControlEvents:UIControlEventTouchUpInside];
    [commentView addSubview:privateButton];
    commentViewRect = commentView.frame;
    
    [muzzikTableView registerClass:[CommentMuzzikCell class] forCellReuseIdentifier:@"CommentMuzzikCell"];
    
    page = 1;
    headView = [[UIView alloc] initWithFrame:CGRectMake(0, -SCREEN_WIDTH/2, SCREEN_WIDTH, SCREEN_WIDTH/2)];
    [muzzikTableView insertSubview:headView atIndex:[[muzzikTableView subviews] count]-1];
    
    _headimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/2)];
    _headimage.contentMode = UIViewContentModeScaleAspectFill;
    [_headimage setAlpha:0];
    [headView addSubview:_headimage];
    _coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/2)];
    [_coverImage setAlpha:1];
    [_coverImage setImage:[UIImage imageNamed:Image_prifilebgcover]];
    [headView addSubview:_coverImage];
    _attentionButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 16, 85, 23)];
    [_attentionButton addTarget:self action:@selector(attentionAction) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:_attentionButton];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, 30, 30)];
    [_nameLabel setFont:[UIFont fontWithName:Font_Next_DemiBold size:20]];
    _nameLabel.textColor = [UIColor whiteColor];
    [headView addSubview:_nameLabel];
    _genderImage = [[UIImageView alloc] init];
    [headView addSubview:_genderImage];
    
    _constellationImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _constellationLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, SCREEN_WIDTH/2-50, 20)];
    
    _birthImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _birthLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    
    _companyImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    
    _schoolImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32,0)];
    _muzzikView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _userImage = [[UIButton alloc] initWithFrame:CGRectMake(16, 16, 50, 50)];
    [_userImage addTarget:self action:@selector(goToUser) forControlEvents:UIControlEventTouchUpInside];
    _userImage.layer.cornerRadius = 25;
    _userImage.layer.masksToBounds = YES;
    
    [_muzzikView addSubview:_userImage];
    _timeStamp = [[UILabel alloc] initWithFrame:CGRectMake(80, 48, 96, 9)];
    [_timeStamp setTextColor:Color_Additional_5];
    [_timeStamp setFont:[UIFont fontWithName:Font_Next_medium size:9]];

    

    
    
    [_muzzikView addSubview:_timeStamp];
    _timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(180, 50, 8, 8)];
    [_timeImage setImage:[UIImage imageNamed:Image_timeImage]];
    [_muzzikView addSubview:_timeImage];
    
    _userName = [[UILabel alloc] initWithFrame:CGRectMake(80, 27, SCREEN_WIDTH-96, 20)];
    //  [_userName setTextColor:Color_LightGray];
    [_userName setFont:[UIFont fontWithName:Font_Next_DemiBold size:Font_size_userName]];
    [_userName setTextColor:Color_Text_1];
    MprivateImage = [[UIImageView alloc] init];
    [MprivateImage setImage:[UIImage imageNamed:Image_detailinvisibleImage]];
    [MprivateImage setHidden:YES];
    [_muzzikView addSubview:MprivateImage];
    
    [_muzzikView addSubview:_userName];
    _muzzikMessage = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake( 16, 78, SCREEN_WIDTH-32, 2000)];
    [_muzzikMessage setTextColor:Color_Text_2];
    [_muzzikMessage setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
    
    [self loadMuzzikView];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Globle shareGloble].isHeadView = YES;
    MuzzikObject *mobject = [MuzzikObject shareClass];
    if ([mobject.music.name length]>0) {
        //已经选择歌曲了
        if (isContainMusic) {
            songLabel.text = mobject.music.name;
            artistLabel.text = mobject.music.artist;
        }
        //尚未选择歌曲
        else{
            isContainMusic = YES;
            [songView setFrame:CGRectMake(0, commentView.frame.size.height, SCREEN_WIDTH, 55)];
            [commentView setFrame:CGRectMake(commentView.frame.origin.x, commentView.frame.origin.y-55, SCREEN_WIDTH, commentView.frame.size.height+55)];
            [commentView addSubview:songView];
            songLabel.text = mobject.music.name;
            artistLabel.text = mobject.music.artist;
            [muzzikTableView setFrame:CGRectMake(muzzikTableView.frame.origin.x, muzzikTableView.frame.origin.y, SCREEN_WIDTH, muzzikTableView.frame.size.height-55)];
            muzzikTableView.contentOffset = CGPointMake(muzzikTableView.contentOffset.x, muzzikTableView.contentOffset.y+55);
            [musicButton setImage:[UIImage imageNamed:Image_detailaddedsongImage] forState:UIControlStateNormal];
            tableOriginRect = CGRectMake(tableOriginRect.origin.x, tableOriginRect.origin.y, tableOriginRect.size.width, tableOriginRect.size.height-55);
            commentViewRect = CGRectMake(commentViewRect.origin.x, commentViewRect.origin.y-55, SCREEN_WIDTH, commentViewRect.size.height+55);
        }
    }
    if ([mobject.tempmessage length]>0) {
        checkPair = YES;
        NSString *temp = [comnentTextView.text stringByAppendingString:[mobject.tempmessage substringFromIndex:1]];
        if ([temp length]>140) {
            [MuzzikItem showNotifyOnView:self.view text:@"发送内容超出140个字符的限制"];
            mobject.tempmessage = nil;
        }else{
            comnentTextView.text = temp;
            mobject.tempmessage = nil;
        }
        
    }
    userInfo *user = [userInfo shareClass];
    if ([user.notificationMessage length]>0) {
        [MuzzikItem showNewNotifyByText:user.notificationMessage];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [Globle shareGloble].isHeadView = NO;
    

    // [MytableView removeKeyPath];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadComment{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/comments",BaseURL,self.muzzik_id]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakre = request;
    [request setCompletionBlock :^{
        NSLog(@"%@",[weakre responseString]);
        NSLog(@"%d",[weakre responseStatusCode]);
        if ([weakre responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakre responseData]  options:NSJSONReadingMutableContainers error:nil];
            lastID = [dic objectForKey:@"tail"];
            commentArray = [[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            if ([[dic objectForKey:@"muzziks"] count] >1) {
                [muzzikTableView addFooterWithTarget:self action:@selector(refreshFooter)];
            }
            if ([commentArray count]>0) {
                [_muzzikView addSubview:commentTitle];
            }
           
            [muzzikTableView reloadData];
            if ([self.showType isEqualToString:Constant_Comment]) {
                [comnentTextView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.5];
            }else if([self.showType isEqualToString:Constant_showComment]){
                if ([commentArray count]>0) {
                    [muzzikTableView setContentOffset:CGPointMake(0, _muzzikView.frame.size.height-SCREEN_WIDTH-64) animated:NO];
                }
                
            }
            
        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakre error]);
        NSLog(@"hhhh%@  kkk%@",[weakre responseString],[weakre responseHeaders]);
    }];
    [request startAsynchronous];
}
-(void)viewDidScroll:(UIScrollView *)scrollView{
    [super viewDidScroll:scrollView];
    NSLog(@"%f",scrollView.contentOffset.y);
    CGFloat yOffset  = scrollView.contentOffset.y;
    if (yOffset < -SCREEN_WIDTH/2 ) {
        CGRect f = _headimage.frame;
        f.origin.y = yOffset+SCREEN_WIDTH/2;
        f.size.height =  -yOffset;
        _headimage.frame = f;
        
        CGRect cover = _coverImage.frame;
        cover.origin.y = yOffset+SCREEN_WIDTH/2;
        cover.size.height =  -yOffset;
        _coverImage.frame = cover;
        
        CGRect d = _attentionButton.frame;

        d.origin.y = yOffset+SCREEN_WIDTH/2+16;
        
    }
}



#pragma -mark tableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    muzzik *tempMuzzik = commentArray[indexPath.row];
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-140, 2000)];
    label.text = tempMuzzik.message;
    
    [label setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
    int textHeight = [MuzzikItem heightForLabel:label WithText:label.text];
    
    if (tempMuzzik.onlytext) {
        return 75+textHeight;
    }else{
        return 110+textHeight;
    }
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    muzzik *tempMuzzik = commentArray[indexPath.row];
    CommentMuzzikCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentMuzzikCell" forIndexPath:indexPath];
    [cell.userImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
            [cell.userImage setAlpha:0];
            [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            [UIView animateWithDuration:0.5 animations:^{
                [cell.userImage setAlpha:1];
            }];
        }
        
        
    }];
    
    cell.delegate = self;
    Globle *glob = [Globle shareGloble];
    BOOL ispalying = false;
    if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause) {
        ispalying = YES;
    }
    cell.MuzzikModel = tempMuzzik;
    cell.userName.text = tempMuzzik.MuzzikUser.name;
    [cell.userName sizeToFit];
    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+2, cell.userName.frame.origin.y, 20, 20)];
    if (tempMuzzik.isprivate ) {
        [cell.privateImage setHidden:NO];
    }else{
        [cell.privateImage setHidden:YES];
    }
    cell.message.text = tempMuzzik.message;
    [cell.message addClickMessagewithTopics:tempMuzzik.topics];
    [cell.message addClickMessageForAt];
    cell.message.delegate = self;
    CGSize msize = [cell.message sizeThatFits:CGSizeMake(SCREEN_WIDTH-140, 2000)];
    [cell.message setFrame:CGRectMake(cell.message.frame.origin.x, cell.message.frame.origin.y, msize.width, msize.height)];
    cell.timeLabel.text = [MuzzikItem transtromTime:tempMuzzik.date];
    if (!tempMuzzik.onlytext) {
        [cell.playButton setHidden:NO];
        [cell.songName setHidden:NO];
        UIColor *color;
        if ([tempMuzzik.color longLongValue] == 1) {
            color = Color_Action_Button_1;
            if (ispalying) {
                [cell.playButton setImage:[UIImage imageNamed:Image_detailstopredImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_detailredplay] forState:UIControlStateNormal];
            }
            
        }
        else if([tempMuzzik.color longLongValue] == 2){
            //bluelikeImage
            color = Color_Action_Button_2;
            if (ispalying) {
                [cell.playButton setImage:[UIImage imageNamed:Image_detailstopyellowImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_detailyellowplay] forState:UIControlStateNormal];
            }
        }
        else{
            color = Color_Action_Button_3;
            if (ispalying) {
                [cell.playButton setImage:[UIImage imageNamed:Image_detailstopblueImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_detailblueplay] forState:UIControlStateNormal];
            }
        }
        [cell.songName setFrame:CGRectMake(cell.songName.frame.origin.x, cell.message.frame.size.height+cell.message.frame.origin.y+13, SCREEN_WIDTH-140, 20)];
        [cell.playButton setFrame:CGRectMake(SCREEN_WIDTH-53, cell.message.frame.size.height+cell.message.frame.origin.y+6, 40, 40)];
        NSMutableAttributedString *attributesText = [[NSMutableAttributedString alloc] init];
        
        NSAttributedString *item = [MuzzikItem formatAttrItem:tempMuzzik.music.name color:color font:[UIFont boldSystemFontOfSize:15]];
        [attributesText appendAttributedString:item];
        
        NSAttributedString *item1 = [MuzzikItem formatAttrItem:[NSString stringWithFormat:@"  %@",tempMuzzik.music.artist] color:color font:[UIFont boldSystemFontOfSize:13]];
        [attributesText appendAttributedString:item1];
        cell.songName.attributedText = attributesText;
        [cell.lineview setFrame:CGRectMake(16, cell.message.frame.size.height+cell.message.frame.origin.y+52, SCREEN_WIDTH-32, 1)];
    }else{
//        if (indexPath.row%2 == 0) {
//            cell.backgroundColor = Color_Orange;
//        }else{
//            cell.backgroundColor = Color_Additional_4;
//        }
        [cell.playButton setHidden:YES];
        [cell.lineview setFrame:CGRectMake(16, cell.message.frame.size.height+cell.message.frame.origin.y+15, SCREEN_WIDTH-32, 1)];
        if (ispalying) {
            [cell.playButton setImage:[UIImage imageNamed:Image_detailstoporangeImage] forState:UIControlStateNormal];
        }else{
            [cell.playButton setImage:[UIImage imageNamed:Image_detailgreyplay] forState:UIControlStateNormal];
        }
        [cell.playButton setFrame:CGRectMake(SCREEN_WIDTH-53, cell.message.frame.size.height+cell.message.frame.origin.y-30, 40, 40)];
        [cell.songName setHidden:YES];
    }
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return commentArray.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    muzzik *tempMuzzik = commentArray[indexPath.row];
    userInfo *user = [userInfo shareClass];
    commentToMuzzik = commentArray[indexPath.row];
    if ([user.uid isEqualToString:tempMuzzik.MuzzikUser.user_id]) {
        [comnentTextView resignFirstResponder];
        commentDeleteSheet = [[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除评论", nil];
        [commentDeleteSheet setButtonTextColor:Color_Active_Button_1 forButtonAtIndex:0];
        [commentDeleteSheet showInView:self.view.window];
    }else{
        isComment = YES;
        
        comnentTextView.placeholder = [NSString stringWithFormat:@"回复 %@",commentToMuzzik.MuzzikUser.name];
        [comnentTextView becomeFirstResponder];
    }
    
    

}


#pragma mark - HOGrowingDelegate
-(void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
    CGFloat delta = height-growingTextView.frame.size.height;
    tableOriginRect = CGRectMake(tableOriginRect.origin.x, tableOriginRect.origin.y, tableOriginRect.size.width, tableOriginRect.size.height-delta);
    commentViewRect = CGRectMake(commentViewRect.origin.x, commentViewRect.origin.y-delta, SCREEN_WIDTH, commentViewRect.size.height+delta);
    [songView setFrame:CGRectMake(0, songView.frame.origin.y+delta, SCREEN_WIDTH, 55)];
    [commentView setFrame:CGRectMake(commentView.frame.origin.x, commentView.frame.origin.y-delta, SCREEN_WIDTH, commentView.frame.size.height+delta)];
    [muzzikTableView setFrame:CGRectMake(muzzikTableView.frame.origin.x, muzzikTableView.frame.origin.y, muzzikTableView.frame.size.width, muzzikTableView.frame.size.height-delta)];
    [UIView animateWithDuration:0.2 animations:^{
        muzzikTableView.contentOffset = CGPointMake(muzzikTableView.contentOffset.x, muzzikTableView.contentOffset.y+delta);
    }];
    
}
-(BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    
        MuzzikObject *mobject = [MuzzikObject shareClass];
        ASIHTTPRequest *shareRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_new]]];
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    if ([comnentTextView.text length]>0) {
        [requestDic setObject:[NSString stringWithFormat:@"@%@ %@",commentToMuzzik.MuzzikUser.name,comnentTextView.text] forKey:Parameter_message];
    }
    else{
        [requestDic setObject:[NSString stringWithFormat:@"@%@ I Love This Muzzik!",commentToMuzzik.MuzzikUser.name] forKey:Parameter_message];
    }
    
        if (mobject.music) {
            NSDictionary *musicDic = [NSDictionary dictionaryWithObjectsAndKeys:mobject.music.key,@"key",mobject.music.name,@"name",mobject.music.artist,@"artist", nil];
            [requestDic setObject:musicDic forKey:@"music"];
        }
        if (isPrivate) {
            [requestDic setObject:[NSNumber numberWithBool:YES] forKey:@"private"];
        }else{
            [requestDic setObject:[NSNumber numberWithBool:NO] forKey:@"private"];
        }
        [requestDic setValue:commentToMuzzik.muzzik_id forKey:@"reply"];
        [shareRequest addBodyDataSourceWithJsonByDic:requestDic Method:PutMethod auth:YES];
        __weak ASIHTTPRequest *weakShare = shareRequest;
        [shareRequest setCompletionBlock:^{
            NSLog(@"data:%@, status:%d",[weakShare responseString],[weakShare responseStatusCode]);
            if ([weakShare responseStatusCode] == 200) {
                
                comnentTextView.text = @"";
                if (mobject.music) {
                    [self deleSong];
                }

                mobject.music = nil;
                mobject.message = nil;
                mobject.tempmessage = nil;
                mobject.imageKey = nil;
                mobject.lyricArray = nil;
                mobject.isMessageVCOpen = NO;
                mobject.lyricArray = nil;
                [comnentTextView performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.3];
                
                ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/comments",BaseURL,self.muzzik_id]]];
                [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
                __weak ASIHTTPRequest *weakre = request;
                [request setCompletionBlock :^{
                    NSLog(@"%@",[weakre responseString]);
                    NSLog(@"%d",[weakre responseStatusCode]);
                    if ([weakre responseStatusCode] == 200) {
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakre responseData]  options:NSJSONReadingMutableContainers error:nil];
                        lastID = [dic objectForKey:@"tail"];
                        commentArray = [[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                        if ([commentArray count]>0) {
                            [_muzzikView addSubview:commentTitle];
                            self.localmuzzik.comments = [NSString stringWithFormat:@"%lu",(unsigned long)commentArray.count];
                            [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:self.localmuzzik];
                            [muzzikTableView reloadData];
                            [muzzikTableView scrollToRowAtIndexPath:
                             [NSIndexPath indexPathForRow:0 inSection:0]
                                                   atScrollPosition: UITableViewScrollPositionBottom
                                                           animated:YES];
                        }
                        
                        
                    }
                    else{
                        //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                    }
                }];
                [request setFailedBlock:^{
                    NSLog(@"%@",[weakre error]);
                    NSLog(@"hhhh%@  kkk%@",[weakre responseString],[weakre responseHeaders]);
//                    [userInfo checkLoginWithVC:self];
                }];
                [request startAsynchronous];
                
            }
        }];
        [shareRequest setFailedBlock:^{
           // [userInfo checkLoginWithVC:self];
            NSLog(@"%@",[weakShare error]);
        }];
        [shareRequest startAsynchronous];
       return YES;
}

-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    if ([growingTextView.text length]<138-[commentToMuzzik.MuzzikUser.name length]) {
        if (growingTextView.text.length> commentText.length) {
            NSString *temp = [growingTextView.text substringFromIndex:[growingTextView.text length]-1];
            if ([temp isEqualToString:@"@"] || [temp isEqualToString:@"＠"]) {
                MuzzikObject *mobject = [MuzzikObject shareClass];
                mobject.atFriendFrom = At_From_detail;
                FriendVC *friendvc = [[FriendVC alloc] init];
                [self.navigationController pushViewController:friendvc animated:YES];
            }else if([temp isEqualToString:@"#"] || [temp isEqualToString:@"＃"]){
                if (checkPair) {
                    checkPair = !checkPair;
                }else{
                    TopicHotVC *topicvc = [[TopicHotVC alloc] init];
                    [self.navigationController pushViewController:topicvc animated:YES];
                }
                
            }
        }
        commentText = growingTextView.text;
    }
    else{
        growingTextView.internalTextView.text = [growingTextView.text substringToIndex:138-[commentToMuzzik.MuzzikUser.name length]];
    }
    
   
}
#pragma mark - action
-(void)tappedToSave:(PhotoImageView *)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存图片", nil];
    saveImage = sender.image;
    [sheet showInView:self.view.window];
}

- (void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if(buttonIndex==1){
        return;
    }
    else if(actionSheet == commentDeleteSheet){
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@api/muzzik/%@",BaseURL,commentToMuzzik.muzzik_id]]];
        [requestForm addBodyDataSourceWithJsonByDic:nil Method:DeleteMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            if ([weakrequest responseStatusCode] == 200 && [[dic objectForKey:@"result"] boolValue]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:String_Muzzik_Delete object:commentToMuzzik];
                [commentArray removeObject:commentToMuzzik];
                commentToMuzzik = self.localmuzzik;
                comnentTextView.placeholder = [NSString stringWithFormat:@"回复 %@",commentToMuzzik.MuzzikUser.name];
                [muzzikTableView reloadData];
                [MuzzikItem showNotifyOnView:self.view text:@"评论删除成功"];
            }
        }];
        [requestForm setFailedBlock:^{
            
            // [SVProgressHUD showErrorWithStatus:@"network error"];
        }];
        [requestForm startAsynchronous];
    }
    else if(actionSheet == alertSheet){
        userInfo *user = [userInfo shareClass];
        if ([user.token length]>0) {
            repostVC *informvc = [[repostVC alloc] init];
            informvc.informString = [NSString stringWithFormat:@"muzzik id:%@",self.localmuzzik.muzzik_id];
            [self.navigationController pushViewController:informvc animated:YES];
        }else{
            [userInfo checkLoginWithVC:self];
        }
}
    else{
        if (buttonIndex==0){
            [self saveToAlbumWithMetadata:nil imageData:UIImagePNGRepresentation(saveImage) customAlbumName:@"Muzzik相册" completionBlock:^
             {
                 //这里可以创建添加成功的方法
                 [MuzzikItem showNotifyOnView:self.navigationController.view text:@"保存成功"];
             }
                             failureBlock:^(NSError *error)
             {
                 //处理添加失败的方法显示alert让它回到主线程执行，不然那个框框死活不肯弹出来
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     //添加失败一般是由用户不允许应用访问相册造成的，这边可以取出这种情况加以判断一下
                     if([error.localizedDescription rangeOfString:@"User denied access"].location != NSNotFound ||[error.localizedDescription rangeOfString:@"用户拒绝访问"].location!=NSNotFound){
                         
                         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles: nil];
                         
                         [alert show];
                         
                     }
                 });
             }];
        }
    }
    
    
}


- (void)saveToAlbumWithMetadata:(NSDictionary *)metadata
                      imageData:(NSData *)imageData
                customAlbumName:(NSString *)customAlbumName
                completionBlock:(void (^)(void))completionBlock
                   failureBlock:(void (^)(NSError *error))failureBlock
{
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    void (^AddAsset)(ALAssetsLibrary *, NSURL *) = ^(ALAssetsLibrary *assetsLibrary, NSURL *assetURL) {
        [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                
                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:customAlbumName]) {
                    [group addAsset:asset];
                    if (completionBlock) {
                        completionBlock();
                    }
                }
            } failureBlock:^(NSError *error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        } failureBlock:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
            }
        }];
    };
    __weak ALAssetsLibrary *weakassetsLibrary = assetsLibrary;
    [assetsLibrary writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
        if (customAlbumName) {
            [assetsLibrary addAssetsGroupAlbumWithName:customAlbumName resultBlock:^(ALAssetsGroup *group) {
                if (group) {
                    [weakassetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        [group addAsset:asset];
                        if (completionBlock) {
                            completionBlock();
                            
                        }
                    } failureBlock:^(NSError *error) {
                        if (failureBlock) {
                            failureBlock(error);
                        }
                    }];
                } else {
                    AddAsset(weakassetsLibrary, assetURL);
                }
            } failureBlock:^(NSError *error) {
                AddAsset(weakassetsLibrary, assetURL);
            }];
        } else {
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}

-(void)PrivateAction{
    if (isPrivate) {
        isPrivate = !isPrivate;
        [privateButton setImage:[UIImage imageNamed:Image_detailvisibleImage] forState:UIControlStateNormal];
    }else{
        isPrivate = !isPrivate;
        [privateButton setImage:[UIImage imageNamed:Image_detailinvisibleImage] forState:UIControlStateNormal];
    }
}
-(void) colorViewWithColorString:(NSString *) colorString{
    UIColor *color;
    if ([colorString intValue] == 1) {
        color = Color_Action_Button_1;
        [self.repostImage setImage:[UIImage imageNamed:Image_redretweetImage]];
        if (self.localmuzzik.ismoved) {
            [self.likeButton setImage:[UIImage imageNamed:@"redlikedImage"] forState:UIControlStateNormal];
        }else{
            [self.likeButton setImage:[UIImage imageNamed:@"redlikeImage"] forState:UIControlStateNormal];
        }
        if (self.isPlaying) {
            [self.playButton setImage:[UIImage imageNamed:@"redstopImage"] forState:UIControlStateNormal];
        }else{
            [self.playButton setImage:[UIImage imageNamed:@"redplayImage"] forState:UIControlStateNormal];
        }
        if (self.localmuzzik.isReposted) {
            [self.repostButton setImage:[UIImage imageNamed:Image_hottweetredretweetImage] forState:UIControlStateNormal];
        }else{
            [self.repostButton setImage:[UIImage imageNamed:Image_detailretweetImage] forState:UIControlStateNormal];
        }
        
    }
    else if([colorString intValue] == 2){
        //bluelikeImage
        
        color = Color_Action_Button_2;
        
        [self.repostImage setImage:[UIImage imageNamed:Image_yellowretweetImage]];
        if (self.localmuzzik.ismoved) {
            [self.likeButton setImage:[UIImage imageNamed:@"yellowlikedImage"] forState:UIControlStateNormal];
        }else{
            [self.likeButton setImage:[UIImage imageNamed:@"yellowlikeImage"] forState:UIControlStateNormal];
        }
        if (self.isPlaying) {
            [self.playButton setImage:[UIImage imageNamed:@"yellowstopImage"] forState:UIControlStateNormal];
        }else{
            [self.playButton setImage:[UIImage imageNamed:@"yellowplayImage"] forState:UIControlStateNormal];
        }
        if (self.localmuzzik.isReposted) {
            [self.repostButton setImage:[UIImage imageNamed:Image_hottweetyellowretweetImage] forState:UIControlStateNormal];
        }else{
            [self.repostButton setImage:[UIImage imageNamed:Image_detailretweetImage] forState:UIControlStateNormal];
        }
        
    }
    else{
        color = Color_Action_Button_3;
        [self.repostImage setImage:[UIImage imageNamed:Image_blueretweetImage]];
        if (self.localmuzzik.ismoved) {
            [self.likeButton setImage:[UIImage imageNamed:@"bluelikedImage"] forState:UIControlStateNormal];
        }else{
            [self.likeButton setImage:[UIImage imageNamed:@"bluelikeImage"] forState:UIControlStateNormal];
        }
        if (self.isPlaying) {
            [self.playButton setImage:[UIImage imageNamed:@"bluestopImage"] forState:UIControlStateNormal];
        }else{
            [self.playButton setImage:[UIImage imageNamed:@"blueplayImage"] forState:UIControlStateNormal];
        }
        if (self.localmuzzik.isReposted) {
            [self.repostButton setImage:[UIImage imageNamed:Image_hottweetblueretweetImage] forState:UIControlStateNormal];
        }else{
            [self.repostButton setImage:[UIImage imageNamed:Image_detailretweetImage] forState:UIControlStateNormal];
        }
    }
    [_moves setTitle:[self.localmuzzik.moveds integerValue]>0? [NSString stringWithFormat:@"喜欢数%@",self.localmuzzik.moveds] : @"喜欢数" forState:UIControlStateNormal];
    [_reposts setTitle:[self.localmuzzik.reposts integerValue]>0? [NSString stringWithFormat:@"转发数%@",self.localmuzzik.reposts] : @"转发数" forState:UIControlStateNormal];
    [_shares setTitle:[self.localmuzzik.shares integerValue]>0? [NSString stringWithFormat:@"分享数%@",self.localmuzzik.shares] : @"分享数" forState:UIControlStateNormal];
    [_comments setTitle:[self.localmuzzik.comments integerValue]>0? [NSString stringWithFormat:@"评论数%@",self.localmuzzik.comments] : @"评论数" forState:UIControlStateNormal];
    [_progress setTintColor:color];
    [_musicArtist setTextColor:color];
    [_musicName setTextColor:color];
}
-(void)attentionAction{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if ([[_profileDic objectForKey:@"isFollow"] boolValue]) {
            [_profileDic setValue:[NSNumber numberWithBool:NO] forKey:@"isFollow"];
            
            MuzzikUser *attentionuser = [MuzzikUser new];
            attentionuser.user_id = [_profileDic objectForKey:@"_id"];
            attentionuser.isFans = [[_profileDic objectForKey:@"isFans"] boolValue];
            attentionuser.isFollow = [[_profileDic objectForKey:@"isFollow"] boolValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:attentionuser];
            
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_user_Unfollow]]];
            [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[_profileDic objectForKey:@"_id"] forKey:@"_id"] Method:PostMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@",[weakrequest responseString]);
                NSLog(@"%d",[weakrequest responseStatusCode]);
                
                if ([weakrequest responseStatusCode] == 200) {
                    
                    
    
                }
                else{
                    //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                }
            }];
            [requestForm setFailedBlock:^{
                NSLog(@"%@",[weakrequest error]);
                NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
            }];
            [requestForm startAsynchronous];
        }
        else{
            [_profileDic setValue:[NSNumber numberWithBool:YES] forKey:@"isFollow"];
            
            MuzzikUser *attentionuser = [MuzzikUser new];
            attentionuser.user_id = [_profileDic objectForKey:@"_id"];
            attentionuser.isFans = [[_profileDic objectForKey:@"isFans"] boolValue];
            attentionuser.isFollow = [[_profileDic objectForKey:@"isFollow"] boolValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:attentionuser];
            
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_User_Follow]]];
            [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:self.localmuzzik.MuzzikUser.user_id forKey:@"_id"] Method:PostMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@",[weakrequest responseString]);
                NSLog(@"%d",[weakrequest responseStatusCode]);
                
                if ([weakrequest responseStatusCode] == 200) {
                    
                }
                else{
                    //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                }
            }];
            [requestForm setFailedBlock:^{
                NSLog(@"%@",[weakrequest error]);
                NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
                
            }];
            [requestForm startAsynchronous];
        }
    }else{
        [userInfo checkLoginWithVC:self];
    }
    
}
-(void)attentionOrVisit{
    
    if ([[_profileDic objectForKey:@"isFollow"] boolValue] && [[_profileDic objectForKey:@"isFans"] boolValue] ) {
        if ([[_profileDic objectForKey:@"isSupportChat"] boolValue]) {
            [self newConversationAction];
        }
    }else if ([[_profileDic objectForKey:@"isFollow"] boolValue]) {
        
        
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = self.localmuzzik.MuzzikUser.user_id;
        
        userDetailInfo *oldInfovc;
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[userDetailInfo class]]) {
                userDetailInfo *udetail = (userDetailInfo *)vc;
                if ([udetail.uid isEqualToString:self.localmuzzik.MuzzikUser.user_id]) {
                    oldInfovc = udetail;
                    break;
                }
                
            }
        }
        if (oldInfovc) {
            NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
            [array removeObjectAtIndex:[self.navigationController.viewControllers indexOfObject:oldInfovc]];
            
            [array addObject:oldInfovc];
            [self.navigationController setViewControllers:array animated:YES];
        }else{
            [self.navigationController pushViewController:detailuser animated:YES];
        }
        
    }else{
        userInfo *user = [userInfo shareClass];
        if ([user.token length]>0) {
            [_profileDic setValue:[NSNumber numberWithBool:YES] forKey:@"isFollow"];
            MuzzikUser *attentionuser = [MuzzikUser new];
            attentionuser.user_id = [_profileDic objectForKey:@"_id"];
            attentionuser.isFans = [[_profileDic objectForKey:@"isFans"] boolValue];
            attentionuser.isFollow = [[_profileDic objectForKey:@"isFollow"] boolValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:attentionuser];
            
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_User_Follow]]];
            [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:self.localmuzzik.MuzzikUser.user_id forKey:@"_id"] Method:PostMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@",[weakrequest responseString]);
                NSLog(@"%d",[weakrequest responseStatusCode]);
                
                if ([weakrequest responseStatusCode] == 200) {
                    
                }
                else{
                    //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                }
            }];
            [requestForm setFailedBlock:^{
                NSLog(@"%@",[weakrequest error]);
                NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
                
            }];
            [requestForm startAsynchronous];
        }else{
            [userInfo checkLoginWithVC:self];
        }
        
    }
}
-(void)goToUser{
    
    
    userInfo *user = [userInfo shareClass];
    if ([self.localmuzzik.MuzzikUser.user_id isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        home.isPush = YES;
        [self.navigationController pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = self.localmuzzik.MuzzikUser.user_id;
        
        userDetailInfo *oldInfovc;
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[userDetailInfo class]]) {
                userDetailInfo *udetail = (userDetailInfo *)vc;
                if ([udetail.uid isEqualToString:self.localmuzzik.MuzzikUser.user_id]) {
                    oldInfovc = udetail;
                    break;
                }
                
            }
        }
        if (oldInfovc) {
            NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
            [array removeObjectAtIndex:[self.navigationController.viewControllers indexOfObject:oldInfovc]];
            
            [array addObject:oldInfovc];
            [self.navigationController setViewControllers:array animated:YES];
        }else{
            [self.navigationController pushViewController:detailuser animated:YES];
        }
    }
}
-(void)pushRepost{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = self.localmuzzik.muzzik_id;
    showvc.showType = @"repost";
    [self.navigationController pushViewController:showvc animated:YES];
}


-(void)pushMove{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = self.localmuzzik.muzzik_id;
    showvc.showType = @"moved";
    [self.navigationController pushViewController:showvc animated:YES];
}
-(void)pushShare{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = self.localmuzzik.muzzik_id;
    showvc.showType = @"share";
    [self.navigationController pushViewController:showvc animated:YES];
}
-(void)pushComment{
    if ([commentArray count]>0) {
        [muzzikTableView setContentOffset:CGPointMake(0, muzzikTableView.contentSize.height-SCREEN_WIDTH*3/2+10) animated:YES];
    }
    
    
}
-(void) moveAction{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        self.localmuzzik.ismoved = !self.localmuzzik.ismoved;
        if (self.localmuzzik.ismoved) {
            self.localmuzzik.moveds = [NSString stringWithFormat:@"%d",[self.localmuzzik.moveds intValue]+1 ];
        }else{
            self.localmuzzik.moveds = [NSString stringWithFormat:@"%d",[self.localmuzzik.moveds intValue]-1 ];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:self.localmuzzik];
       ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/moved",BaseURL,self.localmuzzik.muzzik_id]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:self.localmuzzik.ismoved] forKey:@"ismoved"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            if ([weakrequest responseStatusCode] == 200) {
                // NSData *data = [weakrequest responseData];
                
                
                
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
        }];
        [requestForm startAsynchronous];
        
        //NSLog(@"json:%@,dic:%@",tempJsonData,dic);
       
    }else{
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
    
}
-(void)repostAction{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        isforRepost = YES;
        if (!self.localmuzzik.isReposted) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定转发这条Muzzik吗?" message:@"" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:nil];
            // optional - add more buttons:
            [alert addButtonWithTitle:@"确定"];
            [alert show];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定取消转发这条Muzzik吗?" message:@"" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:nil];
            // optional - add more buttons:
            [alert addButtonWithTitle:@"确定"];
            [alert show];
        }
    }else{
        [userInfo checkLoginWithVC:self];
    }
    
}
-(void)shareAction{
    muzzikShareView.cell = _muzzikView;
    muzzikShareView.shareImage = [self.userImage imageForState:UIControlStateNormal];;
    muzzikShareView.shareMuzzik = self.localmuzzik;
    [muzzikShareView showShareView];
}
-(void)commentAction{
    [comnentTextView becomeFirstResponder];
}
-(void)deleMuzzikAction{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否删除该Muzzik信息" message:@"" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:nil];
    // optional - add more buttons:
    [alert addButtonWithTitle:@"确定"];
    [alert show];
   
}
-(void)alertMuzzik{

    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        alertSheet = [[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报", nil];
    }else{
        alertSheet = [[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"请先登录，再举报Ta", nil];
    }
    
    [alertSheet showInView:self.view.window];
}
-(void)playMusicLocal{
    MuzzikRequestCenter *center = [MuzzikRequestCenter shareClass];

    center.singleMusic = YES;

    
    [MuzzikPlayer shareClass].MusicArray = [NSMutableArray arrayWithArray:@[self.localmuzzik]];
     [MuzzikPlayer shareClass].listType = TempList;
    [[MuzzikPlayer shareClass] playSongWithSongModel:self.localmuzzik Title:[NSString stringWithFormat:@"单曲<%@>",self.localmuzzik.music.name]];
    [MuzzikItem SetUserInfoWithMuzziks:[NSMutableArray arrayWithArray:@[self.localmuzzik]] title:Constant_userInfo_temp description:[NSString stringWithFormat:@"单曲<%@>",self.localmuzzik.music.name]];
//    if ([[musicPlayer shareClass].MusicArray count]>0) {
//        for (UIView *view in [self.navigationController.view subviews]) {
//            if ([view isKindOfClass:[RFRadioView class]]) {
//                RFRadioView *musicView = (RFRadioView*)view;
//                musicView.isOpen = YES;
//                [UIView animateWithDuration:0.3 animations:^{
//                    [musicView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
//                }];
//                break;
//            }
//        }
//    }
}
-(void)deleSong{
    [musicButton setImage:[UIImage imageNamed:Image_detailaddsongImage] forState:UIControlStateNormal];
    isContainMusic = NO;
    MuzzikObject *mobject = [MuzzikObject shareClass];
    mobject.music = nil;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [songView setFrame:CGRectMake(0, commentView.frame.size.height+55, 0, 0)];
    [commentView setFrame:CGRectMake(commentView.frame.origin.x, commentView.frame.origin.y+55, SCREEN_WIDTH, commentView.frame.size.height-55)];
    [muzzikTableView setFrame:CGRectMake(muzzikTableView.frame.origin.x, muzzikTableView.frame.origin.y, SCREEN_WIDTH, muzzikTableView.frame.size.height+55)];
    [musicButton setImage:[UIImage imageNamed:Image_detailaddsongImage] forState:UIControlStateNormal];
    tableOriginRect = CGRectMake(tableOriginRect.origin.x, tableOriginRect.origin.y, tableOriginRect.size.width, tableOriginRect.size.height+55);
    commentViewRect = CGRectMake(commentViewRect.origin.x, commentViewRect.origin.y+55, SCREEN_WIDTH, commentViewRect.size.height-55);
    //    [self reloadChatTable];
    [UIView commitAnimations];
}
-(void) selectMusic{
    ChooseMusicVC *choosevc = [[ChooseMusicVC alloc] init];
    choosevc.comeInType = @"comment";
    [self.navigationController pushViewController:choosevc animated:YES];
}
-(void)userDetail:(NSString *)user_id{
    userInfo *user = [userInfo shareClass];
    if ([user_id isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        home.isPush = YES;
        [self.navigationController pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = user_id;
        
        userDetailInfo *oldInfovc;
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[userDetailInfo class]]) {
                userDetailInfo *udetail = (userDetailInfo *)vc;
                if ([udetail.uid isEqualToString:user_id]) {
                    oldInfovc = udetail;
                    break;
                }
                
            }
        }
        if (oldInfovc) {
            NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
            [array removeObjectAtIndex:[self.navigationController.viewControllers indexOfObject:oldInfovc]];
            
            [array addObject:oldInfovc];
            [self.navigationController setViewControllers:array animated:YES];
        }else{
            [self.navigationController pushViewController:detailuser animated:YES];
        }
    }
    
    
}

-(void)playnextMuzzikUpdate{
    Globle *glob = [Globle shareGloble];
    if ([[MuzzikPlayer shareClass].playingMuzzik.muzzik_id isEqualToString:self.localmuzzik.muzzik_id]&&!glob.isPause) {
        self.isPlaying = YES;
    }else{
        self.isPlaying = NO;
    }
    [self colorViewWithColorString:[NSString stringWithFormat:@"%@",self.localmuzzik.color]];
    [muzzikTableView reloadData];
}
- (void)refreshFooter
{
    // [self updateSomeThing];
    if ([lastID length]>0) {
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/comments",BaseURL,self.localmuzzik.muzzik_id]]];
        [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:lastID,Parameter_from,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = request;
        [request setCompletionBlock :^{
            // NSLog(@"%@",[weakrequest responseString]);
            NSData *data = [weakrequest responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dic) {
                muzzik *muzzikToy = [muzzik new];
                [commentArray addObjectsFromArray:[muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]]];
                lastID = [dic objectForKey:@"tail"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [muzzikTableView reloadData];
                    [muzzikTableView footerEndRefreshing];
                    if ([[dic objectForKey:@"muzziks"] count]<1 ) {
                        [muzzikTableView removeFooter];
                    }
                });
                
            }
        }];
        [request setFailedBlock:^{
            [muzzikTableView footerEndRefreshing];
            NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
        }];
        [request startAsynchronous];

    }
    
}
#pragma mark - 监听键盘高度改变事件

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.view addGestureRecognizer:tapOnview];
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    //
    CGRect newTableFrame = tableOriginRect;
    newTableFrame.size.height += -keyboardRect.size.height;
    

    
    CGRect newInputFieldFrame = commentViewRect;
    newInputFieldFrame.origin.y += -keyboardRect.size.height;
    
    
    // 键盘的动画时间，设定与其完全保持一致
    NSNumber *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];

    if ([animationDurationValue doubleValue]  < 0.05) {
        //不用动画
        muzzikTableView.frame = newTableFrame;
        commentView.frame = newInputFieldFrame;
        [self reloadChatTable];
        return;
    }
    
    
    NSNumber *num = [NSNumber new];
    [animationDurationValue getValue:(__bridge void *)(num)];
    
    
    // 键盘的动画是变速的，设定与其完全保持一致
    NSNumber *animationCurveObject = [userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // 开始及执行动画
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[animationDurationValue doubleValue]];
    [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurveObject];
    
    muzzikTableView.frame = newTableFrame;
    commentView.frame = newInputFieldFrame;
    
    [self reloadChatTable];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.view removeGestureRecognizer:tapOnview];
    commentToMuzzik = self.localmuzzik;
    comnentTextView.placeholder = [NSString stringWithFormat:@"回复 %@",commentToMuzzik.MuzzikUser.name];
    NSDictionary* userInfo = [notification userInfo];
    
    // 键盘的动画时间，设定与其完全保持一致
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // 键盘的动画是变速的，设定与其完全保持一致
    NSValue *animationCurveObject =[userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSUInteger animationCurve;
    [animationCurveObject getValue:&animationCurve];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurve];
    
    commentView.frame = commentViewRect;
    muzzikTableView.frame = tableOriginRect;
    [UIView commitAnimations];
}

-(void)reloadChatTable
{
    
    CGPoint contentOffsetPoint = muzzikTableView.contentOffset;
    CGRect frame = muzzikTableView.frame;
    if (fabs(contentOffsetPoint.y - muzzikTableView.contentSize.height - frame.size.height) < 15.0 || muzzikTableView.contentSize.height < frame.size.height || !firstLoad ||frame.size.height != tableOriginRect.size.height)
    {
        firstLoad = YES;
        if (!isComment) {
            if ([commentArray count]==0) {
                [muzzikTableView setContentOffset:CGPointMake(0, _muzzikView.frame.size.height-SCREEN_WIDTH+64) animated:YES];
            }else if([commentArray count]<=2){
                [muzzikTableView setContentOffset:CGPointMake(0, _muzzikView.frame.size.height-SCREEN_WIDTH+64+[commentArray count]*75+20) animated:YES];
            }else{
                [muzzikTableView setContentOffset:CGPointMake(0, _muzzikView.frame.size.height-SCREEN_WIDTH+64+160) animated:YES];
            }
            
        }else{
            [muzzikTableView scrollToRowAtIndexPath:
             [NSIndexPath indexPathForRow:[commentArray indexOfObject:commentToMuzzik]  inSection:0]
                                   atScrollPosition: UITableViewScrollPositionBottom
                                           animated:YES];
        }
        
//        if ([commentArray count]>0) {
//            [muzzikTableView scrollToRowAtIndexPath:
//             [NSIndexPath indexPathForRow:[commentArray count]-1 inSection:0]
//                                   atScrollPosition: UITableViewScrollPositionBottom
//                                           animated:YES];
//        }
//        else{
//            [muzzikTableView setContentOffset:CGPointMake(0, _muzzikView.frame.size.height-SCREEN_WIDTH/2) animated:YES];
//        }
        
    }
}

#pragma mark - 后退
-(void)tapAction:(UITapGestureRecognizer *)tap{
    
    MuzzikObject *mobject = [MuzzikObject shareClass];
    [mobject clearObject];
    [super tapAction:tap];
    
}

- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTransitInformation:(NSDictionary *)components{
    NSLog(@"%@",components);
    if ([[components allKeys] containsObject:@"topic_id"]) {
        TopicDetail *topicDetail = [[TopicDetail alloc] init];
        topicDetail.topic_id = [components objectForKey:@"topic_id"];
        [self.navigationController pushViewController:topicDetail animated:YES];
    }else if([[components allKeys] containsObject:@"at_name"]){
        
        userInfo *user = [userInfo shareClass];
        if ([[components objectForKey:@"at_name"] isEqualToString:user.name]) {
            UserHomePage *home = [[UserHomePage alloc] init];
            home.isPush = YES;
            [self.navigationController pushViewController:home animated:YES];
        }else{
            userDetailInfo *uInfo = [[userDetailInfo alloc] init];
            uInfo.uid = [[components objectForKey:@"at_name"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self.navigationController pushViewController:uInfo animated:YES];
        }
    }
}
#pragma -mark cellDelegate


-(void)playSongWithSongModel:(muzzik *)songModel{
    [MuzzikPlayer shareClass].listType = TempList;
    [MuzzikPlayer shareClass].MusicArray = [NSMutableArray arrayWithArray:@[songModel]];
    [MuzzikItem SetUserInfoWithMuzziks:[NSMutableArray arrayWithArray:@[songModel]] title:Constant_userInfo_temp description:[NSString stringWithFormat:@"单曲<%@>",songModel.music.name]];
    [[MuzzikPlayer shareClass] playSongWithSongModel:songModel Title:[NSString stringWithFormat:@"单曲<%@>",songModel.music.name]];
    

}
-(void)shareActionWithMuzzik:(muzzik *)localMuzzik image:(UIImage *) image cell:(UITableViewCell *)cell{
    muzzikShareView.cell = cell;
    muzzikShareView.shareImage = image;
    muzzikShareView.shareMuzzik = localMuzzik;
    [muzzikShareView showShareView];
}
-(void)dataSourceUserUpdate:(NSNotification *)notify{
    MuzzikUser *user = notify.object;
    if ([[_profileDic objectForKey:@"_id"] isEqualToString:user.user_id]) {
            [_profileDic setObject:[NSNumber numberWithBool:user.isFans ]forKey:@"isFans"];
            [_profileDic setObject:[NSNumber numberWithBool:user.isFollow ]forKey:@"isFollow"];
        if (user.isFollow &&user.isFans) {
            if ([[_profileDic objectForKey:@"isSupportChat"] boolValue]) {
                [_addFriendButton setImage:[UIImage imageNamed:@"detailchatImage"] forState:UIControlStateNormal];
            }else{
                [_addFriendButton setImage:[UIImage imageNamed:Image_viewprofileImage] forState:UIControlStateNormal];
            }
            [_attentionButton setImage:[UIImage imageNamed:Image_profilefolloweacherother] forState:UIControlStateNormal];
            [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-85, 16, 65, 23)];
            
        }else if(user.isFollow){
            [_addFriendButton setImage:[UIImage imageNamed:Image_viewprofileImage] forState:UIControlStateNormal];
            [_attentionButton setImage:[UIImage imageNamed:Image_profilefollowed] forState:UIControlStateNormal];
            [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-75, 16, 55, 23)];

        }else{
            [_addFriendButton setImage:[UIImage imageNamed:Image_detailfollowImage] forState:UIControlStateNormal];
            [_attentionButton setImage:[UIImage imageNamed:Image_profilefollow] forState:UIControlStateNormal];
            [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-65, 16, 45, 23)];

        }
    }
}

-(void)dataSourceMuzzikUpdate:(NSNotification *)notify{
    muzzik *tempMuzzik = (muzzik *)notify.object;
    if ([self.localmuzzik.muzzik_id isEqualToString:tempMuzzik.muzzik_id]) {
        self.localmuzzik.ismoved = tempMuzzik.ismoved;
        self.localmuzzik.isReposted = tempMuzzik.isReposted;
        self.localmuzzik.moveds = tempMuzzik.moveds;
        self.localmuzzik.reposts = tempMuzzik.reposts;
        self.localmuzzik.shares = tempMuzzik.shares;
        self.localmuzzik.comments = tempMuzzik.comments;
        [self colorViewWithColorString:[NSString stringWithFormat:@"%@",self.localmuzzik.color]];
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView == TipsAlterView && buttonIndex == 1){
        ASIHTTPRequest *feedBackRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/admin/feedback",BaseURL]]];
        [feedBackRequest addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:self.localmuzzik.muzzik_id forKey:@"message"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *WeakImageRequest = feedBackRequest;
        [feedBackRequest setCompletionBlock:^{
            if ([WeakImageRequest responseStatusCode]==200) {
                [MuzzikItem showNotifyOnView:self.navigationController.view text:@"举报成功"];
                
            }
        }];
        [feedBackRequest setFailedBlock:^{
            NSLog(@"%@",[WeakImageRequest error]);
            [userInfo checkLoginWithVC:self];
        }];
        [feedBackRequest startAsynchronous];
    }else if (buttonIndex == 1) {
        // do stuff
        if (isforRepost) {
            isforRepost = NO;
            if (!self.localmuzzik.isReposted) {
               
                self.localmuzzik.isReposted = YES;
                self.localmuzzik.reposts = [NSString stringWithFormat:@"%d",[self.localmuzzik.reposts intValue]+1];
                [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:self.localmuzzik];
                
                ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik",BaseURL]]];
                NSDictionary *dictionary = [NSDictionary dictionaryWithObject:self.localmuzzik.muzzik_id forKey:@"repost"];
                [requestForm addBodyDataSourceWithJsonByDic:dictionary Method:PutMethod auth:YES];
                __weak ASIHTTPRequest *weakrequest = requestForm;
                [requestForm setCompletionBlock :^{
                    NSLog(@"%@",[weakrequest requestHeaders]);
                    NSLog(@"%@",[weakrequest responseString]);
                    NSLog(@"%d",[weakrequest responseStatusCode]);
                    if ([weakrequest responseStatusCode] == 200) {
                         [MuzzikItem showNotifyOnView:self.view text:@"转发成功"];
                    }
                    
                    else if([weakrequest responseStatusCode] == 401){
                        //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                    }else if ([weakrequest responseStatusCode] == 400){
//                        [MuzzikItem showNotifyOnView:self.view text:@"转发成功"];
//                        self.localmuzzik.isReposted = YES;
//                        [self colorViewWithColorString:self.localmuzzik.color];

                    }
                }];
                [requestForm setFailedBlock:^{
                    NSLog(@"%@",[weakrequest error]);
                    [userInfo checkLoginWithVC:self];
                }];
                [requestForm startAsynchronous];
            }
            else{
                
                self.localmuzzik.isReposted = NO;
                self.localmuzzik.reposts = [NSString stringWithFormat:@"%d",[self.localmuzzik.reposts intValue]-1];
                [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:self.localmuzzik];
                ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/repost",BaseURL,self.localmuzzik.muzzik_id]]];
                [requestForm addBodyDataSourceWithJsonByDic:nil Method:DeleteMethod auth:YES];
                __weak ASIHTTPRequest *weakrequest = requestForm;
                [requestForm setCompletionBlock :^{
                    NSLog(@"%@",[weakrequest requestHeaders]);
                    NSLog(@"%@",[weakrequest responseString]);
                    NSLog(@"%d",[weakrequest responseStatusCode]);
                    if ([weakrequest responseStatusCode] == 200) {
                       [MuzzikItem showNotifyOnView:self.view text:@"取消转发"];
                    }
                    
                    else if([weakrequest responseStatusCode] == 401){
                        //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                    }else if ([weakrequest responseStatusCode] == 400){
                        
                    }
                }];
                [requestForm setFailedBlock:^{
                    NSLog(@"%@",[weakrequest error]);
                }];
                [requestForm startAsynchronous];
            }
        }
        else{
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@api/muzzik/%@",BaseURL,self.localmuzzik.muzzik_id]]];
            [requestForm addBodyDataSourceWithJsonByDic:nil Method:DeleteMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"%@",[weakrequest responseString]);
                NSLog(@"%d",[weakrequest responseStatusCode]);
                if ([weakrequest responseStatusCode] == 200 && [[dic objectForKey:@"result"] boolValue]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:String_Muzzik_Delete object:self.localmuzzik];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
            [requestForm setFailedBlock:^{
                
                // [SVProgressHUD showErrorWithStatus:@"network error"];
            }];
            [requestForm startAsynchronous];
        }
        
        
        
    }else{
        
    }
    
}
-(void) setUserInfo:(NSDictionary *) proDic{
    if (proDic) {
        self.localmuzzik.MuzzikUser.name = [proDic objectForKey:@"name"];
        commentToMuzzik.MuzzikUser.name =[proDic objectForKey:@"name"];
        comnentTextView.placeholder = [NSString stringWithFormat:@"评论 %@",[proDic objectForKey:@"name"]];
        [_userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,[proDic objectForKey:@"avatar"],Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [UIView animateWithDuration:0.5 animations:^{
                [_userImage setAlpha:1];
            }];
        }];
        _userName.text = [proDic objectForKey:@"name"];
        
        if (self.localmuzzik.isprivate) {
            [_userName sizeToFit];
            [MprivateImage setHidden:NO];
            [MprivateImage setFrame:CGRectMake(_userName.frame.origin.x+_userName.frame.size.width+2, _userName.frame.origin.y, 20, 20)];
        }
        
        
        NSArray *dicKeys = [proDic allKeys];
        if ([dicKeys containsObject:@"avatar"]) {
            [_headimage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,[proDic objectForKey:@"avatar"],Image_Size_Big]] placeholderImage:[UIImage imageNamed:Image_placeholdImage] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [UIView animateWithDuration:0.5 animations:^{
                    [_headimage setAlpha:1];
                    [_coverImage setAlpha:1];
                }];
                
                
            }];
        }
        if ([dicKeys containsObject:@"name"]) {
            _nameLabel.text = [proDic objectForKey:@"name"];
            [_nameLabel sizeToFit];
            [_nameLabel setFrame:CGRectMake(16, 16, _nameLabel.frame.size.width, _nameLabel.frame.size.height)];
            [_genderImage setFrame:CGRectMake(CGRectGetMaxX(_nameLabel.frame)+4, CGRectGetMidY(_nameLabel.frame)-8, 14, 14)];
            if ([[proDic objectForKey:@"gender"] isEqualToString:@"m"]) {
                [_genderImage setImage:[UIImage imageNamed:Image_profilemaleImage]];
            }else{
                [_genderImage setImage:[UIImage imageNamed:Image_profilefemaleImage]];
            }
        }
        
        CGFloat recordHeight = SCREEN_WIDTH/2-32;
        if ([dicKeys containsObject:@"birthday"] && [proDic objectForKey:@"birthday"]>0) {
            double unixTimeStamp = [[NSString stringWithFormat:@"%@",[proDic objectForKey:@"birthday"]] doubleValue]/1000;
            NSTimeInterval _interval=unixTimeStamp;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
            NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
            [_formatter setLocale:[NSLocale currentLocale]];
            [_formatter setDateFormat:@"YYYY.MM.dd"];
            NSString *_date=[_formatter stringFromDate:date];
            
            
            _birthImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
            [_birthImage setImage:[UIImage imageNamed:Image_profilebirthImage]];
            [headView addSubview:_birthImage];
            _birthLabel.frame = CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20);
            [_birthLabel setText:_date];
            [_birthLabel setTextColor:Color_Text_4];
            [_birthLabel setFont:[UIFont systemFontOfSize:12]];
            [headView addSubview:_birthLabel];
            recordHeight = recordHeight-28;
            
        }
        if ([dicKeys containsObject:@"company"] && [[proDic objectForKey:@"company"] length]>0) {
            _companyImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, recordHeight+5, 8, 8)];
            [_companyImage setImage:[UIImage imageNamed:Image_profilejobImage]];
            [headView addSubview:_companyImage];
            _companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20)];
            [_companyLabel setText:[proDic objectForKey:@"company"]];
            [_companyLabel setTextColor:Color_Text_4];
            [_companyLabel setFont:[UIFont systemFontOfSize:12]];
            [headView addSubview:_companyLabel];
            recordHeight = recordHeight-28;
            
        }else if([dicKeys containsObject:@"school"] && [[proDic objectForKey:@"school"] length]>0){
            _schoolImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, recordHeight+5, 8, 8)];
            [_schoolImage setImage:[UIImage imageNamed:Image_profileschoolImage]];
            [headView addSubview:_schoolImage];
            _schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20)];
            [_schoolLabel setText:[proDic objectForKey:@"school"]];
            [_schoolLabel setTextColor:Color_Text_4];
            [_schoolLabel setFont:[UIFont systemFontOfSize:12]];
            [headView addSubview:_schoolLabel];
            recordHeight = recordHeight-28;
        }
        if ([dicKeys containsObject:@"description"]) {
            UILabel *temp = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32, 100)];
            temp.numberOfLines = 0;
            [temp setFont:[UIFont systemFontOfSize:12]];
            temp.text =  [proDic objectForKey:@"description"];
            [temp sizeToFit];
            _descriptionLabel.frame = CGRectMake(16, CGRectGetMaxY(_nameLabel.frame)+10, SCREEN_WIDTH-32, temp.frame.size.height);
            _descriptionLabel.numberOfLines = 0;
            
            [_descriptionLabel setFont:[UIFont systemFontOfSize:12]];
            _descriptionLabel.text = [proDic objectForKey:@"description"];
            [_descriptionLabel setTextColor:[UIColor whiteColor]];
            [headView addSubview:_descriptionLabel];
        }
        
        
        if ([dicKeys containsObject:@"genres"] && [[proDic objectForKey:@"genres"] count]>0) {
            _genresView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-10, SCREEN_WIDTH/2-88, SCREEN_WIDTH/2-6, 76)];
            [headView addSubview: _genresView];
            int local = SCREEN_WIDTH/2-6;
            int localheight = 56;
            for (NSDictionary * dic in [proDic objectForKey:@"genres"]) {
                UILabel *tempLabel = [[UILabel alloc ] initWithFrame:CGRectMake(0, 0, 100, 20)];
                [tempLabel setFont:[UIFont systemFontOfSize:12]];
                [tempLabel setText:[dic objectForKey:@"data"]];
                [tempLabel sizeToFit];
                if (local- tempLabel.frame.size.width-20<0) {
                    localheight = localheight-28;
                    local = SCREEN_WIDTH/2-6;
                    if (localheight<28) {
                        break;
                    }
                }
                UILabel *tagLabel = [[UILabel alloc ] initWithFrame:CGRectMake(local- tempLabel.frame.size.width-20, localheight, tempLabel.frame.size.width+20, 20)];
                [tagLabel setFont:[UIFont systemFontOfSize:12]];
                [tagLabel setText:[dic objectForKey:@"data"]];
                tagLabel.textAlignment = NSTextAlignmentCenter;
                [tagLabel setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2]];
                tagLabel.layer.cornerRadius = 10;
                tagLabel.clipsToBounds = YES;
                [tagLabel setTextColor:Color_line_1];
                
                [_genresView addSubview:tagLabel];
                local = local- tempLabel.frame.size.width-28;
            }
        }
        userInfo *user = [userInfo shareClass];
        
        if ([user.uid isEqualToString:[proDic objectForKey:@"_id"]]) {
            
            _deleMuzzikButton = [[UIButton alloc] initWithFrame:CGRectMake(16,_reposts.frame.origin.y+40, (int)((SCREEN_WIDTH-32)/4), 55)];
            [_deleMuzzikButton setImage:[UIImage imageNamed:Image_detaildeleteImage] forState:UIControlStateNormal];
            [_deleMuzzikButton addTarget:self action:@selector(deleMuzzikAction) forControlEvents:UIControlEventTouchUpInside];
            [_muzzikView addSubview:_deleMuzzikButton];
            
            _repostButton = [[UIButton alloc] initWithFrame:CGRectMake((int)((SCREEN_WIDTH-32)/4)+16,_reposts.frame.origin.y+40, (int)((SCREEN_WIDTH-32)/4), 55)];
            [_repostButton setImage:[UIImage imageNamed:Image_detailretweetImage] forState:UIControlStateNormal];
            [_repostButton addTarget:self action:@selector(repostAction) forControlEvents:UIControlEventTouchUpInside];
            [_muzzikView addSubview:_repostButton];
            //[_repostButton setBackgroundColor:Color_Additional_4];
            _shareButton = [[UIButton alloc] initWithFrame:CGRectMake((int)((SCREEN_WIDTH-32)/2)+16,_reposts.frame.origin.y+40, (int)((SCREEN_WIDTH-32)/4), 55)];
            [_shareButton setImage:[UIImage imageNamed:Image_detailshareImage] forState:UIControlStateNormal];
            [_shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
            [_muzzikView addSubview:_shareButton];
            
            _commentButton = [[UIButton alloc] initWithFrame:CGRectMake((int)((SCREEN_WIDTH-32)/4)*3+16,_reposts.frame.origin.y+40,(int)((SCREEN_WIDTH-32)/4), 55)];
            [_commentButton setImage:[UIImage imageNamed:Image_detailreplyImage] forState:UIControlStateNormal];
            [_commentButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
            [_muzzikView addSubview:_commentButton];
            commentTitle = [[UIView alloc] initWithFrame:CGRectMake(0, _reposts.frame.origin.y+95, SCREEN_WIDTH, 45)];
            UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 0, 30, 45)];
            commentLabel.font = [UIFont boldSystemFontOfSize:15];
            commentLabel.textColor = Color_Text_1;
            commentLabel.text = @"评论";
            [commentTitle addSubview:commentLabel];
            [MuzzikItem addLineOnView:commentTitle heightPoint:44 toLeft:16 toRight:16 withColor:Color_line_1];
            [MuzzikItem addLineOnView:commentTitle heightPoint:45 toLeft:16 toRight:16 withColor:Color_line_1];
            
            [_muzzikView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, _reposts.frame.origin.y+140)];
            [MuzzikItem addLineOnView:_muzzikView heightPoint:_reposts.frame.origin.y+94 toLeft:16 toRight:16 withColor:Color_line_1];
            [muzzikTableView setTableHeaderView:_muzzikView];
            
        }
        else{
            _repostButton = [[UIButton alloc] initWithFrame:CGRectMake(16,_reposts.frame.origin.y+40, (int)((SCREEN_WIDTH-32)/4), 55)];
            [_repostButton setImage:[UIImage imageNamed:Image_detailretweetImage] forState:UIControlStateNormal];
            [_repostButton addTarget:self action:@selector(repostAction) forControlEvents:UIControlEventTouchUpInside];
            [_muzzikView addSubview:_repostButton];
            //[_repostButton setBackgroundColor:Color_Additional_4];
            _shareButton = [[UIButton alloc] initWithFrame:CGRectMake((int)((SCREEN_WIDTH-32)/4)+16,_reposts.frame.origin.y+40, (int)((SCREEN_WIDTH-32)/4), 55)];
            [_shareButton setImage:[UIImage imageNamed:Image_detailshareImage] forState:UIControlStateNormal];
            [_shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
            [_muzzikView addSubview:_shareButton];
            
            _commentButton = [[UIButton alloc] initWithFrame:CGRectMake((int)((SCREEN_WIDTH-32)/2)+16,_reposts.frame.origin.y+40, (int)((SCREEN_WIDTH-32)/4), 55)];
            [_commentButton setImage:[UIImage imageNamed:Image_detailreplyImage] forState:UIControlStateNormal];
            [_commentButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
            [_muzzikView addSubview:_commentButton];
            
            alterButton = [[UIButton alloc] initWithFrame:CGRectMake((int)((SCREEN_WIDTH-32)/4)*3+16,_reposts.frame.origin.y+40, (int)((SCREEN_WIDTH-32)/4), 55)];
            [alterButton setImage:[UIImage imageNamed:@"squaremoreicon"] forState:UIControlStateNormal];
            [alterButton addTarget:self action:@selector(alertMuzzik) forControlEvents:UIControlEventTouchUpInside];
            [_muzzikView addSubview:alterButton];
            cardView = [[UIView alloc] initWithFrame:CGRectMake(16, _reposts.frame.origin.y+95, SCREEN_WIDTH-32, 135)];
            cardView.backgroundColor = Color_line_2;
            cardView.layer.cornerRadius = 5;
            cardView.clipsToBounds = YES;
            cardView.layer.borderColor = Color_line_1.CGColor;
            cardView.layer.borderWidth = 1.0f;
            
            [_muzzikView addSubview:cardView];
            UIButton *cardHeader = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 67, 67)];
            cardHeader.layer.cornerRadius = 33.5;
            cardHeader.clipsToBounds = YES;
            [cardHeader sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,[proDic objectForKey:@"avatar"],Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [UIView animateWithDuration:0.5 animations:^{
                    [cardHeader setAlpha:1];
                }];
            }];
            [cardHeader addTarget:self action:@selector(goToUser) forControlEvents:UIControlEventTouchUpInside];
            [cardView addSubview:cardHeader];
            
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(97, 18, 150, 20)];
            [nameLabel setFont:[UIFont fontWithName:Font_Next_DemiBold size:18]];
            nameLabel.text = [proDic objectForKey:@"name"];
            [nameLabel sizeToFit];
            [cardView addSubview:nameLabel];
            _addFriendButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 93, SCREEN_WIDTH-62, 27)];
            [_addFriendButton setBackgroundImage:[MuzzikItem buttonImageFromColor:Color_Active_Button_1] forState:UIControlStateNormal];
            _addFriendButton.layer.cornerRadius = 3;
            _addFriendButton.clipsToBounds = YES;
            [_addFriendButton addTarget:self action:@selector(attentionOrVisit) forControlEvents:UIControlEventTouchUpInside];
            
            
            [cardView addSubview:_addFriendButton];
            if ([[proDic objectForKey:@"isFollow"] boolValue] &&[[proDic objectForKey:@"isFans"] boolValue]) {
                if ([[_profileDic objectForKey:@"isSupportChat"] boolValue]) {
                    [_addFriendButton setImage:[UIImage imageNamed:@"detailchatImage"] forState:UIControlStateNormal];
                }else{
                    [_addFriendButton setImage:[UIImage imageNamed:Image_viewprofileImage] forState:UIControlStateNormal];
                }
                [_attentionButton setImage:[UIImage imageNamed:Image_profilefolloweacherother] forState:UIControlStateNormal];
                [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-85, 16, 65, 23)];
               
            }else if([[proDic objectForKey:@"isFollow"] boolValue]){
                
                [_addFriendButton setImage:[UIImage imageNamed:Image_viewprofileImage] forState:UIControlStateNormal];
                [_attentionButton setImage:[UIImage imageNamed:Image_profilefollowed] forState:UIControlStateNormal];
                [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-75, 16, 55, 23)];
            }else{
                
                [_addFriendButton setImage:[UIImage imageNamed:Image_detailfollowImage] forState:UIControlStateNormal];
                [_attentionButton setImage:[UIImage imageNamed:Image_profilefollow] forState:UIControlStateNormal];
                [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-65, 16, 45, 23)];
            }
            [genresV removeFromSuperview];
            if ([[proDic allKeys] containsObject:@"genres"] && [[proDic objectForKey:@"genres"] count]>0) {
                
                genresV = [[UIView alloc] initWithFrame:CGRectMake(97, 49, SCREEN_WIDTH-140, 40)];
                [cardView addSubview: genresV];
                int local = 0;
                int localheight = 0;
                for (NSDictionary * dic in [proDic objectForKey:@"genres"]) {
                    UILabel *tempLabel = [[UILabel alloc ] initWithFrame:CGRectMake(local, localheight, 100, 15)];
                    [tempLabel setFont:[UIFont systemFontOfSize:11]];
                    [tempLabel setText:[dic objectForKey:@"data"]];
                    [tempLabel setTextColor:Color_Text_3];
                    [tempLabel sizeToFit];
                    if (local+ tempLabel.frame.size.width>SCREEN_WIDTH-140) {
                        localheight = localheight+15;
                        local = 0;
                        if (localheight>20) {
                            break;
                        }
                    }else{
                        local = local+tempLabel.frame.size.width+15;
                        [genresV addSubview:tempLabel];
                    }
                    
                }
            }else if ([dicKeys containsObject:@"description"] && [[proDic objectForKey:@"description"] length]>0) {
                [genresV removeFromSuperview];
                 genresV = [[UIView alloc] initWithFrame:CGRectMake(97, 47, SCREEN_WIDTH-140, 40)];
                UILabel *descrip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, genresV.frame.size.width-5, 40)];
                
                NSDictionary *attributes;
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                paragraphStyle.lineSpacing = 3;
                attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:11], NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:Color_Text_3};
                NSAttributedString * attr= [[NSAttributedString alloc] initWithString:[proDic objectForKey:@"description"] attributes:attributes];
                descrip.attributedText = attr;
                descrip.numberOfLines = 0;
                [genresV addSubview:descrip];
                 [cardView addSubview: genresV];
            }
            if (cardView.frame.size.width - nameLabel.frame.size.width< 137){
                [nameLabel setFrame:CGRectMake(97, 18, cardView.frame.size.width - 137, 20)];
            }
            UIImageView *genderSign = [[UIImageView alloc] initWithFrame:CGRectMake(97+(int)nameLabel.frame.size.width+5, 23, 14, 14)];
            if ([[proDic objectForKey:@"gender"] isEqualToString:@"m"]) {
                [genderSign setImage:[UIImage imageNamed:Image_profilemaleImage]];
            }else{
                [genderSign setImage:[UIImage imageNamed:Image_profilefemaleImage]];
            }
            [cardView addSubview:genderSign];
            commentTitle = [[UIView alloc] initWithFrame:CGRectMake(0, _reposts.frame.origin.y+230, SCREEN_WIDTH, 45)];
            UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 0, 30, 45)];
            commentLabel.font = [UIFont boldSystemFontOfSize:15];
            commentLabel.textColor = Color_Text_1;
            commentLabel.text = @"评论";
            [commentTitle addSubview:commentLabel];
            [MuzzikItem addLineOnView:commentTitle heightPoint:44 toLeft:16 toRight:16 withColor:Color_line_1];
            [MuzzikItem addLineOnView:commentTitle heightPoint:45 toLeft:16 toRight:16 withColor:Color_line_1];
            
            [_muzzikView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, _reposts.frame.origin.y+275)];
            [muzzikTableView setTableHeaderView:_muzzikView];
            
        }
        [self colorViewWithColorString:[NSString stringWithFormat:@"%@",self.localmuzzik.color]];
        
    }
}
-(void)reloadDataSource{
    [super reloadDataSource];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        [self loadMuzzikView];
    });
    

}
-(void)loadMuzzikView{
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@",BaseURL,self.muzzik_id]]];
    [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        self.localmuzzik.rawDic = dic;
        self.localmuzzik.ismoved = [[dic objectForKey:@"ismoved"] boolValue];
        self.localmuzzik.date = [dic objectForKey:@"date"];
        self.localmuzzik.message = [dic objectForKey:@"message"];
        if ([[dic allKeys] containsObject:@"image"] ) {
            self.localmuzzik.image = [dic objectForKey:@"image"];
        }
        self.localmuzzik.type = [dic objectForKey:@"type"];
        self.localmuzzik.muzzik_id = [dic objectForKey:@"_id"];
        self.localmuzzik.topics = [dic objectForKey:@"topics"];
        self.localmuzzik.users = [dic objectForKey:@"users"];
        self.localmuzzik.onlytext = [[dic objectForKey:@"onlyText"] boolValue];
        self.localmuzzik.isReposted = [[dic objectForKey:@"isReposted"] boolValue];
        self.localmuzzik.reposts = [dic objectForKey:@"reposts"];
        self.localmuzzik.shares = [dic objectForKey:@"shares"];
        self.localmuzzik.comments = [dic objectForKey:@"comments"];
        self.localmuzzik.color = [dic objectForKey:@"color"];
        self.localmuzzik.moveds = [dic objectForKey:@"moveds"];
        self.localmuzzik.isprivate = [[dic objectForKey:@"private"] boolValue];
        self.localmuzzik.plays = [dic objectForKey:@"plays"];
        self.localmuzzik.repostID = [dic objectForKey:@"repostID"];
        self.localmuzzik.title = [dic objectForKey:@"title"];
        self.localmuzzik.repostDate = [dic objectForKey:@"repostDate"];
        self.localmuzzik.MuzzikUser = [MuzzikUser new];
        self.localmuzzik.MuzzikUser.avatar = [[dic objectForKey:@"user"] objectForKey:@"avatar"];
        self.localmuzzik.MuzzikUser.user_id = [[dic objectForKey:@"user"] objectForKey:@"_id"];
        self.localmuzzik.MuzzikUser.gender = [[dic objectForKey:@"user"] objectForKey:@"gender"];
        self.localmuzzik.MuzzikUser.name = [[dic objectForKey:@"user"] objectForKey:@"name"];
        self.localmuzzik.MuzzikUser.isFollow =[[[dic objectForKey:@"user"] objectForKey:@"isFollow"] boolValue];;
        self.localmuzzik.MuzzikUser.isFans =[[[dic objectForKey:@"user"] objectForKey:@"isFans"] boolValue];
        self.localmuzzik.music = [music new];
        self.localmuzzik.music.music_id = [[dic objectForKey:@"music"] objectForKey:@"_id"];
        self.localmuzzik.music.artist = [[dic objectForKey:@"music"] objectForKey:@"artist"];
        //NSLog(@"%@",[[dic objectForKey:@"music"] objectForKey:@"artist"]);
        self.localmuzzik.music.key = [[dic objectForKey:@"music"] objectForKey:@"key"];
        // newmuzzik.music.block = [[[dic objectForKey:@"music"] objectForKey:@"block"] boolValue];
        self.localmuzzik.music.name = [[dic objectForKey:@"music"] objectForKey:@"name"];
        if ([[dic allKeys ] containsObject:@"reply"] &&[[dic objectForKey:@"reply"] isKindOfClass:[NSDictionary class]] &&[[[dic objectForKey:@"reply"] allKeys] count]>1) {
            self.localmuzzik.reply.reply_id = [[dic objectForKey:@"reply"] objectForKey:@"_id"];
            self.localmuzzik.reply.message = [[dic objectForKey:@"reply"] objectForKey:@"message"];
            self.localmuzzik.reply.color = [[dic objectForKey:@"reply"] objectForKey:@"color"];
        }else if([[dic allKeys ] containsObject:@"reply"] &&[[dic objectForKey:@"reply"] isKindOfClass:[NSString class]] && [[dic objectForKey:@"reply"] length]>0 ){
            self.localmuzzik.replystring = [dic objectForKey:@"reply"];
        }
        commentToMuzzik = self.localmuzzik;
        if ([self.localmuzzik.replystring length]>0) {
            [self initNagationBar:@"详情" leftBtn:Constant_backImage rightBtn:10];
        }
        if ([self.localmuzzik.type isEqualToString:@"repost"]) {
            _repostImage = [[UIImageView alloc] initWithFrame:CGRectMake(66, 36, 8, 8)];
            [_muzzikView addSubview:_repostImage];
            _repostUserName = [[UILabel alloc] initWithFrame:CGRectMake(80, 36, 150, 10)];
            [_repostUserName setTextColor:Color_Additional_5];
            [_repostUserName setFont:[UIFont fontWithName:Font_Next_DemiBold size:8]];
            _repostUserName.text = self.localmuzzik.reposter.name;
            [_muzzikView addSubview:_repostUserName];
            _timeStamp.text = [MuzzikItem transtromTime:self.localmuzzik.repostDate];
            
        }else{
            _timeStamp.text = [MuzzikItem transtromTime:self.localmuzzik.date];
        }
        [_timeStamp sizeToFit];
        [_timeImage setFrame:CGRectMake(CGRectGetMaxX(_timeStamp.frame)+3, _timeImage.frame.origin.y, _timeImage.frame.size.width, _timeImage.frame.size.height)];
        
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@",BaseURL_LUCH,self.localmuzzik.MuzzikUser.user_id]]];
        [requestForm addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakreq = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakreq responseString]);
            NSLog(@"%d",[weakreq responseStatusCode]);
            if ([weakreq responseStatusCode] == 200) {
                _profileDic = [NSJSONSerialization JSONObjectWithData:[weakreq responseData]  options:NSJSONReadingMutableContainers error:nil];
                _muzzikMessage.text = self.localmuzzik.message;
                [_muzzikMessage addClickMessagewithTopics:self.localmuzzik.topics];
                [_muzzikMessage addClickMessageForAt];
                _muzzikMessage.delegate = self;
                
                [_muzzikMessage setFrame:CGRectMake( _muzzikMessage.frame.origin.x , _muzzikMessage.frame.origin.y, SCREEN_WIDTH-32, (int)[MuzzikItem heightForLabel:_muzzikMessage WithText:_muzzikMessage.text]+10)];
                [_muzzikView addSubview:_muzzikMessage];
                _muzzikView.backgroundColor = [UIColor whiteColor];
                _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(_muzzikMessage.frame)+10, SCREEN_WIDTH-32, 0.5)];
                [_progress setProgress:1];
                [_muzzikView addSubview:_progress];
                _musicName = [[UILabel alloc] initWithFrame:CGRectMake(80, CGRectGetMaxY(_progress.frame)+12, SCREEN_WIDTH-150, 20)];
                [_musicName setFont:[UIFont fontWithName:Font_Next_Bold size:16]];
                _musicName.text = self.localmuzzik.music.name;
                [_muzzikView addSubview:_musicName];
                
                _musicArtist = [[UILabel alloc] initWithFrame:CGRectMake(80, CGRectGetMaxY(_progress.frame)+31, SCREEN_WIDTH-150, 25)];
                [_musicArtist setFont:[UIFont fontWithName:Font_Next_Bold size:13]];
                _musicArtist.text = self.localmuzzik.music.artist;
                [_muzzikView addSubview:_musicArtist];
                
                _likeButton = [[UIButton alloc] initWithFrame:CGRectMake(21, CGRectGetMaxY(_progress.frame)+13, 36, 36)];
                [_likeButton addTarget:self action:@selector(moveAction) forControlEvents:UIControlEventTouchUpInside];
                [_muzzikView addSubview:_likeButton];
                
                _playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-57, CGRectGetMaxY(_progress.frame)+13, 36, 36)];
                
                [_playButton addTarget:self action:@selector(playMusicLocal) forControlEvents:UIControlEventTouchUpInside];
                [_muzzikView addSubview:_playButton];
                if (![self.localmuzzik.image isKindOfClass:[NSNull class]] && [self.localmuzzik.image length]>0) {
                    _poImage = [[PhotoImageView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(_progress.frame)+60, SCREEN_WIDTH-32, SCREEN_WIDTH-32)];
                    _poImage.delegate = self;
                    _poImage.layer.cornerRadius = 3;
                    _poImage.clipsToBounds = YES;
                    [_poImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,self.localmuzzik.image,Image_Size_Big]] placeholderImage:[UIImage imageNamed:Image_placeholdImage] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [UIView animateWithDuration:0.5 animations:^{
                            [_poImage setAlpha:1];
                        }];
                        
                        
                    }];
                    [_muzzikView addSubview:_poImage];
                    
                    _reposts = [[UIButton alloc] initWithFrame:CGRectMake((int)((SCREEN_WIDTH-32)/4)+16, CGRectGetMaxY(_progress.frame)+SCREEN_WIDTH+28, (int)((SCREEN_WIDTH-32)/4), 40)];
                    
                    
                }else{
                    _upperLine = [[UIImageView alloc] initWithFrame:CGRectMake(16,CGRectGetMaxY(_progress.frame)+59, SCREEN_WIDTH-32, 1)];
                    [_upperLine setImage:[UIImage imageNamed:Image_lineImage]];
                    [_muzzikView addSubview:_upperLine];
                    _reposts = [[UIButton alloc] initWithFrame:CGRectMake((int)((SCREEN_WIDTH-32)/4)+16, CGRectGetMaxY(_progress.frame)+60, (int)((SCREEN_WIDTH-32)/4), 40)];
                    
                }
                [_reposts setTitle:[self.localmuzzik.reposts integerValue]>0? [NSString stringWithFormat:@"转发数%@",self.localmuzzik.reposts] : @"转发数" forState:UIControlStateNormal];
                [_reposts setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
                [_reposts.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
                [_reposts addTarget:self action:@selector(pushRepost) forControlEvents:UIControlEventTouchUpInside];
                _reposts.titleLabel.textAlignment = NSTextAlignmentCenter;
                [_muzzikView addSubview:_reposts];
                
                _moves = [[UIButton alloc] initWithFrame:CGRectMake(16, _reposts.frame.origin.y, (int)((SCREEN_WIDTH-32)/4), 40)];
                [_moves setTitle:@"喜欢数" forState:UIControlStateNormal];
                [_moves setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
                [_moves.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
                [_moves addTarget:self action:@selector(pushMove) forControlEvents:UIControlEventTouchUpInside];
                _moves.titleLabel.textAlignment = NSTextAlignmentCenter;
                [_moves setTitle:[self.localmuzzik.moveds integerValue]>0? [NSString stringWithFormat:@"喜欢数%@",self.localmuzzik.moveds] : @"喜欢数" forState:UIControlStateNormal];
                [_muzzikView addSubview:_moves];
                
                _shares = [[UIButton alloc] initWithFrame:CGRectMake((int)((SCREEN_WIDTH-32)/2)+16, _reposts.frame.origin.y, (int)((SCREEN_WIDTH-32)/4), 40)];
                [_shares setTitle:@"分享数" forState:UIControlStateNormal];
                [_shares setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
                [_shares.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
                [_shares addTarget:self action:@selector(pushShare) forControlEvents:UIControlEventTouchUpInside];
                [_shares setTitle:[self.localmuzzik.shares integerValue]>0? [NSString stringWithFormat:@"分享数%@",self.localmuzzik.shares] : @"分享数" forState:UIControlStateNormal];
                _shares.titleLabel.textAlignment = NSTextAlignmentCenter;
                [_muzzikView addSubview:_shares];
                
                _comments = [[UIButton alloc] initWithFrame:CGRectMake((int)((SCREEN_WIDTH-32)/4)*3+16, _reposts.frame.origin.y, (int)((SCREEN_WIDTH-32)/4), 40)];
                [_comments setTitle:@"评论数" forState:UIControlStateNormal];
                [_comments setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
                [_comments.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
                [_comments addTarget:self action:@selector(pushComment) forControlEvents:UIControlEventTouchUpInside];
                [_comments setTitle:[self.localmuzzik.comments integerValue]>0? [NSString stringWithFormat:@"评论数%@",self.localmuzzik.comments] : @"评论数" forState:UIControlStateNormal];
                _comments.titleLabel.textAlignment = NSTextAlignmentCenter;
                [_muzzikView addSubview:_comments];
#pragma -mark head
                _headimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/2)];
                _headimage.contentMode = UIViewContentModeScaleAspectFill;
                [_headimage setAlpha:0];
                [headView addSubview:_headimage];
                _coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/2)];
                [_coverImage setAlpha:1];
                [_coverImage setImage:[UIImage imageNamed:Image_prifilebgcover]];
                [headView addSubview:_coverImage];
                _attentionButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 16, 85, 23)];
                [_attentionButton addTarget:self action:@selector(attentionAction) forControlEvents:UIControlEventTouchUpInside];
                [headView addSubview:_attentionButton];
                
                
                _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, 30, 30)];
                [_nameLabel setFont:[UIFont fontWithName:Font_Next_DemiBold size:20]];
                _nameLabel.textColor = [UIColor whiteColor];
                [headView addSubview:_nameLabel];
                _genderImage = [[UIImageView alloc] init];
                [headView addSubview:_genderImage];
                
                _constellationImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
                _constellationLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, SCREEN_WIDTH/2-50, 20)];
                
                _birthImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
                _birthLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
                
                _companyImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
                _companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
                
                _schoolImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
                _schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
                _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32,0)];
                
                
                
                
                _downLine = [[UIImageView alloc] initWithFrame:CGRectMake(16,_reposts.frame.origin.y+40, SCREEN_WIDTH-32, 1)];
                [_downLine setImage:[UIImage imageNamed:Image_lineImage]];
                [_muzzikView addSubview:_downLine];
                
                songView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, SCREEN_WIDTH, 55)];
                [MuzzikItem addLineOnView:songView heightPoint:0 toLeft:10 toRight:10 withColor:Color_line_1];
                songLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 7.5, SCREEN_WIDTH-100, 20)];
                [songLabel setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
                songLabel.textColor = Color_Theme_5;
                [songView addSubview:songLabel];
                
                artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 27.5, SCREEN_WIDTH-100, 20)];
                [artistLabel setFont:[UIFont fontWithName:Font_Next_DemiBold size:12]];
                artistLabel.textColor = Color_Theme_5;
                [songView addSubview:artistLabel];
                deleButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-40, 7.5, 40, 40)];
                [deleButton setImage:[UIImage imageNamed:Image_deletesongImage] forState:UIControlStateNormal];
                [deleButton addTarget:self action:@selector(deleSong) forControlEvents:UIControlEventTouchUpInside];
                [songView addSubview:deleButton];
                
                [self setUserInfo:_profileDic];
                [self loadComment];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakreq error]);
            NSLog(@"hhhh%@  kkk%@",[weakreq responseString],[weakreq responseHeaders]);
            if (![[weakreq responseString] length]>0) {
                [self networkErrorShow];
            }
        }];
        [requestForm startAsynchronous];
        
        
        
        
        
        
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
        NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
        if (![[weakrequest responseString] length]>0) {
            [self networkErrorShow];
        }
        
    }];
    [request startAsynchronous];
    
    
    
}
-(void)newConversationAction{
    RCUserInfo *targetUserinfo;
    if ([[_profileDic objectForKey:@"_id"] length] >0 && [[_profileDic objectForKey:@"avatar"] length] >0 && [[_profileDic objectForKey:@"name"] length] >0) {
        BOOL isContained = NO;
        IMConversationViewcontroller *imVC = [[IMConversationViewcontroller alloc] init];
        
        
        AppDelegate *app = (AppDelegate *) [UIApplication sharedApplication].delegate;
        targetUserinfo = [[RCUserInfo alloc] initWithUserId:[_profileDic objectForKey:@"_id"] name:[_profileDic objectForKey:@"name"]  portrait:[_profileDic objectForKey:@"avatar"] ];
        imVC.con = [app getConversationByUserInfo:targetUserinfo];
        imVC.con.unReadMessage = [NSNumber numberWithInt:0];
        imVC.title = imVC.con.targetUser.name;
        [app.managedObjectContext save:nil];
        
        
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[IMConversationViewcontroller class]]) {
                isContained = YES;
                break;
            }
        }
        if (isContained) {
            NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[IMConversationViewcontroller class]]) {
                    [array removeObjectAtIndex:[self.navigationController.viewControllers indexOfObject:vc]];
                }
            }
            [array addObject:imVC];
            [self.navigationController setViewControllers:array animated:YES];
        }else{
            [self.navigationController pushViewController:imVC animated:YES];
        }
    }
    
}
-(void)rightBtnAction:(UIButton *)sender{
    if ([self.localmuzzik.replystring length]>0) {
        DialogVC *dialog = [[DialogVC alloc] init];
        dialog.muzzik_id = self.localmuzzik.muzzik_id;
        MuzzikObject *mobject = [MuzzikObject shareClass];
        if (mobject.music) {
             [self deleSong];
        }
        [mobject clearObject];
       
        [privateButton setImage:[UIImage imageNamed:Image_detailvisibleImage] forState:UIControlStateNormal];
        commentToMuzzik = self.localmuzzik;
        comnentTextView.placeholder = [NSString stringWithFormat:@"回复 %@",commentToMuzzik.MuzzikUser.name];
        [comnentTextView becomeFirstResponder];
        [self.navigationController pushViewController:dialog animated:YES];
        
    }else{
        [super rightBtnAction:sender];
    }
}
@end
