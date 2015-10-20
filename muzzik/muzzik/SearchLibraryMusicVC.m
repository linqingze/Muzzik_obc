//
//  SearchLibraryMusicVC.m
//  muzzik
//
//  Created by muzzik on 15/4/24.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "SearchLibraryMusicVC.h"
#import "SearchMusicCell.h"
#import "MessageStepViewController.h"
@interface SearchLibraryMusicVC (){
    NSInteger indexOfMuzzik;
    BOOL isSearch;
    NSString *_searchText;
    NSInteger page;
}
@property(nonatomic,retain)NSMutableArray *movedMusicArray;
@property(nonatomic,retain)NSMutableArray *searchArray;

@end

@implementation SearchLibraryMusicVC


- (void)viewDidLoad {
    page =1;
    [super viewDidLoad];
    self.movedMusicArray = [NSMutableArray array];
    self.searchArray = [NSMutableArray array];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    [self.tableView registerClass:[SearchMusicCell class] forCellReuseIdentifier:@"SearchMusicCell"];
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Get_suggest_muzzik]]];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            page ++;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            
            muzzik *muzzikToy = [muzzik new];
            NSMutableArray *songarray = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *localMuzzik in songarray) {
                BOOL isContained = NO;
                for (muzzik *originMuzzik in self.movedMusicArray ) {
                    if ([originMuzzik.muzzik_id isEqualToString:localMuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                }
                if (!isContained) {
                    [self.movedMusicArray  addObject:localMuzzik];
                }
            }
            
            [self.tableView reloadData];
        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
    }];
    [requestForm setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
         [MuzzikItem showNotifyOnViewUpon:self.view text:@"网络请求失败，请重试"];
    }];
    [requestForm startAsynchronous];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView addFooterWithTarget:self action:@selector(refreshFooter)];
    
    
}
- (void)refreshFooter
{
    // [self updateSomeThing];
    
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Music_Search]]];
    NSDictionary  *paraDic;
    if ([_searchText length]>0) {
        paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)page],Parameter_page,[_searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"q", nil];
    }else{
        paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)page],Parameter_page, nil];
    }
    [requestForm addBodyDataSourceWithJsonByDic:paraDic Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        
        if ([weakrequest responseStatusCode] == 200) {
            page++;
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            if (isSearch) {
                
                muzzik *muzzikToy = [muzzik new];
                NSMutableArray *songarray = [muzzikToy makeMuzziksByMusicArray:[dic objectForKey:@"music"]];
                for (muzzik *localMuzzik in songarray) {
                    BOOL isContained = NO;
                    for (muzzik *originMuzzik in self.searchArray ) {
                        if ([originMuzzik.music.name isEqualToString:localMuzzik.music.name] && [originMuzzik.music.artist isEqualToString:localMuzzik.music.artist]) {
                            isContained = YES;
                            break;
                        }

                    }
                    if (!isContained) {
                        [self.searchArray  addObject:localMuzzik];
                    }
                }
                
            }else{
                muzzik *muzzikToy = [muzzik new];
                NSMutableArray *songarray = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                for (muzzik *localMuzzik in songarray) {
                    BOOL isContained = NO;
                    for (muzzik *originMuzzik in self.movedMusicArray ) {
                        if ([originMuzzik.muzzik_id isEqualToString:localMuzzik.muzzik_id]) {
                            isContained = YES;
                            break;
                        }
                    }
                    if (!isContained) {
                        [self.movedMusicArray  addObject:localMuzzik];
                    }
                }
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.tableView footerEndRefreshing];
            });
        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
    }];
    [requestForm setFailedBlock:^{
        [self.tableView footerEndRefreshing];
        NSLog(@"%@",[weakrequest error]);
        NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
        
    }];
    [requestForm startAsynchronous];
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
     return isSearch ?[self.searchArray count]:[self.movedMusicArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Globle *glob = [Globle shareGloble];
    SearchMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchMusicCell" forIndexPath:indexPath];
     muzzik *localMuzzik = isSearch ?self.searchArray[indexPath.row]:self.movedMusicArray[indexPath.row];
    cell.songName.text = localMuzzik.music.name;
    cell.Artist.text = localMuzzik.music.artist;
    cell.index = indexPath.row;
    cell.songMuzzik = localMuzzik;
    cell.delegate = self;
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
        tempMuzzik = [self.movedMusicArray objectAtIndex:indexPath.row];
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
    center.subUrlString = URL_Music_Search;
    if ([_searchText length]>0) {
        center.requestDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)page],Parameter_page,[_searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"q", nil];
        center.MuzzikType = Type_Muzzik_Music;
    }else{
        center.requestDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)page],Parameter_page, nil];
        center.MuzzikType = Type_Muzzik_Muzzik;
    }
    center.isPage = YES;
    center.singleMusic = NO;
    
    center.page = page;
    
    
    MuzzikPlayer *player = [MuzzikPlayer shareClass];
    player.listType = TempList;
    player.MusicArray = [[self.searchArray count]>0 ?self.searchArray:self.movedMusicArray mutableCopy];
    [player playSongWithSongModel:songModel Title:isSearch ? [NSString stringWithFormat:@"搜索 %@ 的歌曲",_searchText]:@"曲库歌曲"];
    if (isSearch) {
        [MuzzikItem SetUserInfoWithMuzziks:self.searchArray title:Constant_userInfo_temp description:[NSString stringWithFormat:@"搜索 %@ 的歌曲",_searchText]];
    }else{
        [MuzzikItem SetUserInfoWithMuzziks:self.movedMusicArray title:Constant_userInfo_temp description:@"曲库歌曲"];
    }
}

-(void)updateDataSource:(NSString *)searchText{
    _searchText = searchText;
    [self.searchArray removeAllObjects];
    if ([searchText length]>0) {
        isSearch = YES;
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Music_Search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"] Method:GetMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            page = 2;
            if ([weakrequest responseStatusCode] == 200) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                muzzik *muzzikToy = [muzzik new];
                NSMutableArray *songarray = [muzzikToy makeMuzziksByMusicArray:[dic objectForKey:@"music"]];
                for (muzzik *localMuzzik in songarray) {
                    BOOL isContained = NO;
                    for (muzzik *originMuzzik in self.searchArray ) {
                        if ([originMuzzik.music.name isEqualToString:localMuzzik.music.name] && [originMuzzik.music.artist isEqualToString:localMuzzik.music.artist]) {
                            isContained = YES;
                            break;
                        }

                    }
                    if (!isContained) {
                        [self.searchArray  addObject:localMuzzik];
                    }
                }
                [self.tableView reloadData];
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
        isSearch = NO;
        [self.tableView reloadData];
    }
    
}

//更新播放按钮显示
-(void)playnextMuzzikUpdate{
    [self.tableView reloadData];
    
}
@end
