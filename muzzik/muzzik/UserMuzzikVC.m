//
//  UserMuzzikVC.m
//  muzzik
//
//  Created by muzzik on 15/5/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "UserMuzzikVC.h"
#import "MuzzikTableVC.h"
#import "CommentTableVC.h"
@interface UserMuzzikVC()<SUNSlideSwitchViewDelegate>{
    SUNSlideSwitchView *sliderView;
    MuzzikTableVC *muzzikTable;
    CommentTableVC *commentvc;
}

@end

@implementation UserMuzzikVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    [self initNagationBar:@"我的Muzzik" leftBtn:Constant_backImage rightBtn:0];
    sliderView = [[SUNSlideSwitchView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    sliderView.tabItemNormalColor = Color_Text_4;
    sliderView.tabItemSelectedColor = Color_Text_2;
    sliderView.shadowImage = [[UIImage imageNamed:@"red_line_and_shadow.png"]
                              stretchableImageWithLeftCapWidth:59.0f topCapHeight:0.0f];
    [self.view addSubview:sliderView];
    sliderView.slideSwitchViewDelegate = self;
    muzzikTable = [[MuzzikTableVC alloc] init];
    muzzikTable.keeper = self;
    muzzikTable.title =@"信息";
    
    commentvc = [[CommentTableVC alloc] init];
    commentvc.keeper = self;
    commentvc.title = @"评论";
    
    
    [sliderView buildUI];
    // Do any additional setup after loading the view.
}
-(void)playnextMuzzikUpdate{
    if (self.isViewLoaded &&self.view.window) {
        [self updateAnimation];
    }
}
#pragma mark - datasource delegate
- (NSUInteger)numberOfTab:(SUNSlideSwitchView *)view
{
    return 2;
}


- (UIViewController *)slideSwitchView:(SUNSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    if (number == 0) {
        return muzzikTable;
    }
    else{
        
        return commentvc;
    }
}
- (void)slideSwitchView:(SUNSlideSwitchView *)view didselectTab:(NSUInteger)number
{
    if (number == 0) {
        [muzzikTable viewDidCurrentView];
    }
    else if (number == 1) {
        [commentvc viewDidCurrentView];
    }
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

@end
