//
//  IMConversationViewcontroller.m
//  muzzik
//
//  Created by muzzik on 15/12/30.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "IMConversationViewcontroller.h"
#import "ownerTableViewCell.h"
@interface IMConversationViewcontroller ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *IMTableView;
    UIView *IMTalkView;
    NSMutableArray *messageArray;
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
    [IMTableView registerClass:[ownerTableViewCell class] forCellReuseIdentifier:@"ownerTableViewCell"];
    
}
-(void) settingTalkView{
    
}
#pragma mark tableView_DelegateMethod

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return messageArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Message *message = messageArray[indexPath.row];
    
    NSLog(@"%@",message.cellHeight);
    if (!message.cellHeight) {
        ownerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        message.cellHeight =[NSNumber numberWithDouble:[cell configureCellWithMessage:message]];
    }
    return [message.cellHeight doubleValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     ownerTableViewCell*  cell = [tableView dequeueReusableCellWithIdentifier:@"ownerTableViewCell" forIndexPath:indexPath];
    Message *tempMessage = messageArray[indexPath.row];
    [cell configureCellWithMessage:tempMessage];
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

@end
