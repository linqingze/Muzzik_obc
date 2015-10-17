//
//  ClassifySelectionVC.m
//  muzzik
//
//  Created by muzzik on 15/5/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "ClassifySelectionVC.h"
#import "SelectionLabel.h"
@interface ClassifySelectionVC ()<SelectionLabelDelegate,UITableViewDelegate>{
    UITableView *selectionTableView;
    NSMutableArray *classArray;
    NSMutableDictionary *Fdictionary;
    BOOL ischange;
    UIView *headView;
}

@end

@implementation ClassifySelectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNagationBar:@"选择风格" leftBtn:Constant_backImage rightBtn:3];
    selectionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:selectionTableView];
    headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    selectionTableView.delegate = self;
    [selectionTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [selectionTableView setTableHeaderView:headView];
    Fdictionary = [NSMutableDictionary dictionary];
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Classify]]];
    [requestForm addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData]  options:NSJSONReadingMutableContainers error:nil];
            classArray = [dic objectForKey:@"genres"];
            
            
            NSMutableArray *labelArray = [NSMutableArray array];
            for (NSDictionary * dic in classArray) {
                SelectionLabel *tempLabel = [[SelectionLabel alloc ] initWithFrame:CGRectMake(0, 0, 100, 30)];
                [tempLabel setFont:[UIFont systemFontOfSize:15]];
                tempLabel.genre = dic;
                tempLabel.delegate = self;
                [tempLabel setText:[dic objectForKey:@"data"]];
                [tempLabel sizeToFit];
                [tempLabel setFrame:CGRectMake(0, 0, tempLabel.frame.size.width+30, 30)];
                tempLabel.layer.cornerRadius = 15;
                tempLabel.clipsToBounds = YES;
                for (NSDictionary *tempdic in [_profileDic objectForKey:@"genres"]) {
                    if ([[tempdic objectForKey:@"_id"] isEqualToString:[dic objectForKey:@"_id"]]) {
                        tempLabel.isSelected = YES;
                        break;
                    }
                }
                if (tempLabel.isSelected) {
                    [tempLabel setTextColor:Color_Active_Button_1];
                }else{
                    [tempLabel setTextColor:Color_Text_1];
                }
                
                tempLabel.textAlignment = NSTextAlignmentCenter;
                [tempLabel setBackgroundColor:Color_line_2];
                if (tempLabel.frame.size.width>SCREEN_WIDTH-26) {
                    continue;
                }
                [labelArray addObject:tempLabel];
            }
            int maxXpoint = SCREEN_WIDTH-13;
            int localheight = 25;
            int localX = 13;
            while ([labelArray count]>0) {
                UILabel *templabel = [labelArray firstObject];
                if (localX + templabel.frame.size.width > maxXpoint) {
                    for (int i =1; i<labelArray.count; i++) {
                        UILabel *subTempLabel = labelArray[i];
                        if (localX+subTempLabel.frame.size.width+13 < maxXpoint) {
                            [subTempLabel setFrame:CGRectMake(localX, localheight, subTempLabel.frame.size.width, subTempLabel.frame.size.height)];
                            [headView addSubview:subTempLabel];
                            [labelArray removeObject:subTempLabel];
                            localX = localX +subTempLabel.frame.size.width+13;
                            break;
                        }
                    }
                    localX = 13;
                    localheight = localheight+50;
                }
                else{
                    [templabel setFrame:CGRectMake(localX, localheight, templabel.frame.size.width, templabel.frame.size.height)];
                    [headView addSubview:templabel];
                    [labelArray removeObject:templabel];
                    localX = localX+templabel.frame.size.width+13;
                    
                }
            }
            [headView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, localheight+55)];
            [selectionTableView setTableHeaderView:headView];
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
    // Do any additional setup after loading the view.
}

-(void)rightBtnAction:(UIButton *)sender{
    if (ischange) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@%@",BaseURL,URL_Update_Profile]]];
        NSMutableDictionary *dic= [NSMutableDictionary dictionaryWithObjectsAndKeys:[_profileDic objectForKey:@"genres"],@"genres", nil];
        [requestForm addBodyDataSourceWithJsonByDic:dic Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            if ([weakrequest responseStatusCode] == 200 && [[dic objectForKey:@"result"] boolValue]) {
                [self.navigationController popViewControllerAnimated:YES];
                //
            }
        }];
        [requestForm setFailedBlock:^{
            // [SVProgressHUD showErrorWithStatus:@"network error"];
        }];
        [requestForm startAsynchronous];
    }
    
}
-(void)tappedWithObject:(SelectionLabel *)sender{
    ischange = YES;
    if (sender.isSelected) {
        sender.isSelected = NO;
        [sender setTextColor:Color_Text_1];
        NSMutableArray *array = [_profileDic objectForKey:@"genres"];
        for (NSDictionary *dic in array) {
            if ([[dic objectForKey:@"_id"] isEqualToString:[sender.genre objectForKey:@"_id"]]) {
                [array removeObject:dic];
                
                break;
            }
        }
    }else{
        sender.isSelected = YES;
        [sender setTextColor:Color_Active_Button_1];
        NSMutableArray *array = [_profileDic objectForKey:@"genres"];
        [array addObject:sender.genre];
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
