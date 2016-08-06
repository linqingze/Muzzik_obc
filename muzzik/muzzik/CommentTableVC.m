//
//  CommentTableVC.m
//  muzzik
//
//  Created by muzzik on 15/5/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "CommentTableVC.h"
#import "CommentMuzzikCell.h"
#import "UIButton+WebCache.h"
#import "TopicDetail.h"
#import "userDetailInfo.h"
#import "DetaiMuzzikVC.h"
@interface CommentTableVC ()<UITableViewDataSource,UITableViewDelegate,TTTAttributedLabelDelegate,CellDelegate>{
    int numberOfProducts;
    BOOL needsLoad;
    NSMutableDictionary *RefreshDic;
    UITableView *MytableView;
    BOOL isPlaying;
    UIButton *newButton;
    NSString *lastId;
    NSString *headId;
    NSMutableArray *commentArray;
}

@end

@implementation CommentTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.uid = [userInfo shareClass].uid;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMuzzik:) name:String_Muzzik_Delete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    MytableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-94)];
    [MytableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    MytableView.dataSource = self;
    MytableView.delegate = self;
    [self.view addSubview:MytableView];
    [MytableView registerClass:[CommentMuzzikCell class] forCellReuseIdentifier:@"CommentMuzzikCell"];
    
    [self followScrollView:MytableView];
    RefreshDic = [NSMutableDictionary dictionary];
    [self loadDataMessage];
    [MytableView addHeaderWithTarget:self action:@selector(refreshHeader)];
    [MytableView addFooterWithTarget:self action:@selector(refreshFooter)];
}

-(void)loadDataMessage{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,self.uid]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:self.uid,@"uid",[NSNumber numberWithBool:YES],@"reply",Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            commentArray = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (int i = (int)(commentArray.count-1); i>=0; i--) {
                muzzik *tempMuzzik = commentArray[i];
                if ([tempMuzzik.replystring isEqualToString:@"53e709da97c888c50b1a2fb8"]) {
                    [commentArray removeObject:tempMuzzik];
                }
            }
            lastId = [dic objectForKey:Parameter_tail];
            [MytableView reloadData];
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
        if (![[weakrequest responseString] length]>0) {
            [self networkErrorShow];
        }
    }];
    [request startAsynchronous];
    
    
}
-(void)reloadDataSource{
    [super reloadDataSource];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadDataMessage];
    });
    
    
}

- (void)refreshHeader
{
    // [self updateSomeThing];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,self.uid]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:self.uid,@"uid",[NSNumber numberWithBool:YES],@"reply",Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            commentArray = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (int i = (int)(commentArray.count-1); i>=0; i--) {
                muzzik *tempMuzzik = commentArray[i];
                if ([tempMuzzik.replystring isEqualToString:@"53e709da97c888c50b1a2fb8"]) {
                    [commentArray removeObject:tempMuzzik];
                }
            }
            lastId = [dic objectForKey:Parameter_tail];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MytableView reloadData];
                [MytableView headerEndRefreshing];
            });
            
        }
    }];
    [request setFailedBlock:^{
        [MytableView headerEndRefreshing];
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
}

-(void)viewDidCurrentView{
    [self.keeper followScrollView:MytableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    
}
- (void)refreshFooter
{
    // [self updateSomeThing];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,self.uid]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:self.uid,@"uid",[NSNumber numberWithBool:YES],@"reply",lastId,Parameter_from,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            NSMutableArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            
            for (int i = (int)(array.count-1); i>=0; i--) {
                muzzik *tempMuzzik = array[i];
                if ([tempMuzzik.replystring isEqualToString:@"53e709da97c888c50b1a2fb8"]) {
                    [array removeObject:tempMuzzik];
                }
            }
            [commentArray addObjectsFromArray:array];
            lastId = [dic objectForKey:@"tail"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MytableView footerEndRefreshing];
                [MytableView reloadData];
                
                if ([[dic objectForKey:@"muzziks"] count]<1 ) {
                    [MytableView removeFooter];
                }
            });
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
        [MytableView footerEndRefreshing];
    }];
    [request startAsynchronous];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma -mark tableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    muzzik *tempMuzzik = commentArray[indexPath.row];
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-140, 2000)];
    label.text = tempMuzzik.message;
    
    [label setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
    int textHeight = [MuzzikItem heightForLabel:label WithText:label.text];
    
    if (tempMuzzik.onlytext) {
        return 75+textHeight;
    }else{
        return 110+textHeight;
    }
    
    
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    muzzik *tempMuzzik = commentArray[indexPath.row];
    CommentMuzzikCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentMuzzikCell" forIndexPath:indexPath];
    
    
    [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
            [cell.userImage setAlpha:0];
            [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            [UIView animateWithDuration:0.5 animations:^{
                [cell.userImage setAlpha:1];
            }];
        }
        
        
    }];

    
    cell.delegate = self;
    Globle *glob = [Globle shareGloble];
    BOOL ispalying = false;
    if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause) {
        ispalying = YES;
    }
    cell.MuzzikModel = tempMuzzik;
    cell.userName.text = tempMuzzik.MuzzikUser.name;
    [cell.userName sizeToFit];
    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+2, cell.userName.frame.origin.y, 20, 20)];
    if (tempMuzzik.isprivate ) {
        [cell.privateImage setHidden:NO];
    }else{
        [cell.privateImage setHidden:YES];
    }
    cell.message.text = tempMuzzik.message;
    [cell.message addClickMessagewithTopics:tempMuzzik.topics];
    [cell.message addClickMessageForAt];
    cell.message.delegate = self;
    CGSize msize = [cell.message sizeThatFits:CGSizeMake(SCREEN_WIDTH-140, 2000)];
    [cell.message setFrame:CGRectMake(cell.message.frame.origin.x, cell.message.frame.origin.y, msize.width, msize.height)];
    cell.timeLabel.text = [MuzzikItem transtromTime:tempMuzzik.date];
    if (!tempMuzzik.onlytext) {
        [cell.songName setHidden:NO];
        UIColor *color;
        if ([tempMuzzik.color longLongValue] == 1) {
            color = Color_Action_Button_1;
            if (ispalying) {
                [cell.playButton setImage:[UIImage imageNamed:Image_detailstopredImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_detailredplay] forState:UIControlStateNormal];
            }
            
        }
        else if([tempMuzzik.color longLongValue] == 2){
            //bluelikeImage
            color = Color_Action_Button_2;
            if (ispalying) {
                [cell.playButton setImage:[UIImage imageNamed:Image_detailstopyellowImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_detailyellowplay] forState:UIControlStateNormal];
            }
        }
        else{
            color = Color_Action_Button_3;
            if (ispalying) {
                [cell.playButton setImage:[UIImage imageNamed:Image_detailstopblueImage] forState:UIControlStateNormal];
            }else{
                [cell.playButton setImage:[UIImage imageNamed:Image_detailblueplay] forState:UIControlStateNormal];
            }
        }
        [cell.songName setFrame:CGRectMake(cell.songName.frame.origin.x, cell.message.frame.size.height+cell.message.frame.origin.y+13, SCREEN_WIDTH-140, 20)];
        [cell.playButton setFrame:CGRectMake(SCREEN_WIDTH-53, cell.message.frame.size.height+cell.message.frame.origin.y+6, 40, 40)];
        NSMutableAttributedString *attributesText = [[NSMutableAttributedString alloc] init];
        
        NSAttributedString *item = [MuzzikItem formatAttrItem:tempMuzzik.music.name color:color font:[UIFont boldSystemFontOfSize:15]];
        [attributesText appendAttributedString:item];
        
        NSAttributedString *item1 = [MuzzikItem formatAttrItem:[NSString stringWithFormat:@"  %@",tempMuzzik.music.artist] color:color font:[UIFont boldSystemFontOfSize:13]];
        [attributesText appendAttributedString:item1];
        cell.songName.attributedText = attributesText;
        [cell.lineview setFrame:CGRectMake(16, cell.message.frame.size.height+cell.message.frame.origin.y+52, SCREEN_WIDTH-32, 1)];
    }else{
        [cell.lineview setFrame:CGRectMake(16, cell.message.frame.size.height+cell.message.frame.origin.y+15, SCREEN_WIDTH-32, 1)];
        if (ispalying) {
            [cell.playButton setImage:[UIImage imageNamed:Image_detailstoporangeImage] forState:UIControlStateNormal];
        }else{
            [cell.playButton setImage:[UIImage imageNamed:Image_detailgreyplay] forState:UIControlStateNormal];
        }
        [cell.playButton setFrame:CGRectMake(SCREEN_WIDTH-53, cell.message.frame.size.height+cell.message.frame.origin.y-30, 40, 40)];
        [cell.songName setHidden:YES];
    }
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return commentArray.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([commentArray[indexPath.row] isKindOfClass:[muzzik class]]) {
        muzzik *tempMuzzik = commentArray[indexPath.row];
        DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
        detail.muzzik_id = tempMuzzik.muzzik_id;
        [self.keeper.navigationController pushViewController:detail animated:YES];
    }
    
    
}
-(void)deleteMuzzik:(NSNotification *)notify{
    muzzik *localMzzik = notify.object;
    for (muzzik *tempMuzzik in commentArray) {
        if ([tempMuzzik.muzzik_id isEqualToString:localMzzik.muzzik_id]) {
            [commentArray removeObject:tempMuzzik];
            [MytableView reloadData];
            break;
        }
    }
    
}
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTransitInformation:(NSDictionary *)components{
    NSLog(@"%@",components);
    if ([[components allKeys] containsObject:@"topic_id"]) {
        TopicDetail *topicDetail = [[TopicDetail alloc] init];
        topicDetail.topic_id = [components objectForKey:@"topic_id"];
        [self.keeper.navigationController pushViewController:topicDetail animated:YES];
    }else if([[components allKeys] containsObject:@"at_name"]){
        
        userInfo *user = [userInfo shareClass];
        if ([[components objectForKey:@"at_name"] isEqualToString:user.name]) {
            UserHomePage *home = [[UserHomePage alloc] init];
            home.isPush = YES;
            [self.keeper.navigationController pushViewController:home animated:YES];
        }else{
            userDetailInfo *uInfo = [[userDetailInfo alloc] init];
            uInfo.uid = [[components objectForKey:@"at_name"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self.keeper.navigationController pushViewController:uInfo animated:YES];
        }
    }
}
-(void)playSongWithSongModel:(muzzik *)songModel{
    MuzzikRequestCenter *center = [MuzzikRequestCenter shareClass];
    center.singleMusic = YES;
    [MuzzikPlayer shareClass].listType = TempList;
    [MuzzikPlayer shareClass].MusicArray = [NSMutableArray arrayWithArray:@[songModel]];
    [[MuzzikPlayer shareClass] playSongWithSongModel:songModel Title:[NSString stringWithFormat:@"单曲<%@>",songModel.music.name]];
    [MuzzikItem SetUserInfoWithMuzziks: [NSMutableArray arrayWithArray:@[songModel]] title:Constant_userInfo_temp description:[NSString stringWithFormat:@"单曲<%@>",songModel.music.name]];

    
    
    
}
-(void)playnextMuzzikUpdate{

    [MytableView reloadData];
    if (self.isViewLoaded &&self.view.window) {
        [self.keeper updateAnimation];
    }
}
@end
