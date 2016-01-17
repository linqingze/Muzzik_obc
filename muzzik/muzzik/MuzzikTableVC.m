//
//  MuzzikTableVC.m
//  muzzik
//
//  Created by muzzik on 15/5/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "MuzzikTableVC.h"
#import "UIImageView+WebCache.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NormalCell.h"
#import "TopicHeaderView.h"
#import "appConfiguration.h"
#import <MediaPlayer/MediaPlayer.h>
#import "userInfo.h"
#import "TTTAttributedLabel.h"
#import "ChooseMusicVC.h"
#import "LoginViewController.h"
#import "UIButton+WebCache.h"
#import "showUserVC.h"
#import "NormalNoCardCell.h"
#import "DetaiMuzzikVC.h"
#import "MuzzikCard.h"
#import "MuzzikNoCardCell.h"
#import "userDetailInfo.h"
#import "TopicDetail.h"
#import "MuzzikShareView.h"
#import <TencentOpenAPI/TencentOAuth.h>
@interface MuzzikTableVC (){
    UIImage *shareImage;
    int numberOfProducts;
    BOOL needsLoad;
    UITableView *MytableView;
    BOOL isPlaying;
    UIButton *newButton;
    NSString *lastId;
    NSString *headId;
    int page;
    NSMutableDictionary *RefreshDic;
    NSMutableDictionary *ReFreshPoImageDic;
    //shareView
   MuzzikShareView *muzzikShareView;
}
@property(nonatomic,retain) muzzik *repostMuzzik;
@end

@implementation MuzzikTableVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.muzziks = [NSMutableArray array];
    if ([self.requstType  isEqualToString:@"moved"]) {
        [self initNagationBar:@"喜欢的Muzzik" leftBtn:Constant_backImage rightBtn:0];
        MytableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    }else{
        [self initNagationBar:@"我的Muzzik" leftBtn:Constant_backImage rightBtn:0];
        MytableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-94)];
    }
    page = 2;
    RefreshDic = [NSMutableDictionary dictionary];
    ReFreshPoImageDic = [NSMutableDictionary dictionary];
    self.uid = [userInfo shareClass].uid;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMuzzik:) name:String_Muzzik_Delete object:nil];
    if ([self.requstType isEqualToString:@"moved"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceUserUpdate:) name:String_UserDataSource_update object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceMuzzikUpdate:) name:String_MuzzikDataSource_update object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [MytableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    MytableView.dataSource = self;
    MytableView.delegate = self;
    [self.view addSubview:MytableView];
    [MytableView registerClass:[NormalCell class] forCellReuseIdentifier:@"NormalCell"];
    [MytableView registerClass:[NormalNoCardCell class] forCellReuseIdentifier:@"NormalNoCardCell"];
    [MytableView registerClass:[MuzzikCard class] forCellReuseIdentifier:@"MuzzikCard"];
    [MytableView registerClass:[MuzzikNoCardCell class] forCellReuseIdentifier:@"MuzzikNoCardCell"];
    [self reloadMuzzikSource];
    muzzikShareView = [[MuzzikShareView alloc] initMyShare];
    [self followScrollView:MytableView];
    [MytableView addHeaderWithTarget:self action:@selector(refreshHeader)];
    [MytableView addFooterWithTarget:self action:@selector(refreshFooter)];
}
- (void)refreshHeader
{
    // [self updateSomeThing];
    ASIHTTPRequest *request;
    if ([self.requstType  isEqualToString:@"moved"]) {
        request= [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :@"http://117.121.26.174:8000/api/user/movedMuzzik"]];
    }
    else{
        request= [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,self.uid]]];
    }
    
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:Limit_Constant forKey:Parameter_Limit] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            page = 1;
            muzzik *muzzikToy = [muzzik new];
            NSArray *array;
            if ([self.requstType isEqualToString:@"moved"]) {
                array = [muzzikToy makeMuzziksNeedsSetUserByMuzzikArray:[dic objectForKey:@"muzziks"]];
            }else{
                array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            }

            
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
            if ([self.requstType isEqualToString:@"moved"]) {
                [MuzzikItem SetUserInfoWithMuzziks:self.muzziks title:Constant_userInfo_move description:[NSString stringWithFormat:@"喜欢列表"]];
            }
            else{
                [MuzzikItem SetUserInfoWithMuzziks:self.muzziks title:Constant_userInfo_own description:[NSString stringWithFormat:@"我的Muzzik"]];
            }
            
            lastId = [dic objectForKey:@"tail"];
            headId = [dic objectForKey:Parameter_from];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MytableView reloadData];
                [MytableView headerEndRefreshing];
            });
            
        }
    }];
    [request setFailedBlock:^{
        [MytableView headerEndRefreshing];
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
}

- (void)refreshFooter
{
    
    // [self updateSomeThing];
    ASIHTTPRequest *request;
    if ([self.requstType  isEqualToString:@"moved"]) {
        request= [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :@"http://117.121.26.174:8000/api/user/movedMuzzik"]];
        [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:page],Parameter_page,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    }
    else{
        request= [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,self.uid]]];
        [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    }
    
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            page++;
            muzzik *muzzikToy = [muzzik new];
            NSArray *array;
            if ([self.requstType isEqualToString:@"moved"]) {
                array = [muzzikToy makeMuzziksNeedsSetUserByMuzzikArray:[dic objectForKey:@"muzziks"]];
            }else{
                array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            }
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
            if ([self.requstType isEqualToString:@"moved"]) {
                [MuzzikItem SetUserInfoWithMuzziks:self.muzziks title:Constant_userInfo_move description:[NSString stringWithFormat:@"喜欢列表"]];
            }else{
                [MuzzikItem SetUserInfoWithMuzziks:self.muzziks title:Constant_userInfo_own description:[NSString stringWithFormat:@"我的Muzzik"]];
            }
            lastId = [dic objectForKey:@"tail"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MytableView reloadData];
                [MytableView footerEndRefreshing];
                if ([[dic objectForKey:@"muzziks"] count]<1 ) {
                    [MytableView removeFooter];
                }
            });
            
        }
    }];
    [request setFailedBlock:^{
        [MytableView footerEndRefreshing];
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
}
-(void)viewDidCurrentView{
    if ([self.requstType  length]>0) {
        [self followScrollView:MytableView];
    }else{
        
        [self.keeper followScrollView:MytableView];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    

    
    // MytableView add
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark <UITableViewDataSource>

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
    
    
    if ([tempMuzzik.type isEqualToString:@"normal"] ||[tempMuzzik.type isEqualToString:@"repost"]) {
        
        TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(75, 0, SCREEN_WIDTH-110, 500)];
        [label setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
        [label setText:tempMuzzik.message];
        CGFloat textHeight = [MuzzikItem heightForLabel:label WithText:label.text];
        if (textHeight>limitHeight) {
            if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length]>0) {
                return (int)(260+limitHeight+SCREEN_WIDTH*3/4)+8;
            }else{
                return 248+limitHeight;
            }
            
        }else{
            if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length]>0) {
                return (int)(260+textHeight+SCREEN_WIDTH*3/4)-2;
            }else{
                return 248+(int)textHeight;
            }
        }
    }else if([tempMuzzik.type isEqualToString:@"muzzikCard"]){
        TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(75, 0, SCREEN_WIDTH-96, 500)];
        [label setText:tempMuzzik.message];
        [label setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
        CGFloat textHeight = [MuzzikItem heightForLabel:label WithText:label.text];
        if (textHeight>limitHeight) {
            if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length]>0) {
                return SCREEN_WIDTH+limitHeight+80;
            }else{
                return limitHeight+190;
            }
        }
        else{
            if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length]>0) {
                return (int)(SCREEN_WIDTH+textHeight+80);
            }else{
                return textHeight+190;
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
        if ([self.requstType length]>0) {
            [self.navigationController pushViewController:detail animated:YES];
        }else{
            [self.keeper.navigationController pushViewController:detail animated:YES];
        }
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    userInfo *user = [userInfo shareClass];
    Globle *glob = [Globle shareGloble];
    muzzik *tempMuzzik = [self.muzziks objectAtIndex:indexPath.row];
    if ([tempMuzzik.type isEqualToString:@"repost"] || [tempMuzzik.type isEqualToString:@"normal"] || [tempMuzzik.type isEqualToString:@"muzzikCard"])
    {
        if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length] == 0) {
            if ([tempMuzzik.type isEqualToString:@"repost"] ){
                NormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
                cell.songModel = tempMuzzik;
                
                if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                if ([self.requstType isEqualToString:@"moved"]) {
                    cell.indexpath = indexPath;
                    if ([[user.followDic allKeys] containsObject:tempMuzzik.MuzzikUser.user_id]) {
                        if (([[user.followDic objectForKey:tempMuzzik.MuzzikUser.user_id] integerValue] ^ 2) <2 || [user.uid isEqualToString:tempMuzzik.MuzzikUser.user_id]) {
                            cell.isFollow = YES;
                        }else{
                            cell.isFollow = NO;
                        }
                    }else{
                        cell.isFollow = NO;
                    }
                }
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                if (tempMuzzik.isprivate ) {
                    [cell.privateImage setHidden:NO];
                    [cell.userName sizeToFit];
                    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+2, cell.userName.frame.origin.y, 20, 20)];
                }else{
                    [cell.privateImage setHidden:YES];
                    [cell.userName setFrame:CGRectMake(80, cell.userName.frame.origin.y, SCREEN_WIDTH-120, 20)];
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
                [cell.musicPlayView setFrame:CGRectMake(0, (int)floor(cell.muzzikMessage.frame.origin.y+8+cell.muzzikMessage.bounds.size.height), SCREEN_WIDTH, cell.musicPlayView.frame.size.height)];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.repostDate];
                [cell.timeStamp sizeToFit];
                [cell.timeImage setFrame:CGRectMake(CGRectGetMaxX(cell.timeStamp.frame)+3, cell.timeImage.frame.origin.y, cell.timeImage.frame.size.width, cell.timeImage.frame.size.height)];
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
            else if([tempMuzzik.type isEqualToString:@"normal"]){
                NormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
                cell.songModel = tempMuzzik;
                if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                if ([self.requstType isEqualToString:@"moved"]) {
                    cell.indexpath = indexPath;
                    if ([[user.followDic allKeys] containsObject:tempMuzzik.MuzzikUser.user_id]) {
                        if (([[user.followDic objectForKey:tempMuzzik.MuzzikUser.user_id] integerValue] ^ 2) <2 || [user.uid isEqualToString:tempMuzzik.MuzzikUser.user_id]) {
                            cell.isFollow = YES;
                        }else{
                            cell.isFollow = NO;
                        }
                    }else{
                        cell.isFollow = NO;
                    }
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
                    [cell.userName setFrame:CGRectMake(80, cell.userName.frame.origin.y, SCREEN_WIDTH-120, 20)];
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
                [cell.musicPlayView setFrame:CGRectMake(0,(int) floor(cell.muzzikMessage.frame.origin.y+8+cell.muzzikMessage.bounds.size.height), SCREEN_WIDTH, cell.musicPlayView.frame.size.height)];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                [cell.timeStamp sizeToFit];
                [cell.timeImage setFrame:CGRectMake(CGRectGetMaxX(cell.timeStamp.frame)+3, cell.timeImage.frame.origin.y, cell.timeImage.frame.size.width, cell.timeImage.frame.size.height)];
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
            else{
                MuzzikNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MuzzikNoCardCell" forIndexPath:indexPath];
                cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
                if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                
                cell.delegate = self;
                cell.cardTitle.text = tempMuzzik.title;
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                        [cell.userImage setAlpha:0];
                        [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                        [UIView animateWithDuration:0.5 animations:^{
                            [cell.userImage setAlpha:1];
                        }];
                    }
                    
                    
                }];
                cell.muzzikMessage.delegate = self;
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.index = indexPath.row;
                cell.isMoved = tempMuzzik.ismoved;
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0, (int)floor(cell.muzzikMessage.frame.origin.y+cell.muzzikMessage.frame.size.height+12),cell.musicPlayView.frame.size.width, (int)floor(cell.musicPlayView.frame.size.height))];
                [cell.cardView setFrame:CGRectMake(16, 20, SCREEN_WIDTH-32, (int)floor(cell.muzzikMessage.frame.origin.y+cell.muzzikMessage.frame.size.height+80))];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                return cell;
                
            }
        }else{
            if ([tempMuzzik.type isEqualToString:@"repost"] ){
                NormalNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalNoCardCell" forIndexPath:indexPath];
                cell.songModel = tempMuzzik;
                if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                if ([self.requstType isEqualToString:@"moved"]) {
                    cell.indexpath = indexPath;
                    if ([[user.followDic allKeys] containsObject:tempMuzzik.MuzzikUser.user_id]) {
                        if (([[user.followDic objectForKey:tempMuzzik.MuzzikUser.user_id] integerValue] ^ 2) <2 || [user.uid isEqualToString:tempMuzzik.MuzzikUser.user_id]) {
                            cell.isFollow = YES;
                        }else{
                            cell.isFollow = NO;
                        }
                    }else{
                        cell.isFollow = NO;
                    }
                }

                cell.userName.text = tempMuzzik.MuzzikUser.name;
                if (tempMuzzik.isprivate ) {
                    [cell.privateImage setHidden:NO];
                    [cell.userName sizeToFit];
                    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+2, cell.userName.frame.origin.y, 20, 20)];
                }else{
                    [cell.privateImage setHidden:YES];
                    [cell.userName setFrame:CGRectMake(80, cell.userName.frame.origin.y, SCREEN_WIDTH-120, 20)];
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
                [cell.musicPlayView setFrame:CGRectMake(0,(int)floor( cell.muzzikMessage.frame.origin.y+8+cell.muzzikMessage.bounds.size.height), SCREEN_WIDTH, (int)cell.musicPlayView.frame.size.height)];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.repostDate];
                [cell.timeStamp sizeToFit];
                [cell.timeImage setFrame:CGRectMake(CGRectGetMaxX(cell.timeStamp.frame)+3, cell.timeImage.frame.origin.y, cell.timeImage.frame.size.width, cell.timeImage.frame.size.height)];
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
            else if([tempMuzzik.type isEqualToString:@"normal"]){
                NormalNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalNoCardCell" forIndexPath:indexPath];
                cell.songModel = tempMuzzik;
                if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                if ([self.requstType isEqualToString:@"moved"]) {
                    cell.indexpath = indexPath;
                    if ([[user.followDic allKeys] containsObject:tempMuzzik.MuzzikUser.user_id]) {
                        if (([[user.followDic objectForKey:tempMuzzik.MuzzikUser.user_id] integerValue] ^ 2) <2 || [user.uid isEqualToString:tempMuzzik.MuzzikUser.user_id]) {
                            cell.isFollow = YES;
                        }else{
                            cell.isFollow = NO;
                        }
                    }else{
                        cell.isFollow = NO;
                    }
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
                    [cell.userName setFrame:CGRectMake(80, cell.userName.frame.origin.y, SCREEN_WIDTH-120, 20)];
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
                [cell.musicPlayView setFrame:CGRectMake(0, (int)floor(cell.muzzikMessage.frame.origin.y+8+cell.muzzikMessage.bounds.size.height), SCREEN_WIDTH, floor(cell.musicPlayView.frame.size.height))];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                [cell.timeStamp sizeToFit];
                [cell.timeImage setFrame:CGRectMake(CGRectGetMaxX(cell.timeStamp.frame)+3, cell.timeImage.frame.origin.y, cell.timeImage.frame.size.width, cell.timeImage.frame.size.height)];
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
                MuzzikCard *cell = [tableView dequeueReusableCellWithIdentifier:@"MuzzikCard" forIndexPath:indexPath];
                cell.songModel = [self.muzziks objectAtIndex:indexPath.row];
                if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                cell.delegate = self;
                cell.cardTitle.text = tempMuzzik.title;
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                        [cell.userImage setAlpha:0];
                        [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                        [UIView animateWithDuration:0.5 animations:^{
                            [cell.userImage setAlpha:1];
                        }];
                    }
                    
                    
                }];
                
                [cell.muzzikCardImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.image,Image_Size_Big]] placeholderImage:[UIImage imageNamed:Image_placeholdImage] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (![[ReFreshPoImageDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                        [cell.muzzikCardImage setAlpha:0];
                        [ReFreshPoImageDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                        [UIView animateWithDuration:0.5 animations:^{
                            [cell.muzzikCardImage setAlpha:1];
                        }];
                    }
                    
                    
                }];
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.index = indexPath.row;
                cell.isMoved = tempMuzzik.ismoved;
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                
                
                cell.muzzikMessage.delegate = self;
                cell.RepostID = tempMuzzik.repostID;
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0, (int)(cell.muzzikMessage.frame.origin.y+cell.muzzikMessage.frame.size.height+12), SCREEN_WIDTH-16, cell.musicPlayView.frame.size.height)];
                [cell.cardView setFrame:CGRectMake(16, 20, SCREEN_WIDTH-32,(int) (cell.muzzikMessage.frame.origin.y+cell.muzzikMessage.frame.size.height+80))];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                return cell;
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
-(void)deleteMuzzik:(NSNotification *)notify{
    muzzik *localMzzik = notify.object;
    for (muzzik *tempMuzzik in self.muzziks) {
        if ([tempMuzzik.muzzik_id isEqualToString:localMzzik.muzzik_id]) {
            [self.muzziks removeObject:tempMuzzik];
            [MytableView reloadData];
            break;
        }
    }
    
}

-(void)moveMuzzik:(muzzik *)tempMuzzik{
    
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
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        if ([self.requstType  length]>0) {
            [self.navigationController pushViewController:loginVC animated:YES];
        }else{
            [self.keeper.navigationController pushViewController:loginVC animated:YES];
        }
        
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
        [userInfo checkLoginWithVC:self.keeper];
    }
   
    
    
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // do stuff
        if (!self.repostMuzzik.isReposted) {
            
            self.repostMuzzik.isReposted = YES;
            self.repostMuzzik.reposts = [NSString stringWithFormat:@"%ld",[self.repostMuzzik.reposts integerValue]+1];
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
            self.repostMuzzik.reposts = [NSString stringWithFormat:@"%ld",[self.repostMuzzik.reposts integerValue]-1];
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


-(void)reloadMuzzikSource{
    NSData *data;
    userInfo *user = [userInfo shareClass];
    if ([self.requstType isEqualToString:@"moved"]) {
        data = [MuzzikItem getDataFromLocalKey: [NSString stringWithFormat:@"Persistence_moved_data%@",user.token]];
    }else{
        data = [MuzzikItem getDataFromLocalKey: [NSString stringWithFormat:@"Persistence_own_data%@",user.token]];
    }
    NSDictionary *dic;
    if (data) {
        dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
    if (dic) {
        muzzik *muzzikToy = [muzzik new];
        NSArray *array;
        if ([self.requstType isEqualToString:@"moved"]) {
            array = [muzzikToy makeMuzziksNeedsSetUserByMuzzikArray:[dic objectForKey:@"muzziks"]];
        }else{
            array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
        }
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
        if ([self.requstType isEqualToString:@"moved"]) {
            [MuzzikItem SetUserInfoWithMuzziks:self.muzziks title:Constant_userInfo_move description:[NSString stringWithFormat:@"喜欢列表"]];
        }else{
            [MuzzikItem SetUserInfoWithMuzziks:self.muzziks title:Constant_userInfo_own description:[NSString stringWithFormat:@"我的Muzzik"]];
        }
        lastId = [dic objectForKey:@"tail"];
        headId = [dic objectForKey:Parameter_from];
        [MytableView reloadData];
        
    }
    NSDictionary *requestDic = [NSDictionary dictionaryWithObject:@"20" forKey:Parameter_Limit];
    
    ASIHTTPRequest *request;
    if ([self.requstType  isEqualToString:@"moved"]) {
        request= [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :@"http://117.121.26.174:8000/api/user/movedMuzzik"]];
    }else{
        request= [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,self.uid]]];
  
    }
    [request addBodyDataSourceWithJsonByDic:requestDic Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            [self.muzziks removeAllObjects];
            muzzik *muzzikToy = [muzzik new];
            NSArray *array;
            if ([self.requstType isEqualToString:@"moved"]) {
                array = [muzzikToy makeMuzziksNeedsSetUserByMuzzikArray:[dic objectForKey:@"muzziks"]];
            }else{
                array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            }
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
            if ([self.requstType isEqualToString:@"moved"]) {
                 [MuzzikItem addObjectToLocal:data ForKey:[NSString stringWithFormat:@"Persistence_moved_data%@",user.token]];
                [MuzzikItem SetUserInfoWithMuzziks:self.muzziks title:Constant_userInfo_move description:[NSString stringWithFormat:@"喜欢列表"]];
            }else{
                 [MuzzikItem addObjectToLocal:data ForKey:[NSString stringWithFormat:@"Persistence_own_data%@",user.token]];
                [MuzzikItem SetUserInfoWithMuzziks:self.muzziks title:Constant_userInfo_own description:[NSString stringWithFormat:@"我的Muzzik"]];
            }
            lastId = [dic objectForKey:@"tail"];
            headId = [dic objectForKey:Parameter_from];
            [MytableView reloadData];
            
        }
    }];
    [request setFailedBlock:^{
        if (![[weakrequest responseString] length]>0) {
            [self networkErrorShow];
        }
    }];
    [request startAsynchronous];
}


-(void)reloadDataSource{
    [super reloadDataSource];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadMuzzikSource];
    });
    
    
}

-(void)playnextMuzzikUpdate{
    [MytableView reloadData];
    if (self.isViewLoaded &&self.view.window) {
        [self.keeper updateAnimation];
    }
}
-(void)playSongWithSongModel:(muzzik *)songModel{
    MuzzikRequestCenter *center = [MuzzikRequestCenter shareClass];
    
    
    
    center.singleMusic = NO;
    center.MuzzikType = Type_Muzzik_Muzzik;
    
    
    [MuzzikPlayer shareClass].MusicArray = [self.muzziks mutableCopy];
    if ([self.requstType isEqualToString:@"moved"]) {
        center.isPage = YES;
        center.subUrlString = @"http://117.121.26.174:8000/api/user/movedMuzzik";
        center.requestDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:page],Parameter_page,Limit_Constant,Parameter_Limit, nil];
        center.page = page;
        [MuzzikItem SetUserInfoWithMuzziks:self.muzziks title:Constant_userInfo_move description:[NSString stringWithFormat:@"喜欢列表"]];
        [[MuzzikPlayer shareClass] playSongWithSongModel:songModel Title:@"喜欢列表"];
        [MuzzikPlayer shareClass].listType = MovedList;
    }else{
        center.isPage = NO;
        center.subUrlString = [NSString stringWithFormat:@"api/user/%@/muzziks",self.uid];
        center.requestDic = [NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,Limit_Constant,Parameter_Limit, nil];
        center.lastId = lastId;
        [MuzzikItem SetUserInfoWithMuzziks:self.muzziks title:Constant_userInfo_own description:[NSString stringWithFormat:@"我的Muzzik"]];
        [[MuzzikPlayer shareClass] playSongWithSongModel:songModel Title:@"我的Muzzik列表"];
        [MuzzikPlayer shareClass].listType = ownList;
    }
}

-(void) commentAtMuzzik:(muzzik *)localMuzzik{
    muzzik *tempMuzzik = localMuzzik;
    DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
    detail.muzzik_id = tempMuzzik.muzzik_id;
    detail.showType = Constant_Comment;
    if ([self.requstType length]>0) {
        [self.navigationController pushViewController:detail animated:YES];
    }else{
        [self.keeper.navigationController pushViewController:detail animated:YES];
    }
    
}
-(void) showRepost:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"repost";
    if ([self.requstType  length]>0) {
        [self.navigationController pushViewController:showvc animated:YES];
    }else{
        [self.keeper.navigationController pushViewController:showvc animated:YES];
    }
}
-(void) showShare:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"share";
    if ([self.requstType  length]>0) {
        [self.navigationController pushViewController:showvc animated:YES];
    }else{
        [self.keeper.navigationController pushViewController:showvc animated:YES];
    }
}
-(void)showComment:(muzzik *)localMuzzik{
    muzzik *tempMuzzik = localMuzzik;
    DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
    detail.muzzik_id = tempMuzzik.muzzik_id;
    detail.showType = Constant_showComment;
    if ([self.requstType  length]>0) {
        [self.navigationController pushViewController:detail animated:YES];
    }else{
        [self.keeper.navigationController pushViewController:detail animated:YES];
    }
}

-(void) showMoved:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"moved";
    if ([self.requstType  length]>0) {
        [self.navigationController pushViewController:showvc animated:YES];
    }else{
        [self.keeper.navigationController pushViewController:showvc animated:YES];
    }
}

-(void)userDetail:(NSString *)user_id{
    userInfo *user = [userInfo shareClass];
    if ([user_id isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        home.isPush = YES;
        if ([self.requstType  length]>0) {
            [self.navigationController pushViewController:home animated:YES];
        }else{
            [self.keeper.navigationController pushViewController:home animated:YES];
        }
        
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = user_id;
        if ([self.requstType  length]>0) {
            [self.navigationController pushViewController:detailuser animated:YES];
        }else{
            [self.keeper.navigationController pushViewController:detailuser animated:YES];
        }
    }
    
}

-(NSMutableArray *) searchUsers:(NSString *)message{
    NSString *checkTabel = @"<>,.~!@＠#$¥%％^&*()，。：；;:‘“～  》？《！＃＊……‘“”／/";
    NSMutableArray *array = [NSMutableArray array];
    BOOL GetAt = NO;
    //  || [[message substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"＠"]
    int location = 0;
    for (int i = 0; i<message.length; i++) {
        if ([[message substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"@"]|| [[message substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"＠"]) {
            GetAt = YES;
            location = i;
            continue;
        }else if ([checkTabel rangeOfString:[message substringWithRange:NSMakeRange(i, 1)]].location != NSNotFound && GetAt){
            GetAt = NO;
            [array addObject:[message substringWithRange:NSMakeRange(location, i-location)]];
            
        }else if(i == message.length-1 && GetAt){
            [array addObject:[message substringWithRange:NSMakeRange(location, i-location+1)]];
        }
    }
    
    
    return array;
}

-(void)shareActionWithMuzzik:(muzzik *)localMuzzik image:(UIImage *) image cell:(UITableViewCell *)cell{
    muzzikShareView.cell = cell;
    muzzikShareView.shareImage = image;
    muzzikShareView.shareMuzzik = localMuzzik;
    [muzzikShareView showShareView];
}
-(void)dataSourceMuzzikUpdate:(NSNotification *)notify{
    muzzik *tempMuzzik = (muzzik *)notify.object;
    if ([MuzzikItem checkMutableArray:self.muzziks isContainMuzzik:tempMuzzik]) {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[self.muzziks indexOfObject:tempMuzzik] inSection:0];
        [MytableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}
-(void)dataSourceUserUpdate:(NSNotification *)notify{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MytableView reloadData];
    });
}
@end
