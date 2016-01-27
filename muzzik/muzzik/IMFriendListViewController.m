//
//  IMFriendListViewController.m
//  muzzik
//
//  Created by muzzik on 15/12/30.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "IMFriendListViewController.h"
#import "TransfromTime.h"
#import "UIImageView+WebCache.h"
#import <RongIMLib/RongIMLib.h>
#import "IMConversationViewcontroller.h"
#import "IMShareMessage.h"
#import "AtfreindCell.h"
@interface IMFriendListViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableDictionary *RefreshDic;
    UITableView *MytableView;
    UIView *footView;
}
@end

@implementation IMFriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNagationBar:@"分享给Muzziker" leftBtn:Constant_backImage rightBtn:0];
    MytableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    MytableView.delegate = self;
    MytableView.dataSource = self;
    MytableView.rowHeight = 60;
    [self.view addSubview:MytableView];
    MytableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    if ([[userInfo shareClass].account.myConversation count] == 0) {
        
        UIImageView *tipsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_tip"]];
        footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH,tipsImage.frame.size.height+100)];
        [tipsImage setFrame:CGRectMake(SCREEN_WIDTH/2-tipsImage.frame.size.width/2, 100, tipsImage.frame.size.width, tipsImage.frame.size.height)];
        [footView addSubview:tipsImage];
        [MytableView setTableFooterView:footView];
    }
    
}


#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[userInfo shareClass].account.myConversation count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellName = @"AtfreindCell";
    UserCore *coreUser = [[userInfo shareClass].account.myConversation objectAtIndex:indexPath.row].targetUser;
    AtfreindCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[AtfreindCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,coreUser.avatar,Image_Size_Small]] placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
            [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            [cell.headerImage setAlpha:0];
            [UIView animateWithDuration:0.5 animations:^{
                [cell.headerImage setAlpha:1];
            }];
        }
        
        
    }];
    cell.label.text = coreUser.name;
    
    //self.dataSource[indexPath.section][@"data"][indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UserCore *coreUser = [[userInfo shareClass].account.myConversation objectAtIndex:indexPath.row].targetUser;
    
    
    __block IMConversationViewcontroller *imVC = [[IMConversationViewcontroller alloc] init];

    
    AppDelegate *app = (AppDelegate *) [UIApplication sharedApplication].delegate;
    RCUserInfo *targetUserinfo = [[RCUserInfo alloc] initWithUserId:coreUser.user_id name:coreUser.name portrait:coreUser.avatar];
    imVC.con = [app getConversationByUserInfo:targetUserinfo];
    imVC.con.unReadMessage = [NSNumber numberWithInt:0];
    imVC.title = imVC.con.targetUser.name;
    [app.managedObjectContext save:nil];
    
    if (self.shareMuzzik) {
        IMShareMessage *imshare = [[IMShareMessage alloc] init];
        imshare.jsonStr = [self DataTOjsonString:self.shareMuzzik.rawDic];
        imshare.extra = [self DataTOjsonString:[NSDictionary dictionaryWithObjectsAndKeys:coreUser.name,@"name",coreUser.avatar,@"avatar",coreUser.user_id,@"_id", nil]];
        [app sendIMMessage:imshare targetCon:imVC.con pushContent:[NSString stringWithFormat:@"%@ 给你分享了一条Muzzik",coreUser.name] ];
    }
    
    NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
    [array removeLastObject];
    [array addObject:imVC];
    [self.navigationController setViewControllers:array animated:YES];

    
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
