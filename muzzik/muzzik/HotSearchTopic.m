//
//  HotSearchTopic.m
//  muzzik
//
//  Created by muzzik on 15/6/28.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "HotSearchTopic.h"
#import "HotSearchTopicCell.h"
#import "TopicDetail.h"
#import "MessageStepViewController.h"
@interface HotSearchTopic ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    NSInteger indexOfMuzzik;
    BOOL isSearch;
    NSString *pageID;
    NSInteger _index;
    NSString *_searchText;
    NSInteger page;
    UIView *TapsearchView;
    UILabel *searchLabel;
    UILabel *resultLabel;
    BOOL isNew;
    UITableView *myTableView;
    UIImageView *blankTipsImage;
    UIButton *cancelButton;
    BOOL equalTopic;
}
@property(nonatomic,retain)NSMutableArray *searchArray;
@property (nonatomic,retain) UISearchBar *searchBar;
@property (nonatomic,retain) UIView *searchView;
@end

@implementation HotSearchTopic
- (void)viewDidLoad {
    page = 1;
    [super viewDidLoad];
    myTableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
    [self followScrollView:myTableView];
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
    
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    TapsearchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 15, SCREEN_WIDTH-60, 20)];
    [searchLabel setFont:[UIFont systemFontOfSize:14]];
    [searchLabel setTextColor:Color_Active_Button_1];
    
    UIImageView *searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 19, 12, 12)];
    [searchImage setImage:[UIImage imageNamed:Image_search_Oranger]];
    [TapsearchView addSubview:searchImage];
    
    
    [TapsearchView addSubview:searchLabel];
    [TapsearchView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchTopic)]];
    [MuzzikItem addLineOnView:TapsearchView heightPoint:50 toLeft:13 toRight:13 withColor:Color_line_1];
    [myTableView registerClass:[HotSearchTopicCell class] forCellReuseIdentifier:@"HotSearchTopicCell"];
    blankTipsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:Image_topicTips]];
    [blankTipsImage setFrame:CGRectMake((SCREEN_WIDTH - blankTipsImage.frame.size.width)/2, 30, blankTipsImage.frame.size.width, blankTipsImage.frame.size.height)];
    [self.view addSubview:blankTipsImage];
    
}

-(void) searchBarBack{
    [_searchBar resignFirstResponder];
    [_searchView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.searchView setHidden:NO];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.searchView removeFromSuperview];
    [self.searchView setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HotSearchTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HotSearchTopicCell" forIndexPath:indexPath];
    NSDictionary *dic = self.searchArray[indexPath.row];
    if (!equalTopic && indexPath.row == 0) {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        UIFont *font = [UIFont boldSystemFontOfSize:14];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
        NSString *itemStr = @"添加一个话题";
        NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:Color_Text_2 font:font];
        [text appendAttributedString:item];
        NSAttributedString *item1 = [MuzzikItem formatAttrItem:[NSString stringWithFormat:@"#%@#",_searchText] color:Color_Active_Button_2 font:font];
        [text appendAttributedString:item1];
        cell.topicLabel.attributedText = text;
        [cell.poButton setHidden:YES];
        
    }else{
        [cell.poButton setHidden:NO];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        UIFont *font = [UIFont boldSystemFontOfSize:14];
        cell.index = indexPath.row;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
        NSString *itemStr = @"#";
        NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:Color_Additional_4 font:font];
        [text appendAttributedString:item];
        NSAttributedString *item1 = [MuzzikItem formatAttrItem:[dic objectForKey:@"name"] color:Color_Text_2 font:font];
        [text appendAttributedString:item1];
        NSString *itemStr1 = @"#";
        NSAttributedString *item2 = [MuzzikItem formatAttrItem:itemStr1 color:Color_Additional_4 font:font];
        [text appendAttributedString:item2];
        cell.topicLabel.attributedText = text;
        cell.songVC = self;
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!equalTopic && indexPath.row == 0) {
        MuzzikObject *mobject = [MuzzikObject shareClass];
        userInfo *user = [userInfo shareClass];
        user.poController = self;
        
        mobject.tempmessage = [NSString stringWithFormat:@"#%@#",[self.searchArray[0] objectForKey:@"name"]];
        MessageStepViewController *messagebv = [[MessageStepViewController alloc] init];
        [self.navigationController pushViewController:messagebv animated:YES];
    }else{
        TopicDetail *topic = [[TopicDetail alloc] init];
        topic.topic_id = [self.searchArray[indexPath.row] objectForKey:@"_id"];
        [self.navigationController pushViewController:topic animated:YES];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    [resultLabel removeFromSuperview];
    isNew = NO;
    [self.searchArray removeAllObjects];
    [myTableView reloadData];
    if ([searchText length]>0) {
        [blankTipsImage setHidden:YES];
        searchLabel.text = [NSString stringWithFormat:@"搜索相关主题:%@",self.searchBar.text];
        [self.view addSubview:TapsearchView];
    }else {
        [blankTipsImage setHidden:NO ];
        [TapsearchView removeFromSuperview];
    }
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)loclsearchBar{
    [self.searchBar resignFirstResponder];
    [resultLabel removeFromSuperview];
    [TapsearchView removeFromSuperview];
    
    [self.searchArray removeAllObjects];
    if ([self.searchBar.text length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Topic_search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"] Method:GetMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            _searchText = self.searchBar.text;
            if ([weakrequest responseStatusCode] == 200 && [loclsearchBar.text length]>0) {
                
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                self.searchArray = [dic objectForKey:@"topics"];
                equalTopic = NO;
                for (NSDictionary *tempDic  in self.searchArray) {
                    if ([[tempDic objectForKey:@"name"] isEqualToString:_searchText]) {
                        equalTopic = YES;
                        break;
                    }
                }
                if (!equalTopic) {
                    NSDictionary *addDic = [NSDictionary dictionaryWithObject:_searchText forKey:@"name"];
                    [self.searchArray insertObject:addDic atIndex:0];
                }
                if ([self.searchArray count] == 1 && !equalTopic) {
                    UIFont *font = [UIFont boldSystemFontOfSize:14];
                    NSMutableAttributedString *textResult = [[NSMutableAttributedString alloc] init];
                    NSString *itemStrtResult = @"没有搜索到同";
                    NSAttributedString *itemtResult = [MuzzikItem formatAttrItem:itemStrtResult color:Color_Text_2 font:font];
                    [textResult appendAttributedString:itemtResult];
                    NSAttributedString *itemtResult1 = [MuzzikItem formatAttrItem:[NSString stringWithFormat:@"#%@#",self.searchBar.text] color:Color_Active_Button_2 font:font];
                    [textResult appendAttributedString:itemtResult1];
                    [textResult appendAttributedString:[MuzzikItem formatAttrItem:@"相关的话题" color:Color_Text_2 font:font]];
                    resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 70, SCREEN_WIDTH-50, 20)];
                    resultLabel.attributedText = textResult;
                    [self.view addSubview:resultLabel];
                    
                }
                [myTableView reloadData];
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
            if (![[weakrequest responseString] length]>0) {
                [MuzzikItem showNotifyOnView:self.view text:@"网络请求失败，请重试"];
            }
        }];
        [requestForm startAsynchronous];
    }
    
}


-(void) poAction:(NSInteger)index{
    MuzzikObject *mobject = [MuzzikObject shareClass];
    userInfo *user = [userInfo shareClass];
    user.poController = self;
    mobject.tempmessage = [NSString stringWithFormat:@"#%@#",[self.searchArray[index] objectForKey:@"name"]];
    MessageStepViewController *messagebv = [[MessageStepViewController alloc] init];
    [self.navigationController pushViewController:messagebv animated:YES];
}
-(void)searchTopic{
    [self.searchBar resignFirstResponder];
    [resultLabel removeFromSuperview];
    [TapsearchView removeFromSuperview];
    
    [self.searchArray removeAllObjects];
    if ([self.searchBar.text length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Topic_search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"] Method:GetMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            _searchText = self.searchBar.text;
            if ([weakrequest responseStatusCode] == 200 && [self.searchBar.text length]>0) {
                
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                self.searchArray = [dic objectForKey:@"topics"];
                equalTopic = NO;
                for (NSDictionary *tempDic  in self.searchArray) {
                    if ([[tempDic objectForKey:@"name"] isEqualToString:_searchText]) {
                        equalTopic = YES;
                        break;
                    }
                }
                if (!equalTopic) {
                    NSDictionary *addDic = [NSDictionary dictionaryWithObject:_searchText forKey:@"name"];
                    [self.searchArray insertObject:addDic atIndex:0];
                }
                if ([self.searchArray count] == 1 && !equalTopic) {
                    UIFont *font = [UIFont boldSystemFontOfSize:14];
                    NSMutableAttributedString *textResult = [[NSMutableAttributedString alloc] init];
                    NSString *itemStrtResult = @"没有搜索到同";
                    NSAttributedString *itemtResult = [MuzzikItem formatAttrItem:itemStrtResult color:Color_Text_2 font:font];
                    [textResult appendAttributedString:itemtResult];
                    NSAttributedString *itemtResult1 = [MuzzikItem formatAttrItem:[NSString stringWithFormat:@"#%@#",self.searchBar.text] color:Color_Active_Button_2 font:font];
                    [textResult appendAttributedString:itemtResult1];
                    [textResult appendAttributedString:[MuzzikItem formatAttrItem:@"相关的话题" color:Color_Text_2 font:font]];
                    resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, SCREEN_WIDTH-50, 20)];
                    resultLabel.attributedText = textResult;
                    [self.view addSubview:resultLabel];
                    
                }
                [myTableView reloadData];
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
            if (![[weakrequest responseString] length]>0) {
                [MuzzikItem showNotifyOnView:self.view text:@"网络请求失败，请重试"];
            }
        }];
        [requestForm startAsynchronous];
    }
    
}

@end
