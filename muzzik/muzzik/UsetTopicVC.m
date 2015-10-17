//
//  UsetTopicVC.m
//  muzzik
//
//  Created by muzzik on 15/5/13.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "UsetTopicVC.h"
#import "TopicModel.h"
#import "TopicDetail.h"
#import "myTopicCell.h"
@interface UsetTopicVC ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *topicTableView;
    NSMutableArray *TopicArray;
    NSInteger page;
}
@end

@implementation UsetTopicVC


-(void)viewDidLoad{
    [super viewDidLoad];
    page = 1;
    [self initNagationBar:@"我的话题" leftBtn:Constant_backImage rightBtn:0];
    topicTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:topicTableView];
    [self followScrollView:topicTableView];
    topicTableView.delegate = self;
    topicTableView.dataSource = self;
    [topicTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [topicTableView registerClass:[myTopicCell class] forCellReuseIdentifier:@"myTopicCell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [topicTableView addFooterWithTarget:self action:@selector(refreshFooter)];
    [self loadDataMessage];
   }



-(void)loadDataMessage{
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/topic/byInitiator/%@",BaseURL,[userInfo shareClass].uid]]];
    NSDictionary  *paraDic;
    paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)page],Parameter_page, Limit_Constant,Parameter_Limit,nil];
    [requestForm addBodyDataSourceWithJsonByDic:paraDic Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            TopicArray = [[TopicModel new] makeTopicssByMuzzikArray:[dic objectForKey:@"topics"]];
            [topicTableView reloadData];
            if ([TopicArray count]<1) {
                [topicTableView removeFooter];
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
    // [self updateSomeThing];
    page++;
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/topic/byInitiator/%@",BaseURL,[userInfo shareClass].uid]]];
    NSDictionary  *paraDic;
    paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)page],Parameter_page, Limit_Constant,Parameter_Limit,nil];
    [requestForm addBodyDataSourceWithJsonByDic:paraDic Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
             [TopicArray addObjectsFromArray:[[TopicModel new] makeTopicssByMuzzikArray:[dic objectForKey:@"topics"]]];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [topicTableView footerEndRefreshing];
                [topicTableView reloadData];
                
                if ([[dic objectForKey:@"topics"] count]<1) {
                    [topicTableView removeFooter];
                }
            });
        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
    }];
    [requestForm setFailedBlock:^{
        [topicTableView footerEndRefreshing];
        NSLog(@"%@",[weakrequest error]);
        NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
    }];
    [requestForm startAsynchronous];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return [TopicArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    myTopicCell * cell = [tableView dequeueReusableCellWithIdentifier:@"myTopicCell"];
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    TopicModel *topic =TopicArray[indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    NSString *itemStr = @"#";
    NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:Color_Additional_4 font:font];
    [text appendAttributedString:item];
    NSAttributedString *item1 = [MuzzikItem formatAttrItem:topic.name color:Color_Text_2 font:font];
    [text appendAttributedString:item1];
    NSString *itemStr1 = @"#";
    NSAttributedString *item2 = [MuzzikItem formatAttrItem:itemStr1 color:Color_Additional_4 font:font];
    [text appendAttributedString:item2];
    cell.topicLabel.attributedText = text;
    
    //self.dataSource[indexPath.section][@"data"][indexPath.row];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TopicModel *tModel = TopicArray[indexPath.row];
    TopicDetail *tdetail = [[TopicDetail alloc] init];
    tdetail.topic_id = tModel.tid;
    [self.navigationController pushViewController:tdetail animated:YES];
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
