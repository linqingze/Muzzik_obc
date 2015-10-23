//
//  HostViewController.m
//  ICViewPager
//
//  Created by Ilter Cengiz on 28/08/2013.
//  Copyright (c) 2013 Ilter Cengiz. All rights reserved.
//
#import "SUNSlideSwitchView.h"
#import "ChooseMusicVC.h"
#import "SongTableViewController.h"
#import "SearchLibraryMusicVC.h"
#import "LocalMusicTableViewController.h"
@interface ChooseMusicVC () <UISearchBarDelegate,SUNSlideSwitchViewDelegate>{
    UIView *searchView;
    UIButton *cancelButton;
    SUNSlideSwitchView *sliderView;
    SearchLibraryMusicVC *searchVC;
    SongTableViewController *svc;
    LocalMusicTableViewController *localVC;
}

@end

@implementation ChooseMusicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    sliderView = [[SUNSlideSwitchView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    sliderView.tabItemNormalColor = Color_Text_4;
    sliderView.tabItemSelectedColor = Color_Text_2;
    sliderView.shadowImage = [[UIImage imageNamed:@"red_line_and_shadow.png"]
                              stretchableImageWithLeftCapWidth:59.0f topCapHeight:0.0f];
    [self.view addSubview:sliderView];
    sliderView.slideSwitchViewDelegate = self;
    //[MuzzikItem addLineOnView:self.navigationController.view heightPoint:64 toLeft:0 toRight:0 withColor:Color_NavigationBar];
    [self.view setBackgroundColor:Color_NavigationBar];
    [self initNagationBar:@"选歌" leftBtn:Constant_backImage rightBtn:Constant_searchImage];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(6, 6, SCREEN_WIDTH-64, 28)];
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
        [searchField setFrame:CGRectMake(30, 5, _searchBar.frame.size.width-30, _searchBar.frame.size.height - 10)];
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
    NSArray *arr = [self.navigationController.view subviews];
    NSLog(@"%@",arr);
    [searchView setBackgroundColor:Color_NavigationBar];
    [searchView addSubview:_searchBar];
    [self.rightBtn setAlpha:1];
    [self.leftBtn setAlpha:1];
    [self.rightBtn setHidden:NO];
    searchVC = [[SearchLibraryMusicVC alloc] init];
    searchVC.keeper = self;
    searchVC.title = @"网络";
    svc = [[SongTableViewController alloc] init];
    svc.keeper = self;
    svc.title = @"喜欢";

    localVC = [[LocalMusicTableViewController alloc] init];
    localVC.keeper = self;
    localVC.title = @"本地匹配";
    
    [sliderView buildUI];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _searchBar.text = @"";
    _searchBar.placeholder = @"";
    if ([self.activityVC respondsToSelector:@selector(updateDataSource:)]) {
        [self.activityVC updateDataSource:@""];
    }
    [_searchBar resignFirstResponder];
    [searchView removeFromSuperview];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - datasource delegate
- (NSUInteger)numberOfTab:(SUNSlideSwitchView *)view
{
    return 3;
}


- (UIViewController *)slideSwitchView:(SUNSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    if (number == 0) {

        return searchVC;
    } else if (number == 1) {
        return svc;
    }else {
        return localVC;
    }
}
- (void)slideSwitchView:(SUNSlideSwitchView *)view didselectTab:(NSUInteger)number
{
    if (number == 0) {
        [searchVC viewDidCurrentView];
    }
    else if (number == 1) {
        [svc viewDidCurrentView];
    }
    else if(number == 2)
            [localVC viewDidCurrentView];
}

-(void)rightBtnAction:(UIButton *)sender{
    _searchBar.placeholder = @"搜索";
    [_searchBar becomeFirstResponder];
    [self.navigationController.view addSubview:searchView];
    [UIView animateWithDuration:0.3 animations:^{
        [searchView setAlpha:1];
        
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void) searchBarBack{
    _searchBar.text = @"";
    _searchBar.placeholder = @"";
    
    if ([self.activityVC respondsToSelector:@selector(updateDataSource:)]) {
        [self.activityVC updateDataSource:@""];
    }
    [UIView animateWithDuration:0.3 animations:^{
        
        [searchView setAlpha:0];
    } completion:^(BOOL finished) {
        [_searchBar resignFirstResponder];
        [searchView removeFromSuperview];
    }];
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
