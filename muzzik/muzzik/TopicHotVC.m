//
//  TopicHotVC.m
//  muzzik
//
//  Created by muzzik on 15/4/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "TopicHotVC.h"
#import "HotSearchTopicCell.h"
@interface TopicHotVC()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>{
    UITableView *topicTableView;
    NSMutableArray *TopicArray;
    NSMutableArray *searchArray;
    BOOL isSearch;
    UIView *searchView;
    UISearchBar *searchBar;
    UIButton *cancelButton;
    NSInteger page;
    BOOL isNew;
    BOOL equalTopic;
    NSString *_searchText;
    UIView *TapsearchView;
    UILabel *searchLabel;
    UILabel *resultLabel;
    NSInteger localpage;
    NSMutableArray *recentArray;
    
}
@end

@implementation TopicHotVC


-(void)viewDidLoad{
    [super viewDidLoad];
    page = 1;
    localpage = 1;
    TopicArray = [NSMutableArray array];
    recentArray  = [[MuzzikItem getArrayFromLocalForKey:@"Recent_Topic_Array_Local"] mutableCopy];
    [self initNagationBar:@"选择话题" leftBtn:Constant_backImage rightBtn:Constant_searchImage];
    topicTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:topicTableView];
    topicTableView.delegate = self;
    topicTableView.dataSource = self;
    [topicTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Get_Topic]]];
    [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",localpage],Parameter_page,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            localpage ++;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            if (recentArray) {
                [TopicArray addObjectsFromArray:recentArray];
                NSArray *array = [dic objectForKey:@"topics"];
                for (NSDictionary *tempDic in array) {
                    BOOL isContained = NO;
                    for (NSDictionary *localDic in recentArray) {
                        if ([[localDic objectForKey:@"name"] isEqualToString:[tempDic objectForKey:@"name"]]) {
                            isContained = YES;
                            break;
                        }
                    }
                    if (!isContained) {
                        [TopicArray addObject:tempDic];
                    }
                }
            }
            else{
                TopicArray = [dic objectForKey:@"topics"];
            }
           
            [topicTableView reloadData];
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
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [topicTableView addFooterWithTarget:self action:@selector(refreshFooter)];
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(6, 6, SCREEN_WIDTH-64, 28)];
    //[searchBar.subviews[0] removeFromSuperview];
    [searchBar setBackgroundImage:[MuzzikItem createImageWithColor:Color_NavigationBar]];
    searchBar.placeholder = @"搜索";
    [searchBar setTintColor:Color_Orange];
    searchBar.delegate = self;
    UITextField *searchField;
    UIView *view = searchBar.subviews[0];
    
    for(int i = 0; i < [view.subviews count]; i++) {
        NSLog(@"%@",[[view.subviews objectAtIndex:i] class]);
        if([[view.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            searchField = [view.subviews objectAtIndex:i];
        }
    }
    if(!(searchField == nil)) {
        searchField.textColor = [UIColor whiteColor];
        [searchField setFrame:CGRectMake(30, 5, searchBar.frame.size.width-30, searchBar.frame.size.height - 10)];
        [searchField setBackgroundColor:Color_search_background];//在这添加灰色的图片
        [searchField setBorderStyle:UITextBorderStyleNone];
        searchField.layer.cornerRadius = 5;
        searchField.clipsToBounds = YES;
    }
    searchView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-150, 20, 0, 40)];
    [searchView setFrame:CGRectMake(0, 20, SCREEN_WIDTH, 40)];
    cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-52, 6, 40, 28)];
    [cancelButton setBackgroundImage:[MuzzikItem createImageWithColor:Color_search_background] forState:UIControlStateNormal];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [cancelButton setTitleColor:Color_Orange forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(searchBarBack) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.layer.cornerRadius = 5;
    cancelButton.clipsToBounds = YES;
    [searchView addSubview:cancelButton];
    
    [searchView setBackgroundColor:Color_NavigationBar];
    [searchView addSubview:searchBar];
    [topicTableView addFooterWithTarget:self action:@selector(refreshFooter)];
    [topicTableView registerClass:[HotSearchTopicCell class] forCellReuseIdentifier:@"HotSearchTopicCell"];
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
}
- (void)refreshFooter
{
    // [self updateSomeThing];
    page++;
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Get_Topic]]];
    NSDictionary  *paraDic;
    if ([searchBar.text length]>0) {
        paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",page],Parameter_page,[searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"q", nil];
        
    }else{
         paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",localpage],Parameter_page,Limit_Constant,Parameter_Limit, nil];
    }
    [requestForm addBodyDataSourceWithJsonByDic:paraDic Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            if (isSearch) {
                page ++;
                [searchArray addObjectsFromArray:[dic objectForKey:@"topics"]];
                
            }else{
                if (recentArray) {
                    NSArray *array = [dic objectForKey:@"topics"];
                    for (NSDictionary *tempDic in array) {
                        BOOL isContained = NO;
                        for (NSDictionary *localDic in recentArray) {
                            if ([[localDic objectForKey:@"name"] isEqualToString:[tempDic objectForKey:@"name"]]) {
                                isContained = YES;
                                break;
                            }
                        }
                        if (!isContained) {
                            [TopicArray addObject:tempDic];
                        }
                    }
                }
                else{
                    [TopicArray addObjectsFromArray:[dic objectForKey:@"topics"]];
                }
                
                localpage++;
                
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [topicTableView reloadData];
                [topicTableView footerEndRefreshing];
            });
        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
    }];
    [requestForm setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
        NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
        [topicTableView footerEndRefreshing];
    }];
    [requestForm startAsynchronous];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [searchView removeFromSuperview];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
    
}

// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    if (isSearch) {
        return [searchArray count];
    }else{
        return [TopicArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   HotSearchTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HotSearchTopicCell" forIndexPath:indexPath];
    
    NSDictionary *tempDic;
    if (isSearch) {
        tempDic = searchArray[indexPath.row];
    }else{
         tempDic = TopicArray[indexPath.row];

    }
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    if (isSearch && !equalTopic && indexPath.row == 0) {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        UIFont *font = [UIFont boldSystemFontOfSize:14];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
        NSString *itemStr = @"添加一个话题";
        NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:Color_Text_2 font:font];
        [text appendAttributedString:item];
        NSAttributedString *item1 = [MuzzikItem formatAttrItem:[NSString stringWithFormat:@"#%@#",searchBar.text] color:Color_Active_Button_2 font:font];
        [text appendAttributedString:item1];
        cell.topicLabel.attributedText = text;
        [cell.poButton setHidden:YES];
    }
    else{
        [cell.poButton setHidden:YES];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
        NSString *itemStr = @"#";
        NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:Color_Additional_4 font:font];
        [text appendAttributedString:item];
        NSAttributedString *item1 = [MuzzikItem formatAttrItem:[tempDic objectForKey:@"name"] color:Color_Text_2 font:font];
        [text appendAttributedString:item1];
        NSString *itemStr1 = @"#";
        NSAttributedString *item2 = [MuzzikItem formatAttrItem:itemStr1 color:Color_Additional_4 font:font];
        [text appendAttributedString:item2];
        cell.topicLabel.attributedText = text;
    }
    //self.dataSource[indexPath.section][@"data"][indexPath.row];
    return cell;

    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *tempTopic;
    MuzzikObject *mobject = [MuzzikObject shareClass];
    if (isSearch) {
        tempTopic = [searchArray objectAtIndex:indexPath.row];
    }
    else{
        tempTopic = TopicArray[indexPath.row];
    }
    BOOL isRecent = NO;
    for (NSDictionary *tempDic in recentArray) {
        if ([[tempDic objectForKey:@"name"] isEqualToString:[tempTopic objectForKey:@"name"]]) {
            [recentArray removeObject:tempDic];
            [recentArray insertObject:tempDic atIndex:0];
            isRecent = YES;
            break;
        }
    }
    if (!isRecent) {
        if (!recentArray) {
            recentArray = [NSMutableArray array];
        }
        [recentArray insertObject:tempTopic atIndex:0];
    }
    if ([recentArray count]>5) {
        [recentArray removeLastObject];
    }
    [MuzzikItem addObjectToLocal:[recentArray copy] ForKey:@"Recent_Topic_Array_Local"];
    mobject.tempmessage = [NSString stringWithFormat:@"#%@#",[tempTopic objectForKey:@"name"]];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnAction:(UIButton *)sender{
    searchBar.placeholder = @"搜索";
    [searchBar becomeFirstResponder];
    [self.navigationController.view addSubview:searchView];
    [UIView animateWithDuration:0.3 animations:^{
        //        [searchView setFrame:CGRectMake(0, 20, SCREEN_WIDTH, 40)];
        
        [searchView setAlpha:1];
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void) searchBarBack{
    [TapsearchView removeFromSuperview];
    [resultLabel removeFromSuperview];
    
    page =1;
    isSearch = NO;
    isNew = NO;
    searchBar.text = @"";
    searchBar.placeholder = @"";

    [UIView animateWithDuration:0.3 animations:^{
        
        [searchView setAlpha:0];
    } completion:^(BOOL finished) {
        [searchBar resignFirstResponder];
        [searchView removeFromSuperview];
    }];
    [topicTableView reloadData];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    page = 1;
    
    [resultLabel removeFromSuperview];
    [searchArray removeAllObjects];
    
    if ([searchText length]>0) {
        isSearch = YES;
        searchLabel.text = [NSString stringWithFormat:@"搜索相关主题:%@",searchText];
        [self.view addSubview:TapsearchView];
    }else {
        isSearch = NO;
        [TapsearchView removeFromSuperview];
    }
    [topicTableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)localsearchBar{
    [searchBar resignFirstResponder];
    
    [TapsearchView removeFromSuperview];
    if ([localsearchBar.text length]>0) {
        isSearch = YES;
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Topic_search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"] Method:GetMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200  && [localsearchBar.text length]>0) {
                _searchText = localsearchBar.text;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                searchArray = [dic objectForKey:@"topics"];
                equalTopic = NO;
                for (NSDictionary *tempDic  in searchArray) {
                    if ([[tempDic objectForKey:@"name"] isEqualToString:_searchText]) {
                        equalTopic = YES;
                        break;
                    }
                }
                page ++;
                if (!equalTopic) {
                    NSDictionary *addDic = [NSDictionary dictionaryWithObject:_searchText forKey:@"name"];
                    [searchArray insertObject:addDic atIndex:0];
                }
                if ([searchArray count] == 1 && !equalTopic) {
                    UIFont *font = [UIFont boldSystemFontOfSize:14];
                    NSMutableAttributedString *textResult = [[NSMutableAttributedString alloc] init];
                    NSString *itemStrtResult = @"没有搜索到同";
                    NSAttributedString *itemtResult = [MuzzikItem formatAttrItem:itemStrtResult color:Color_Text_2 font:font];
                    [textResult appendAttributedString:itemtResult];
                    NSAttributedString *itemtResult1 = [MuzzikItem formatAttrItem:[NSString stringWithFormat:@"#%@#",searchBar.text] color:Color_Active_Button_2 font:font];
                    [textResult appendAttributedString:itemtResult1];
                    [textResult appendAttributedString:[MuzzikItem formatAttrItem:@"相关的话题" color:Color_Text_2 font:font]];
                    resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 70, SCREEN_WIDTH-50, 20)];
                    resultLabel.attributedText = textResult;
                    [self.view addSubview:resultLabel];
                    
                }
                [topicTableView reloadData];
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
    else{
        isSearch = NO;
        [topicTableView reloadData];
    }

}

-(void)searchTopic{
    [searchBar resignFirstResponder];
    
    [TapsearchView removeFromSuperview];
    if ([searchBar.text length]>0) {
        isSearch = YES;
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Topic_search]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"] Method:GetMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200 && [searchBar.text length]>0) {
                _searchText = searchBar.text;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                searchArray = [dic objectForKey:@"topics"];
                equalTopic = NO;
                for (NSDictionary *tempDic  in searchArray) {
                    if ([[tempDic objectForKey:@"name"] isEqualToString:_searchText]) {
                        equalTopic = YES;
                        break;
                    }
                }
                page ++;
                if (!equalTopic) {
                    NSDictionary *addDic = [NSDictionary dictionaryWithObject:_searchText forKey:@"name"];
                    [searchArray insertObject:addDic atIndex:0];
                }
                if ([searchArray count] == 1 && !equalTopic) {
                    UIFont *font = [UIFont boldSystemFontOfSize:14];
                    NSMutableAttributedString *textResult = [[NSMutableAttributedString alloc] init];
                    NSString *itemStrtResult = @"没有搜索到同";
                    NSAttributedString *itemtResult = [MuzzikItem formatAttrItem:itemStrtResult color:Color_Text_2 font:font];
                    [textResult appendAttributedString:itemtResult];
                    NSAttributedString *itemtResult1 = [MuzzikItem formatAttrItem:[NSString stringWithFormat:@"#%@#",searchBar.text] color:Color_Active_Button_2 font:font];
                    [textResult appendAttributedString:itemtResult1];
                    [textResult appendAttributedString:[MuzzikItem formatAttrItem:@"相关的话题" color:Color_Text_2 font:font]];
                    resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 70, SCREEN_WIDTH-50, 20)];
                    resultLabel.attributedText = textResult;
                    [self.view addSubview:resultLabel];
                    
                }
                [topicTableView reloadData];
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
    else{
        isSearch = NO;
        [topicTableView reloadData];
    }

}

@end
