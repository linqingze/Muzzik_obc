//
//  LocalMusicTableViewController.m
//  muzzik
//
//  Created by muzzik on 15/8/14.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "LocalMusicTableViewController.h"
#import "SearchMusicCell.h"
#import "MessageStepViewController.h"
@interface LocalMusicTableViewController ()<searchSource,UIAlertViewDelegate,CellDelegate>{
    NSInteger indexOfMuzzik;
    BOOL isSearch;
    NSString *_searchText;
    NSInteger page;
}
@property(nonatomic,retain)NSMutableArray *LocalMusicArray;
@property(nonatomic,retain)NSMutableArray *searchArray;

@end

@implementation LocalMusicTableViewController

- (void)viewDidLoad {
    page =1;
    [super viewDidLoad];
    self.LocalMusicArray = [NSMutableArray array];
    self.searchArray = [NSMutableArray array];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    [self.tableView registerClass:[SearchMusicCell class] forCellReuseIdentifier:@"SearchMusicCell"];
    self.LocalMusicArray = [[muzzik new] makeMuzziksByMusicArray:[[MuzzikItem getArrayFromLocalForKey:@"Muzzik_Local_Itunes_Muzzik"] mutableCopy]];
    if ([self.LocalMusicArray count] == 0) {
        UIImageView *emptyImage;
        int i = rand()%3;
        if (i == 0) {
            emptyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yellowlocalsongstips"]];
        }else if (i == 1){
            emptyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bluelocalsongstips"]];
        }else{
            emptyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"redlocalsongstips"]];
        }
        [emptyImage setFrame:CGRectMake((SCREEN_WIDTH-emptyImage.frame.size.width)/2, 80, emptyImage.frame.size.width, emptyImage.frame.size.height)];
        [self.view addSubview:emptyImage];
    }
}

-(void)viewDidCurrentView{
    self.keeper.activityVC = self;
    if ([self.keeper.searchBar.text length]>0) {
        [self updateDataSource:self.keeper.searchBar.text];
    }
    [self.keeper followScrollView:self.tableView];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return isSearch ?[self.searchArray count]:[self.LocalMusicArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Globle *glob = [Globle shareGloble];
    SearchMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchMusicCell" forIndexPath:indexPath];
    muzzik *localMuzzik = isSearch ?self.searchArray[indexPath.row]:self.LocalMusicArray[indexPath.row];
    cell.songName.text = localMuzzik.music.name;
    cell.Artist.text = localMuzzik.music.artist;
    cell.index = indexPath.row;
    cell.delegate = self;
    cell.songMuzzik = localMuzzik;
    if ([[MuzzikPlayer shareClass].playingMuzzik.music.key isEqualToString:localMuzzik.music.key]&&!glob.isPause && glob.isPlaying) {
        [cell.playButton setImage:[UIImage imageNamed:@"stopImage_new"] forState:UIControlStateNormal];
    }else{
        [cell.playButton setImage:[UIImage imageNamed:@"playImage_new"] forState:UIControlStateNormal];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.shareDic = [NSMutableDictionary dictionary];
    muzzik *tempMuzzik = [muzzik new];
    if (isSearch) {
        tempMuzzik = [self.searchArray objectAtIndex:indexPath.row];
    }
    else{
        tempMuzzik = [self.LocalMusicArray objectAtIndex:indexPath.row];
    }
    MuzzikObject *mobject = [MuzzikObject shareClass];
    if ([self.keeper.comeInType isEqualToString:@"comment"]) {
        mobject.music = tempMuzzik.music;
        [self.keeper.navigationController popViewControllerAnimated:YES];
    }else{
        // [MuzzikItem getLyricByMusic:tempMuzzik.music];
        if (mobject.isMessageVCOpen) {
            mobject.music = tempMuzzik.music;
            [self.keeper.navigationController popViewControllerAnimated:YES];
        }else{
            mobject.music = tempMuzzik.music;
            MessageStepViewController *msgVC = [[MessageStepViewController alloc] init];
            msgVC.isNewSelected = YES;
            [self.keeper.navigationController pushViewController:msgVC animated:YES];
        }
    }
}

-(void)playSongWithSongModel:(muzzik *)songModel{
    
    MuzzikRequestCenter *center = [MuzzikRequestCenter shareClass];
    center.singleMusic = YES;
    
    
    MuzzikPlayer *player = [MuzzikPlayer shareClass];
    player.listType = TempList;
    player.MusicArray = [[self.searchArray count]>0 ?self.searchArray:self.LocalMusicArray mutableCopy];
    [player playSongWithSongModel:songModel Title:isSearch ? [NSString stringWithFormat:@"搜索 %@ 的歌曲",_searchText]:@"本地匹配"];
    if (isSearch) {
        [MuzzikItem SetUserInfoWithMuzziks:self.searchArray title:Constant_userInfo_temp description:[NSString stringWithFormat:@"搜索 %@ 的歌曲",_searchText]];
    }else{
        [MuzzikItem SetUserInfoWithMuzziks:self.LocalMusicArray title:Constant_userInfo_temp description:@"本地匹配"];
    }
    
}

-(void)updateDataSource:(NSString *)searchText{
    _searchText = searchText;
    [self.searchArray removeAllObjects];
    if ([searchText length]>0) {
        isSearch = YES;
        [self.searchArray removeAllObjects];
        for (muzzik *tempMuzzik in self.LocalMusicArray) {
            NSRange rangName = [[tempMuzzik.music.name uppercaseString] rangeOfString:[searchText uppercaseString]];
            NSRange rangArtist = [[tempMuzzik.music.artist uppercaseString] rangeOfString:[searchText uppercaseString]];
            if (rangName.location != NSNotFound || rangArtist.location != NSNotFound) {
                [self.searchArray addObject:tempMuzzik];
            }
        }
    }else{
        isSearch = NO;
        
    }
    [self.tableView reloadData];
    
}

//更新播放按钮显示
-(void)playnextMuzzikUpdate{
    
    [self.tableView reloadData];
    
}
@end
