//
//  SearchForSong.m
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "SearchForSong.h"
#import "MusicAndArtistCell.h"
#import "MessageStepViewController.h"
#import "MuzzikObject.h"
#import "songDetailVCViewController.h"
@interface SearchForSong ()<searchSource,UITableViewDataSource,UITableViewDelegate>{
    UITableView *myTableView;
    NSInteger indexOfMuzzik;
    BOOL isSearch;
    NSString *pageID;
    NSInteger _index;
    NSString *_searchText;
    UIView *searchView;
    UILabel *searchLabel;
    NSUInteger page;
    UIImageView *blankTipsImage;
}
@property(nonatomic,retain)NSMutableArray *searchArray;
@end

@implementation SearchForSong

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    myTableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-108)];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
    [self initNagationBar:@"搜索歌曲" leftBtn:0 rightBtn:0];
    self.searchArray = [NSMutableArray array];
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 15, SCREEN_WIDTH-60, 20)];
    [searchLabel setFont:[UIFont systemFontOfSize:14]];
    [searchLabel setTextColor:Color_Active_Button_1];
    UIImageView *searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 19, 12, 12)];
    [searchImage setImage:[UIImage imageNamed:Image_search_Oranger]];
    [searchView addSubview:searchImage];
    [searchView addSubview:searchLabel];
    [searchView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchSong)]];
    [MuzzikItem addLineOnView:searchView heightPoint:50 toLeft:13 toRight:13 withColor:Color_line_1];
    [myTableView registerClass:[MusicAndArtistCell class] forCellReuseIdentifier:@"MusicAndArtistCell"];
    blankTipsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:Image_musicTips]];
    [blankTipsImage setFrame:CGRectMake((SCREEN_WIDTH - blankTipsImage.frame.size.width)/2, 30, blankTipsImage.frame.size.width, blankTipsImage.frame.size.height)];
    [self.view addSubview:blankTipsImage];
    
}
- (void)viewDidCurrentView
{
    NSLog(@"加载为当前视图 = %@",self.title);
    self.keeper.activityVC = self;
    [self.keeper followScrollView:myTableView];
    if (![self.keeper.searchBar.text isEqualToString:_searchText]) {
        [self.searchArray removeAllObjects];
        [myTableView reloadData];
    }
    if ([self.keeper.searchBar.text length]>0 &&![_searchText isEqualToString:self.keeper.searchBar.text] && [self.searchArray count] == 0) {
        searchLabel.text = [NSString stringWithFormat:@"搜索相关音乐:%@",self.keeper.searchBar.text];
        [self.view addSubview:searchView];
    }else{
        [searchView removeFromSuperview];
    }
    if ([self.keeper.searchBar.text length]>0) {
        [blankTipsImage setHidden:YES];
    }else {
        [self.searchArray removeAllObjects];
        [myTableView reloadData];
        [blankTipsImage setHidden:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    

}

- (void)refreshFooter
{
    // [self updateSomeThing];
    if ([_searchText length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Music_Search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[NSNumber numberWithInteger:page],Parameter_page,[_searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"q", nil] Method:GetMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                NSMutableArray *songarray = [[muzzik new] makeMuzziksByMusicArray:[dic objectForKey:@"music"]];
                for (muzzik *localMuzzik in songarray) {
                    BOOL isContained = NO;
                    for (muzzik *originMuzzik in self.searchArray) {
                        if ([originMuzzik.music.name isEqualToString:localMuzzik.music.name] && [originMuzzik.music.artist isEqualToString:localMuzzik.music.artist]) {
                            isContained = YES;
                            break;
                        }
                    }
                    if (!isContained) {
                        [self.searchArray addObject:localMuzzik];
                    }
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [myTableView reloadData];
                    [myTableView footerEndRefreshing];
                    if ([[dic objectForKey:@"music"] count]<1 ) {
                        [myTableView removeFooter];
                    }else{
                        page ++;
                    }
                });
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
            NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
            if (![[weakrequest responseString] length]>0) {
                [MuzzikItem showNotifyOnView:self.view text:@"网络请求失败，请重试"];
            }
        }];
        [requestForm startAsynchronous];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicAndArtistCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MusicAndArtistCell" forIndexPath:indexPath];
    muzzik *localMuzzik = self.searchArray[indexPath.row];
    NSRange rangsongName = [[localMuzzik.music.name uppercaseString] rangeOfString:[_searchText uppercaseString]];
    if (rangsongName.location != NSNotFound) {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:localMuzzik.music.name];
        [text addAttribute:NSForegroundColorAttributeName value:Color_Active_Button_1 range:rangsongName];
        if (rangsongName.location>0) {
            [text addAttribute:NSForegroundColorAttributeName value:Color_Text_2 range:NSMakeRange(0, rangsongName.location)];
        }
        if ((rangsongName.location+rangsongName.length)<[localMuzzik.music.name length]) {
            [text addAttribute:NSForegroundColorAttributeName value:Color_Text_2 range:NSMakeRange(rangsongName.location+rangsongName.length ,[localMuzzik.music.name length]- rangsongName.location - rangsongName.length)];
        }
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:Font_Next_Bold size:14] range:NSMakeRange(0, [localMuzzik.music.name length])];
    
        cell.songName.attributedText = text;

    }else{
        cell.songName.text = localMuzzik.music.name;
    }
    
    NSRange rangArtist = [[localMuzzik.music.artist uppercaseString] rangeOfString:[_searchText uppercaseString]];
    if (rangArtist.location != NSNotFound) {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:localMuzzik.music.artist];
        [text addAttribute:NSForegroundColorAttributeName value:Color_Active_Button_1 range:rangArtist];
        if (rangArtist.location>0) {
            [text addAttribute:NSForegroundColorAttributeName value:Color_Text_3 range:NSMakeRange(0, rangArtist.location)];
        }
        if ((rangArtist.location+rangArtist.length)<[localMuzzik.music.artist length]) {
            [text addAttribute:NSForegroundColorAttributeName value:Color_Text_3 range:NSMakeRange(rangArtist.location+rangArtist.length ,[localMuzzik.music.artist length]- rangArtist.location - rangArtist.length)];
        }
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:Font_Next_DemiBold size:12] range:NSMakeRange(0, [localMuzzik.music.artist length])];
        
        cell.Artist.attributedText = text;
        
    }else{
        cell.Artist.text = localMuzzik.music.artist;
    }

    cell.index = indexPath.row;
    cell.songVC = self;
    Globle *glob = [Globle shareGloble];
    if ([[musicPlayer shareClass].localMuzzik.music.key isEqualToString:localMuzzik.music.key] && !glob.isPause) {
        [cell.playButton setImage:[UIImage imageNamed:Image_stoporangeImage] forState:UIControlStateNormal];
    }else{
        [cell.playButton setImage:[UIImage imageNamed:Image_playgreyImage] forState:UIControlStateNormal];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    songDetailVCViewController *songDetail = [[songDetailVCViewController alloc] init];
    songDetail.detailMuzzik = self.searchArray[indexPath.row];
    [self.keeper.navigationController pushViewController:songDetail animated:YES];
}
-(void)updateDataSource:(NSString *)searchText{
    
    [self.searchArray removeAllObjects];
    [myTableView reloadData];
    if ([searchText length]>0) {
        [blankTipsImage setHidden:YES];
        searchLabel.text = [NSString stringWithFormat:@"搜索相关音乐:%@",self.keeper.searchBar.text];
        [self.view addSubview:searchView];
    }else {
        [blankTipsImage setHidden:NO];
        [searchView removeFromSuperview];
    }
}

-(void)searchDataSource:(NSString *)searchText{
     [searchView removeFromSuperview];
    _searchText = searchText;
    [self.searchArray removeAllObjects];
    if ([searchText length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Music_Search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"q", nil] Method:GetMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200 && [_searchText isEqualToString:self.keeper.searchBar.text] && [_searchText length]>0) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                NSMutableArray *songarray = [[muzzik new] makeMuzziksByMusicArray:[dic objectForKey:@"music"]];
                for (muzzik *localMuzzik in songarray) {
                    BOOL isContained = NO;
                    for (muzzik *originMuzzik in self.searchArray) {
                        if ([originMuzzik.music.name isEqualToString:localMuzzik.music.name] && [originMuzzik.music.artist isEqualToString:localMuzzik.music.artist]) {
                            isContained = YES;
                            break;
                        }
                    }
                    if (!isContained) {
                        [self.searchArray addObject:localMuzzik];
                    }
                }
                if ([[dic objectForKey:@"music"] count] >0) {
                    [myTableView addFooterWithTarget:self action:@selector(refreshFooter)];
                    page = 2;
                }
                [myTableView reloadData];
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
            if (![[weakrequest responseString] length]>0) {
                [MuzzikItem showNotifyOnView:self.view text:@"网络请求失败，请重试"];
            }
        }];
        [requestForm startAsynchronous];
    }
}
-(void)searchSong{
    [self.keeper.searchBar resignFirstResponder];
    [searchView removeFromSuperview];
    _searchText = self.keeper.searchBar.text;
    [self.searchArray removeAllObjects];
    if ([self.keeper.searchBar.text length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Music_Search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[_searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"q", nil] Method:GetMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200 && [_searchText isEqualToString:self.keeper.searchBar.text] && [_searchText length]>0) {
            
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            
                NSMutableArray *songarray = [[muzzik new] makeMuzziksByMusicArray:[dic objectForKey:@"music"]];
                for (muzzik *localMuzzik in songarray) {
                    BOOL isContained = NO;
                    for (muzzik *originMuzzik in self.searchArray) {
                        if ([originMuzzik.music.name isEqualToString:localMuzzik.music.name] && [originMuzzik.music.artist isEqualToString:localMuzzik.music.artist]) {
                            isContained = YES;
                            break;
                        }
                    }
                    if (!isContained) {
                        [self.searchArray addObject:localMuzzik];
                    }
                }
                
                if ([[dic objectForKey:@"music"] count] >0) {
                    page = 2;
                    [myTableView addFooterWithTarget:self action:@selector(refreshFooter)];
                }
                [myTableView reloadData];
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
            if (![[weakrequest responseString] length]>0) {
                [MuzzikItem showNotifyOnView:self.view text:@"网络请求失败，请重试"];
            }
        }];
        [requestForm startAsynchronous];
    }
}

-(void)playnextMuzzikUpdate{
        [myTableView reloadData];
}
-(void)playMuzzikWithIndex:(NSInteger)index{
    MuzzikRequestCenter *center = [MuzzikRequestCenter shareClass];
    center.subUrlString = URL_Music_Search;
    center.requestDic = [NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[NSNumber numberWithInteger:page],Parameter_page,[_searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"q", nil];
    center.isPage = YES;
    center.singleMusic = NO;
    center.MuzzikType = Type_Muzzik_Music;
    center.page = page;
    musicPlayer *player = [musicPlayer shareClass];
    player.listType = TempList;
    player.MusicArray = [self.searchArray mutableCopy];
    player.index = index;
    [player playSongWithSongModel:self.searchArray[index] Title:[NSString stringWithFormat:@"搜索 %@ 的歌曲",_searchText]];
    [MuzzikItem SetUserInfoWithMuzziks:self.searchArray title:Constant_userInfo_temp description:[NSString stringWithFormat:@"搜索 %@ 的歌曲",_searchText]];
    
    
    
}
-(void)commentMuzzikWithIndex:(NSInteger)index{
    muzzik *tempMuzzik = self.searchArray[index];
    MuzzikObject *mobject = [MuzzikObject shareClass];
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        user.poController = self.keeper;
        mobject.music = tempMuzzik.music;
        //[MuzzikItem getLyricByMusic:tempMuzzik.music];
        MessageStepViewController *messagebv = [[MessageStepViewController alloc] init];
        [self.keeper.navigationController pushViewController:messagebv animated:YES];
    }else{
        [userInfo checkLoginWithVC:self.keeper];
    }
    
}

@end
