//
//  FriendVC.m
//  Where
//
//  Created by 林清泽 on 15/4/20.
//  Copyright (c) 2015年 iOS Fangli. All rights reserved.
//

#import "FriendVC.h"
#import "TransfromTime.h"
#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import "AtFriendSearchVC.h"
@interface FriendVC ()<UITableViewDataSource,UITableViewDelegate,BATableViewDelegate>{
    NSMutableDictionary *RefreshDic;
    BATableView *MytableView;
    NSMutableArray *recentContactArray;
    NSMutableArray *friendArray;
    NSMutableArray *arrCapital;
    NSInteger friendCount;
    NSInteger page;
    NSMutableDictionary *Fdictionary;
    UIButton *nextButton;
    NSMutableArray *allUsers;
}

@property (nonatomic,retain)TransfromTime *transfrom;

@end

@implementation FriendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    RefreshDic = [NSMutableDictionary dictionary];
    Fdictionary = [NSMutableDictionary dictionary];
    [self initNagationBar:@" @ 好友" leftBtn:Constant_backImage rightBtn:4];
    friendArray = [NSMutableArray array];
    MytableView = [[BATableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    MytableView.delegate = self;
    [self.view addSubview:MytableView];
    nextButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-67, SCREEN_HEIGHT-133, 54, 52)];
    [nextButton setImage:[UIImage imageNamed:@"cycledone"] forState:UIControlStateNormal];
    [self.view addSubview: nextButton];
    [nextButton addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setHidden:YES];
    page = 1;
    ASIHTTPRequest *requestRecent = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,URL_RecentContact]]];
    [requestRecent addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequestRecent = requestRecent;
    [requestRecent setCompletionBlock:^{
        NSLog(@"%@",[weakrequestRecent originalURL]);
        NSLog(@"%@",[weakrequestRecent responseString]);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequestRecent responseData] options:NSJSONReadingMutableContainers error:nil];
        recentContactArray = [[MuzzikUser new] makeMuzziksByUserArray:[dic objectForKey:@"users"]];
        [self requestForFriend];
    }];
    [requestRecent startAsynchronous];
    
    
    // Do any additional setup after loading the view.
    self.transfrom = [[TransfromTime alloc] init];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}
-(void) requestForFriend{
    ASIHTTPRequest *requestfriend = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,URL_Friends_get]]];
    [requestfriend addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:@"100",Parameter_Limit,[NSString stringWithFormat:@"%ld",(long)page],Parameter_page, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestfriend;
    [requestfriend setCompletionBlock:^{
//        NSLog(@"%@",[weakrequest originalURL]);
//        NSLog(@"%@",[weakrequest responseString]);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
        NSMutableArray *tempArray = [[MuzzikUser new] makeMuzziksByUserArray:[dic objectForKey:@"users"]];
        for (int i = (int)tempArray.count -1; i>=0; i--) {
            MuzzikUser *newUser = tempArray[i];
            for (MuzzikUser *recentUser in recentContactArray) {
                if ([recentUser.user_id isEqualToString:newUser.user_id]) {
                    [tempArray removeObject:newUser];
                    break;
                }
            }
        }
        [friendArray addObjectsFromArray:tempArray];
        
        if ([[dic objectForKey:@"users"] count]<100) {
            allUsers = [NSMutableArray arrayWithArray:recentContactArray];
            [allUsers addObjectsFromArray:friendArray];
            NSMutableArray *arr = [NSMutableArray arrayWithArray:[self.transfrom firstCharactor:friendArray]];
            arrCapital = [NSMutableArray array];
            for (NSDictionary *dictionary in arr) {
                if (![arrCapital containsObject:[dictionary objectForKey:@"firstcapital"]]) {
                    [arrCapital addObject:[dictionary objectForKey:@"firstcapital"]];
                }
            }
            NSMutableArray *uppercaseArr = [NSMutableArray array];
            for (NSString *str in arrCapital) {
                [uppercaseArr addObject:[str uppercaseString]];
            }
            
            friendArray = [NSMutableArray arrayWithArray:[self.transfrom arrayFromString:arr  searchStr:uppercaseArr]];
            if ([arrCapital count]>0 && [[arrCapital objectAtIndex:0] isEqualToString:@"#"]) {
                [arrCapital addObject:[arrCapital objectAtIndex:0]];
                [friendArray addObject:[friendArray objectAtIndex:0]];
                [friendArray removeObjectAtIndex:0];
                [arrCapital removeObjectAtIndex:0];
                
            }
            if ([recentContactArray count]>0) {
                NSMutableArray *temparray = [NSMutableArray array];
                for (MuzzikUser *muzzikuser in recentContactArray) {
                    [temparray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"*",@"firstcapital",muzzikuser,@"user", nil]];
                }
                [arrCapital insertObject:@"最近联系人" atIndex:0];
                [friendArray insertObject:temparray atIndex:0];
            }
            
            
            
            [MytableView reloadData];
            
            
        }else{
            [self requestForFriend];
        }
        
    }];
    [requestfriend startAsynchronous];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDataSource
- (NSArray *) sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    return arrCapital;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return arrCapital[section];
}
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    
//}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [friendArray count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[friendArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellName = @"AtfreindCell";
    
    AtfreindCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[AtfreindCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    MuzzikUser *muzzikuser =[ friendArray[indexPath.section][indexPath.row] objectForKey:@"user"];
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
    cell.label.text = muzzikuser.name;
    BOOL isSelected = NO;
    for (NSString *string in [Fdictionary allKeys]) {
        if ([string isEqualToString:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]]) {
            isSelected = YES;
            break;
        }
    }
    if (isSelected) {
        [cell.label setTextColor:Color_Additional_4];
        cell.label.font = [UIFont boldSystemFontOfSize:15];
    }else{
        cell.label.font = [UIFont boldSystemFontOfSize:14];
        cell.label.textColor = Color_Text_2;
    }
    
    //self.dataSource[indexPath.section][@"data"][indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@",indexPath.description);
    BOOL isSelected = NO;
    for (NSString *string in [Fdictionary allKeys]) {
        if ([string isEqualToString:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]]) {
            isSelected = YES;
            break;
        }
    }
    if (isSelected) {
        [Fdictionary removeObjectForKey:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]];
    }else{
        [Fdictionary setObject:indexPath forKey:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]];
        
    }
    if ([[Fdictionary allKeys] count]>0) {
        [nextButton setHidden:NO];
    }else{
        [nextButton setHidden:YES];
    }
    [tableView reloadData];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(void) nextAction{
    MuzzikObject *muzzikobject = [MuzzikObject shareClass];
    NSString *message = @"";
    for (NSString *indexstring in [Fdictionary allKeys]) {
        NSArray *array = [indexstring componentsSeparatedByString:@"-"];
        MuzzikUser *muzzikuser = [friendArray[[array[0] integerValue] ][[array[1] integerValue]] objectForKey:@"user"];
        message = [message stringByAppendingString:[NSString stringWithFormat:@"@%@ ",muzzikuser.name]];
    }

    muzzikobject.tempmessage = message;
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)rightBtnAction:(UIButton *)sender{
    AtFriendSearchVC *atsearch = [[AtFriendSearchVC alloc]  init];
    atsearch.friendArray = friendArray;
    atsearch.Fdictionary = Fdictionary;
    atsearch.localUsers = allUsers;
    [self.navigationController pushViewController:atsearch animated:YES];
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
