//
//  repostVC.m
//  muzzik
//
//  Created by muzzik on 15/7/8.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "repostVC.h"
#import "InformCell.h"
@interface repostVC ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *informTable;
    NSArray *informArray;
    NSMutableDictionary *RecordDic;
}

@end

@implementation repostVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"举报" leftBtn:Constant_backImage rightBtn:0];
    informTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT-104)];
    informTable.delegate = self;
    informTable.dataSource = self;
    [self.view addSubview:informTable];
    
    UIView *tipsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [tipsView setBackgroundColor:Color_line_2];
    [self.view addSubview:tipsView];
    UILabel *tips = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 40)];
    tips.font = [UIFont boldSystemFontOfSize:12];
    [tips setTextColor:Color_Text_2];
    [tips setText:@"请选择举报原因"];
    [tipsView addSubview:tips];
    [informTable registerClass:[InformCell class] forCellReuseIdentifier:@"InformCell"];
    [informTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    informArray = @[@"色情低俗",@"广告骚扰", @"政治敏感", @"欺诈骗钱", @"违法(暴力恐怖、违禁品等)", @"聚众赌博"];
    RecordDic = [NSMutableDictionary dictionary];
    // Do any additional setup after loading the view.
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InformCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InformCell" forIndexPath:indexPath];
    cell.informTextLabel.text = informArray[indexPath.row];
    if ([[RecordDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
        [cell.informImage setImage:[UIImage imageNamed:@"settingonImage"]];
    }else{
        [cell.informImage setImage:[UIImage imageNamed:@"settingoffImage"]];
    }
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return informArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (![[RecordDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
        [RecordDic setObject:informArray[indexPath.row] forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }else{
        [RecordDic removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }
    [informTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    if ([[RecordDic allKeys] count]>0) {
        [self initNagationBar:@"举报" leftBtn:Constant_backImage rightBtn:6];
    }else{
        [self initNagationBar:@"举报" leftBtn:Constant_backImage rightBtn:0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)rightBtnAction:(UIButton *)sender{
    if ([[RecordDic allKeys] count]>0) {
        NSString *messageString = [NSMutableString stringWithFormat:@"举报 %@:",self.informString];
        NSArray *array = [RecordDic allValues];
        for (NSString *tempstring in array) {
           messageString =  [messageString stringByAppendingString:[NSString stringWithFormat:@" %@",tempstring]];
        }
        ASIHTTPRequest *feedBackRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/admin/feedback",BaseURL]]];
        [feedBackRequest addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:messageString forKey:@"message"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *WeakImageRequest = feedBackRequest;
        [feedBackRequest setCompletionBlock:^{
            if ([WeakImageRequest responseStatusCode]==200) {
                [MuzzikItem showNotifyOnView:self.navigationController.view text:@"举报成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        [feedBackRequest setFailedBlock:^{
            NSLog(@"%@",[WeakImageRequest error]);

        }];
        [feedBackRequest startAsynchronous];
    }
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
