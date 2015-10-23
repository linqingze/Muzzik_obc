//
//  AtFriendSearchVC.m
//  muzzik
//
//  Created by muzzik on 15/6/22.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "AtFriendSearchVC.h"
#import "AtfreindCell.h"
#import "NewSearchCell.h"
#import "UIImageView+WebCache.h"
#import "MessageStepViewController.h"
@interface AtFriendSearchVC ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>{
    UIButton *cancelButton;
    UITableView *myTabelView;
    BOOL isNetwork;
    int page;
    NSMutableDictionary *RefreshDic;
}


@property (nonatomic,retain) UISearchBar *searchBar;
@property (nonatomic,retain) UIView *searchView;
@end

@implementation AtFriendSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    RefreshDic = [NSMutableDictionary dictionary];
    self.searchLocalUsers = [NSMutableArray array];
    [self initNagationBar:nil leftBtn:0 rightBtn:0];
    _searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(6, 6, SCREEN_WIDTH-60, 28)];
    //[searchBar.subviews[0] removeFromSuperview];
    [_searchBar setBackgroundImage:[MuzzikItem createImageWithColor:Color_NavigationBar]];
    _searchBar.placeholder = @"搜索";
    [_searchBar setTintColor:Color_Orange];
    _searchBar.delegate = self;
    UITextField *searchField;
    UIView *view = _searchBar.subviews[0];
    
    for(int i = 0; i < [view.subviews count]; i++) {
        NSLog(@"%@",[[view.subviews objectAtIndex:i] class]);
        if([[view.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            searchField = [view.subviews objectAtIndex:i];
        }
    }
    if(!(searchField == nil)) {
        searchField.textColor = [UIColor whiteColor];
        // [searchField setFrame:CGRectMake(30, 5, _searchBar.frame.size.width-30, _searchBar.frame.size.height - 10)];
        [searchField setBackgroundColor:Color_search_background];//在这添加灰色的图片
        [searchField setBorderStyle:UITextBorderStyleNone];
        searchField.layer.cornerRadius = 5;
        searchField.clipsToBounds = YES;
        searchField.textAlignment = NSTextAlignmentLeft;
    }
    _searchView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-150, 20, 0, 40)];
    [_searchView setFrame:CGRectMake(0, 20, SCREEN_WIDTH, 40)];
    cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-52, 6, 40, 28)];
    [cancelButton setBackgroundImage:[MuzzikItem createImageWithColor:Color_search_background] forState:UIControlStateNormal];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [cancelButton setTitleColor:Color_Orange forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(searchBarBack) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.layer.cornerRadius = 5;
    cancelButton.clipsToBounds = YES;
    [_searchView addSubview:cancelButton];
    
    [_searchView setBackgroundColor:Color_NavigationBar];
    [_searchView addSubview:_searchBar];
    [self.navigationController.view addSubview:_searchView];
    // Do any additional setup after loading the view.
    myTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    myTabelView.delegate = self;
    myTabelView.dataSource = self;
    [myTabelView registerClass:[AtfreindCell class] forCellReuseIdentifier:@"AtfreindCell"];
    [myTabelView registerClass:[NewSearchCell class] forCellReuseIdentifier:@"NewSearchCell"];
    [self.view addSubview:myTabelView];
    [myTabelView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
}
-(void) searchBarBack{
    [_searchBar resignFirstResponder];
    [_searchView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.searchLocalUsers removeAllObjects];
    isNetwork = NO;
    page = 1;
    [myTabelView removeFooter];
    for (MuzzikUser *user in self.localUsers) {
        NSRange rang = [[user.name uppercaseString] rangeOfString:[searchText uppercaseString]];
        if (rang.location != NSNotFound) {
            [self.searchLocalUsers addObject:user];
        }
    }
    if ([searchText length]>0) {
        MuzzikUser *user = [MuzzikUser new];
        user.name = searchText;
        [_searchLocalUsers addObject:user];
    }
    [myTabelView reloadData];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)loclsearchBar{
    [self.searchBar resignFirstResponder];
}
#pragma mark - tableView delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_searchBar.text length]>0) {
        return _searchLocalUsers.count;
    }else{
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.searchLocalUsers.count-1 && !isNetwork) {
       NewSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewSearchCell" forIndexPath:indexPath];
        cell.searchText.text = [NSString stringWithFormat:@"通过网络搜索：%@",_searchBar.text];
          [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }else{
        AtfreindCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AtfreindCell"];
        if (!cell) {
            cell = [[AtfreindCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AtfreindCell"];
        }
        
        MuzzikUser *muzzikuser =self.searchLocalUsers[indexPath.row];
        
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,muzzikuser.avatar,Image_Size_Small]] placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                [cell.headerImage setAlpha:0];
                [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                [UIView animateWithDuration:0.5 animations:^{
                    [cell.headerImage setAlpha:1];
                }];
            }
            
            
            
        }];
        cell.label.text = muzzikuser.name;
        cell.label.font = [UIFont boldSystemFontOfSize:14];
        cell.label.textColor = Color_Text_2;
        return cell;
    }
    
    
    
    //self.dataSource[indexPath.section][@"data"][indexPath.row];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.searchBar resignFirstResponder];
    if (indexPath.row == self.searchLocalUsers.count-1 && !isNetwork) {
        isNetwork = YES;
        
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Users_search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"name",Limit_Constant,Parameter_Limit,[NSNumber numberWithInt:page],Parameter_page, nil] Method:GetMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                
                page++;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                if ([[dic objectForKey:@"users"] count] == [Limit_Constant integerValue]) {
                    [myTabelView addFooterWithTarget:self action:@selector(refreshFooter)];
                }
                self.searchLocalUsers = [[MuzzikUser new] makeMuzziksByUserArray:[dic objectForKey:@"users"]];
                [myTabelView reloadData];
                
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
        //
    }else{
        [self.searchView removeFromSuperview];
        MuzzikObject *muzzikobject = [MuzzikObject shareClass];
        NSString *message = @"";
        for (NSString *indexstring in [self.Fdictionary allKeys]) {
            NSArray *array = [indexstring componentsSeparatedByString:@"-"];
            MuzzikUser *muzzikuser = [self.friendArray[[array[0] integerValue] ][[array[1] integerValue]] objectForKey:@"user"];
            message = [message stringByAppendingString:[NSString stringWithFormat:@"@%@ ",muzzikuser.name]];
        }
        MuzzikUser *muser = self.searchLocalUsers[indexPath.row];
         message = [message stringByAppendingString:[NSString stringWithFormat:@"@%@ ",muser.name]];
        muzzikobject.tempmessage = message;
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[MessageStepViewController class]]) {
                [self.navigationController popToViewController:vc animated:YES];
            }
        }
    }
    
}

- (void)refreshFooter
{
    
    
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Users_search]]];
    [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"name",Limit_Constant,Parameter_Limit,[NSNumber numberWithInt:page],Parameter_page, nil] Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            if ([[dic objectForKey:@"users"] count] == [Limit_Constant integerValue]) {
                [myTabelView addFooterWithTarget:self action:@selector(refreshFooter)];
            }
            [self.searchLocalUsers addObjectsFromArray:[[MuzzikUser new] makeMuzziksByUserArray:[dic objectForKey:@"users"]]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [myTabelView reloadData];
                [myTabelView footerEndRefreshing];
                if ([[dic objectForKey:@"users"] count]<1 ) {
                    [myTabelView removeFooter];
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
    }];
    [requestForm startAsynchronous];
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
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

@end
