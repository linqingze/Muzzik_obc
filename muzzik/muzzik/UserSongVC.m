//
//  UserSongVC.m
//  muzzik
//
//  Created by muzzik on 15/5/13.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "UserSongVC.h"
#import "SongListCell.h"
#import "MessageStepViewController.h"
#import "DetaiMuzzikVC.h"
@interface UserSongVC ()<UITableViewDataSource,UITableViewDelegate,CellDelegate>{
    UITableView *songTableView;
    NSString *lastId;
}
@property (nonatomic,retain) NSMutableArray *muzziks;
@end

@implementation UserSongVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"歌单" leftBtn:Constant_backImage rightBtn:0];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    self.muzziks = [NSMutableArray array];
    songTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:songTableView];
    songTableView.delegate = self;
    songTableView.dataSource = self;
    songTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self followScrollView:songTableView];
    [songTableView registerClass:[SongListCell class] forCellReuseIdentifier:@"SongListCell"];
    if ([self.uid length]==0) {
        self.uid = [userInfo shareClass].uid;
    }
    [self loadDataMessage];
    // Do any additional setup after loading the view.
    
    [songTableView addFooterWithTarget:self action:@selector(refreshFooter)];
}


-(void)loadDataMessage{
    
    
    ASIHTTPRequest *request= [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,self.uid]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            NSMutableArray *songarray = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *localMuzzik in songarray) {
                BOOL isContained = NO;
                for (muzzik *originMuzzik in self.muzziks) {
                    if ([originMuzzik.music.key isEqualToString:localMuzzik.music.key]) {
                        isContained = YES;
                        break;
                    }
                }
                if (!isContained) {
                    [self.muzziks addObject:localMuzzik];
                }
            }
            
            lastId = [dic objectForKey:@"tail"];
            [songTableView reloadData];
            if ([[dic objectForKey:@"muzziks"] count]<1 ) {
                [songTableView removeFooter];
            }
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
        if (![[weakrequest responseString] length]>0) {
            [self networkErrorShow];
        }
    }];
    [request startAsynchronous];

    
    
}
-(void)reloadDataSource{
    [super reloadDataSource];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadDataMessage];
    });
    
    
}


- (void)refreshFooter
{
    
    // [self updateSomeThing];
    ASIHTTPRequest *request= [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,self.uid]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    
    
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            if ([[dic allKeys] containsObject:@"tail"]) {
                lastId = [dic objectForKey:@"tail"];
            }else{
                lastId = @"";
            }
            
            muzzik *muzzikToy = [muzzik new];
            NSMutableArray *songarray = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *localMuzzik in songarray) {
                BOOL isContained = NO;
                for (muzzik *originMuzzik in self.muzziks) {
                    if ([originMuzzik.music.name isEqualToString:localMuzzik.music.name] && [originMuzzik.music.artist isEqualToString:localMuzzik.music.artist]) {
                        isContained = YES;
                        break;
                    }
                }
                if (!isContained) {
                    [self.muzziks addObject:localMuzzik];
                }
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [songTableView reloadData];
                [songTableView footerEndRefreshing];
                if ([[dic objectForKey:@"muzziks"] count]<1 ) {
                    [songTableView removeFooter];
                }
            });
            
        }
    }];
    [request setFailedBlock:^{
        [songTableView footerEndRefreshing];
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.muzziks.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     SongListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongListCell" forIndexPath:indexPath];
    muzzik *tempMuzzik = self.muzziks[indexPath.row];
    Globle *glob = [Globle shareGloble];
    cell.timeLabel.text = [MuzzikItem transtromTime:tempMuzzik.date];
    cell.songName.text = tempMuzzik.music.name;
    cell.Artist.text = tempMuzzik.music.artist;
    cell.cellMuzzik = tempMuzzik;
    cell.delegate = self;
    BOOL isplaying = NO;
    if ([tempMuzzik.muzzik_id isEqualToString:[musicPlayer shareClass].localMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
        isplaying = YES;
    }else{
        isplaying = NO;
    }
    UIColor *color;
    if (isplaying) {
        if ([tempMuzzik.color longLongValue] == 1) {
            color =Color_Action_Button_1;
            if (!glob.isPause) {
                [cell.playButton setImage:[UIImage imageNamed:Image_stopredImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_playredImage] forState:UIControlStateNormal];
            }
            [cell.CommentButton setImage:[UIImage imageNamed:Image_songlistredpostweetImage] forState:UIControlStateNormal];
            [cell.timeImage setImage:[UIImage imageNamed:Image_timelineredImage]];
            [cell.songName setTextColor:color];
            [cell.Artist setTextColor:color];
            
        }
        else if([tempMuzzik.color longLongValue] == 2){
            //bluelikeImage
            color = Color_Action_Button_2;
            if (!glob.isPause) {
                [cell.playButton setImage:[UIImage imageNamed:Image_stopyellowImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_playyellowImage] forState:UIControlStateNormal];
            }
            [cell.CommentButton setImage:[UIImage imageNamed:Image_songlistyellowpostweetImage] forState:UIControlStateNormal];
            [cell.timeImage setImage:[UIImage imageNamed:Image_timelineyellowImage]];
            [cell.songName setTextColor:color];
            [cell.Artist setTextColor:color];
        }
        else{
            color = Color_Action_Button_3;
            if (!glob.isPause) {
                [cell.playButton setImage:[UIImage imageNamed:Image_stopblueImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_playblueImage] forState:UIControlStateNormal];
            }
            [cell.CommentButton setImage:[UIImage imageNamed:Image_songlistbluepostweetImage] forState:UIControlStateNormal];
            [cell.timeImage setImage:[UIImage imageNamed:Image_timelineblueImage]];
            [cell.songName setTextColor:color];
            [cell.Artist setTextColor:color];
        }
    }else{
        [cell.songName setTextColor:Color_Text_2];
        [cell.Artist setTextColor:Color_Text_2];
        [cell.CommentButton setImage:[UIImage imageNamed:Image_songlistpostweetImage] forState:UIControlStateNormal];
        [cell.playButton setImage:[UIImage imageNamed:Image_playgreyImage] forState:UIControlStateNormal];
        if ([tempMuzzik.color longLongValue] == 1) {
            [cell.timeImage setImage:[UIImage imageNamed:Image_timelineredImage]];
        }
        else if([tempMuzzik.color longLongValue] == 2){
            [cell.timeImage setImage:[UIImage imageNamed:Image_timelineyellowImage]];
        }
        else{
             [cell.timeImage setImage:[UIImage imageNamed:Image_timelineblueImage]];
        }
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.muzziks[indexPath.row] isKindOfClass:[muzzik class]]) {
        muzzik *tempMuzzik = self.muzziks[indexPath.row];
        DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
        detail.muzzik_id = tempMuzzik.muzzik_id;
        [self.navigationController pushViewController:detail animated:YES];
    }
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
-(void)playSongWithSongModel:(muzzik *)songModel{
    MuzzikRequestCenter *center = [MuzzikRequestCenter shareClass];
    center.subUrlString = [NSString stringWithFormat:@"api/user/%@/muzziks",self.uid];
    center.requestDic = [NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,Limit_Constant,Parameter_Limit, nil];
    center.isPage = NO;
    center.singleMusic = NO;
    center.MuzzikType = Type_Muzzik_Muzzik;
    center.lastId = lastId;
    
    musicPlayer *player = [musicPlayer shareClass];
    player.listType = TempList;
    player.MusicArray = [self.muzziks mutableCopy];
    NSString *titleName;
    if ([self.uid isEqualToString:[userInfo shareClass].uid]) {
        titleName = @"我的歌单";
    }else{
        titleName = [NSString stringWithFormat:@"%@的歌单",self.userName];
    }
    [player playSongWithSongModel:songModel Title:titleName];
    [MuzzikItem SetUserInfoWithMuzziks: self.muzziks title:Constant_userInfo_temp description:titleName];
}

-(void)newMuzzik:(muzzik *)localMzzik{
    MuzzikObject *mobject = [MuzzikObject shareClass];
    
    mobject.music = localMzzik.music;
   // [MuzzikItem getLyricByMusic:localMzzik.music];
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        user.poController = self;
        MessageStepViewController *messagebv = [[MessageStepViewController alloc] init];
        [self.navigationController pushViewController:messagebv animated:YES];
    }else{
        [userInfo checkLoginWithVC:self];
    }
    
    
}

-(void)playnextMuzzikUpdate{
    [songTableView reloadData];
}
@end
