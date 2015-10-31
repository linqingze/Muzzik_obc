//
//  SearchForUser.m
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "SearchForUser.h"
#import "searchUserCell.h"
#import "UIImageView+WebCache.h"
#import "MuzzikObject.h"
#import "userDetailInfo.h"
@interface SearchForUser ()<CellDelegate>{
    NSInteger indexOfMuzzik;
    BOOL isSearch;
    NSString *pageID;
    NSInteger _index;
    NSString *_searchText;
    NSInteger page;
    UIView *searchView;
    UILabel *searchLabel;
    UITableView *myTableView;
    UIImageView *blankTipsImage;
    UILabel *searchBlankLabel;
    NSMutableDictionary *RefreshDic;
}
@property(nonatomic,retain)NSMutableArray *searchArray;
@end

@implementation SearchForUser

- (void)viewDidLoad {
    page = 1;
    [super viewDidLoad];
    RefreshDic = [NSMutableDictionary dictionary];
    [self initNagationBar:@"搜索用户" leftBtn:0 rightBtn:0];
    searchBlankLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    [searchBlankLabel setTextColor:Color_Additional_5];
    searchBlankLabel.font = [UIFont boldSystemFontOfSize:15] ;
    searchBlankLabel.text = @"以上为搜索结果";
    searchBlankLabel.textAlignment = NSTextAlignmentCenter;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceUserUpdate:) name:String_UserDataSource_update object:nil];
    myTableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-94)];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   
    
    searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 15, SCREEN_WIDTH-60, 20)];
    [searchLabel setFont:[UIFont systemFontOfSize:14]];
    [searchLabel setTextColor:Color_Active_Button_1];
    UIImageView *searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 19, 12, 12)];
    [searchImage setImage:[UIImage imageNamed:Image_search_Oranger]];
    [searchView addSubview:searchImage];
    [searchView addSubview:searchLabel];
    [searchView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchUser)]];
    [MuzzikItem addLineOnView:searchView heightPoint:50 toLeft:13 toRight:13 withColor:Color_line_1];
    [myTableView registerClass:[searchUserCell class] forCellReuseIdentifier:@"searchUserCell"];
    blankTipsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:Image_userTips]];
    [blankTipsImage setFrame:CGRectMake((SCREEN_WIDTH - blankTipsImage.frame.size.width)/2, 30, blankTipsImage.frame.size.width, blankTipsImage.frame.size.height)];
    [self.view addSubview:blankTipsImage];
    
}
- (void)viewDidCurrentView{
    self.keeper.activityVC = self;
    [self.keeper followScrollView:myTableView];
    if (![self.keeper.searchBar.text isEqualToString:_searchText]) {
        [myTableView setTableFooterView:nil];
        [self.searchArray removeAllObjects];
        [myTableView reloadData];
    }
    if ([self.keeper.searchBar.text length]>0 &&![_searchText isEqualToString:self.keeper.searchBar.text] && [self.searchArray count] == 0) {
        searchLabel.text = [NSString stringWithFormat:@"搜索相关用户:%@",self.keeper.searchBar.text];
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
    return self.searchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    searchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchUserCell" forIndexPath:indexPath];
    MuzzikUser *muzzikuser = self.searchArray[indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [cell.headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,muzzikuser.avatar,Image_Size_Small]] placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
            [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            [cell.headerImage setAlpha:0];
            [UIView animateWithDuration:0.5 animations:^{
                [cell.headerImage setAlpha:1];
            }];
        }
        
        
    }];
    cell.delegate = self;
    cell.muzzikUser = muzzikuser;
    cell.index = indexPath.row;
    cell.label.text = muzzikuser.name;
    if ([[userInfo shareClass].uid length]>0 && [muzzikuser.user_id isEqualToString:[userInfo shareClass].uid]) {
        [cell.attentionButton setHidden:YES];
    }else{
        [cell.attentionButton setHidden:NO];
    }
    if (muzzikuser.isFollow &&muzzikuser.isFans) {
        [cell.attentionButton setImage:[UIImage imageNamed:Image_followedeachotherImageSQ] forState:UIControlStateNormal];
        [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-80, 0, 65, 60)];
    }else if(muzzikuser.isFollow){
        [cell.attentionButton setImage:[UIImage imageNamed:Image_followedImageSQ] forState:UIControlStateNormal];
        [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-70, 0, 55, 60)];
    }else{
        [cell.attentionButton setImage:[UIImage imageNamed:Image_followImageSQ] forState:UIControlStateNormal];
        [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-60, 0, 45, 60)];
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MuzzikUser *attentionuser = self.searchArray[indexPath.row];
    userInfo *user = [userInfo shareClass];
    if ([attentionuser.user_id isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        home.isPush = YES;
        [self.keeper.navigationController pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = attentionuser.user_id;
        [self.keeper.navigationController pushViewController:detailuser animated:YES];
    }
    
}
-(void)updateDataSource:(NSString *)searchText{
     [myTableView setTableFooterView:nil];
    [self.searchArray removeAllObjects];
    [myTableView reloadData];
    if ([searchText length]>0) {
        [blankTipsImage setHidden:YES];
        searchLabel.text = [NSString stringWithFormat:@"搜索相关用户:%@",self.keeper.searchBar.text];
        [self.view addSubview:searchView];
    }else {
        [blankTipsImage setHidden:NO];
        [searchView removeFromSuperview];
    }
}

-(void)searchDataSource:(NSString *)searchText{
    [self searchUser];
}
//关注用户
-(void)attention:(NSInteger)index{
    MuzzikUser *attentionuser = self.searchArray[index];
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if (attentionuser.isFollow) {
            attentionuser.isFollow = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:attentionuser];
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_user_Unfollow]]];
            [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:attentionuser.user_id forKey:@"_id"] Method:PostMethod auth:YES];
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
            attentionuser.isFollow = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:attentionuser];
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_User_Follow]]];
            [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:attentionuser.user_id forKey:@"_id"] Method:PostMethod auth:YES];
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

-(void) searchUser{
    [self.keeper.searchBar resignFirstResponder];
    [searchView removeFromSuperview];
    _searchText = self.keeper.searchBar.text;
    [self.searchArray removeAllObjects];
    if ([self.keeper.searchBar.text length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Users_search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[self.keeper.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"name"] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);

            if ([weakrequest responseStatusCode] == 200 && [_searchText isEqualToString:self.keeper.searchBar.text] && [_searchText length]>0) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                self.searchArray = [[MuzzikUser new] makeMuzziksByUserArray:[dic objectForKey:@"users"]];
                
                
                if ([[dic objectForKey:@"users"] count] >0) {
                    [myTableView addFooterWithTarget:self action:@selector(refreshFooter)];
                    
                    page = 2;
                }else{
                    [myTableView setTableFooterView:searchBlankLabel];
                }
                [myTableView reloadData];
                
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
-(void)refreshFooter{
    if ([self.keeper.searchBar.text length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Users_search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[self.keeper.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"name",[NSNumber numberWithInteger:page],Parameter_page, nil] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200 && [_searchText isEqualToString:self.keeper.searchBar.text] && [_searchText length]>0) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                [self.searchArray addObjectsFromArray:[[MuzzikUser new] makeMuzziksByUserArray:[dic objectForKey:@"users"]]];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([[dic objectForKey:@"users"] count] >0) {
                        [myTableView footerEndRefreshing];
                        page = page + 1 ;
                    }else{
                        [myTableView removeFooter];
                        [myTableView setTableFooterView:searchBlankLabel];
                    }
                    [myTableView reloadData];
                });
                
                
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [myTableView footerEndRefreshing];
                NSLog(@"%@",[weakrequest error]);
                NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
                if (![[weakrequest responseString] length]>0) {
                    [MuzzikItem showNotifyOnView:self.view text:@"网络请求失败，请重试"];
                }
            }); 
            
        }];
        [requestForm startAsynchronous];
    }
}
-(void)userDetail:(NSString *)user_id{
    userInfo *user = [userInfo shareClass];
    if ([user_id isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        home.isPush = YES;
        [self.keeper.navigationController pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = user_id;
        [self.keeper.navigationController pushViewController:detailuser animated:YES];
    }
}
-(void)dataSourceUserUpdate:(NSNotification *)notify{
    MuzzikUser *user = notify.object;
    if ([MuzzikItem checkMutableArray:self.searchArray isContainUser:user]) {
        [myTableView reloadData];
    }
}
@end
