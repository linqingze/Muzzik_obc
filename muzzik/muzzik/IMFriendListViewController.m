//
//  IMFriendListViewController.m
//  muzzik
//
//  Created by muzzik on 15/12/30.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "IMFriendListViewController.h"
#import "BATableView.h"
#import "TransfromTime.h"
#import "UIImageView+WebCache.h"
#import <RongIMLib/RongIMLib.h>
#import "IMConversationViewcontroller.h"
#import "IMShareMessage.h"
@interface IMFriendListViewController ()<BATableViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSMutableDictionary *RefreshDic;
    BATableView *MytableView;
    NSMutableArray *recentContactArray;
    NSMutableArray *friendArray;
    NSMutableArray *arrCapital;
    NSInteger friendCount;
    NSInteger page;
    UIButton *nextButton;
    NSMutableArray *allUsers;
    NSMutableArray *localArray;
}
@property (nonatomic,retain)TransfromTime *transfrom;
@end

@implementation IMFriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    localArray = [NSMutableArray array];
    allUsers = [NSMutableArray array];
    RefreshDic = [NSMutableDictionary dictionary];
    [self initNagationBar:@" @ 好友" leftBtn:Constant_backImage rightBtn:4];
    friendArray = [NSMutableArray array];
    MytableView = [[BATableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    MytableView.delegate = self;
    [self.view addSubview:MytableView];
    page = 1;
    [self requestForFriend];
    NSData *friendData = [MuzzikItem getDataFromLocalKey:@"localFriend_Muzzik"];
    NSArray *tempArray = [NSKeyedUnarchiver unarchiveObjectWithData:friendData];
    if (tempArray) {
        friendArray =[[MuzzikUser new] makeMuzziksByUserArray:[tempArray mutableCopy]];
        if ([friendArray count]>0) {
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
            [MytableView reloadData];
        }
    }
    
    // Do any additional setup after loading the view.
    self.transfrom = [[TransfromTime alloc] init];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
}


-(void) requestForFriend{
    ASIHTTPRequest *requestfriend = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/follows",BaseURL,[userInfo shareClass].uid]]];
    [requestfriend addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:@"100",Parameter_Limit,[NSString stringWithFormat:@"%ld",(long)page],Parameter_page, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestfriend;
    [requestfriend setCompletionBlock:^{
        //        NSLog(@"%@",[weakrequest originalURL]);
        //        NSLog(@"%@",[weakrequest responseString]);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
        NSMutableArray *tempArray = [[MuzzikUser new] makeMuzziksByUserArray:[dic objectForKey:@"users"]];
        [localArray addObjectsFromArray:[dic objectForKey:@"users"]];
        [allUsers addObjectsFromArray:tempArray];
        
        if ([[dic objectForKey:@"users"] count]<100) {
            friendArray = allUsers;
            [localArray addObjectsFromArray:[dic objectForKey:@"users"]];
            [MuzzikItem addObjectToLocal:[NSKeyedArchiver archivedDataWithRootObject:localArray] ForKey:@"localFriend_Muzzik"];
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
    
    //self.dataSource[indexPath.section][@"data"][indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MuzzikUser *muzzikuser =[ friendArray[indexPath.section][indexPath.row] objectForKey:@"user"];
    userInfo *user = [userInfo shareClass];
    
    
    __block IMConversationViewcontroller *imVC = [[IMConversationViewcontroller alloc] init];

    
    AppDelegate *app = (AppDelegate *) [UIApplication sharedApplication].delegate;
    RCUserInfo *targetUserinfo = [[RCUserInfo alloc] initWithUserId:muzzikuser.user_id name:muzzikuser.name portrait:muzzikuser.avatar];
    imVC.con = [app getConversationByUserInfo:targetUserinfo];
    imVC.con.unReadMessage = [NSNumber numberWithInt:0];
    imVC.title = imVC.con.targetUser.name;
    [app.managedObjectContext save:nil];
    
    if (self.shareMuzzik) {
        IMShareMessage *imshare = [[IMShareMessage alloc] init];
        imshare.jsonStr = [self DataTOjsonString:self.shareMuzzik.rawDic];
        imshare.extra = [self DataTOjsonString:[NSDictionary dictionaryWithObjectsAndKeys:muzzikuser.name,@"name",muzzikuser.avatar,@"avatar",muzzikuser.user_id,@"_id", nil]];
        [app sendIMMessage:imshare targetCon:imVC.con pushContent:[NSString stringWithFormat:@"%@ 给你分享了一条Muzzik",user.name] ];
    }
    
    [self.navigationController pushViewController:imVC animated:YES];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
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
