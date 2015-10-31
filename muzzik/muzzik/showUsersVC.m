//
//  showUsersVC.m
//  muzzik
//
//  Created by muzzik on 15/5/13.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "showUsersVC.h"
#import "searchUserCell.h"
#import "UIImageView+WebCache.h"
#import "userDetailInfo.h"
@interface showUsersVC ()<UITableViewDataSource,UITableViewDelegate,CellDelegate>{
    UITableView *userTableview;
    NSMutableArray *userArray;
    int page;
    NSMutableDictionary *RefreshDic;
}

@end

@implementation showUsersVC

- (void)viewDidLoad {
    [super viewDidLoad];
    RefreshDic = [NSMutableDictionary dictionary];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceUserUpdate:) name:String_UserDataSource_update object:nil];
    page = 2;
    userTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:userTableview];
    userTableview.delegate = self;
    userTableview.dataSource = self;
    userTableview.separatorStyle = UITableViewCellSeparatorStyleNone;

    [userTableview registerClass:[searchUserCell class] forCellReuseIdentifier:@"searchUserCell"];
    [self loadDataMessage];
    
    [userTableview addFooterWithTarget:self action:@selector(refreshFooter)];
}


-(void)loadDataMessage{
    ASIHTTPRequest *requestForm;
    NSString *uid;
    if ([self.uid length]>0) {
        uid = self.uid;
    }else{
        uid = [userInfo shareClass].uid;
    }
    if ([self.showType isEqualToString:@"fans"]) {
        [self initNagationBar:@"粉丝" leftBtn:Constant_backImage rightBtn:0];
        requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/fans",BaseURL,uid]]];
    }else{
        [self initNagationBar:@"关注" leftBtn:Constant_backImage rightBtn:0];
        requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/follows",BaseURL,uid]]];
    }
    [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:Limit_Constant forKey:Parameter_Limit] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            userArray = [[MuzzikUser new] makeMuzziksByUserArray:[dic objectForKey:@"users"]];
            [userTableview reloadData];
            if ([userArray count]<1) {
                [userTableview removeFooter];
            }
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


- (void)refreshFooter
{
    ASIHTTPRequest *requestForm;
    NSString *uid;
    if ([self.uid length]>0) {
        uid = self.uid;
    }else{
        uid = [userInfo shareClass].uid;
    }
    if ([self.showType isEqualToString:@"fans"]) {
        requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/fans",BaseURL,uid]]];
    }else{
        requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/follows",BaseURL,uid]]];
    }
    [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[NSNumber numberWithInt:page],Parameter_page, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        
        if ([weakrequest responseStatusCode] == 200) {
            page++;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            [userArray addObjectsFromArray :[[MuzzikUser new] makeMuzziksByUserArray:[dic objectForKey:@"users"]]];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [userTableview reloadData];
                [userTableview footerEndRefreshing];
                if ([[dic objectForKey:@"users"] count]<1 ) {
                    [userTableview removeFooter];
                }
            });
        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
    }];
    [requestForm setFailedBlock:^{
        [userTableview footerEndRefreshing];
        NSLog(@"%@",[weakrequest error]);
        NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
    }];
    [requestForm startAsynchronous];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.view setNeedsLayout];
    
    
    // MytableView add
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return userArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    searchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchUserCell" forIndexPath:indexPath];
    MuzzikUser *muzzikuser = userArray[indexPath.row];
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
    
    MuzzikUser *attentionuser = userArray[indexPath.row];
    userInfo *user = [userInfo shareClass];
    if ([attentionuser.user_id isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        home.isPush = YES;
        [self.navigationController pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = attentionuser.user_id;
        [self.navigationController pushViewController:detailuser animated:YES];
    }

}
-(void)attention:(NSInteger)index{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        MuzzikUser *attentionuser = userArray[index];
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

            }];
            [requestForm startAsynchronous];
        }else{
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

            }];
            [requestForm startAsynchronous];
        }
    }
    
}
-(void)dataSourceUserUpdate:(NSNotification *)notify{
    MuzzikUser *user = notify.object;
    if ([MuzzikItem checkMutableArray:userArray isContainUser:user]) {
        [userTableview reloadData];
    }
}

@end
