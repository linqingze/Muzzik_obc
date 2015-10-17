//
//  ChooseLyricVC.m
//  muzzik
//
//  Created by muzzik on 15/4/28.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import "ChooseLyricVC.h"
#import "TableViewCell.h"
#import "RJTextView.h"
#import "JSImagePickerViewController.h"
#import "StyledPageControl.h"
#import "ASIFormDataRequest.h"
#import "FontTableCell.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "NLImageCropperView.h"
@interface ChooseLyricVC()<UITableViewDataSource,UITableViewDelegate,RJTextViewDelegate,ASIProgressDelegate,JSImagePickerViewControllerDelegate,NLImageCropperViewDelegate>{
    NLImageCropperView* _imageCropper;
    NSMutableArray *fontArray;
    NSMutableArray *lyricArray;
    NSArray *famousArray;
    UIImageView *headImage;
    long long _curSize;
    BOOL isCharacterWhite;
    BOOL isShow;
    UIButton *fontButton;
    UIButton *ColorButton;
    UIButton *ImageButton;
    UIButton *LibraryButton;
    StyledPageControl *PageControl;
    UIScrollView *Scroll;
    UIButton *nextButton;
    UIImageView *shareCycle;
    UIView *controlView;
    UIView *sharaView;
    NSInteger step;
    BOOL isShareToWeiChat;
    BOOL isShareToWeiBo;
    BOOL isShareToQQ;
    UIView *resultView;
    UIImage *Muzzikimage;
    RJTextView *shareLabel;
    UIColor *shareColor;
    UIImageView *MuzzikLogoImage;
    UIView *lyricView;
    RJTextView *lyricTextView;
    UITableView *lyricTablenview;
    UIView *editView;
    RJTextView *editTextView;
    
    UIView *famousView;
    RJTextView *famousTextView;
    UITableView *famousTableview;
    
    UITableView *fontTableView;
    BOOL fontTableShowed;
    UIImageView *animationView;
    UIView *shareWhiteView;
    UIImageView *MuzzikLogo;
    UILabel *tipsLabel;
    
    UIView *shareChannelView;
    UIButton *weiboShare;
    UIButton *weChatshare;
    UIButton *QQZoneShare;
    UILabel *NoLyricTips;
    BOOL isSending;
    BOOL isDefaultImage;
    BOOL allowToSubmit;
}
@end
@implementation ChooseLyricVC

-(void)viewDidLoad{
    [super viewDidLoad];
    isShareToWeiChat = YES;
    lyricArray = [NSMutableArray array];
    [self initNagationBar:@"填选一句话（3/3）" leftBtn:Constant_backImage rightBtn:0];
    MuzzikObject *mobject = [MuzzikObject shareClass];
    if ([mobject.lyricArray count]>0) {
        for (NSDictionary *dic in mobject.lyricArray) {
            if ([[[dic allValues][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] >0 ) {
                [lyricArray addObject:dic];
            }
        }
    }
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"popWords" ofType:@"plist"];
    
    famousArray = [NSArray arrayWithContentsOfFile:plistPath];
    //    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchOutside:)]];
    headImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    headImage.contentMode = UIViewContentModeScaleAspectFit;
    [headImage setBackgroundColor:[UIColor whiteColor]];
    
    if (self.image) {
        headImage.image = self.image;
        MuzzikLogoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"muzzikwhite"]];
        shareColor = [UIColor whiteColor];
        MuzzikLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sharewhiteMuzzik"]];
    }else{
        [headImage setImage:[UIImage imageNamed:Image_Textcover]];
        MuzzikLogoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"muzzikblack"]];
        MuzzikLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shareblackMuzzik"]];
        shareColor = [UIColor blackColor];
    }
    [MuzzikLogoImage setFrame:CGRectMake(10, SCREEN_WIDTH-MuzzikLogoImage.frame.size.height-10,MuzzikLogoImage.frame.size.width , MuzzikLogoImage.frame.size.height)];
    
    [self.view addSubview:headImage];
    Scroll = [[UIScrollView alloc] initWithFrame:headImage.frame];
    userInfo *user = [userInfo shareClass];
    
    
    [self.view addSubview:Scroll];
    shareWhiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [shareWhiteView setBackgroundColor:[UIColor whiteColor]];
    lyricView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    
    [lyricView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideControl)]];
    Scroll.delegate = self;
    Scroll.pagingEnabled = YES;
    [Scroll setShowsHorizontalScrollIndicator:NO];
    lyricTablenview = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 25, SCREEN_WIDTH, SCREEN_WIDTH-50)];
    lyricTablenview.delegate = self;
    lyricTablenview.dataSource = self;
   
    [lyricTablenview setBackgroundColor:[UIColor clearColor]];
    lyricTablenview.backgroundView  = nil;
    [lyricTablenview registerClass:[TableViewCell class] forCellReuseIdentifier:@"TableViewCell"];
    lyricTablenview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    famousView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [Scroll addSubview:famousView];
    [famousView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideControl)]];
    famousTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 25, SCREEN_WIDTH, SCREEN_WIDTH-50)];
    famousTableview.delegate = self;
    famousTableview.dataSource = self;
    [Scroll addSubview:famousTableview];
    [famousTableview setBackgroundColor:[UIColor clearColor]];
    famousTableview.backgroundView  = nil;
    [famousTableview registerClass:[TableViewCell class] forCellReuseIdentifier:@"TableViewCell"];
    famousTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
     [self loadFont];
    
    
    editView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*2, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [Scroll addSubview:editView];
    //[editView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideControl)]];
    editTextView = [[RJTextView alloc] initWithFrame:CGRectMake(70, 120, SCREEN_WIDTH-140, 60)
                                         defaultText:@""
                                                font:[UIFont fontWithName:Font_default_share size:20]
                                               color:shareColor
                                             minSize:CGSizeMake(100, 54)];
    editTextView.fontname = Font_default_share;
    editTextView.delegate = self;
    [editTextView.closeButton removeFromSuperview];
    [editView addSubview:editTextView];
    
    
    
    controlView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, 30)];
    [self.view addSubview:controlView];
    
    PageControl = [[StyledPageControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-20, 0, 40, 30)];
    //page control
    [PageControl setCoreSelectedColor:Color_Active_Button_1];
    PageControl.strokeSelectedColor = [UIColor clearColor] ;
    PageControl.strokeNormalColor = [UIColor clearColor] ;
    [PageControl setCoreNormalColor:Color_line_1];
    [PageControl setDiameter:8];
    [PageControl setGapWidth:5];
    
    [controlView addSubview:PageControl];
    
    ImageButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-73, 0, 30, 30)];
    [ImageButton setImage:[UIImage imageNamed:Image_SwitchingImage] forState:UIControlStateNormal];
    [controlView addSubview:ImageButton];
    [ImageButton addTarget:self action:@selector(swithImage) forControlEvents:UIControlEventTouchUpInside];
    
    ColorButton = [[UIButton alloc] initWithFrame:CGRectMake(13, 0, 30, 30)];
    
    
    LibraryButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-43, 0, 30, 30)];
    [controlView addSubview:LibraryButton];
    
    [LibraryButton addTarget:self action:@selector(changeImage) forControlEvents:UIControlEventTouchUpInside];
    if (self.image) {
        isShow = YES;
        [LibraryButton setImage:[UIImage imageNamed:Image_addedpicImage] forState:UIControlStateNormal];
        [ImageButton setHidden:NO];
        isCharacterWhite = YES;
        [ColorButton setImage:[UIImage imageNamed:Image_textwhiteImage] forState:UIControlStateNormal];
    }else{
        isDefaultImage = YES;
        isCharacterWhite = NO;
        [LibraryButton setImage:[UIImage imageNamed:Image_addpicImage] forState:UIControlStateNormal];
        [ColorButton setImage:[UIImage imageNamed:Image_textblackImage] forState:UIControlStateNormal];
        [ImageButton setHidden:YES];
    }
    [ColorButton addTarget:self action:@selector(changColor) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:ColorButton];
    
    fontButton = [[UIButton alloc] initWithFrame:CGRectMake(43, 0, 30, 30)];
    [fontButton setImage:[UIImage imageNamed:Image_fontImage] forState:UIControlStateNormal];
    [fontButton setImage:[UIImage imageNamed:Image_fontclickImage] forState:UIControlStateHighlighted];
    [fontButton addTarget:self action:@selector(changFont) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:fontButton];
    fontTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH+31 , SCREEN_WIDTH, SCREEN_HEIGHT-SCREEN_WIDTH-95)];
    fontTableView.delegate = self;
    fontTableView.dataSource = self;
    [Scroll addSubview:fontTableView];
    [fontTableView registerClass:[FontTableCell class] forCellReuseIdentifier:@"FontTableCell"];
    fontTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    
    [MuzzikItem addLineOnView:self.view heightPoint:SCREEN_WIDTH+30 toLeft:13 toRight:13 withColor:Color_line_1];
   
    //    nextButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-67, SCREEN_HEIGHT-113, 54, 52)];
    //    [nextButton setImage:[UIImage imageNamed:Image_Next] forState:UIControlStateNormal];
    //    [self.view addSubview: nextButton];
    //    [nextButton addTarget:self action:@selector(summitAction) forControlEvents:UIControlEventTouchUpInside];
    
    if ([lyricArray count] == 1) {
        lyricTextView = [[RJTextView alloc] initWithFrame:CGRectMake(0, 0, 1,1)
                                              defaultText:@""
                                                     font:[UIFont systemFontOfSize:15.f]
                                                    color:shareColor
                                                  minSize:CGSizeMake(60, 60)];
        [self checkNext];
    }
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [path stringByAppendingPathComponent:@"Font"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断temp文件夹是否存在
    BOOL fileExists = [fileManager fileExistsAtPath:folderPath];
    if (!fileExists) {//如果不存在说创建,因为下载时,不会自动创建文件夹
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    
    
    for (NSDictionary *dic in fontArray) {
        if ([[dic allKeys] containsObject:@"path"]) {
            [MuzzikItem customFontWithPath:[NSString stringWithFormat:@"%@.ttf",[folderPath stringByAppendingPathComponent:[dic objectForKey:@"fontname"]]]];
        }
    }
    sharaView = [[UIView alloc] initWithFrame:CGRectMake(-SCREEN_WIDTH, SCREEN_WIDTH, SCREEN_WIDTH, 30)];
    [sharaView setBackgroundColor:[UIColor whiteColor]];
    UILabel *notify = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, SCREEN_WIDTH-32, 30)];
    [notify setFont:[UIFont systemFontOfSize:14]];
    [notify setTextColor:Color_Text_2];
    [notify setText:@"赞赞哒,同步炫耀吧！"];
    [sharaView addSubview:notify];
    tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-80, (SCREEN_WIDTH+SCREEN_HEIGHT)/2-47, 165, 50)];
    [self.view addSubview:tipsLabel];
    
    NSDictionary *attributes;
    tipsLabel.numberOfLines=0;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 3;
    attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:15], NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:Color_Additional_5};
    NSAttributedString * attr= [[NSAttributedString alloc] initWithString:@"拖动短句选取你喜欢的话\n并移动到合适的位置" attributes:attributes];
    tipsLabel.attributedText = attr;
    shareChannelView = [[UIView alloc] initWithFrame:CGRectMake(-SCREEN_WIDTH, SCREEN_WIDTH+35, SCREEN_WIDTH, 60)];
    
    if (user.WeChatInstalled && user.QQInstalled) {
        isShareToWeiChat = YES;
        weiboShare = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-45, 0, 90, 60)];
        weChatshare = [[UIButton alloc] initWithFrame:CGRectMake(16, 0, 90, 60)];
        QQZoneShare = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-106, 0, 90, 60)];
        
        [weiboShare setImage:[UIImage imageNamed:@"shareunselectedweibo"] forState:UIControlStateNormal];
        [weChatshare setImage:[UIImage imageNamed:@"sharefriendcircle"] forState:UIControlStateNormal];
        [QQZoneShare setImage:[UIImage imageNamed:@"shareunselectedqzone"] forState:UIControlStateNormal];
        
        [QQZoneShare addTarget:self action:@selector(setChannelShare:) forControlEvents:UIControlEventTouchUpInside];
        [weChatshare addTarget:self action:@selector(setChannelShare:) forControlEvents:UIControlEventTouchUpInside];
        [weiboShare addTarget:self action:@selector(setChannelShare:) forControlEvents:UIControlEventTouchUpInside];
        
        [shareChannelView addSubview:QQZoneShare];
        [shareChannelView addSubview:weiboShare];
        [shareChannelView addSubview:weChatshare];
        
    }
    else if(user.WeChatInstalled || user.QQInstalled){
        if (user.WeChatInstalled) {
            isShareToWeiChat = YES;
            weiboShare = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-45, 0, 90, 60)];
            weChatshare = [[UIButton alloc] initWithFrame:CGRectMake(16, 0, 90, 60)];
            
            [weiboShare setImage:[UIImage imageNamed:@"shareunselectedweibo"] forState:UIControlStateNormal];
            [weChatshare setImage:[UIImage imageNamed:@"sharefriendcircle"] forState:UIControlStateNormal];
            
            [weChatshare addTarget:self action:@selector(setChannelShare:) forControlEvents:UIControlEventTouchUpInside];
            [weiboShare addTarget:self action:@selector(setChannelShare:) forControlEvents:UIControlEventTouchUpInside];
            
            [shareChannelView addSubview:weiboShare];
            [shareChannelView addSubview:weChatshare];
            
        }else{
            isShareToWeiBo = YES;
            weiboShare = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-45, 0, 90, 60)];
            QQZoneShare = [[UIButton alloc] initWithFrame:CGRectMake(16, 0, 90, 60)];
            
            [weiboShare setImage:[UIImage imageNamed:@"shareweibo"] forState:UIControlStateNormal];
            [QQZoneShare setImage:[UIImage imageNamed:@"shareunselectedqzone"] forState:UIControlStateNormal];
            
            [QQZoneShare addTarget:self action:@selector(setChannelShare:) forControlEvents:UIControlEventTouchUpInside];
            [weiboShare addTarget:self action:@selector(setChannelShare:) forControlEvents:UIControlEventTouchUpInside];
            [shareChannelView addSubview:QQZoneShare];
            [shareChannelView addSubview:weiboShare];
            
        }
    }
    else{
        isShareToWeiBo = YES;
        weiboShare = [[UIButton alloc] initWithFrame:CGRectMake(16, 0, 90, 60)];
        [weiboShare setImage:[UIImage imageNamed:@"shareweibo"] forState:UIControlStateNormal];
        [weiboShare addTarget:self action:@selector(setChannelShare:) forControlEvents:UIControlEventTouchUpInside];
        [shareChannelView addSubview:weiboShare];

    }

    
    
    NoLyricTips = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH + 20, 130, SCREEN_WIDTH-40, 20)];
    [NoLyricTips setTextColor:shareColor];
    NoLyricTips.textAlignment = NSTextAlignmentCenter;
    [NoLyricTips setFont:[UIFont fontWithName:Font_default_share size:15]];
    if ([mobject.GeiLyricType isEqualToString:@"loading"]) {
        [NoLyricTips setText:@"歌词加载Ing..."];
    }else if([mobject.GeiLyricType isEqualToString:@"error"]){
        
        [NoLyricTips setText:@"暂无歌词"];
        
    }
    if (!user.hideLyric) {
        [Scroll setContentSize:CGSizeMake(SCREEN_WIDTH*3, SCREEN_WIDTH)];
        [Scroll addSubview:lyricView];
        [Scroll addSubview:lyricTablenview];
        [Scroll addSubview:NoLyricTips];
        [PageControl setNumberOfPages:3];
    }else{
        [Scroll setContentSize:CGSizeMake(SCREEN_WIDTH*2, SCREEN_WIDTH)];
        [PageControl setNumberOfPages:2];
        [editView setFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    }
    _imageCropper = [[NLImageCropperView alloc] initWithFrame:self.view.bounds];
    _imageCropper.delegate = self;
   

}
-(void)setChannelShare:(id)sender{
    if (sender == weChatshare) {
        if (isShareToWeiChat) {
            isShareToWeiChat = NO;
            [weChatshare setImage:[UIImage imageNamed:@"shareunselectedfriendcircle"] forState:UIControlStateNormal];
        }else{
            isShareToQQ = NO;
            isShareToWeiBo = NO;
            isShareToWeiChat = YES;
            [QQZoneShare setImage:[UIImage imageNamed:@"shareunselectedqzone"] forState:UIControlStateNormal];
            [weiboShare setImage:[UIImage imageNamed:@"shareunselectedweibo"] forState:UIControlStateNormal];
            [weChatshare setImage:[UIImage imageNamed:@"sharefriendcircle"] forState:UIControlStateNormal];
        }
    }
    else if (sender == weiboShare) {
        if (isShareToWeiBo) {
            isShareToWeiBo = NO;
            [weiboShare setImage:[UIImage imageNamed:@"shareunselectedweibo"] forState:UIControlStateNormal];
        }else{
            isShareToQQ = NO;
            isShareToWeiBo = YES;
            isShareToWeiChat = NO;
            [QQZoneShare setImage:[UIImage imageNamed:@"shareunselectedqzone"] forState:UIControlStateNormal];
            [weiboShare setImage:[UIImage imageNamed:@"shareweibo"] forState:UIControlStateNormal];
            [weChatshare setImage:[UIImage imageNamed:@"shareunselectedfriendcircle"] forState:UIControlStateNormal];
        }
    }
    else if (sender == QQZoneShare) {
        if (isShareToQQ) {
            isShareToQQ = NO;
            [QQZoneShare setImage:[UIImage imageNamed:@"shareunselectedqzone"] forState:UIControlStateNormal];
        }else{
            isShareToQQ = YES;
            isShareToWeiBo = NO;
            isShareToWeiChat = NO;
            [QQZoneShare setImage:[UIImage imageNamed:@"shareqzone"] forState:UIControlStateNormal];
            [weiboShare setImage:[UIImage imageNamed:@"shareunselectedweibo"] forState:UIControlStateNormal];
            [weChatshare setImage:[UIImage imageNamed:@"shareunselectedfriendcircle"] forState:UIControlStateNormal];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.image ) {
        headImage.image = self.image;
        isShow = YES;
        [ImageButton setHidden:NO];
        isDefaultImage = NO;
//        shareColor = [UIColor whiteColor];
//        [shareLabel.textView setTextColor:shareColor];
//        [lyricTablenview reloadData];
    }
    [self checkNext];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    if (tableView == lyricTablenview) {
        return lyricArray.count;
    }else if (tableView == famousTableview) {
        return famousArray.count;
    }else{
        return fontArray.count;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == fontTableView) {
        
        NSDictionary *dic = fontArray[indexPath.row];
        
        FontTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FontTableCell" forIndexPath:indexPath];
        
        if ([self.downLoadList containsObject:dic]) {
            [cell.pieProgress setHidden:NO];
        }else{
            [cell.pieProgress setHidden:YES];
        }
        cell.keeperVC = self;
        [cell.fontImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Muzzik%ld",(long)indexPath.row]]];
        cell.dic = dic;
        if ([[dic objectForKey:@"islocal"] boolValue]) {
            [cell.downButton setHidden:YES];
        }
        else{
            [cell.downButton setHidden:NO];
        }
        return cell;
    }else{
        TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];
        if (tableView == lyricTablenview) {
            [cell.label setFrame:CGRectMake(25, 10, SCREEN_WIDTH-50, 40)];
            cell.label.text = [[lyricArray[indexPath.row] allObjects][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
        }else{
            cell.label.text = famousArray[indexPath.row];
        }
        if (isCharacterWhite) {
            cell.label.textColor = [UIColor whiteColor];
        }else{
            cell.label.textColor = [UIColor blackColor];
        }
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 10, SCREEN_WIDTH-50, 80)];
        tempLabel.font = [UIFont fontWithName:Font_default_share size:19];
        tempLabel.text = cell.label.text;
        tempLabel.numberOfLines = 0;
        [tempLabel sizeToFit];
        [cell.label setFrame:CGRectMake((SCREEN_WIDTH-(int)tempLabel.frame.size.width-5)/2, cell.label.frame.origin.y, (int)tempLabel.frame.size.width+5, (int)tempLabel.frame.size.height+3)];
        cell.label.textAlignment = NSTextAlignmentCenter;
        return cell;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == fontTableView) {
        return 50;
    }else if(tableView == lyricTablenview){
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, SCREEN_WIDTH-50, 50)];
        tempLabel.font = [UIFont fontWithName:Font_default_share size:19];
        
        tempLabel.numberOfLines = 0;
        if ([lyricArray count]>0) {
            tempLabel.text = [[lyricArray[indexPath.row] allObjects][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
        }
        int textHeight = [MuzzikItem heightForLabel:tempLabel WithText:tempLabel.text];
        return textHeight+25;
    }else{
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, SCREEN_WIDTH-50, 50)];
        tempLabel.font = [UIFont fontWithName:Font_default_share size:19];
        tempLabel.numberOfLines = 0;
        if ([famousArray count]>0) {
            tempLabel.text = [famousArray[indexPath.row] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
        }
        
        int textHeight = [MuzzikItem heightForLabel:tempLabel WithText:tempLabel.text];
        return textHeight+25;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == fontTableView) {
        NSDictionary *dic = fontArray[indexPath.row];
        if ([[dic objectForKey:@"islocal"] boolValue]) {
            NSLog(@"%@",[dic objectForKey:@"fontname"]);
            shareLabel.textView.font = [UIFont fontWithName:[dic objectForKey:@"fontname"]  size:shareLabel.fontsize];
            shareLabel.curFont = [UIFont fontWithName:[dic objectForKey:@"fontname"]  size:shareLabel.fontsize];
            shareLabel.fontname = [dic objectForKey:@"fontname"];
        }else{
        
            [MuzzikItem showNotifyOnView:self.view text:@"还没下载字体哦～"];
        }
    }else{
        
        
        if (tableView == lyricTablenview) {
            if ([lyricArray count]>1) {
                TableViewCell *cell = (TableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
                CGPoint point = [cell.superview convertPoint:cell.frame.origin toView:Scroll];
                RJTextView *textView = [[RJTextView alloc] initWithFrame:CGRectMake(cell.label.frame.origin.x-22, point.y-7.5, cell.label.frame.size.width+44, cell.label.frame.size.height*3-4)
                                                             defaultText:cell.label.text
                                                                    font:[UIFont fontWithName:Font_default_share size:16]
                                                                   color:shareColor
                                                                 minSize:CGSizeMake(cell.label.frame.size.width+37, cell.label.frame.size.height+37)];
                textView.fontname = Font_default_share;
                [textView.textView setEditable:NO];
                textView.delegate = self;
                [lyricView addSubview:textView];
                lyricTextView = textView;
                shareLabel = textView;
                [lyricTablenview removeFromSuperview];
            }
            
        }else{
            TableViewCell *cell = (TableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            CGPoint point = [cell.superview convertPoint:cell.frame.origin toView:Scroll];
            RJTextView *textView = [[RJTextView alloc] initWithFrame:CGRectMake(cell.label.frame.origin.x-22, point.y-7.5, cell.label.frame.size.width+44, cell.label.frame.size.height*3-4)
                                                         defaultText:cell.label.text
                                                                font:[UIFont fontWithName:Font_default_share size:16]
                                                               color:shareColor
                                                             minSize:CGSizeMake(cell.label.frame.size.width+37, cell.label.frame.size.height+37)];
            textView.fontname = Font_default_share;
            [textView.textView setEditable:NO];
            textView.delegate = self;
            [famousView addSubview:textView];
            famousTextView = textView;
            shareLabel = textView;
            [famousTableview removeFromSuperview];
        }
        [self checkNext];
    }
}
#pragma mark - Gesture
-(void)hideTips{
    [NoLyricTips removeFromSuperview];
}
-(void)Notips{
    [NoLyricTips setText:@"暂无歌词"];
    [Scroll addSubview:NoLyricTips];
}
-(void)changFont{
    if (fontTableShowed) {
        fontTableShowed = NO;
        [fontButton setImage:[UIImage imageNamed:Image_fontImage] forState:UIControlStateNormal];
        [fontTableView removeFromSuperview];
        
    }else{
        fontTableShowed = YES;
        [fontButton setImage:[UIImage imageNamed:Image_fontclickImage] forState:UIControlStateNormal];
        [self.view addSubview:fontTableView];
    }
}

-(void) hideControl{
    if (shareLabel.hideView) {
        [shareLabel showTextViewBox];
    }else{
        [shareLabel hideTextViewBox];
    }
}
-(void)textViewDidEndEditing:(RJTextView *)textView{
    if ([textView.textView.text length]>0) {
        shareLabel = editTextView;
    }else{
        shareLabel = nil;
    }
    [self checkNext];
}
-(void)textViewDidChanged:(UITextView *)textView{
    if ([textView.text length]>0) {
        shareLabel = editTextView;
    }else{
        shareLabel = nil;
    }
    [self checkNext];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sView
{
    if (sView == Scroll) {
        [self.view endEditing:YES];
        int index = fabs(sView.contentOffset.x) / sView.frame.size.width;
        //NSLog(@"%d",index);
        [PageControl setCurrentPage:index];
        userInfo *user = [userInfo shareClass];
        if (index == 0) {
            NSDictionary *attributes;
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            paragraphStyle.alignment = NSTextAlignmentCenter;
            paragraphStyle.lineSpacing = 3;
            attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:15], NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:Color_Additional_5};
            NSAttributedString * attr= [[NSAttributedString alloc] initWithString:@"拖动短句选取你喜欢的话\n并移动到合适的位置" attributes:attributes];
            tipsLabel.attributedText = attr;
            
            
            
            shareLabel = famousTextView;
        }else if(index == 1){
            NSDictionary *attributes;
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            paragraphStyle.alignment = NSTextAlignmentCenter;
            paragraphStyle.lineSpacing = 3;
            
            attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:15], NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:Color_Additional_5};
            if (!user.hideLyric) {
                NSAttributedString * attr= [[NSAttributedString alloc] initWithString:@"拖动歌词选取你喜欢的话\n并移动到合适的位置" attributes:attributes];
                tipsLabel.attributedText = attr;
                shareLabel = lyricTextView;
            }else{
                NSAttributedString * attr= [[NSAttributedString alloc] initWithString:@"添加一句话\n并且移动到合适位置" attributes:attributes];
                tipsLabel.attributedText = attr;
                shareLabel = editTextView;
                if (editTextView.textView.text.length >0) {
                    shareLabel = editTextView;
                }else{
                    shareLabel = nil;
                }
            }
            
            
            
        }else if(index == 2){
            NSDictionary *attributes;
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            paragraphStyle.alignment = NSTextAlignmentCenter;
            paragraphStyle.lineSpacing = 3;
            attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:15], NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:Color_Additional_5};
            NSAttributedString * attr= [[NSAttributedString alloc] initWithString:@"添加一句话\n并且移动到合适位置" attributes:attributes];
            tipsLabel.attributedText = attr;
            
            [editTextView.textView becomeFirstResponder];
            if (editTextView.textView.text.length >0) {
                shareLabel = editTextView;
            }else{
                shareLabel = nil;
            }
            
        }
        [self checkNext];
    }
    
}
-(void)checkNext{
    if (isDefaultImage) {
        if (shareLabel) {
            [self initNagationBar:@"填选一句话（3/3）" leftBtn:Constant_backImage rightBtn:2];
            allowToSubmit = NO;
        }else{
            [self initNagationBar:@"填选一句话（3/3）" leftBtn:Constant_backImage rightBtn:5];
            allowToSubmit = YES;
        }
    }else{
        [self initNagationBar:@"填选一句话（3/3）" leftBtn:Constant_backImage rightBtn:2];
        allowToSubmit = NO;
    }
    
}
-(void)rightBtnAction:(UIButton *)sender{
    MuzzikObject *mobject = [MuzzikObject shareClass];
    if (allowToSubmit) {
        if (!isSending) {
            userInfo *user = [userInfo shareClass];
            isSending = YES;
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
                } else if([weakShare responseStatusCode] == 400){
                    isSending = NO;
                }
                else if([weakShare responseStatusCode] == 409){
                    isSending = NO;
                }
            }];
            [shareRequest setFailedBlock:^{
                isSending = NO;
                [MuzzikItem showNotifyOnView:self.view text:@"请求失败，请确认网络状态再次重试"];
                NSLog(@"%@",[weakShare error ]);
            }];
            [shareRequest startAsynchronous];
        
        }
    }else{
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *folderPath = [path stringByAppendingPathComponent:@"Font"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //判断temp文件夹是否存在
        BOOL fileExists = [fileManager fileExistsAtPath:folderPath];
        if (!fileExists) {//如果不存在说创建,因为下载时,不会自动创建文件夹
            [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        
        NSArray  *arr = [fileManager subpathsAtPath:folderPath];
        NSLog(@"%@",arr);
        
        
        
        
        [shareLabel hideTextViewBox];
        userInfo *user = [userInfo shareClass];
        
        if (fontTableShowed) {
            fontTableShowed = NO;
            [fontButton setImage:[UIImage imageNamed:Image_fontImage] forState:UIControlStateNormal];
            [fontTableView removeFromSuperview];
        }
        
        
        if (step == 0) {
            isSending = NO;
            step = 1;
            [tipsLabel setHidden:YES];
            [self initNagationBar:@"发布并分享" leftBtn:Constant_backImage rightBtn:5];
            
            [headImage addSubview:shareLabel];
            
            Muzzikimage = [MuzzikItem convertViewToImage:headImage];
            [headImage addSubview:MuzzikLogoImage];
            UIImage *tempImage = [MuzzikItem convertViewToImage:headImage];
            animationView = [[UIImageView alloc] initWithImage:tempImage];
            [self.view addSubview:shareWhiteView];
            
            [self.view addSubview:sharaView];
            UIImageView *cover = [[UIImageView alloc] initWithImage:[UIImage imageNamed:Image_Cover]];
            resultView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-cover.frame.size.width/2, 100, cover.frame.size.width , 177)];
            [resultView setBackgroundColor:[UIColor whiteColor]];
            [shareWhiteView addSubview:resultView];
            [resultView addSubview:cover];
            UIImageView *usershareHeadThumb = [[UIImageView alloc] initWithFrame:CGRectMake(130, 60, 60, 60)];
            usershareHeadThumb.layer.cornerRadius = 30 ;
            usershareHeadThumb.clipsToBounds = YES;
            [usershareHeadThumb setImage:user.userHeadThumb];
            [resultView addSubview:usershareHeadThumb];
            UIView *storyView = [[UIView alloc] initWithFrame:CGRectMake(cover.frame.size.width-66, 0, 60, cover.frame.size.height)];
            [cover addSubview:storyView];
            UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 60, 10)];
            dateLabel.textColor = Color_Text_2;
            dateLabel.font = [UIFont fontWithName:Font_default_share size:6];
            NSDate *  senddate=[NSDate date];
            
            NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
            
            [dateformatter setDateFormat:@"yyyy.MM.dd"];
            dateLabel.text = [dateformatter stringFromDate:senddate];
            [storyView addSubview:dateLabel];
            
            
            UIView *playerLine = [[UIView alloc] initWithFrame:CGRectMake(0, cover.frame.size.height-37, 60, 1)];
            [playerLine setBackgroundColor:Color_Active_Button_1];
            [storyView addSubview:playerLine];
            UILabel *musicName = [[UILabel alloc] initWithFrame:CGRectMake(0, cover.frame.size.height-30, 50, 10)];
            [musicName setFont:[UIFont fontWithName:Font_default_share size:8]];
            musicName.text = mobject.music.name;
            [musicName setTextColor:Color_Active_Button_1];
            [storyView addSubview:musicName];
            UILabel *musicArtist = [[UILabel alloc] initWithFrame:CGRectMake(0, cover.frame.size.height-16, 50, 10)];
            [musicArtist setFont:[UIFont fontWithName:Font_default_share size:6]];
            [musicArtist setTextColor:Color_Active_Button_1];
            musicArtist.text = mobject.music.artist;
            [storyView addSubview:musicArtist];
            UIImageView *playImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shareplayBig"]];
            [playImage setFrame:CGRectMake(54, cover.frame.size.height-22, 6, 7)];
            [storyView addSubview:playImage];
            UILabel *storyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 37, 60, cover.frame.size.height-80)];
            NSDictionary *attributes;
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            paragraphStyle.lineSpacing = 2;
            attributes = @{NSFontAttributeName:[UIFont fontWithName:Font_default_share size:8], NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:Color_Text_2};
            NSAttributedString * attr= [[NSAttributedString alloc] initWithString:mobject.message attributes:attributes];
            storyLabel.attributedText = attr;
            storyLabel.numberOfLines = 0;
            [storyLabel sizeToFit];
            UILabel *tempNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 100)];
            tempNameLabel.font = [UIFont fontWithName:Font_default_share size:11];
            tempNameLabel.text = [userInfo shareClass].name;
            tempNameLabel.numberOfLines = 0;
            [tempNameLabel sizeToFit];
            
            if (storyLabel.frame.size.height>cover.frame.size.height-100) {
                [storyLabel setFrame:CGRectMake(0, 59, 60, cover.frame.size.height-100)];
            }else{
                [storyLabel setFrame:CGRectMake(0, cover.frame.size.height-storyLabel.frame.size.height-46, 60, storyLabel.frame.size.height+5)];
            }
            [storyView addSubview:storyLabel];
            UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(0, storyLabel.frame.origin.y-tempNameLabel.frame.size.height-7, 60, tempNameLabel.frame.size.height+3)];
            userName.text = [userInfo shareClass].name;
            userName.textColor = Color_Text_1;
            userName.font = [UIFont fontWithName:Font_default_share size:11];
            userName.numberOfLines = 0;
            [storyView addSubview:userName];
            [shareWhiteView addSubview:animationView];
            animationView.layer.cornerRadius = 2;
            animationView.clipsToBounds = YES;
            // UIImageView *coverPage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:Image_Textcover]];
            //[coverPage setFrame:CGRectMake(SCREEN_WIDTH/2 - 141, 100, 189, 189)];
            [UIView animateWithDuration:0.5 animations:^{
                [animationView setFrame:CGRectMake(SCREEN_WIDTH/2 - cover.frame.size.width/2+4, 104, 170, 170)];
                //[sharaView setFrame:CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, 30)];
            } completion:^(BOOL finished) {
                [animationView setFrame:CGRectMake(4, 4, 170, 170)];
                [resultView addSubview:animationView];
                //[lyricView addSubview:coverPage];
            }];
            
            [self.view addSubview:sharaView];
            [self.view addSubview:shareChannelView];
            [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [sharaView setFrame:CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, 30)];
                [controlView setFrame:CGRectMake(SCREEN_WIDTH, SCREEN_WIDTH, SCREEN_WIDTH, 30)];
                [shareChannelView setFrame:CGRectMake(0, SCREEN_WIDTH+35, SCREEN_WIDTH, 60)];
            } completion:^(BOOL finished) {
                
            }];
            
            
        }
        else{
            if (!isSending) {
                isSending = YES;
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
                        NSData *imageData = UIImageJPEGRepresentation(Muzzikimage, 1);
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
                                    if (isShareToWeiChat || isShareToWeiBo) {
                                        UIView *weChatShareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1324, 748)];
                                        UIImageView *CDcover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1324, 748)];
                                        [weChatShareView addSubview:CDcover];
                                        UIImageView *usershareHeadThumb = [[UIImageView alloc] initWithFrame:CGRectMake(555, 254, 254, 254)];
                                        usershareHeadThumb.layer.cornerRadius = 127 ;
                                        usershareHeadThumb.clipsToBounds = YES;
                                        [usershareHeadThumb setImage:user.userHeadThumb];
                                        [weChatShareView addSubview:usershareHeadThumb];
                                        
                                        [CDcover setImage:[UIImage imageNamed:Image_cover_CD]];
                                        [MuzzikLogoImage setFrame:CGRectMake(10, SCREEN_WIDTH-MuzzikLogoImage.frame.size.height-10,MuzzikLogoImage.frame.size.width , MuzzikLogoImage.frame.size.height)];
                                        
                                        UIImageView *picImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 724, 724)];
                                        //                                        if (self.image) {
                                        //                                            [picImage setImage:self.image];
                                        //                                        }else{
                                        //                                            [picImage setImage:[MuzzikItem createImageWithColor:[UIColor whiteColor]]];
                                        //                                            picImage.contentMode = UIViewContentModeScaleAspectFill;
                                        //                                        }
                                        [MuzzikLogo setFrame:CGRectMake(20, 704-MuzzikLogo.frame.size.height,MuzzikLogo.frame.size.width , MuzzikLogo.frame.size.height)];
                                        if (isShow && self.image) {
                                            [picImage setImage:headImage.image];
                                            
                                        }else{
                                            [picImage setImage:[UIImage imageNamed:@"TextureShare"]];
                                            
                                        }
                                        [picImage addSubview:MuzzikLogo];
                                        picImage.contentMode = UIViewContentModeScaleAspectFill;
                                        picImage.layer.cornerRadius = 5;
                                        picImage.clipsToBounds = YES;
                                        [weChatShareView addSubview:picImage];
                                        UIView *storyView = [[UIView alloc] initWithFrame:CGRectMake(1074, 10, 240, 738)];
                                        [weChatShareView addSubview:storyView];
                                        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 240, 40)];
                                        dateLabel.textColor = Color_Text_1;
                                        dateLabel.font = [UIFont fontWithName:Font_default_share size:24];
                                        NSDate *  senddate=[NSDate date];
                                        
                                        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
                                        
                                        [dateformatter setDateFormat:@"yyyy.MM.dd"];
                                        dateLabel.text = [dateformatter stringFromDate:senddate];
                                        [storyView addSubview:dateLabel];
                                        
                                        
                                        UIView *playerLine = [[UIView alloc] initWithFrame:CGRectMake(0, CDcover.frame.size.height-148, 240, 4)];
                                        [playerLine setBackgroundColor:Color_Active_Button_1];
                                        [storyView addSubview:playerLine];
                                        UILabel *musicName = [[UILabel alloc] initWithFrame:CGRectMake(0, CDcover.frame.size.height-120, 200, 40)];
                                        [musicName setFont:[UIFont fontWithName:Font_default_share size:32]];
                                        musicName.text = mobject.music.name;
                                        [musicName setTextColor:Color_Active_Button_1];
                                        [storyView addSubview:musicName];
                                        UILabel *musicArtist = [[UILabel alloc] initWithFrame:CGRectMake(0, CDcover.frame.size.height-72, 200, 40)];
                                        [musicArtist setFont:[UIFont fontWithName:Font_default_share size:24]];
                                        [musicArtist setTextColor:Color_Active_Button_1];
                                        musicArtist.text = mobject.music.artist;
                                        [storyView addSubview:musicArtist];
                                        UIImageView *playImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:Image_shareplay]];
                                        [playImage setFrame:CGRectMake(216, CDcover.frame.size.height-88, 24, 28)];
                                        [storyView addSubview:playImage];
                                        UILabel *storyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 148, 240, CDcover.frame.size.height-320)];
                                        NSDictionary *attributes;
                                        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                                        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
                                        paragraphStyle.lineSpacing = 7;
                                        attributes = @{NSFontAttributeName:[UIFont fontWithName:Font_default_share size:31], NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:Color_Text_2};
                                        NSAttributedString * attr= [[NSAttributedString alloc] initWithString:mobject.message attributes:attributes];
                                        storyLabel.attributedText = attr;
                                        storyLabel.numberOfLines = 0;
                                        [storyLabel sizeToFit];
                                        
                                        UILabel *tempNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 300)];
                                        tempNameLabel.font = [UIFont fontWithName:Font_default_share size:44];
                                        tempNameLabel.text = [userInfo shareClass].name;
                                        tempNameLabel.numberOfLines = 0;
                                        [tempNameLabel sizeToFit];
                                        
                                        
                                        if (storyLabel.frame.size.height>CDcover.frame.size.height-400) {
                                            [storyLabel setFrame:CGRectMake(0, 236, 240, CDcover.frame.size.height-400)];
                                        }else{
                                            [storyLabel setFrame:CGRectMake(0, CDcover.frame.size.height-storyLabel.frame.size.height-184, 240, storyLabel.frame.size.height+20)];
                                        }
                                        
                                        [storyView addSubview:storyLabel];
                                        UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(0, storyLabel.frame.origin.y-tempNameLabel.frame.size.height-28, 240, tempNameLabel.frame.size.height+12)];
                                        
                                        userName.text = [userInfo shareClass].name;
                                        userName.textColor = Color_Text_1;
                                        userName.numberOfLines = 0;
                                        userName.font = [UIFont fontWithName:Font_default_share size:44];
                                        [storyView addSubview:userName];
                                        CGFloat scale = 724.0/SCREEN_WIDTH;
                                        [shareLabel setFrame:CGRectMake(shareLabel.frame.origin.x * scale, shareLabel.frame.origin.y * scale, shareLabel.frame.size.width * scale, shareLabel.frame.size.height *scale)];
                                        [shareLabel.textView setFrame:CGRectMake(shareLabel.textView.frame.origin.x * scale, shareLabel.textView.frame.origin.y * scale, shareLabel.textView.frame.size.width * scale, shareLabel.textView.frame.size.height *scale)];
                                        //                                    NSLog(@"%f",shareLabel.fontSize);
                                        shareLabel.textView.font = [UIFont fontWithName:shareLabel.fontname size:shareLabel.fontsize * scale];
                                        [picImage addSubview:shareLabel];
                                        [picImage setBackgroundColor:[UIColor whiteColor]];
                                        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                        
                                        UIGraphicsBeginImageContextWithOptions(weChatShareView.bounds.size, NO, 1.0f);
                                        //    UIGraphicsBeginImageContext(v.bounds.size,YES,2.0f);
                                        [weChatShareView setBackgroundColor:[UIColor whiteColor]];
                                        [weChatShareView.layer renderInContext:UIGraphicsGetCurrentContext()];
                                        
                                        UIImage *timage = UIGraphicsGetImageFromCurrentImageContext();
                                        
                                        UIGraphicsEndImageContext();
                                        if (isShareToWeiChat) {
                                            [app sendImageContent:timage];
                                            //保存图片
                                            //                                            [self saveToAlbumWithMetadata:nil imageData:UIImagePNGRepresentation(timage) customAlbumName:@"Muzzik相册" completionBlock:^
                                            //                                             {
                                            //                                                 //这里可以创建添加成功的方法
                                            //                                                 // [MuzzikItem showNotifyOnView:self.navigationController.view text:@"保存成功"];
                                            //                                             }
                                            //                                                             failureBlock:^(NSError *error)
                                            //                                             {
                                            //                                                 //处理添加失败的方法显示alert让它回到主线程执行，不然那个框框死活不肯弹出来
                                            //                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                            //
                                            //                                                     //添加失败一般是由用户不允许应用访问相册造成的，这边可以取出这种情况加以判断一下
                                            //                                                     if([error.localizedDescription rangeOfString:@"User denied access"].location != NSNotFound ||[error.localizedDescription rangeOfString:@"用户拒绝访问"].location!=NSNotFound){
                                            //
                                            //                                                         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles: nil];
                                            //
                                            //                                                         [alert show];
                                            //
                                            //                                                     }
                                            //                                                 });
                                            //                                             }];
                                        }
                                        else if(isShareToWeiBo){
                                            WBMessageObject *message = [WBMessageObject message];
                                            
                                            message.text =[NSString stringWithFormat:@"一起来用Muzzik吧 %@%@",URL_Muzzik_SharePage,[muzzikDic objectForKey:@"_id" ]];
                                            
                                            WBImageObject *image = [WBImageObject object];
                                            image.imageData = UIImageJPEGRepresentation(timage, 1.0);
                                            message.imageObject = image;
                                            AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
                                            
                                            WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
                                            authRequest.redirectURI = URL_WeiBo_redirectURI;
                                            authRequest.scope = @"all";
                                            
                                            WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:myDelegate.wbtoken];
                                            
                                            //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
                                            [WeiboSDK sendRequest:request];
                                            NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:[muzzikDic objectForKey:@"_id" ],@"_id",@"weibo",@"channel", nil];
                                            
                                            ASIHTTPRequest *requestShare = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
                                            
                                            [requestShare addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
                                            __weak ASIHTTPRequest *weakrequest = requestShare;
                                            [requestShare setCompletionBlock :^{
                                            }];
                                            [requestShare setFailedBlock:^{
                                                NSLog(@"%@",[weakrequest error]);
                                            }];
                                            [requestShare startAsynchronous];
                                            
                                            //保存图片
                                            //                                            [self saveToAlbumWithMetadata:nil imageData:UIImagePNGRepresentation(timage) customAlbumName:@"Muzzik相册" completionBlock:^
                                            //                                             {
                                            //                                                 //这里可以创建添加成功的方法
                                            //                                                 // [MuzzikItem showNotifyOnView:self.navigationController.view text:@"保存成功"];
                                            //                                             }
                                            //                                                             failureBlock:^(NSError *error)
                                            //                                             {
                                            //                                                 //处理添加失败的方法显示alert让它回到主线程执行，不然那个框框死活不肯弹出来
                                            //                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                            //
                                            //                                                     //添加失败一般是由用户不允许应用访问相册造成的，这边可以取出这种情况加以判断一下
                                            //                                                     if([error.localizedDescription rangeOfString:@"User denied access"].location != NSNotFound ||[error.localizedDescription rangeOfString:@"用户拒绝访问"].location!=NSNotFound){
                                            //
                                            //                                                         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles: nil];
                                            //
                                            //                                                         [alert show];
                                            //
                                            //                                                     }
                                            //                                                 });
                                            //                                             }];
                                        }
                                    }
                                    else if (isShareToQQ){
                                        TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:ID_QQ_APP
                                                                                             andDelegate:nil];
                                        QQApiNewsObject* img = [QQApiNewsObject objectWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_Muzzik_SharePage,[muzzikDic objectForKey:@"_id" ]]] title:@"在Muzzik上分享了首歌" description:[NSString stringWithFormat:@"%@  %@",mobject.music.name,mobject.music.artist] previewImageData:UIImageJPEGRepresentation([MuzzikItem convertViewToImage:headImage], 0.7)];
                                        SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
                                        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
                                        [self handleSendResult:sent];
                                    }
                                    [self setPoMuzzikMessage:muzzikDic];
                                    [mobject clearObject];
                                    [self.navigationController popToViewController:user.poController animated:YES];
                                    user.poController = nil;
                                }
                            }];
                            [shareRequest setFailedBlock:^{
                                isSending = NO;
                                NSLog(@"%@",[weakShare error]);
                            }];
                            [shareRequest startAsynchronous];
                            
                            
                        }];
                        [interRequest setFailedBlock:^{
                            isSending = NO;
                            [MuzzikItem showNotifyOnView:self.view text:@"请求失败，请确认网络状态再次重试"];
                            NSLog(@"%@",[form responseString]);
                        }];
                        [interRequest startAsynchronous];
                        
                    }
                    else if([weakrequest responseStatusCode] == 400){
                        isSending = NO;
                    }
                    else if([weakrequest responseStatusCode] == 409){
                        isSending = NO;
                    }
                }];
                [requestForm setFailedBlock:^{
                    isSending = NO;
                    [MuzzikItem showNotifyOnView:self.view text:@"请求失败，请确认网络状态再次重试"];
                    NSLog(@"%@",[weakrequest error ]);
                }];
                [requestForm startAsynchronous];
            }

        }

    }
}


#pragma -mark action
-(void)changShare{
    if (isShareToWeiChat) {
        isShareToWeiChat = NO;
        [shareCycle setImage:[UIImage imageNamed:@"SmallshareselectImage"]];
    }else{
        isShareToWeiChat = YES;
        [shareCycle setImage:[UIImage imageNamed:@"SmallshareselectedImage"]];
    }
}
-(void) changColor{
 
    if (!isCharacterWhite) {
        isCharacterWhite = YES;
        [editTextView.textView setTextColor:[UIColor whiteColor]];
        shareColor = [UIColor whiteColor];
        [ColorButton setImage:[UIImage imageNamed:Image_textwhiteImage] forState:UIControlStateNormal];
        shareLabel.textView.textColor = [UIColor whiteColor];
        [MuzzikLogoImage setImage:[UIImage imageNamed:@"muzzikwhite"]];
        [MuzzikLogo setImage:[UIImage imageNamed:@"sharewhiteMuzzik"]];
    }else{
        isCharacterWhite = NO;
        [editTextView.textView setTextColor:[UIColor blackColor]];
        shareColor = [UIColor blackColor];
        [ColorButton setImage:[UIImage imageNamed:Image_textblackImage] forState:UIControlStateNormal];
        shareLabel.textView.textColor = [UIColor blackColor];
        [MuzzikLogoImage setImage:[UIImage imageNamed:@"muzzikblack"]];
         [MuzzikLogo setImage:[UIImage imageNamed:@"shareblackMuzzik"]];
    }
    [lyricTablenview reloadData];
    [famousTableview reloadData];
}
-(void)closeLabel:(RJTextView *)rjView{
    if (rjView == lyricTextView) {
        shareLabel = nil;
        lyricTextView = nil;
        [Scroll addSubview:lyricTablenview];
    }else{
        shareLabel = nil;
        famousTextView = nil;
        [Scroll addSubview:famousTableview];
    }
    [self checkNext];
}

-(void) swithImage{
    
    
    if (isShow) {
        isShow = NO;
        isDefaultImage = YES;
        [headImage setImage:[UIImage imageNamed:Image_Textcover]];
    }else{
        isShow = YES;
        headImage.image = self.image;
        
    }
    [self checkNext];
}
-(void)tapAction:(UITapGestureRecognizer *)tap{
    if (step == 0) {
        [super tapAction:tap];
    }else{
        step = 0 ;
       
        [self initNagationBar:@"填选一句话（3/3）" leftBtn:Constant_backImage rightBtn:2];
        [animationView setFrame:CGRectMake(SCREEN_WIDTH/2 - 156, 104, 170, 170)];
        [self.view addSubview:animationView];
        [UIView animateWithDuration:0.5 animations:^{
            [sharaView setFrame:CGRectMake(-SCREEN_WIDTH, SCREEN_WIDTH, SCREEN_WIDTH, 30)];
            [controlView setFrame:CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, 30)];
            [shareChannelView setFrame:CGRectMake(-SCREEN_WIDTH, SCREEN_WIDTH+35, SCREEN_WIDTH, 60)];
            
            //[sharaView setFrame:CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, 30)];
        } completion:^(BOOL finished) {
             [tipsLabel setHidden:NO];
            [sharaView removeFromSuperview];
            [shareChannelView removeFromSuperview];
            //[lyricView addSubview:coverPage];
        }];
        
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [animationView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
            
        } completion:^(BOOL finished) {
            [animationView removeFromSuperview];
            [shareWhiteView removeFromSuperview];
            [MuzzikLogoImage removeFromSuperview];
            for (UIView *view in [shareWhiteView subviews]) {
                [view removeFromSuperview];
            }
            userInfo *user = [userInfo shareClass];
            if (!user.hideLyric) {
                if (PageControl.currentPage == 0) {
                     [famousView addSubview:shareLabel];
                    
                }else if (PageControl.currentPage == 1){
                   [lyricView addSubview:shareLabel];
                }else{
                    [editView addSubview:shareLabel];
                }
            }else{
                if (PageControl.currentPage == 0) {
                    [famousView addSubview:shareLabel];
                }else if (PageControl.currentPage == 1){
                    [editView addSubview:shareLabel];
                }
            }
            
            [shareLabel showTextViewBox];
        }];
    }
}
-(void) changeImage{
    
    JSImagePickerViewController *imagePicker = [[JSImagePickerViewController alloc] init];
    imagePicker.delegate = self;
    [imagePicker showImagePickerInController:self animated:YES];
}

#pragma mark - JSImagePikcerViewControllerDelegate

- (void)imagePickerDidSelectImage:(UIImage *)image {
    [_imageCropper setImage:image];
    CGFloat minLength = image.size.width <image.size.height ? image.size.width : image.size.height;
    if (minLength >200) {
        [_imageCropper setCropRegionRect:CGRectMake(image.size.width/2-100*_imageCropper.scalingFactor, image.size.height/2 - 100*_imageCropper.scalingFactor, 200*_imageCropper.scalingFactor, 200*_imageCropper.scalingFactor)];
    }else{
        [_imageCropper setCropRegionRect:CGRectMake(image.size.width/2-minLength/2, image.size.height/2 - minLength/2, minLength*_imageCropper.scalingFactor, minLength)];
    }
    [self.navigationController.view addSubview:_imageCropper];
}
-(void)userCropImage:(UIImage *)image{
    self.image = image;
    isShow = YES;
    [headImage setImage:image];
    [LibraryButton setImage:[UIImage imageNamed:Image_addedpicImage] forState:UIControlStateNormal];
}




- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        default:
        {
            break;
        }
    }
}
-(void)setPoMuzzikMessage:(NSDictionary *)dic{
    userInfo *user = [userInfo shareClass];
    MuzzikObject *mobject = [MuzzikObject shareClass];
    muzzik *newmuzzik = [muzzik new];
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

#pragma mark - Request
-(void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes{
    _curSize += bytes;
    float value = (_curSize*1.0)/([request contentLength]*1.0);
    [self.pieProgress setProgress:value];
}


-(void) loadFont{
    fontArray = [NSMutableArray array];
    NSDictionary *dicFirst = [NSDictionary dictionaryWithObjectsAndKeys:Font_Next_Bold,@"fontname",[NSNumber numberWithBool:YES],@"islocal", nil];
    [fontArray addObject:dicFirst];
    
    NSString *fontPathC = [[NSBundle mainBundle] pathForResource:@"Copperplate_00" ofType:@"ttf"];
    NSDictionary *dicC = [NSDictionary dictionaryWithObjectsAndKeys:[MuzzikItem customFontWithPath:fontPathC],@"fontname",[NSNumber numberWithBool:YES],@"islocal", nil];
    [fontArray addObject:dicC];
    
    NSString *fontPath1 = [[NSBundle mainBundle] pathForResource:@"Bluehigh" ofType:@"ttf"];
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:[MuzzikItem customFontWithPath:fontPath1],@"fontname",[NSNumber numberWithBool:YES],@"islocal", nil];
    [fontArray addObject:dic1];
    
    NSString *fontPath2 = [[NSBundle mainBundle] pathForResource:@"calico_cyrillic" ofType:@"ttf"];
    NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:[MuzzikItem customFontWithPath:fontPath2],@"fontname",[NSNumber numberWithBool:YES],@"islocal", nil];
    [fontArray addObject:dic2];
    
    NSString *fontPath3 = [[NSBundle mainBundle] pathForResource:@"kilsonburg" ofType:@"ttf"];
    NSDictionary *dic3 = [NSDictionary dictionaryWithObjectsAndKeys:[MuzzikItem customFontWithPath:fontPath3],@"fontname",[NSNumber numberWithBool:YES],@"islocal", nil];
    [fontArray addObject:dic3];
    
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:@"VNI_HLThuphap" ofType:@"ttf"];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[MuzzikItem customFontWithPath:fontPath],@"fontname",[NSNumber numberWithBool:YES],@"islocal", nil];
    [fontArray addObject:dic];
    
    
    
    
    
    
    
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *fontDic = [userDefault arrayForKey:@"Font_Array_local_Address"];
    if ([fontDic count] == 0) {
        fontDic = @[[NSDictionary dictionaryWithObjectsAndKeys:@"http://7d9m5z.com1.z0.glb.clouddn.com/SongTiHeiTi.ttf",@"urladdress",[NSNumber numberWithBool:NO],@"islocal",@"STSongti-SC-Black",@"fontname", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"http://7d9m5z.com1.z0.glb.clouddn.com/HanYiYanKaiTi.ttf",@"urladdress",[NSNumber numberWithBool:NO],@"islocal",@"HYx4gf",@"fontname", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"http://7d9m5z.com1.z0.glb.clouddn.com/HuaKangWaWaTi.ttf",@"urladdress",[NSNumber numberWithBool:NO],@"islocal",@"DFPWaWaW5",@"fontname", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"http://7d9m5z.com1.z0.glb.clouddn.com/FangZhengLiBianFanTi.ttf",@"urladdress",[NSNumber numberWithBool:NO],@"islocal",@"FZLBFW--GB1-0",@"fontname", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"http://7d9m5z.com1.z0.glb.clouddn.com/FangZhengShuSong.ttf",@"urladdress",[NSNumber numberWithBool:NO],@"islocal",@"FZSSFW--GB1-0",@"fontname", nil]];
        [userDefault setObject:fontDic forKey:@"Font_Array_local_Address"];
        [userDefault synchronize];
    }
    [fontArray addObjectsFromArray:fontDic];
    
    NSString *fontPathchdefault = [[NSBundle mainBundle] pathForResource:@"HYQuanTangShiF" ofType:@"ttf"];
    NSDictionary *dicfontPathchdefault = [NSDictionary dictionaryWithObjectsAndKeys:[MuzzikItem customFontWithPath:fontPathchdefault],@"fontname",[NSNumber numberWithBool:YES],@"islocal", nil];
    [fontArray addObject:dicfontPathchdefault];
    
    
}

-(void)startDownload{
    
    if ([self.downLoadList count]>0) {
        NSDictionary *dic = self.downLoadList[0];
        FontTableCell *cell = (FontTableCell *)[fontTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[fontArray indexOfObject:dic] inSection:0]];
        [cell.pieProgress setHidden:NO];
        self.pieProgress = cell.pieProgress;
        ASIHTTPRequest *_asiRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[dic objectForKey:@"urladdress"]]];
        [_asiRequest setDelegate:self];
        [_asiRequest setDownloadProgressDelegate:self];
        [_asiRequest setShowAccurateProgress:YES];
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *folderPath = [path stringByAppendingPathComponent:@"Font"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //判断temp文件夹是否存在
        BOOL fileExists = [fileManager fileExistsAtPath:folderPath];
        if (!fileExists) {//如果不存在说创建,因为下载时,不会自动创建文件夹
            [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        
        NSArray  *arr = [fileManager subpathsAtPath:folderPath];
        NSLog(@"%@",arr);
        
        
        NSString *savePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.ttf",[dic objectForKey:@"fontname"]]];
        NSString *tempPath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",[dic objectForKey:@"fontname"]]];
        __weak ASIHTTPRequest *weakrequest = _asiRequest;
        [_asiRequest setDownloadDestinationPath:savePath];
        [_asiRequest setTemporaryFileDownloadPath:tempPath];
        [_asiRequest setAllowResumeForFileDownloads:YES];
        [_asiRequest setCompletionBlock:^{
            _curSize = 0;
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            NSMutableArray *fontDicArray = [[userDefault arrayForKey:@"Font_Array_local_Address"] mutableCopy];
            [MuzzikItem customFontWithPath:savePath];
            for (int i = 0; i<fontDicArray.count; i++) {
                if ([[fontDicArray[i] objectForKey:@"fontname"] isEqualToString:[dic objectForKey:@"fontname"]]) {
                    [fontDicArray replaceObjectAtIndex:i withObject:[NSDictionary dictionaryWithObjectsAndKeys:[dic objectForKey:@"fontname"],@"fontname",[NSNumber numberWithBool:YES],@"islocal",savePath,@"path", nil]];
                    [fontArray replaceObjectAtIndex:[fontArray indexOfObject:dic] withObject:[NSDictionary dictionaryWithObjectsAndKeys:[dic objectForKey:@"fontname"],@"fontname",[NSNumber numberWithBool:YES],@"islocal", nil]];
                }
            }
            
            [userDefault setObject:[fontDicArray copy] forKey:@"Font_Array_local_Address"];
            [userDefault synchronize];
            [fontTableView reloadData];
            [self.downLoadList removeObject:dic];
            if ([self.downLoadList count]>0) {
                [self startDownload];
            }
        }];
        [_asiRequest setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
        }];
        //        [_asiRequest setDownloadSizeIncrementedBlock:^(long long size) {
        //            NSLog(@"%lld",size);
        //            NSLog(@"%@          %@",[weakrequest responseHeaders],[weakrequest responseData]);
        //        }];
        [_asiRequest startAsynchronous];
    }
    
    
}
-(void) reloadTableView{
    [fontTableView reloadData];
}
-(void)reloadLyricTableView{
    MuzzikObject *mobject = [MuzzikObject shareClass];
    if ([mobject.lyricArray count]>0) {
        for (NSDictionary *dic in mobject.lyricArray) {
            if ([[[dic allValues][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] >0 ) {
                [lyricArray addObject:dic];
            }
        }
    }
    
    [lyricTablenview reloadData];
}
//- (void)saveToAlbumWithMetadata:(NSDictionary *)metadata
//                      imageData:(NSData *)imageData
//                customAlbumName:(NSString *)customAlbumName
//                completionBlock:(void (^)(void))completionBlock
//                   failureBlock:(void (^)(NSError *error))failureBlock
//{
//    
//    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
//    void (^AddAsset)(ALAssetsLibrary *, NSURL *) = ^(ALAssetsLibrary *assetsLibrary, NSURL *assetURL) {
//        [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
//            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//                
//                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:customAlbumName]) {
//                    [group addAsset:asset];
//                    if (completionBlock) {
//                        completionBlock();
//                    }
//                }
//            } failureBlock:^(NSError *error) {
//                if (failureBlock) {
//                    failureBlock(error);
//                }
//            }];
//        } failureBlock:^(NSError *error) {
//            if (failureBlock) {
//                failureBlock(error);
//            }
//        }];
//    };
//    __weak ALAssetsLibrary *weakassetsLibrary = assetsLibrary;
//    [assetsLibrary writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
//        if (customAlbumName) {
//            [assetsLibrary addAssetsGroupAlbumWithName:customAlbumName resultBlock:^(ALAssetsGroup *group) {
//                if (group) {
//                    [weakassetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
//                        [group addAsset:asset];
//                        if (completionBlock) {
//                            completionBlock();
//                            
//                        }
//                    } failureBlock:^(NSError *error) {
//                        if (failureBlock) {
//                            failureBlock(error);
//                        }
//                    }];
//                } else {
//                    AddAsset(weakassetsLibrary, assetURL);
//                }
//            } failureBlock:^(NSError *error) {
//                AddAsset(weakassetsLibrary, assetURL);
//            }];
//        } else {
//            if (completionBlock) {
//                completionBlock();
//            }
//        }
//    }];
//}


@end
