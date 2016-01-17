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
#import "MuzzikShareView.h"
#import "TopicDetail.h"
@interface SuggestMuzzikVC ()<UICollectionViewDataSource,UICollectionViewDelegate,CellDelegate,TTTAttributedLabelDelegate>{
    StyledPageControl *pagecontrol;
    NSMutableDictionary *RefreshDic;
    MuzzikShareView *muzzikShareView;
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
    muzzikShareView = [[MuzzikShareView alloc] initMyShare];
}

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


-(void)shareActionWithMuzzik:(muzzik *)localMuzzik image:(UIImage *) image cell:(UITableViewCell *)cell{
    muzzikShareView.cell = cell;
    muzzikShareView.shareImage = image;
    muzzikShareView.shareMuzzik = localMuzzik;
    [muzzikShareView showShareView];
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
