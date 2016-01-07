//
//  IMConversationViewcontroller.m
//  muzzik
//
//  Created by muzzik on 15/12/30.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "IMConversationViewcontroller.h"

@interface IMConversationViewcontroller ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *IMTableView;
    UIView *IMTalkView;
}

@end

@implementation IMConversationViewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingTableView];
    [self settingTalkView];
    // Do any additional setup after loading the view.
}
-(void) settingTableView{
    IMTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-50)];
    IMTableView.backgroundColor = [UIColor whiteColor];
    IMTableView.delegate = self;
    IMTableView.dataSource = self;
    
}
-(void) settingTalkView{
    
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
