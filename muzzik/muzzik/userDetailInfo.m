//
//  userDetailInfo.m
//  muzzik
//
//  Created by muzzik on 15/5/6.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
#import "showUserVC.h"
#import "userDetailInfo.h"
#import "NormalCell.h"
#import "NormalNoCardCell.h"
#import "UIButton+WebCache.h"
#import "DetaiMuzzikVC.h"
#import "UIImageView+WebCache.h"
#import "UserSongVC.h"
#import "showUsersVC.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "TopicDetail.h"
#import "repostVC.h"
@interface userDetailInfo ()<UITableViewDataSource,UITableViewDelegate,TTTAttributedLabelDelegate,CellDelegate,UIActionSheetDelegate>{
    UITableView *MyTableView;
    int page;
    //shareView
    NSMutableDictionary *RefreshDic;
    NSMutableDictionary *ReFreshPoImageDic;
    muzzik *shareMuzzik;
    UIView *shareViewFull;
    UIView *shareView;
    UIButton *shareToTimeLineButton;
    UIButton *shareToWeiChatButton;
    UIButton *shareToWeiboButton;
    UIButton *shareToQQButton;
    UIButton *shareToQQZoneButton;
    CGFloat maxScaleY;
    BOOL isDataSourceUpdated;
    UIImage *shareImage;
    NSString *muzzikuserName;
    UIAlertView *loginAlter;
}
@property(nonatomic,retain) muzzik *repostMuzzik;
@property (nonatomic,retain) NSMutableDictionary *profileDic;
@property (nonatomic,retain) NSMutableArray *muzziks;
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
@property(nonatomic,retain)UIView *messageView;
@property(nonatomic,retain)UILabel *muzzikCount;
@property(nonatomic,retain)UILabel *followCount;
@property(nonatomic,retain)UILabel *fansCount;
@property(nonatomic,retain)UILabel *songCount;
@property(nonatomic,retain)UIView *headView;
@property(nonatomic,retain)UIImageView *coverImage;
@end

@implementation userDetailInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMuzzik:) name:String_Muzzik_Delete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceMuzzikUpdate:) name:String_MuzzikDataSource_update object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceUserUpdate:) name:String_UserDataSource_update object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    page = 1;
    self.muzziks = [NSMutableArray array];
    RefreshDic = [NSMutableDictionary dictionary];
    ReFreshPoImageDic = [NSMutableDictionary dictionary];
    [self SettingShareView];
    [self initNagationBar:@"Ta" leftBtn:Constant_backImage rightBtn:11];
    MyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:MyTableView];
     _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH+55)];
    [self settingHeadView];
    MyTableView.delegate = self;
    MyTableView.dataSource = self;
    [MyTableView registerClass:[NormalCell class] forCellReuseIdentifier:@"NormalCell"];
    [MyTableView registerClass:[NormalNoCardCell class] forCellReuseIdentifier:@"NormalNoCardCell"];
    MyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self followScrollView:MyTableView];
    [MyTableView setTableHeaderView:_headView];
    [self loadDataMessage];
    [MyTableView addFooterWithTarget:self action:@selector(refreshFooter)];
    


    // Do any additional setup after loading the view.
}
-(void)loadDataMessage{
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@",BaseURL,self.uid]]];
    [requestForm addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            _profileDic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData]  options:NSJSONReadingMutableContainers error:nil];
            if (_profileDic) {
                if ([[_profileDic objectForKey:@"_id"] length]>0) {
                    self.uid = [_profileDic objectForKey:@"_id"];
                }
                if ([[_profileDic objectForKey:@"isFollow"] boolValue] &&[[_profileDic objectForKey:@"isFans"] boolValue]) {
                    [_attentionButton setImage:[UIImage imageNamed:Image_profilefolloweacherother] forState:UIControlStateNormal];
                    [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-85, 16, 65, 23)];
                }else if([[_profileDic objectForKey:@"isFollow"] boolValue]){
                    [_attentionButton setImage:[UIImage imageNamed:Image_profilefollowed] forState:UIControlStateNormal];
                    [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-75, 16, 55, 23)];
                }else{
                    [_attentionButton setImage:[UIImage imageNamed:Image_profilefollow] forState:UIControlStateNormal];
                    [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-65, 16, 45, 23)];
                }
                NSArray *dicKeys = [_profileDic allKeys];
                if ([dicKeys containsObject:@"avatar"]) {
                    [_headimage setAlpha:0];
                    [_headimage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?imageView2/1/w/600/h/600",BaseURL_image,[_profileDic objectForKey:@"avatar"]]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [UIView animateWithDuration:0.5 animations:^{
                            [_headimage setAlpha:1];
                            [_coverImage setAlpha:1];
                        }];
                    }];
                }
                if ([dicKeys containsObject:@"name"]) {
                    _nameLabel.text = [_profileDic objectForKey:@"name"];
                    muzzikuserName = [_profileDic objectForKey:@"name"];
                    [_nameLabel sizeToFit];
                    [_nameLabel setFrame:CGRectMake(16, SCREEN_WIDTH/2-_nameLabel.frame.size.height, _nameLabel.frame.size.width, _nameLabel.frame.size.height)];
                    [_genderImage setFrame:CGRectMake(CGRectGetMaxX(_nameLabel.frame)+6, CGRectGetMidY(_nameLabel.frame)-10, 16, 16)];
                    if ([[_profileDic objectForKey:@"gender"] isEqualToString:@"m"]) {
                        [_genderImage setImage:[UIImage imageNamed:Image_profilemaleImage]];
                    }else{
                        [_genderImage setImage:[UIImage imageNamed:Image_profilefemaleImage]];
                    }
                }
                [_constellationImage removeFromSuperview];
                [_constellationLabel removeFromSuperview];
                CGFloat recordHeight = SCREEN_WIDTH-32;
                if ([dicKeys containsObject:@"astro"] && [[_profileDic objectForKey:@"astro"] length]>0) {
                    _constellationImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
                    [_constellationImage setImage:[UIImage imageNamed:Image_profileconstellationImage]];
                    [_headView addSubview:_constellationImage];
                    _constellationLabel.frame = CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20);
                    [_constellationLabel setText:[MuzzikItem transtromAstroToChinese:[_profileDic objectForKey:@"astro"]]];
                    [_constellationLabel setTextColor:Color_Text_4];
                    [_constellationLabel setFont:[UIFont systemFontOfSize:12]];
                    [_headView addSubview:_constellationLabel];
                    recordHeight = recordHeight-28;
                    
                }
                [_birthImage removeFromSuperview];
                [_birthLabel removeFromSuperview];
                if ([dicKeys containsObject:@"birthday"] && [_profileDic objectForKey:@"birthday"]>0) {
                    double unixTimeStamp = [[NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"birthday"]] doubleValue]/1000;
                    NSTimeInterval _interval=unixTimeStamp;
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
                    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
                    [_formatter setLocale:[NSLocale currentLocale]];
                    [_formatter setDateFormat:@"YYYY.MM.dd"];
                    NSString *_date=[_formatter stringFromDate:date];
                    
                    
                    _birthImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
                    [_birthImage setImage:[UIImage imageNamed:Image_profilebirthImage]];
                    [_headView addSubview:_birthImage];
                    _birthLabel.frame = CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20);
                    [_birthLabel setText:_date];
                    [_birthLabel setTextColor:Color_Text_4];
                    [_birthLabel setFont:[UIFont systemFontOfSize:12]];
                    [_headView addSubview:_birthLabel];
                    recordHeight = recordHeight-28;
                    
                }
                [_companyImage removeFromSuperview];
                [_companyLabel removeFromSuperview];
                [_schoolImage removeFromSuperview];
                [_schoolLabel removeFromSuperview];
                if ([dicKeys containsObject:@"company"] && [[_profileDic objectForKey:@"company"] length]>0) {
                    _companyImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
                    [_companyImage setImage:[UIImage imageNamed:Image_profilejobImage]];
                    [_headView addSubview:_companyImage];
                    _companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20)];
                    [_companyLabel setText:[_profileDic objectForKey:@"company"]];
                    [_companyLabel setTextColor:Color_Text_4];
                    [_companyLabel setFont:[UIFont systemFontOfSize:12]];
                    [_headView addSubview:_companyLabel];
                    recordHeight = recordHeight-28;
                    
                }else if([dicKeys containsObject:@"school"] && [[_profileDic objectForKey:@"school"] length]>0){
                    _schoolImage.frame = CGRectMake(16, recordHeight+5, 8, 8);
                    [_schoolImage setImage:[UIImage imageNamed:Image_profileschoolImage]];
                    [_headView addSubview:_schoolImage];
                    _schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, recordHeight, SCREEN_WIDTH/2-50, 20)];
                    [_schoolLabel setText:[_profileDic objectForKey:@"school"]];
                    [_schoolLabel setTextColor:Color_Text_4];
                    [_schoolLabel setFont:[UIFont systemFontOfSize:12]];
                    [_headView addSubview:_schoolLabel];
                    recordHeight = recordHeight-28;
                }
                if ([dicKeys containsObject:@"description"]) {
                    UILabel *temp = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32, 100)];
                    temp.numberOfLines = 0;
                    [temp setFont:[UIFont systemFontOfSize:12]];
                    temp.text =  [_profileDic objectForKey:@"description"];
                    [temp sizeToFit];
                    _descriptionLabel.frame = CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32, temp.frame.size.height);
                    _descriptionLabel.numberOfLines = 0;
                    
                    [_descriptionLabel setFont:[UIFont systemFontOfSize:12]];
                    _descriptionLabel.text = [_profileDic objectForKey:@"description"];
                    [_descriptionLabel setTextColor:[UIColor whiteColor]];
                    [_headView addSubview:_descriptionLabel];
                }
                
                
                if ([dicKeys containsObject:@"genres"] && [[_profileDic objectForKey:@"genres"] count]>0) {
                    [_genresView removeFromSuperview];
                    _genresView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-10, SCREEN_WIDTH-88, SCREEN_WIDTH/2-6, 76)];
                    [_headView addSubview: _genresView];
                    int local = SCREEN_WIDTH/2-6;
                    int localheight = 56;
                    for (NSDictionary * dic in [_profileDic objectForKey:@"genres"]) {
                        UILabel *tempLabel = [[UILabel alloc ] initWithFrame:CGRectMake(0, 0, 100, 20)];
                        [tempLabel setFont:[UIFont systemFontOfSize:12]];
                        [tempLabel setText:[dic objectForKey:@"data"]];
                        [tempLabel sizeToFit];
                        if (tempLabel.frame.size.width-20>SCREEN_WIDTH/2-6) continue;
                        if (local- tempLabel.frame.size.width-20<0) {
                            localheight = localheight-28;
                            local = SCREEN_WIDTH/2-6;
                            if (localheight<0) {
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
                if ([[NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"muzzikTotal"]] length] == 0) {
                    _muzzikCount.text = @"0";
                }else{
                    _muzzikCount.text = [NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"muzzikTotal"]];
                }
                
                if ([[NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"followsCount"]] length] == 0) {
                    _followCount.text = @"0";
                }else{
                    _followCount.text = [NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"followsCount"]];
                }
                
                if ([[NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"fansCount"]] length] == 0) {
                    _fansCount.text = @"0";
                }else{
                    _fansCount.text = [NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"fansCount"]];
                }
                
                if ([[NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"musicsTotal"]] length] == 0) {
                    _songCount.text = @"0";
                }else{
                   _songCount.text = [NSString stringWithFormat:@"%@",[_profileDic objectForKey:@"musicsTotal"]];
                }
            }
            
            
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,[_profileDic  objectForKey:@"_id"]]]];
            [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[NSNumber numberWithInt:page],Parameter_page, nil] Method:GetMethod auth:YES];
            __weak ASIHTTPRequest *weakre = request;
            [request setCompletionBlock :^{
                NSLog(@"%@",[weakre responseString]);
                NSLog(@"%d",[weakre responseStatusCode]);
                if ([weakre responseStatusCode] == 200) {
                    NSData *data = [weakre responseData];
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    if (dic) {
                        page = 2;
                        muzzik *muzzikToy = [muzzik new];
                        NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                        for (muzzik *tempmuzzik in array) {
                            BOOL isContained = NO;
                            for (muzzik *arrayMuzzik in self.muzziks) {
                                if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                                    isContained = YES;
                                    break;
                                }
                                
                            }
                            if (!isContained) {
                                [self.muzziks addObject:tempmuzzik];
                            }
                            isContained = NO;
                        }
                        [MyTableView reloadData];
                        
                    }
                }
                else{
                    //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                }
            }];
            [request setFailedBlock:^{
                NSLog(@"%@",[weakre error]);
                if (![[weakrequest responseString] length]>0) {
                    [self networkErrorShow];
                }
            }];
            [request startAsynchronous];
        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
    }];
    [requestForm setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
        if (![[weakrequest responseString] length]>0) {
            [self networkErrorShow];
        }
    }];
    [requestForm startAsynchronous];
}

-(void)reloadDataSource{
    [super reloadDataSource];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadDataMessage];
    });
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
-(void)refreshFooter{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,self.uid]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[NSNumber numberWithInt:page],Parameter_page, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            page ++;
            muzzik *muzzikToy = [muzzik new];
            NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *tempmuzzik in array) {
                BOOL isContained = NO;
                for (muzzik *arrayMuzzik in self.muzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                    
                }
                if (!isContained) {
                    [self.muzziks addObject:tempmuzzik];
                }
                isContained = NO;
            }
           
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MyTableView reloadData];
                [MyTableView footerEndRefreshing];
                if ([[dic objectForKey:@"muzziks"] count]<1 ) {
                    [MyTableView removeFooter];
                }
            });
            
        }
    }];
    [request setFailedBlock:^{
        [MyTableView footerEndRefreshing];
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    
    return self.muzziks.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    muzzik *tempMuzzik = [self.muzziks objectAtIndex:indexPath.row];
    
    
    if ([tempMuzzik.type isEqualToString:@"normal"] ||[tempMuzzik.type isEqualToString:@"repost"] || [tempMuzzik.type isEqualToString:@"muzzikCard"]) {
        
        TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(75, 0, SCREEN_WIDTH-110, 500)];
        [label setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
        [label setText:tempMuzzik.message];
        CGFloat textHeight = [MuzzikItem heightForLabel:label WithText:label.text];
        if (textHeight>limitHeight) {
            if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length]>0) {
                return (int)(260+limitHeight+SCREEN_WIDTH*3/4)+20;
            }else{
                return 260+limitHeight;
            }
            
        }else{
            if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length]>0) {
                return (int)(260+textHeight+SCREEN_WIDTH*3/4)+10;
            }else{
                return 260+(int)textHeight;
            }
        }
    }else{
        return 0;
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.muzziks[indexPath.row] isKindOfClass:[muzzik class]]) {
        muzzik *tempMuzzik = self.muzziks[indexPath.row];
        DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
        detail.muzzik_id = tempMuzzik.muzzik_id;
        [self.navigationController pushViewController:detail animated:YES];
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Globle *glob = [Globle shareGloble];
    muzzik *tempMuzzik = [self.muzziks objectAtIndex:indexPath.row];
    if ([tempMuzzik.type isEqualToString:@"repost"] || [tempMuzzik.type isEqualToString:@"normal"] || [tempMuzzik.type isEqualToString:@"muzzikCard"] )
    {
        if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length] == 0) {
            if ([tempMuzzik.type isEqualToString:@"repost"] ||[tempMuzzik.type isEqualToString:@"muzzikCard"]){
                NormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
                cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
                if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                if (tempMuzzik.isprivate ) {
                    [cell.privateImage setHidden:NO];
                    [cell.userName sizeToFit];
                    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+2, cell.userName.frame.origin.y, 20, 20)];
                }else{
                    [cell.privateImage setHidden:YES];
                    [cell.userName setFrame:CGRectMake(80, 55, SCREEN_WIDTH-120, 20)];
                }
                
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                        [cell.userImage setAlpha:0];
                        [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                        [UIView animateWithDuration:0.5 animations:^{
                            [cell.userImage setAlpha:1];
                        }];
                    }
                    
                    
                }];
                
                
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                [cell.repostImage setHidden:NO];
                cell.repostUserName.text = tempMuzzik.reposter.name;
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                cell.isMoved = tempMuzzik.ismoved;
                cell.isReposted = tempMuzzik.isReposted;
                cell.index = indexPath.row;
                cell.muzzikMessage.delegate = self;
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0, (int)floor(95+cell.muzzikMessage.bounds.size.height), SCREEN_WIDTH, cell.musicPlayView.frame.size.height)];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.repostDate];
                
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.muzzik_id = tempMuzzik.muzzik_id;
                cell.delegate=self;
                if ([tempMuzzik.moveds integerValue]>0) {
                    [cell.moves setTitle:[NSString stringWithFormat:@"喜欢数%@",tempMuzzik.moveds] forState:UIControlStateNormal];
                }else{
                    [cell.moves setTitle:@"喜欢数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.reposts integerValue]>0) {
                    [cell.reposts setTitle:[NSString stringWithFormat:@"转发数%@",tempMuzzik.reposts] forState:UIControlStateNormal];
                }
                else{
                    [cell.reposts setTitle:@"转发数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.comments integerValue]>0) {
                    [cell.comments setTitle:[NSString stringWithFormat:@"评论数%@",tempMuzzik.comments ] forState:UIControlStateNormal];
                }
                else{
                    [cell.comments setTitle:@"评论数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.shares integerValue]>0) {
                    [cell.shares setTitle:[NSString stringWithFormat:@"分享数%@",tempMuzzik.shares] forState:UIControlStateNormal];
                }
                else{
                    [cell.shares setTitle:@"分享数" forState:UIControlStateNormal];
                }
                return  cell;
            }
            else {
                NormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
                cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
                if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                        [cell.userImage setAlpha:0];
                        [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                        [UIView animateWithDuration:0.5 animations:^{
                            [cell.userImage setAlpha:1];
                        }];
                    }
                    
                    
                }];
                
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                if (tempMuzzik.isprivate ) {
                    [cell.privateImage setHidden:NO];
                    [cell.userName sizeToFit];
                    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+2, cell.userName.frame.origin.y, 20, 20)];
                }else{
                    [cell.privateImage setHidden:YES];
                    [cell.userName setFrame:CGRectMake(80, 55, SCREEN_WIDTH-120, 20)];
                }
                
                cell.repostUserName.text = @"";
                [cell.repostImage setHidden:YES];
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                cell.isMoved = tempMuzzik.ismoved;
                cell.isReposted = tempMuzzik.isReposted;
                cell.index = indexPath.row;
                cell.muzzikMessage.delegate = self;
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0,(int) floor(95+cell.muzzikMessage.bounds.size.height), SCREEN_WIDTH, cell.musicPlayView.frame.size.height)];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.muzzik_id = tempMuzzik.muzzik_id;
                cell.delegate=self;
                if ([tempMuzzik.moveds integerValue]>0) {
                    [cell.moves setTitle:[NSString stringWithFormat:@"喜欢数%@",tempMuzzik.moveds] forState:UIControlStateNormal];
                }else{
                    [cell.moves setTitle:@"喜欢数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.reposts integerValue]>0) {
                    [cell.reposts setTitle:[NSString stringWithFormat:@"转发数%@",tempMuzzik.reposts] forState:UIControlStateNormal];
                }
                else{
                    [cell.reposts setTitle:@"转发数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.comments integerValue]>0) {
                    [cell.comments setTitle:[NSString stringWithFormat:@"评论数%@",tempMuzzik.comments ] forState:UIControlStateNormal];
                }
                else{
                    [cell.comments setTitle:@"评论数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.shares integerValue]>0) {
                    [cell.shares setTitle:[NSString stringWithFormat:@"分享数%@",tempMuzzik.shares] forState:UIControlStateNormal];
                }
                else{
                    [cell.shares setTitle:@"分享数" forState:UIControlStateNormal];
                }
                return  cell;
            }
        }else{
            if ([tempMuzzik.type isEqualToString:@"repost"] || [tempMuzzik.type isEqualToString:@"muzzikCard"]){
                NormalNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalNoCardCell" forIndexPath:indexPath];
                cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
                if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                if (tempMuzzik.isprivate ) {
                    [cell.privateImage setHidden:NO];
                    [cell.userName sizeToFit];
                    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+2, cell.userName.frame.origin.y, 20, 20)];
                }else{
                    [cell.privateImage setHidden:YES];
                    [cell.userName setFrame:CGRectMake(80, 55, SCREEN_WIDTH-120, 20)];
                }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                        [cell.userImage setAlpha:0];
                        [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                        [UIView animateWithDuration:0.5 animations:^{
                            [cell.userImage setAlpha:1];
                        }];
                    }
                    
                    
                }];
                
                [cell.poImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.image,Image_Size_Big]] placeholderImage:[UIImage imageNamed:Image_placeholdImage] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (![[ReFreshPoImageDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                        [cell.poImage setAlpha:0];
                        [ReFreshPoImageDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                        [UIView animateWithDuration:0.5 animations:^{
                            [cell.poImage setAlpha:1];
                        }];
                    }
                    
                    
                }];
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                [cell.repostImage setHidden:NO];
                cell.repostUserName.text = tempMuzzik.reposter.name;
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                cell.isMoved = tempMuzzik.ismoved;
                cell.isReposted = tempMuzzik.isReposted;
                cell.index = indexPath.row;
                cell.muzzikMessage.delegate = self;
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0,(int)floor( 95+cell.muzzikMessage.bounds.size.height), SCREEN_WIDTH, (int)cell.musicPlayView.frame.size.height)];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.repostDate];
                
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.muzzik_id = tempMuzzik.muzzik_id;
                cell.delegate=self;
                if ([tempMuzzik.moveds integerValue]>0) {
                    [cell.moves setTitle:[NSString stringWithFormat:@"喜欢数%@",tempMuzzik.moveds] forState:UIControlStateNormal];
                }else{
                    [cell.moves setTitle:@"喜欢数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.reposts integerValue]>0) {
                    [cell.reposts setTitle:[NSString stringWithFormat:@"转发数%@",tempMuzzik.reposts] forState:UIControlStateNormal];
                }
                else{
                    [cell.reposts setTitle:@"转发数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.comments integerValue]>0) {
                    [cell.comments setTitle:[NSString stringWithFormat:@"评论数%@",tempMuzzik.comments ] forState:UIControlStateNormal];
                }
                else{
                    [cell.comments setTitle:@"评论数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.shares integerValue]>0) {
                    [cell.shares setTitle:[NSString stringWithFormat:@"分享数%@",tempMuzzik.shares] forState:UIControlStateNormal];
                }
                else{
                    [cell.shares setTitle:@"分享数" forState:UIControlStateNormal];
                }
                return  cell;
            }
            else {
                NormalNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalNoCardCell" forIndexPath:indexPath];
                cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
                if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                        [cell.userImage setAlpha:0];
                        [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                        [UIView animateWithDuration:0.5 animations:^{
                            [cell.userImage setAlpha:1];
                        }];
                    }
                    
                    
                }];
                
                [cell.poImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.image,Image_Size_Big]] placeholderImage:[UIImage imageNamed:Image_placeholdImage] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (![[ReFreshPoImageDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                        [cell.poImage setAlpha:0];
                        [ReFreshPoImageDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                        [UIView animateWithDuration:0.5 animations:^{
                            [cell.poImage setAlpha:1];
                        }];
                    }
                    
                    
                }];
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                if (tempMuzzik.isprivate ) {
                    [cell.privateImage setHidden:NO];
                    [cell.userName sizeToFit];
                    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+2, cell.userName.frame.origin.y, 20, 20)];
                }else{
                    [cell.privateImage setHidden:YES];
                    [cell.userName setFrame:CGRectMake(80, 55, SCREEN_WIDTH-120, 20)];
                }
                cell.repostUserName.text = @"";
                [cell.repostImage setHidden:YES];
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                cell.isMoved = tempMuzzik.ismoved;
                cell.isReposted = tempMuzzik.isReposted;
                cell.index = indexPath.row;
                cell.muzzikMessage.delegate = self;
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0, (int)floor(95+cell.muzzikMessage.bounds.size.height), SCREEN_WIDTH, floor(cell.musicPlayView.frame.size.height))];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.muzzik_id = tempMuzzik.muzzik_id;
                cell.delegate=self;
                if ([tempMuzzik.moveds integerValue]>0) {
                    [cell.moves setTitle:[NSString stringWithFormat:@"喜欢数%@",tempMuzzik.moveds] forState:UIControlStateNormal];
                }else{
                    [cell.moves setTitle:@"喜欢数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.reposts integerValue]>0) {
                    [cell.reposts setTitle:[NSString stringWithFormat:@"转发数%@",tempMuzzik.reposts] forState:UIControlStateNormal];
                }
                else{
                    [cell.reposts setTitle:@"转发数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.comments integerValue]>0) {
                    [cell.comments setTitle:[NSString stringWithFormat:@"评论数%@",tempMuzzik.comments ] forState:UIControlStateNormal];
                }
                else{
                    [cell.comments setTitle:@"评论数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.shares integerValue]>0) {
                    [cell.shares setTitle:[NSString stringWithFormat:@"分享数%@",tempMuzzik.shares] forState:UIControlStateNormal];
                }
                else{
                    [cell.shares setTitle:@"分享数" forState:UIControlStateNormal];
                }
                return  cell;
            }
            
            
        }
        
    }
    else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        return cell;
    }
    
    
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
-(void)userDetail:(NSString *)uid{
    userInfo *user = [userInfo shareClass];
    if ([uid isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        home.isPush = YES;
        [self.navigationController pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = uid;
        [self.navigationController pushViewController:detailuser animated:YES];
    }
}
-(void)payAttention{
    if ([[_profileDic objectForKey:@"isFollow"] boolValue]) {
        [_profileDic setValue:[NSNumber numberWithBool:NO] forKey:@"isFollow"];
        MuzzikUser *attentionuser = [MuzzikUser new];
        attentionuser.user_id = [_profileDic objectForKey:@"_id"];
        attentionuser.isFans = [[_profileDic objectForKey:@"isFans"] boolValue];
        attentionuser.isFollow = [[_profileDic objectForKey:@"isFollow"] boolValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:attentionuser];
        
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_user_Unfollow]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:self.uid forKey:@"_id"] Method:PostMethod auth:YES];
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
        }];
        [requestForm startAsynchronous];
    }else{
        [_profileDic setValue:[NSNumber numberWithBool:YES] forKey:@"isFollow"];
        MuzzikUser *attentionuser = [MuzzikUser new];
        attentionuser.user_id = [_profileDic objectForKey:@"_id"];
        attentionuser.isFans = [[_profileDic objectForKey:@"isFans"] boolValue];
        attentionuser.isFollow = [[_profileDic objectForKey:@"isFollow"] boolValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:attentionuser];
        
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_User_Follow]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:self.uid forKey:@"_id"] Method:PostMethod auth:YES];
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
        }];
        [requestForm startAsynchronous];
    }

}
-(void)moveMuzzik:(muzzik *) tempMuzzik{
    
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        tempMuzzik.ismoved = !tempMuzzik.ismoved;
        if (tempMuzzik.ismoved) {
            tempMuzzik.moveds = [NSString stringWithFormat:@"%d",[tempMuzzik.moveds intValue]+1 ];
        }else{
            tempMuzzik.moveds = [NSString stringWithFormat:@"%d",[tempMuzzik.moveds intValue]-1 ];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:tempMuzzik];
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/moved",BaseURL,tempMuzzik.muzzik_id]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:tempMuzzik.ismoved] forKey:@"ismoved"] Method:PostMethod auth:YES];
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
        [userInfo checkLoginWithVC:self];
    }
    
}
-(void)repostActionWithMuzzik:(muzzik *)tempMuzzik{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        self.repostMuzzik = tempMuzzik;
        if (!tempMuzzik.isReposted) {
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
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // do stuff
        if (!self.repostMuzzik.isReposted) {
           
            self.repostMuzzik.isReposted = YES;
            self.repostMuzzik.reposts = [NSString stringWithFormat:@"%d",[self.repostMuzzik.reposts intValue]+1];
            [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:self.repostMuzzik];
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik",BaseURL]]];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:self.repostMuzzik.muzzik_id forKey:@"repost"];
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
                }
            }];
            [requestForm setFailedBlock:^{
                NSLog(@"%@",[weakrequest error]);
            }];
            [requestForm startAsynchronous];
        }else{
            
            self.repostMuzzik.isReposted = NO;
            self.repostMuzzik.reposts = [NSString stringWithFormat:@"%d",[self.repostMuzzik.reposts intValue]-1];
            [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:self.repostMuzzik];
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/repost",BaseURL,self.repostMuzzik.muzzik_id]]];
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

        
    }else{
        
    }
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%f",scrollView.contentOffset.y);
    CGFloat yOffset  = scrollView.contentOffset.y;
    if (yOffset < 0 ) {
        CGRect f = _headimage.frame;
        f.origin.y = yOffset;
        f.size.height =  SCREEN_WIDTH-yOffset;
        _headimage.frame = f;
        
        CGRect cover = _coverImage.frame;
        cover.origin.y = yOffset;
        cover.size.height =  SCREEN_WIDTH-yOffset;
        _coverImage.frame = cover;
        
        CGRect d = _attentionButton.frame;
        d.origin.y = yOffset+16;
        
        _attentionButton.frame = d;
    }
    if (yOffset>SCREEN_WIDTH) {
        [_messageView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 55)];
        [self.view addSubview:_messageView];
    }else{
        [_messageView  setFrame:CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, 55)];
        [_headView addSubview:_messageView];
    }
}

-(void)playnextMuzzikUpdate{
    [MyTableView reloadData];
}
-(void)playSongWithSongModel:(muzzik *)songModel{
    MuzzikRequestCenter *center = [MuzzikRequestCenter shareClass];
    center.subUrlString = [NSString stringWithFormat:@"api/user/%@/muzziks",self.uid];
    center.requestDic = [NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[NSNumber numberWithInt:page],Parameter_page, nil];
    center.isPage = YES;
    center.singleMusic = NO;
    center.MuzzikType = Type_Muzzik_Muzzik;
    center.page = page;
    
    [MuzzikPlayer shareClass].MusicArray = [self.muzziks mutableCopy];
    [MuzzikPlayer shareClass].listType = TempList;
    [[MuzzikPlayer shareClass] playSongWithSongModel:songModel Title:[NSString stringWithFormat:@"#%@#的Muzzik",songModel.MuzzikUser.name]];
    [MuzzikItem SetUserInfoWithMuzziks:self.muzziks title:Constant_userInfo_temp description:[NSString stringWithFormat:@"#%@#的Muzzik",songModel.MuzzikUser.name]];
}

-(void) commentAtMuzzik:(muzzik *)localMuzzik{
    muzzik *tempMuzzik = localMuzzik;
    DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
    detail.muzzik_id = tempMuzzik.muzzik_id;
    detail.showType = Constant_Comment;
    [self.navigationController pushViewController:detail animated:YES];
}
-(void)deleteMuzzik:(NSNotification *)notify{
    muzzik *localMzzik = notify.object;
    for (muzzik *tempMuzzik in self.muzziks) {
        if ([tempMuzzik.muzzik_id isEqualToString:localMzzik.muzzik_id]) {
            [self.muzziks removeObject:tempMuzzik];
            [MyTableView reloadData];
            break;
        }
    }
}
-(void) showRepost:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"repost";
    [self.navigationController pushViewController:showvc animated:YES];
}
-(void) showShare:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"share";
    [self.navigationController pushViewController:showvc animated:YES];
}
-(void)showComment:(muzzik *)localMuzzik{
    muzzik *tempMuzzik = localMuzzik;
    DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
    detail.muzzik_id = tempMuzzik.muzzik_id;
    detail.showType = Constant_showComment;
    [self.navigationController pushViewController:detail animated:YES];
}

-(void) showMoved:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"moved";
    [self.navigationController pushViewController:showvc animated:YES];
}
-(void)showSong{
    UserSongVC *usersongvc = [[UserSongVC alloc] init];
    usersongvc.uid = self.uid;
    usersongvc.userName = muzzikuserName;
    [self.navigationController pushViewController:usersongvc animated:YES];
}

-(void)showFans{
    showUsersVC *usersvc = [[showUsersVC alloc] init];
    usersvc.showType = @"fans";
    usersvc.uid = self.uid;
    [self.navigationController pushViewController:usersvc animated:YES];
}

-(void)showFollow{
    showUsersVC *usersvc = [[showUsersVC alloc] init];
    usersvc.showType = @"follows";
    usersvc.uid = self.uid;
    [self.navigationController pushViewController:usersvc animated:YES];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) settingHeadView{
    _headimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [_headView addSubview:_headimage];
    _headimage.contentMode = UIViewContentModeScaleAspectFill;
    _coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [_coverImage setImage:[UIImage imageNamed:Image_prifilebgcover]];
    _coverImage.contentMode = UIViewContentModeScaleAspectFill;
    [_headView addSubview:_coverImage];
    _attentionButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 16, 85, 23)];
    [_attentionButton addTarget:self action:@selector(payAttention) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_attentionButton];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, 30, 30)];
    [_nameLabel setFont:[UIFont fontWithName:Font_Next_DemiBold size:24]];
    _nameLabel.textColor = [UIColor whiteColor];
    [_headView addSubview:_nameLabel];
    _genderImage = [[UIImageView alloc] init];
    [_headView addSubview:_genderImage];
    
    _constellationImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _constellationLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, SCREEN_WIDTH/2-50, 20)];
    
    _birthImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _birthLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    
    _companyImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    
    _schoolImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 8, 8)];
    _schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH/2-50, 20)];
    _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH/2, SCREEN_WIDTH-32,0)];
    
    _messageView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, 55)];
    int width_of_View = (CGRectGetWidth(_messageView.frame)-32)/4;
    
    [_messageView setBackgroundColor:[UIColor whiteColor]];
    UIView *muzzikView = [[UIView alloc] initWithFrame:CGRectMake(16, 0, width_of_View, CGRectGetHeight(_messageView.frame))];
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, width_of_View, 20)];
    messageLabel.font = [UIFont systemFontOfSize:11];
    messageLabel.textColor = Color_Additional_5;
    messageLabel.text = @"信息";
    messageLabel.textAlignment = NSTextAlignmentCenter;
    _muzzikCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, width_of_View, 25)];
    [_muzzikCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
    _muzzikCount.textAlignment = NSTextAlignmentCenter;
    _muzzikCount.textColor = Color_Text_2;
    [muzzikView addSubview:_muzzikCount];
    [muzzikView addSubview:messageLabel];
    
    [_messageView addSubview:muzzikView];
    
    UIView *followView = [[UIView alloc] initWithFrame:CGRectMake(width_of_View+16, 0, width_of_View, CGRectGetHeight(_messageView.frame))];
    UILabel *followLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, width_of_View, 20)];
    followLabel.font = [UIFont systemFontOfSize:11];
    followLabel.textColor = Color_Additional_5;
    followLabel.text = @"关注";
    followLabel.textAlignment = NSTextAlignmentCenter;
    _followCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5,width_of_View, 25)];
    [_followCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
    _followCount.textAlignment = NSTextAlignmentCenter;
    _followCount.textColor = Color_Text_2;
    [followView addSubview:_followCount];
    [followView addSubview:followLabel];
    
    [_messageView addSubview:followView];
    [followView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFollow)]];
    UIView *fansView = [[UIView alloc] initWithFrame:CGRectMake(width_of_View*2+16, 0, width_of_View, CGRectGetHeight(_messageView.frame))];
    UILabel *fansLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, width_of_View, 20)];
    fansLabel.font = [UIFont systemFontOfSize:11];
    fansLabel.textColor = Color_Additional_5;
    fansLabel.text = @"粉丝";
    fansLabel.textAlignment = NSTextAlignmentCenter;
    _fansCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, width_of_View, 25)];
    [_fansCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
    _fansCount.textAlignment = NSTextAlignmentCenter;
    _fansCount.textColor = Color_Text_2;
    [fansView addSubview:_fansCount];
    [fansView addSubview:fansLabel];
    [fansView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFans)]];
    [_messageView addSubview:fansView];
    
    UIView *songView = [[UIView alloc] initWithFrame:CGRectMake(width_of_View * 3 + 16, 0, width_of_View, CGRectGetHeight(_messageView.frame))];
    UILabel *songLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25,width_of_View, 20)];
    songLabel.font = [UIFont systemFontOfSize:11];
    songLabel.textColor = Color_Additional_5;
    songLabel.text = @"歌单";
    songLabel.textAlignment = NSTextAlignmentCenter;
    _songCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, width_of_View, 25)];
    [_songCount setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
    _songCount.textAlignment = NSTextAlignmentCenter;
    _songCount.textColor = Color_Text_2;
    [songView addSubview:_songCount];
    [songView addSubview:songLabel];
    [songView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSong)]];
    [_messageView addSubview:songView];
    [_headView addSubview:_messageView];
    UIView *linview = [[UIView alloc] initWithFrame:CGRectMake(16+width_of_View, 16, 1, 22)];
    [linview setBackgroundColor:Color_line_1];
    [_messageView addSubview:linview];
    
    UIView *linview2 = [[UIView alloc] initWithFrame:CGRectMake(16+width_of_View*2, 16, 1, 22)];
    [linview2 setBackgroundColor:Color_line_1];
    [_messageView addSubview:linview2];
    
    UIView *linview3 = [[UIView alloc] initWithFrame:CGRectMake(16+width_of_View*3, 16, 1, 22)];
    [linview3 setBackgroundColor:Color_line_1];
    [_messageView addSubview:linview3];
    UIView *lineWidth = [[UIView alloc] initWithFrame:CGRectMake(16, 53,width_of_View*4, 2)];
    [lineWidth setBackgroundColor:Color_line_1];
    [_messageView addSubview:lineWidth];
    
    UIView *lineRed = [[UIView alloc] initWithFrame:CGRectMake(16, 53, width_of_View, 2)];
    [lineRed setBackgroundColor:Color_Active_Button_1];
    [_messageView addSubview:lineRed];
}


-(void)shareActionWithMuzzik:(muzzik *)localMuzzik image:(UIImage *) image{
    shareMuzzik = localMuzzik;
    shareImage = image;
    [self addShareView];
}

-(void)SettingShareView{
    CGFloat screenWidth = SCREEN_WIDTH;
    
    CGFloat scaleX = 0.1;
    CGFloat scaleY = 0.08;
    userInfo *user = [userInfo shareClass];
    if (user.WeChatInstalled && user.QQInstalled) {
        maxScaleY = 0.7;
    }else{
        maxScaleY = 0.4;
    }
    shareViewFull = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, SCREEN_HEIGHT)];
    [shareViewFull setAlpha:0];
    [shareViewFull setBackgroundColor:[UIColor colorWithRed:0.125 green:0.121 blue:0.164 alpha:0.8]];
    [shareViewFull addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeShareView)]];
    shareView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, screenWidth, screenWidth*maxScaleY)];
    [shareView setBackgroundColor:[UIColor colorWithRed:0.125 green:0.121 blue:0.164 alpha:0.85]];
    if (user.WeChatInstalled) {
        UIButton *wechatButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*0.1, screenWidth*0.08, screenWidth*0.18, screenWidth*0.18)];
        [wechatButton setImage:[UIImage imageNamed:Image_wechatImage] forState:UIControlStateNormal];
        [wechatButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [wechatButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [wechatButton setImage:[UIImage imageNamed:Image_wechatImage] forState:UIControlStateHighlighted];
        [wechatButton addTarget:self action:@selector(shareWeChat) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:wechatButton];
        UILabel *weiChatLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*0.1, screenWidth*0.26, screenWidth*0.18, 20)];
        weiChatLabel.text = @"微 信";
        weiChatLabel.textAlignment = NSTextAlignmentCenter;
        [weiChatLabel setFont:[UIFont systemFontOfSize:12]];
        weiChatLabel.textColor =  Color_line_2;
        [shareView addSubview:weiChatLabel];
        UIButton *timeLineButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*0.41, screenWidth*0.08, SCREEN_WIDTH*0.18, SCREEN_WIDTH*0.18)];
        [timeLineButton setImage:[UIImage imageNamed:Image_momentImage] forState:UIControlStateNormal];
        [timeLineButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [timeLineButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [timeLineButton setImage:[UIImage imageNamed:Image_momentImage] forState:UIControlStateHighlighted];
        [timeLineButton addTarget:self action:@selector(shareTimeLine) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:timeLineButton];
        
        UILabel *timeLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*0.41, screenWidth*0.26, screenWidth*0.18, 20)];
        timeLineLabel.text = @"朋友圈";
        timeLineLabel.textAlignment = NSTextAlignmentCenter;
        [timeLineLabel setFont:[UIFont systemFontOfSize:12]];
        timeLineLabel.textColor =  Color_line_2;
        [shareView addSubview:timeLineLabel];
        scaleX = 0.72;
    }
    
    
    UIButton *weiboButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*0.08, SCREEN_WIDTH*0.18, SCREEN_WIDTH*0.18)];
    [weiboButton setImage:[UIImage imageNamed:Image_weiboImage] forState:UIControlStateNormal];
    [weiboButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
    [weiboButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
    [weiboButton setImage:[UIImage imageNamed:Image_weiboImage] forState:UIControlStateHighlighted];
    [weiboButton addTarget:self action:@selector(shareWeiBo) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:weiboButton];
    UILabel *weiBoLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*0.26, screenWidth*0.18, 20)];
    weiBoLabel.text = @"微 博";
    weiBoLabel.textAlignment = NSTextAlignmentCenter;
    [weiBoLabel setFont:[UIFont systemFontOfSize:12]];
    weiBoLabel.textColor = Color_line_2;
    [shareView addSubview:weiBoLabel];
    if (user.WeChatInstalled) {
        scaleY = 0.39;
        scaleX = 0.1;
    }else{
        scaleX = 0.41;
    }
    if (user.QQInstalled) {
        UIButton *QQButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*scaleY, screenWidth*0.18, screenWidth*0.18)];
        [QQButton setImage:[UIImage imageNamed:Image_qqImage] forState:UIControlStateNormal];
        [QQButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [QQButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [QQButton setImage:[UIImage imageNamed:Image_qqImage] forState:UIControlStateHighlighted];
        [QQButton addTarget:self action:@selector(shareQQ) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:QQButton];
        
        UILabel *QQLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*(scaleY+0.18), screenWidth*0.18, 20)];
        QQLabel.text = @"QQ";
        QQLabel.textAlignment = NSTextAlignmentCenter;
        [QQLabel setFont:[UIFont systemFontOfSize:12]];
        QQLabel.textColor = Color_line_2;
        [shareView addSubview:QQLabel];
        
        UIButton *qqZoneButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*(scaleX+0.31), screenWidth*scaleY, screenWidth*0.18, screenWidth*0.18)];
        [qqZoneButton setImage:[UIImage imageNamed:Image_q_zoneImage] forState:UIControlStateNormal];
        [qqZoneButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [qqZoneButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [qqZoneButton setImage:[UIImage imageNamed:Image_q_zoneImage] forState:UIControlStateHighlighted];
        [qqZoneButton addTarget:self action:@selector(shareQQZone) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:qqZoneButton];
        
        UILabel *QQZoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*(scaleX+0.31), screenWidth*(scaleY+0.18), screenWidth*0.18, 20)];
        QQZoneLabel.text = @"QQ空间";
        QQZoneLabel.textAlignment = NSTextAlignmentCenter;
        [QQZoneLabel setFont:[UIFont systemFontOfSize:12]];
        QQZoneLabel.textColor = Color_line_2;
        [shareView addSubview:QQZoneLabel];
        
    }
    
    [shareViewFull addSubview:shareView];
    
    
    
}
-(void)closeShareView{
    [UIView animateWithDuration:0.5 animations:^{
        [shareViewFull setAlpha:0];
        [shareView setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH*maxScaleY)];
    } completion:^(BOOL finished) {
        [shareViewFull removeFromSuperview];
        
    }];
}
-(void) addShareView{
    [self.navigationController.view addSubview:shareViewFull];
    [UIView animateWithDuration:0.3 animations:^{
        [shareViewFull setAlpha:1];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            [shareView setFrame:CGRectMake(0, SCREEN_HEIGHT-SCREEN_WIDTH*maxScaleY, SCREEN_WIDTH, SCREEN_WIDTH*maxScaleY)];
        } ];
    }];
}
- (WBMessageObject *)messageToShare
{
    WBMessageObject *message = [WBMessageObject message];
    
    message.text =[NSString stringWithFormat:@"一起来用Muzzik吧 %@%@",URL_Muzzik_SharePage,shareMuzzik.muzzik_id];
    
    WBImageObject *image = [WBImageObject object];
    image.imageData = UIImageJPEGRepresentation([MuzzikItem convertViewToImage:[MyTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.muzziks indexOfObject:shareMuzzik] inSection:0]]], 1.0);
    message.imageObject = image;
    return message;
}
-(void)shareWeiBo{
    AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = URL_WeiBo_redirectURI;
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare] authInfo:authRequest access_token:myDelegate.wbtoken];
    
    //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    [WeiboSDK sendRequest:request];
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:shareMuzzik.muzzik_id,@"_id",@"weibo",@"channel", nil];
    
    ASIHTTPRequest *requestShare = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
    
    [requestShare addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestShare;
    [requestShare setCompletionBlock :^{
        
        shareMuzzik.shares = [NSString stringWithFormat:@"%d",[shareMuzzik.shares intValue]+1];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:shareMuzzik];
    }];
    [requestShare setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [requestShare startAsynchronous];
}
-(void) shareQQ{
    TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:ID_QQ_APP
                                                         andDelegate:nil];
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_Muzzik_SharePage,shareMuzzik.muzzik_id];
    //分享图预览图URL地址
    NSString *previewImageUrl = @"http://muzzik-image.qiniudn.com/FieqckeQDGWACSpDA3P0aDzmGcB6";
    //音乐播放的网络流媒体地址
    QQApiAudioObject *audioObj =[QQApiAudioObject objectWithURL:[NSURL URLWithString:url]
                                                          title:shareMuzzik.music.name description:shareMuzzik.music.artist previewImageURL:[NSURL URLWithString:previewImageUrl]];
    //设置播放流媒体地址
    audioObj.flashURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_audio,shareMuzzik.music.key]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObj];
    //将内容分享到qq
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
    //将被容分享到qzone
    //QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:shareMuzzik.muzzik_id,@"_id",@"qq",@"channel", nil];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
    
    [request addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        
        shareMuzzik.shares = [NSString stringWithFormat:@"%d",[shareMuzzik.shares intValue]+1];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:shareMuzzik];
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [request startAsynchronous];
    
    
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
-(void) shareQQZone{
    TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:ID_QQ_APP
                                                         andDelegate:nil];
    //分享跳转URL
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_Muzzik_SharePage,shareMuzzik.muzzik_id];
    //分享图预览图URL地址
    NSString *previewImageUrl = [NSString stringWithFormat:@"%@%@",BaseURL_image,shareMuzzik.MuzzikUser.avatar];
    //音乐播放的网络流媒体地址
    NSString *flashURL = [NSString stringWithFormat:@"%@%@",BaseURL_audio,shareMuzzik.music.key];
    QQApiAudioObject *audioObj =[QQApiAudioObject objectWithURL:[NSURL URLWithString:url]
                                                          title:@"我在Muzzik上分享了首歌" description:[NSString stringWithFormat:@"%@  %@",shareMuzzik.music.name,shareMuzzik.music.artist] previewImageURL:[NSURL URLWithString:previewImageUrl]];
    //设置播放流媒体地址
    audioObj.flashURL = [NSURL URLWithString:flashURL] ;
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObj];
    //将内容分享到qq
    //QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    //将被容分享到qzone
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    
    [self handleSendResult:sent];
    
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:shareMuzzik.muzzik_id,@"_id",@"qzone",@"channel", nil];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
    
    [request addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        
        shareMuzzik.shares = [NSString stringWithFormat:@"%d",[shareMuzzik.shares intValue]+1];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:shareMuzzik];
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [request startAsynchronous];
    
}
-(void) shareTimeLine{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app sendMusicContentByMuzzik:shareMuzzik scen:1 image:shareImage];
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:shareMuzzik.muzzik_id,@"_id",@"moment",@"channel", nil];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
    
    [request addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        
        shareMuzzik.shares = [NSString stringWithFormat:@"%d",[shareMuzzik.shares intValue]+1];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:shareMuzzik];
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [request startAsynchronous];
}

-(void) shareWeChat{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app sendMusicContentByMuzzik:shareMuzzik scen:0 image:shareImage];
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:shareMuzzik.muzzik_id,@"_id",@"wechat",@"channel", nil];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
    
    [request addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        
        shareMuzzik.shares = [NSString stringWithFormat:@"%d",[shareMuzzik.shares intValue]+1];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:shareMuzzik];
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [request startAsynchronous];
}

-(void)dataSourceMuzzikUpdate:(NSNotification *)notify{
    muzzik *tempMuzzik = (muzzik *)notify.object;
    if ([MuzzikItem checkMutableArray:self.muzziks isContainMuzzik:tempMuzzik]) {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[self.muzziks indexOfObject:tempMuzzik] inSection:0];
        [MyTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

-(void)dataSourceUserUpdate:(NSNotification *)notify{
    MuzzikUser *user = notify.object;
    if ([[_profileDic objectForKey:@"_id"] isEqualToString:user.user_id]) {
        [_profileDic setObject:[NSNumber numberWithBool:user.isFans ]forKey:@"isFans"];
        [_profileDic setObject:[NSNumber numberWithBool:user.isFollow ]forKey:@"isFollow"];
        if ([[_profileDic objectForKey:@"isFollow"] boolValue] &&[[_profileDic objectForKey:@"isFans"] boolValue]) {
            [_attentionButton setImage:[UIImage imageNamed:Image_profilefolloweacherother] forState:UIControlStateNormal];
            [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-85, 16, 65, 23)];
        }else if([[_profileDic objectForKey:@"isFollow"] boolValue]){
            [_attentionButton setImage:[UIImage imageNamed:Image_profilefollowed] forState:UIControlStateNormal];
            [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-75, 16, 55, 23)];
        }else{
            [_attentionButton setImage:[UIImage imageNamed:Image_profilefollow] forState:UIControlStateNormal];
            [_attentionButton setFrame:CGRectMake(SCREEN_WIDTH-65, 16, 45, 23)];
        }
    }
}
-(void)rightBtnAction:(UIButton *)sender{
    UIActionSheet *sheet;
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报", nil];
    }else{
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"请先登录，再举报Ta", nil];
    }
    
    [sheet showInView:self.view.window];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex==actionSheet.cancelButtonIndex){
        return;
    }else if (buttonIndex == 0){
        userInfo *user = [userInfo shareClass];
        if ([user.token length]>0) {
            repostVC *informvc = [[repostVC alloc] init];
            informvc.informString = [NSString stringWithFormat:@"user id:%@",self.uid];
            [self.navigationController pushViewController:informvc animated:YES];
        }else{
            [userInfo checkLoginWithVC:self];
        }
        
    }
    
    
}

@end
