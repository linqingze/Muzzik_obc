//
//  searchViewController.m
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "searchViewController.h"
#import "SearchForUser.h"
#import "SearchForSong.h"
#import "SearchForTopic.h"
@interface searchViewController ()<UISearchBarDelegate,SUNSlideSwitchViewDelegate> {
    UIButton *cancelButton;
    SUNSlideSwitchView *sliderView;
    SearchForSong *svcsong;
    SearchForUser *searchvcUser;
    SearchForTopic *searchtopic;
}

@end

@implementation searchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    sliderView = [[SUNSlideSwitchView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    sliderView.tabItemNormalColor = Color_Text_4;
    sliderView.tabItemSelectedColor = Color_Text_2;
    sliderView.shadowImage = [[UIImage imageNamed:@"red_line_and_shadow.png"]
                              stretchableImageWithLeftCapWidth:59.0f topCapHeight:0.0f];
    [self.view addSubview:sliderView];
    sliderView.slideSwitchViewDelegate = self;
    [self.view setBackgroundColor:Color_NavigationBar];
    [self initNagationBar:@"搜索Root" leftBtn:0 rightBtn:0];
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
    svcsong = [[SearchForSong alloc] init];
    svcsong.keeper = self;
    svcsong.title =@"歌曲";
    
    searchvcUser = [[SearchForUser alloc] init];
    searchvcUser.keeper = self;
    searchvcUser.title =@"用户";
    
    searchtopic = [[SearchForTopic alloc] init];
    searchtopic.keeper = self;
    searchtopic.title =@"话题";
    
    
    [sliderView buildUI];

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

#pragma mark - ViewPagerDataSource

#pragma mark - datasource delegate
- (NSUInteger)numberOfTab:(SUNSlideSwitchView *)view
{
    return 3;
}


- (UIViewController *)slideSwitchView:(SUNSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    if (number == 0) {
        
        return svcsong;
    }
    else if (number == 1) {
        return searchvcUser;
    }else{
        return searchtopic;
    }
}
- (void)slideSwitchView:(SUNSlideSwitchView *)view didselectTab:(NSUInteger)number
{
    if (number == 0) {
        [svcsong viewDidCurrentView];
    }
    else if (number == 1) {
        [searchvcUser viewDidCurrentView];
    }else{
        [searchtopic viewDidCurrentView];
    }
}

-(void) searchBarBack{
    [_searchBar resignFirstResponder];
    [_searchView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:NO];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    NSLog(@"%@",searchText);
    if ([self.activityVC respondsToSelector:@selector(updateDataSource:)]) {
        [self.activityVC updateDataSource:searchText];
    }
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)loclsearchBar{
    NSLog(@"search%@",loclsearchBar.text);
    
    [_searchBar resignFirstResponder];
    if ([self.activityVC respondsToSelector:@selector(searchDataSource:)]) {
        [self.activityVC searchDataSource:loclsearchBar.text];
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_searchBar resignFirstResponder];
}

@end
