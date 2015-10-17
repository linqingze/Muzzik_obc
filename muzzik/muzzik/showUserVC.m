//
//  showUserVC.m
//  muzzik
//
//  Created by muzzik on 15/5/2.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "showUserVC.h"
#import "searchUserCell.h"
#import "UIImageView+WebCache.h"
#import "userDetailInfo.h"
@interface showUserVC ()<UITableViewDataSource,UITableViewDelegate,CellDelegate>{
    UITableView *_tableView;
    NSMutableArray *localUserArray;
    NSString *URLString;
    int page;
    int updated;
    NSMutableDictionary *RefreshDic;
    
}

@end

@implementation showUserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceUserUpdate:) name:String_UserDataSource_update object:nil];
    RefreshDic = [NSMutableDictionary dictionary];
    page = 1;
    if ([_showType isEqualToString:@"repost"]){
        [self initNagationBar:@"转发用户" leftBtn:Constant_backImage rightBtn:0];
        URLString = [NSString stringWithFormat:@"%@%@%@",BaseURL,URL_RepostUsers,_muzzik_id];
    }else if ([_showType isEqualToString:@"share"]){
        URLString = [NSString stringWithFormat:@"%@%@%@",BaseURL,URL_ShareUsers,_muzzik_id];
        [self initNagationBar:@"分享用户" leftBtn:Constant_backImage rightBtn:0];
    }else if ([_showType isEqualToString:@"moved"]){
        URLString = [NSString stringWithFormat:@"%@%@%@",BaseURL,URL_MovedUsers,_muzzik_id];
        [self initNagationBar:@"喜欢用户" leftBtn:Constant_backImage rightBtn:0];
    }else if([self.showType isEqualToString:@"songUser"]){
        [self initNagationBar:@"相关用户" leftBtn:Constant_backImage rightBtn:0];
    }
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView registerClass:[searchUserCell class] forCellReuseIdentifier:@"searchUserCell"];
    if(![self.showType isEqualToString:@"songUser"]){
        [self loadDataMessage];
        [_tableView addFooterWithTarget:self action:@selector(refreshFooter)];
    }
    
    

    
    // Do any additional setup after loading the view.
}
-(void)loadDataMessage{
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :URLString]];
    [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:page] ,Parameter_page,@"20",Parameter_Limit, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            page++;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            localUserArray = [[MuzzikUser new] makeMuzziksByUserArray:[dic objectForKey:@"users"]];
            if ([[dic objectForKey:@"users"] count]<1) {
                [_tableView removeFooter];
            }
            [_tableView reloadData];
        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
    }];
    [requestForm setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
        NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
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
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)refreshFooter
{
    // [self updateSomeThing];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :URLString]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:page] ,Parameter_page,@"20",Parameter_Limit, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            page++;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            [localUserArray addObjectsFromArray:[[MuzzikUser new] makeMuzziksByUserArray:[dic objectForKey:@"users"]]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([[dic objectForKey:@"users"] count]<1) {
                    [_tableView removeFooter];
                }
                [_tableView footerEndRefreshing];
                [_tableView reloadData];
            });
            
        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
    }];
    [request setFailedBlock:^{
        [_tableView footerEndRefreshing];
        NSLog(@"%@,%@",[weakrequest responseHeaders],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return [self.showType isEqualToString:@"songUser"]? self.userArray.count:localUserArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    searchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchUserCell" forIndexPath:indexPath];
    MuzzikUser *muzzikuser = [self.showType isEqualToString:@"songUser"]? self.userArray[indexPath.row]:localUserArray[indexPath.row];
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
    if ([[userInfo shareClass].uid length]>0 && [muzzikuser.user_id isEqualToString:[userInfo shareClass].uid]) {
        [cell.attentionButton setHidden:YES];
    }else{
        [cell.attentionButton setHidden:NO];
    }
    if ([self.showType isEqualToString:@"songUser"]) {
        [cell.attentionButton setHidden:YES];
    }
    cell.index = indexPath.row;
    cell.label.text = muzzikuser.name;
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
    MuzzikUser *attentionuser ;
    if ([self.showType isEqualToString:@"songUser"]) {
        attentionuser = self.userArray[indexPath.row];
    }else{
        attentionuser = localUserArray[indexPath.row];
    }
    userInfo *user = [userInfo shareClass];
    if (attentionuser.user_id) {
        if ([attentionuser.user_id isEqualToString:user.uid]) {
            UserHomePage *home = [[UserHomePage alloc] init];
            [self.navigationController pushViewController:home animated:YES];
        }else{
            userDetailInfo *detailuser = [[userDetailInfo alloc] init];
            detailuser.uid = attentionuser.user_id;
            [self.navigationController pushViewController:detailuser animated:YES];
        }
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = [attentionuser.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self.navigationController pushViewController:detailuser animated:YES];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)attention:(NSInteger)index{
    MuzzikUser *attentionuser = localUserArray[index];
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if (attentionuser.isFollow) {
            attentionuser.isFollow = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:attentionuser];
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_user_Unfollow]]];
            [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:attentionuser.user_id forKey:@"_id"] Method:PostMethod auth:YES];
            //__weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
//                NSLog(@"%@",[weakrequest responseString]);
//                NSLog(@"%d",[weakrequest responseStatusCode]);
//                
//                if ([weakrequest responseStatusCode] == 200) {
//                    
//                }
//                else{
//                    //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
//                }
            }];
            [requestForm setFailedBlock:^{
            }];
            [requestForm startAsynchronous];
        }
        else{
            attentionuser.isFollow = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:attentionuser];
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_User_Follow]]];
            [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:attentionuser.user_id forKey:@"_id"] Method:PostMethod auth:YES];
            //__weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
//                NSLog(@"%@",[weakrequest responseString]);
//                NSLog(@"%d",[weakrequest responseStatusCode]);
//                
//                if ([weakrequest responseStatusCode] == 200) {
//                    attentionuser.isFollow = YES;
//                    [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:attentionuser];
//                }
//                else{
//                    //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
//                }
            }];
            [requestForm setFailedBlock:^{
                
            }];
            [requestForm startAsynchronous];
        }
    }else{
        [userInfo checkLoginWithVC:self];
    }
    
}
-(void)dataSourceUserUpdate:(NSNotification *)notify{
    MuzzikUser *user = notify.object;
    if ([MuzzikItem checkMutableArray:localUserArray isContainUser:user]) {
        [_tableView reloadData];
    }
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
