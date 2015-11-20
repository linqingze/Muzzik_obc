//
//  SuggestMuzzikVC.m
//  muzzik
//
//  Created by muzzik on 15/5/17.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "SuggestMuzzikVC.h"
#import "suggestCollectionCell.h"
#import "UIImageView+WebCache.h"
#import "StyledPageControl.h"
#import "UIButton+WebCache.h"
#import "DetaiMuzzikVC.h"
#import "userDetailInfo.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "TopicDetail.h"
@interface SuggestMuzzikVC ()<UICollectionViewDataSource,UICollectionViewDelegate,CellDelegate,TTTAttributedLabelDelegate>{
    StyledPageControl *pagecontrol;
    NSMutableDictionary *RefreshDic;
    //shareView
    muzzik *shareMuzzik;
    UIView *shareViewFull;
    UIView *shareView;
    UIButton *shareToTimeLineButton;
    UIButton *shareToWeiChatButton;
    UIButton *shareToWeiboButton;
    UIButton *shareToQQButton;
    UIButton *shareToQQZoneButton;
    CGFloat maxScaleY;
    UIImage *shareImage;
    NSMutableDictionary *ReFreshPoImageDic;
}
@property(nonatomic,retain) muzzik *repostMuzzik;
@end

@implementation SuggestMuzzikVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMuzzik:) name:String_Muzzik_Delete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceMuzzikUpdate:) name:String_MuzzikDataSource_update object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    pagecontrol = [[StyledPageControl alloc] initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH, 10)];
    RefreshDic = [NSMutableDictionary dictionary];
    ReFreshPoImageDic = [NSMutableDictionary dictionary];
    [pagecontrol setCoreSelectedColor:Color_Active_Button_1];
    [pagecontrol setCoreNormalColor:Color_line_1];
    [pagecontrol setDiameter:7];
    [pagecontrol setGapWidth:4];
    //[pagecontrol setPageControlStyle:PageControlStyleStrokedCircle];
    pagecontrol.numberOfPages = 10;
    [pagecontrol setCurrentPage:0];
    
    [self.view addSubview:pagecontrol];
    [self initNagationBar:_viewTittle leftBtn:Constant_backImage rightBtn:0];
    UICollectionViewFlowLayout  *flowLayout=[[ UICollectionViewFlowLayout alloc ] init];
    [flowLayout setScrollDirection : UICollectionViewScrollDirectionHorizontal];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    _suggestCollectionView = [[ UICollectionView alloc ] initWithFrame : CGRectMake (0,15,SCREEN_WIDTH,SCREEN_HEIGHT-64) collectionViewLayout :flowLayout];
    [_suggestCollectionView registerClass:[suggestCollectionCell class] forCellWithReuseIdentifier:@"suggestCollectionCell"];
    [_suggestCollectionView setBackgroundColor:[UIColor whiteColor]];
    //[hotTopicCollectionView setHeaderHidden:NO];
    _suggestCollectionView.delegate = self;
    _suggestCollectionView.dataSource = self;
    _suggestCollectionView.pagingEnabled = YES;
    [self.view addSubview:_suggestCollectionView];
    [self followScrollView:_suggestCollectionView];
  
//    [self loadDataMessage];
   
    [self SettingShareView];
    // Do any additional setup after loading the view.
}

//-(void)loadDataMessage{
//    if ([MuzzikItem getDataFromLocalKey: Constant_Data_Suggest] ) {
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[MuzzikItem getDataFromLocalKey: Constant_Data_Suggest] options:NSJSONReadingMutableContainers error:nil];
//        if (dic&&[[dic objectForKey:@"muzziks"]count]>0) {
//            suggestMuzzik =  [[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
//            [MuzzikItem SetUserInfoWithMuzziks:suggestMuzzik title:Constant_userInfo_suggest description:[NSString stringWithFormat:@"推荐列表"]];
//            [_suggestCollectionView reloadData];
//        }
//    }
//    userInfo *user = [userInfo shareClass];
//    if (user.checkSuggest) {
//        suggestMuzzik = [[user.playList objectForKey:Constant_userInfo_suggest] objectForKey:UserInfo_muzziks];
//        [_suggestCollectionView reloadData];
//    }else{
//        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/suggest",BaseURL]]];
//        [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:@"10",Parameter_Limit,[NSNumber numberWithBool:YES],@"image", nil] Method:GetMethod auth:YES];
//        __weak ASIHTTPRequest *weakrequest = request;
//        [request setCompletionBlock :^{
//            //    NSLog(@"%@",weakrequest.originalURL);
//            NSLog(@"%@",[weakrequest responseString]);
//            NSData *data = [weakrequest responseData];
//            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//            if (dic&&[[dic objectForKey:@"muzziks"]count]>0) {
//                suggestMuzzik =  [[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
//                [MuzzikItem SetUserInfoWithMuzziks:suggestMuzzik title:Constant_userInfo_suggest description:[NSString stringWithFormat:@"推荐列表"]];
//                [_suggestCollectionView reloadData];
//            }
//        }];
//        [request setFailedBlock:^{
//            if (![[weakrequest responseString] length]>0) {
//                [self networkErrorShow];
//            }
//            
//        }];
//        [request startAsynchronous];
//    }
//}
//-(void)reloadDataSource{
//    [super reloadDataSource];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self loadDataMessage];
//    });
//    
//    
//}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.suggestArray.count>10 ? 10:self.suggestArray.count;
}

-( CGSize )collectionView:( UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:( NSIndexPath *)indexPath

{

    return CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT-79);
    
    
    
}
-(void)clickOnCell:(muzzik *)tempMuzzik{
    DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
    detail.muzzik_id = tempMuzzik.muzzik_id;
    [self.navigationController pushViewController:detail animated:YES];
}
-(void)deleteMuzzik:(NSNotification *)notify{
    muzzik *localMzzik = notify.object;
    for (muzzik *tempMuzzik in self.suggestArray) {
        if ([tempMuzzik.muzzik_id isEqualToString:localMzzik.muzzik_id]) {
            [self.suggestArray removeObject:tempMuzzik];
            [_suggestCollectionView reloadData];
            break;
        }
    }

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    muzzik *tempMuzzik = [self.suggestArray objectAtIndex:indexPath.row];
    suggestCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"suggestCollectionCell" forIndexPath:indexPath];
    [cell.muzzikImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.image,Image_Size_Big]] placeholderImage:[UIImage imageNamed:Image_placeholdImage] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (![[ReFreshPoImageDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
            [cell.muzzikImage setAlpha:0];
            [ReFreshPoImageDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            [UIView animateWithDuration:0.5 animations:^{
                [cell.muzzikImage setAlpha:1];
            }];
        }
        
        
    }];
    cell.delegate = self;
    cell.songModel = tempMuzzik;
    [cell.headImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
            [cell.headImage setAlpha:0];
            [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            [UIView animateWithDuration:0.5 animations:^{
                [cell.headImage setAlpha:1];
            }];
        }
        
        
    }];
    cell.nameLabel.text = tempMuzzik.MuzzikUser.name;
    cell.timeLabel.text = [MuzzikItem transtromTime:tempMuzzik.date];
    
    cell.message.text = tempMuzzik.message;
    cell.message.delegate = self;
    CGFloat height = [MuzzikItem heightForLabel:cell.message WithText:cell.message.text];
    [cell.message setFrame:CGRectMake(cell.message.frame.origin.x, cell.message.frame.origin.y, cell.message.frame.size.width,height )];
    //[cell.ActionView setFrame:CGRectMake(25, cell.message.frame.origin.y+height+15, SCREEN_WIDTH-50, 40)];
    [cell.scroll setContentSize:CGSizeMake(SCREEN_WIDTH, cell.message.frame.origin.y+height+65)];
    if ([[MuzzikPlayer shareClass].playingMuzzik.muzzik_id isEqualToString:tempMuzzik.muzzik_id] && ![Globle shareGloble].isPause) {
        [cell.playButton setHidden:YES];
    }else{
        [cell.playButton setHidden:NO];
        if ([tempMuzzik.color longLongValue] == 1) {
            [cell.playButton setImage:[UIImage imageNamed:Image_hottweetyellowplayImage] forState:UIControlStateNormal];
        }else if ([tempMuzzik.color longLongValue] == 2){
            [cell.playButton setImage:[UIImage imageNamed:Image_hottweetblueplayImage] forState:UIControlStateNormal];
        }else{
            [cell.playButton setImage:[UIImage imageNamed:Image_hottweetredplayImage] forState:UIControlStateNormal];
        }
    }
    if ([tempMuzzik.color longLongValue] == 1) {
        
        //repost
        if (tempMuzzik.isReposted) {
            [cell.repostButton setImage:[UIImage imageNamed:Image_hottweetyellowretweetImage] forState:UIControlStateNormal];
        }else{
            [cell.repostButton setImage:[UIImage imageNamed:Image_hottweetgreyretweetImage] forState:UIControlStateNormal];
        }
        //move
        if (tempMuzzik.ismoved) {
             [cell.moveButton setImage:[UIImage imageNamed:Image_hottweetyellowlikeImage] forState:UIControlStateNormal];
        }else{
             [cell.moveButton setImage:[UIImage imageNamed:Image_hottweetgreylikeImage] forState:UIControlStateNormal];
        }
    }
    else if ([tempMuzzik.color longLongValue] == 2){
        if (tempMuzzik.isReposted) {
            [cell.repostButton setImage:[UIImage imageNamed:Image_hottweetblueretweetImage] forState:UIControlStateNormal];
        }else{
            [cell.repostButton setImage:[UIImage imageNamed:Image_hottweetgreyretweetImage] forState:UIControlStateNormal];
        }
        
        //move
        if (tempMuzzik.ismoved) {
            [cell.moveButton setImage:[UIImage imageNamed:Image_hottweetbluelikeImage] forState:UIControlStateNormal];
        }else{
            [cell.moveButton setImage:[UIImage imageNamed:Image_hottweetgreylikeImage] forState:UIControlStateNormal];
        }
    }
    else{
        if (tempMuzzik.isReposted) {
            [cell.repostButton setImage:[UIImage imageNamed:Image_hottweetredretweetImage] forState:UIControlStateNormal];
        }else{
            [cell.repostButton setImage:[UIImage imageNamed:Image_hottweetgreyretweetImage] forState:UIControlStateNormal];
        }
        
        //move
        if (tempMuzzik.ismoved) {
            [cell.moveButton setImage:[UIImage imageNamed:Image_hottweetredlikeImage] forState:UIControlStateNormal];
        }else{
            [cell.moveButton setImage:[UIImage imageNamed:Image_hottweetgreylikeImage] forState:UIControlStateNormal];
        }
    }
    return cell;
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
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sView
{
    int index = fabs(sView.contentOffset.x) / sView.frame.size.width;
    //NSLog(@"%d",index);
    [pagecontrol setCurrentPage:index];
}
-(void)userDetail:(NSString *)user_id{
    userInfo *user = [userInfo shareClass];
    if ([user_id isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        home.isPush = YES;
        [self.navigationController pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = user_id;
        [self.navigationController pushViewController:detailuser animated:YES];
    }
    
    
}
-(void) commentAtMuzzik:(muzzik *)localMuzzik{
    muzzik *tempMuzzik = localMuzzik;
    DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
    detail.muzzik_id = tempMuzzik.muzzik_id;
    detail.showType = Constant_Comment;
    [self.navigationController pushViewController:detail animated:YES];
}
-(void)moveMuzzik:(muzzik *) tempMuzzik{
    
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        tempMuzzik.ismoved = !tempMuzzik.ismoved;
        [_suggestCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self.suggestArray indexOfObject:tempMuzzik] inSection:0]]];
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/moved",BaseURL,tempMuzzik.muzzik_id]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:tempMuzzik.ismoved] forKey:@"ismoved"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            if ([weakrequest responseStatusCode] == 200) {
                // NSData *data = [weakrequest responseData];
               
                
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
        }];
        [requestForm startAsynchronous];
        
        //NSLog(@"json:%@,dic:%@",tempJsonData,dic);
        
    }else{
        [userInfo checkLoginWithVC:self];
    }
    
}
-(void)repostActionWithMuzzik:(muzzik *)tempMuzzik{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        self.repostMuzzik = tempMuzzik;
        if (!tempMuzzik.isReposted) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定转发这条Muzzik吗?" message:@"" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:nil];
            // optional - add more buttons:
            [alert addButtonWithTitle:@"确定"];
            [alert show];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定取消转发这条Muzzik吗?" message:@"" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:nil];
            // optional - add more buttons:
            [alert addButtonWithTitle:@"确定"];
            [alert show];
        }
    }
    
    else{
        [userInfo checkLoginWithVC:self];
    }
    
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // do stuff
        if (!self.repostMuzzik.isReposted) {
            
            self.repostMuzzik.isReposted = YES;
            self.repostMuzzik.reposts = [NSString stringWithFormat:@"%ld",[self.repostMuzzik.reposts integerValue]+1];
            [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:self.repostMuzzik];
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik",BaseURL]]];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:self.repostMuzzik.muzzik_id forKey:@"repost"];
            [requestForm addBodyDataSourceWithJsonByDic:dictionary Method:PutMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@",[weakrequest requestHeaders]);
                if ([weakrequest responseStatusCode] == 200) {
                    [MuzzikItem showNotifyOnView:self.view text:@"转发成功"];
                }
            }];
            [requestForm setFailedBlock:^{
                NSLog(@"%@",[weakrequest error]);
            }];
            [requestForm startAsynchronous];
        }else{
            
            self.repostMuzzik.isReposted = NO;
            self.repostMuzzik.reposts = [NSString stringWithFormat:@"%ld",[self.repostMuzzik.reposts integerValue]-1];
            [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:self.repostMuzzik];
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/repost",BaseURL,self.repostMuzzik.muzzik_id]]];
            [requestForm addBodyDataSourceWithJsonByDic:nil Method:DeleteMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@",[weakrequest requestHeaders]);
                if ([weakrequest responseStatusCode] == 200) {
                   [MuzzikItem showNotifyOnView:self.view text:@"取消转发"];
                }
            }];
            [requestForm setFailedBlock:^{
                NSLog(@"%@",[weakrequest error]);
            }];
            [requestForm startAsynchronous];
        }
        
        
    }else{
        
    }
    
}


-(void)shareActionWithMuzzik:(muzzik *)localMuzzik image:(UIImage *) image{
    shareMuzzik = localMuzzik;
    shareImage = image;
    [self addShareView];
}

-(void)SettingShareView{
    CGFloat screenWidth = SCREEN_WIDTH;
    
    CGFloat scaleX = 0.1;
    CGFloat scaleY = 0.08;
    userInfo *user = [userInfo shareClass];
    if (user.WeChatInstalled && user.QQInstalled) {
        maxScaleY = 0.7;
    }else{
        maxScaleY = 0.4;
    }
    shareViewFull = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, SCREEN_HEIGHT)];
    [shareViewFull setAlpha:0];
    [shareViewFull setBackgroundColor:[UIColor colorWithRed:0.125 green:0.121 blue:0.164 alpha:0.8]];
    [shareViewFull addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeShareView)]];
    shareView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, screenWidth, screenWidth*maxScaleY)];
    [shareView setBackgroundColor:[UIColor colorWithRed:0.125 green:0.121 blue:0.164 alpha:0.85]];
    if (user.WeChatInstalled) {
        UIButton *wechatButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*0.1, screenWidth*0.08, screenWidth*0.18, screenWidth*0.18)];
        [wechatButton setImage:[UIImage imageNamed:Image_wechatImage] forState:UIControlStateNormal];
        [wechatButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [wechatButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [wechatButton setImage:[UIImage imageNamed:Image_wechatImage] forState:UIControlStateHighlighted];
        [wechatButton addTarget:self action:@selector(shareWeChat) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:wechatButton];
        UILabel *weiChatLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*0.1, screenWidth*0.26, screenWidth*0.18, 20)];
        weiChatLabel.text = @"微 信";
        weiChatLabel.textAlignment = NSTextAlignmentCenter;
        [weiChatLabel setFont:[UIFont systemFontOfSize:12]];
        weiChatLabel.textColor =  Color_line_2;
        [shareView addSubview:weiChatLabel];
        UIButton *timeLineButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*0.41, screenWidth*0.08, SCREEN_WIDTH*0.18, SCREEN_WIDTH*0.18)];
        [timeLineButton setImage:[UIImage imageNamed:Image_momentImage] forState:UIControlStateNormal];
        [timeLineButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [timeLineButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [timeLineButton setImage:[UIImage imageNamed:Image_momentImage] forState:UIControlStateHighlighted];
        [timeLineButton addTarget:self action:@selector(shareTimeLine) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:timeLineButton];
        
        UILabel *timeLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*0.41, screenWidth*0.26, screenWidth*0.18, 20)];
        timeLineLabel.text = @"朋友圈";
        timeLineLabel.textAlignment = NSTextAlignmentCenter;
        [timeLineLabel setFont:[UIFont systemFontOfSize:12]];
        timeLineLabel.textColor =  Color_line_2;
        [shareView addSubview:timeLineLabel];
        scaleX = 0.72;
    }
    
    
    UIButton *weiboButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*0.08, SCREEN_WIDTH*0.18, SCREEN_WIDTH*0.18)];
    [weiboButton setImage:[UIImage imageNamed:Image_weiboImage] forState:UIControlStateNormal];
    [weiboButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
    [weiboButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
    [weiboButton setImage:[UIImage imageNamed:Image_weiboImage] forState:UIControlStateHighlighted];
    [weiboButton addTarget:self action:@selector(shareWeiBo) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:weiboButton];
    UILabel *weiBoLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*0.26, screenWidth*0.18, 20)];
    weiBoLabel.text = @"微 博";
    weiBoLabel.textAlignment = NSTextAlignmentCenter;
    [weiBoLabel setFont:[UIFont systemFontOfSize:12]];
    weiBoLabel.textColor = Color_line_2;
    [shareView addSubview:weiBoLabel];
    if (user.WeChatInstalled) {
        scaleY = 0.39;
        scaleX = 0.1;
    }else{
        scaleX = 0.41;
    }
    if (user.QQInstalled) {
        UIButton *QQButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*scaleY, screenWidth*0.18, screenWidth*0.18)];
        [QQButton setImage:[UIImage imageNamed:Image_qqImage] forState:UIControlStateNormal];
        [QQButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [QQButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [QQButton setImage:[UIImage imageNamed:Image_qqImage] forState:UIControlStateHighlighted];
        [QQButton addTarget:self action:@selector(shareQQ) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:QQButton];
        
        UILabel *QQLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*(scaleY+0.18), screenWidth*0.18, 20)];
        QQLabel.text = @"QQ";
        QQLabel.textAlignment = NSTextAlignmentCenter;
        [QQLabel setFont:[UIFont systemFontOfSize:12]];
        QQLabel.textColor = Color_line_2;
        [shareView addSubview:QQLabel];
        
        UIButton *qqZoneButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*(scaleX+0.31), screenWidth*scaleY, screenWidth*0.18, screenWidth*0.18)];
        [qqZoneButton setImage:[UIImage imageNamed:Image_q_zoneImage] forState:UIControlStateNormal];
        [qqZoneButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [qqZoneButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [qqZoneButton setImage:[UIImage imageNamed:Image_q_zoneImage] forState:UIControlStateHighlighted];
        [qqZoneButton addTarget:self action:@selector(shareQQZone) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:qqZoneButton];
        
        UILabel *QQZoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*(scaleX+0.31), screenWidth*(scaleY+0.18), screenWidth*0.18, 20)];
        QQZoneLabel.text = @"QQ空间";
        QQZoneLabel.textAlignment = NSTextAlignmentCenter;
        [QQZoneLabel setFont:[UIFont systemFontOfSize:12]];
        QQZoneLabel.textColor = Color_line_2;
        [shareView addSubview:QQZoneLabel];
        
    }
    
    [shareViewFull addSubview:shareView];
    
    
    
}
-(void)closeShareView{
    [UIView animateWithDuration:0.5 animations:^{
        [shareViewFull setAlpha:0];
        [shareView setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH*maxScaleY)];
    } completion:^(BOOL finished) {
        [shareViewFull removeFromSuperview];
        
    }];
}
-(void) addShareView{
    [self.navigationController.view addSubview:shareViewFull];
    [UIView animateWithDuration:0.3 animations:^{
        [shareViewFull setAlpha:1];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            [shareView setFrame:CGRectMake(0, SCREEN_HEIGHT-SCREEN_WIDTH*maxScaleY, SCREEN_WIDTH, SCREEN_WIDTH*maxScaleY)];
        } ];
    }];
}
- (WBMessageObject *)messageToShare
{
    WBMessageObject *message = [WBMessageObject message];
    
    message.text =[NSString stringWithFormat:@"一起来用Muzzik吧 %@%@",URL_Muzzik_SharePage,shareMuzzik.muzzik_id];
    
    WBImageObject *image = [WBImageObject object];
    image.imageData = UIImageJPEGRepresentation([MuzzikItem convertViewToImage:[_suggestCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[self.suggestArray indexOfObject:shareMuzzik] inSection:0]]], 1.0);
    message.imageObject = image;
    return message;
}
-(void)shareWeiBo{
    AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = URL_WeiBo_redirectURI;
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare] authInfo:authRequest access_token:myDelegate.wbtoken];
    
    //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    [WeiboSDK sendRequest:request];
}
-(void) shareQQ{
    TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:ID_QQ_APP
                                                         andDelegate:nil];
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_Muzzik_SharePage,shareMuzzik.muzzik_id];
    //分享图预览图URL地址
    NSString *previewImageUrl = @"http://muzzik-image.qiniudn.com/FieqckeQDGWACSpDA3P0aDzmGcB6";
    //音乐播放的网络流媒体地址
    QQApiAudioObject *audioObj =[QQApiAudioObject objectWithURL:[NSURL URLWithString:url]
                                                          title:shareMuzzik.music.name description:shareMuzzik.music.artist previewImageURL:[NSURL URLWithString:previewImageUrl]];
    //设置播放流媒体地址
    audioObj.flashURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_audio,shareMuzzik.music.key]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObj];
    //将内容分享到qq
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
    //将被容分享到qzone
    //QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    
}
- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        default:
        {
            break;
        }
    }
}
-(void) shareQQZone{
    TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:ID_QQ_APP
                                                         andDelegate:nil];
    //分享跳转URL
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_Muzzik_SharePage,shareMuzzik.muzzik_id];
    //分享图预览图URL地址
    NSString *previewImageUrl = [NSString stringWithFormat:@"%@%@",BaseURL_image,shareMuzzik.MuzzikUser.avatar];
    //音乐播放的网络流媒体地址
    NSString *flashURL = [NSString stringWithFormat:@"%@%@",BaseURL_audio,shareMuzzik.music.key];
    QQApiAudioObject *audioObj =[QQApiAudioObject objectWithURL:[NSURL URLWithString:url]
                                                          title:@"我在Muzzik上分享了首歌" description:[NSString stringWithFormat:@"%@  %@",shareMuzzik.music.name,shareMuzzik.music.artist] previewImageURL:[NSURL URLWithString:previewImageUrl]];
    //设置播放流媒体地址
    audioObj.flashURL = [NSURL URLWithString:flashURL] ;
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObj];
    //将内容分享到qq
    //QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    //将被容分享到qzone
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    
    [self handleSendResult:sent];
}
-(void) shareTimeLine{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app sendMusicContentByMuzzik:shareMuzzik scen:1 image:shareImage];
}

-(void) shareWeChat{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app sendMusicContentByMuzzik:shareMuzzik scen:0 image:(UIImage *) shareImage];
}
-(void)playnextMuzzikUpdate{
    [_suggestCollectionView reloadData];
    if (self.isViewLoaded &&self.view.window) {
        [self updateAnimation];
    }
}
-(void)playSongWithSongModel:(muzzik *)songModel{
    MuzzikRequestCenter *center = [MuzzikRequestCenter shareClass];
    center.singleMusic = YES;
    [MuzzikPlayer shareClass].listType = suggestList;
    [MuzzikPlayer shareClass].MusicArray = self.suggestArray;
    [[MuzzikPlayer shareClass] playSongWithSongModel:songModel Title:@"推荐列表"];
    [MuzzikItem SetUserInfoWithMuzziks:self.suggestArray title:Constant_userInfo_suggest description:[NSString stringWithFormat:@"推荐列表"]];
}

-(void)dataSourceMuzzikUpdate:(NSNotification *)notify{
    muzzik *tempMuzzik = (muzzik *)notify.object;
    if ([MuzzikItem checkMutableArray:self.suggestArray isContainMuzzik:tempMuzzik]) {
        [_suggestCollectionView reloadData];
    }
    
}
@end
