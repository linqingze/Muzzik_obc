//
//  TopRankVC.m
//  muzzik
//
//  Created by muzzik on 15/5/21.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "TopRankVC.h"
#import "topicRankCell.h"
#import "TopicModel.h"
#import "UIButton+WebCache.h"
#import "TopicDetail.h"
#import "userDetailInfo.h"
#import "HotSearchTopic.h"
@interface TopRankVC ()<UITableViewDataSource,UITableViewDelegate,CellDelegate>{
    UITableView *topicTableView;
    NSMutableArray *topicArray;
    int page;
    UIButton *newButton;
    NSMutableDictionary *RefreshDic;
}

@end

@implementation TopRankVC

- (void)viewDidLoad {
    [super viewDidLoad];
    RefreshDic = [NSMutableDictionary dictionary];
    page = 1;
    [self initNagationBar:@"话题" leftBtn:Constant_backImage rightBtn:0];
    topicTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:topicTableView];
    topicTableView.delegate = self;
    topicTableView.dataSource = self;
    topicTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self followScrollView:topicTableView];
    [topicTableView registerClass:[topicRankCell class] forCellReuseIdentifier:@"topicRankCell"];
    [self followScrollView:topicTableView];
    [self loadDataMessage];
    newButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-75, SCREEN_HEIGHT-139, 60, 60)];
    newButton.layer.cornerRadius = 28;
    newButton.clipsToBounds = YES;
    [newButton setImage:[UIImage imageNamed:@"topicsearchImage"] forState:UIControlStateNormal];
    [newButton addTarget:self action:@selector(searchTopic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newButton];
    //[topicTableView addHeaderWithTarget:self action:@selector(refreshHeader)];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
-(void)loadDataMessage{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/topic",BaseURL]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:@"date",@"sort",@"1",Parameter_Limit, nil] Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            
            TopicModel *topicToy = [TopicModel new];
            topicArray = [topicToy makeTopicssByMuzzikArray:[dic objectForKey:@"topics"]];
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/topic",BaseURL]]];
            [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:page],Parameter_page,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:NO];
            __weak ASIHTTPRequest *weakreq = requestForm;
            [requestForm setCompletionBlock :^{
                //    NSLog(@"%@",weakrequest.originalURL);
                NSLog(@"%@",[weakreq responseString]);
                NSData *data = [weakreq responseData];
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if (dic) {
                    
                    TopicModel *topicToy = [TopicModel new];
                    [topicArray addObjectsFromArray:[topicToy makeTopicssByMuzzikArray:[dic objectForKey:@"topics"]]];
                    [topicTableView reloadData];
                    if ([[dic objectForKey:@"topics"] count] >0) {
                        page++;
                        [topicTableView addFooterWithTarget:self action:@selector(refreshFooter)];
                    }
                }
            }];
            [requestForm setFailedBlock:^{
                if (![[weakreq responseString] length]>0) {
                    [self networkErrorShow];
                }
            }];
            [requestForm startAsynchronous];
        }
    }];
    [request setFailedBlock:^{
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
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/topic",BaseURL]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:@"date",@"sort",@"1",Parameter_Limit, nil] Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            page = 1;
            TopicModel *topicToy = [TopicModel new];
            topicArray = [topicToy makeTopicssByMuzzikArray:[dic objectForKey:@"topics"]];
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/topic",BaseURL]]];
            [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:page],Parameter_page,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:NO];
            __weak ASIHTTPRequest *weakreq = requestForm;
            [requestForm setCompletionBlock :^{
                //    NSLog(@"%@",weakrequest.originalURL);
                NSLog(@"%@",[weakreq responseString]);
                NSData *data = [weakreq responseData];
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if (dic) {
                    
                    TopicModel *topicToy = [TopicModel new];
                    [topicArray addObjectsFromArray:[topicToy makeTopicssByMuzzikArray:[dic objectForKey:@"topics"]]];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [topicTableView reloadData];
                        [topicTableView headerEndRefreshing];
                    });
                    if ([[dic objectForKey:@"topics"] count] >0) {
                        page++;
                        [topicTableView addFooterWithTarget:self action:@selector(refreshFooter)];
                    }
                }
            }];
            [requestForm setFailedBlock:^{
                [topicTableView headerEndRefreshing];
            }];
            [requestForm startAsynchronous];
        }
    }];
    [request setFailedBlock:^{
        [topicTableView headerEndRefreshing];
    }];
    [request startAsynchronous];
    
    
}

- (void)refreshFooter
{
    
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/topic",BaseURL]]];
    [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:page],Parameter_page,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakreq = requestForm;
    [requestForm setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakreq responseString]);
        NSData *data = [weakreq responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            
            TopicModel *topicToy = [TopicModel new];
            [topicArray addObjectsFromArray:[topicToy makeTopicssByMuzzikArray:[dic objectForKey:@"topics"]]];
            page++;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [topicTableView reloadData];
                [topicTableView footerEndRefreshing];
                if ([[dic objectForKey:@"topics"] count]<1 ) {
                    [topicTableView removeFooter];
                }
            });
        }
    }];
    [requestForm setFailedBlock:^{
        [topicTableView footerEndRefreshing];
    }];
    [requestForm startAsynchronous];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return topicArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    topicRankCell *cell = [tableView dequeueReusableCellWithIdentifier:@"topicRankCell" forIndexPath:indexPath];
    TopicModel *tempTopic = topicArray[indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.userHead sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempTopic.lastPoster.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
            [cell.userHead setAlpha:0];
            [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            [UIView animateWithDuration:0.5 animations:^{
                [cell.userHead setAlpha:1];
            }];
        }
        
        
        
    }];
    cell.delegate = self;
    cell.topicModel = tempTopic;
    cell.timeLabel.text = [MuzzikItem transtromTime:tempTopic.updateTime];
    cell.commentNum.text = [NSString stringWithFormat:@"%@",tempTopic.amount];
    if (indexPath.row == 0) {
        
        [cell.lineView setHidden:YES];
        
        [cell.rankNumber setHidden:YES];
        cell.topicLabel.text = [NSString stringWithFormat:@"#%@#",tempTopic.name];
        [cell.topicLabel setTextColor:[UIColor whiteColor]];
        [cell.timeLabel setTextColor:[UIColor colorWithWhite:1.0 alpha:0.7]];
        [cell.commentNum setTextColor:[UIColor colorWithWhite:1.0 alpha:0.7]];
        [cell.timeImage setImage:[UIImage imageNamed:Image_newtopictimeImage]];
        [cell.commentImage setImage:[UIImage imageNamed:Image_newtopicnumImage]];
        [cell.rankImage setFrame:CGRectMake(24, 0, 23, 60)];
        if ([tempTopic.color longLongValue] == 1) {
            [cell setBackgroundColor:Color_Action_Button_1];
            [cell.rankImage setImage:[UIImage imageNamed:Image_newredtopicImage]];

        }else if([tempTopic.color longLongValue] == 1){
            [cell setBackgroundColor:Color_Action_Button_2];
            
            [cell.rankImage setImage:[UIImage imageNamed:Image_newyellowtopicImage]];

        }else{
            [cell setBackgroundColor:Color_Action_Button_3];
            [cell.rankImage setImage:[UIImage imageNamed:Image_newbluetopicImage]];

        }
    }else{
        [cell.lineView setHidden:NO];
        [cell.rankNumber setHidden:NO];
        [cell setBackgroundColor:[UIColor whiteColor]];
        cell.topicLabel.text = tempTopic.name;
        [cell.topicLabel setTextColor:Color_Text_2];
        [cell.timeLabel setTextColor:Color_Additional_5];
        [cell.timeLabel setAlpha:0.5];
        
        [cell.commentNum setTextColor:Color_Additional_5];
        [cell.commentNum setAlpha:0.5];
        
        [cell.rankImage setFrame:CGRectMake(28, 0, 15, 60)];
        [cell.timeImage setImage:[UIImage imageNamed:Image_topictimeImage]];
        [cell.commentImage setImage:[UIImage imageNamed:Image_topicnumImage]];
        int deltaRank = [tempTopic.lastRank intValue] - [tempTopic.rank intValue];
        if (deltaRank>0) {
            [cell.rankImage setImage:[UIImage imageNamed:Image_topicriseImage]];
            [cell.rankNumber setTextColor:Color_Action_Button_1];
            cell.rankNumber.text = [NSString stringWithFormat:@"%d",deltaRank];
        }else if (deltaRank == 0){
            [cell.rankImage setImage:[UIImage imageNamed:Image_topicholdImage]];
            [cell.rankNumber setTextColor:Color_line_1];
            cell.rankNumber.text = [NSString stringWithFormat:@"%d",deltaRank];
        }else{
            [cell.rankImage setImage:[UIImage imageNamed:Image_topicdeclineImage]];
            [cell.rankNumber setTextColor:Color_Additional_2];
            cell.rankNumber.text = [NSString stringWithFormat:@"%d",-deltaRank];
        }
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TopicModel *temptopic = topicArray[indexPath.row];
    TopicDetail *topdicdetail = [[TopicDetail alloc] init];
    topdicdetail.topic_id =temptopic.tid;
    [self.navigationController pushViewController:topdicdetail animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)userDetail:(NSString *)uid{
    userInfo *user = [userInfo shareClass];
    if ([uid isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        [self.navigationController pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = uid;
        [self.navigationController pushViewController:detailuser animated:YES];
    }
}
-(void)searchTopic{
    HotSearchTopic *hotsearchvc = [[HotSearchTopic alloc] init];
    [self.navigationController pushViewController:hotsearchvc animated:YES];
}

@end
