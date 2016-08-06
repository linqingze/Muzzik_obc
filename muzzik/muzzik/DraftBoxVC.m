//
//  DraftBoxVC.m
//  muzzik
//
//  Created by muzzik on 15/6/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "DraftBoxVC.h"
#import "DraftsCell.h"
#import "MessageStepViewController.h"
@interface DraftBoxVC ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *draftTableView;
    NSArray *draftArray;
}

@end

@implementation DraftBoxVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"草稿箱" leftBtn:Constant_backImage rightBtn:0];
    draftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:draftTableView];
    [self followScrollView:draftTableView];
    draftTableView.delegate = self;
    draftTableView.dataSource = self;
    [draftTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [draftTableView registerClass:[DraftsCell class] forCellReuseIdentifier:@"DraftsCell"];

    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    draftArray = [MuzzikItem muzzikDraftsFromLocal];
    [draftTableView reloadData];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DraftsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DraftsCell" forIndexPath:indexPath];
    NSDictionary *dic = draftArray[indexPath.row];
    
    cell.timeLabel.text = [dic objectForKey:@"lastdate"];
    cell.songName.text = [dic objectForKey:@"music_name"];
    cell.Artist.text = [dic objectForKey:@"music_artist"];
    if ([[dic objectForKey:@"message"] length]>0) {
        cell.message.text = [dic objectForKey:@"message"];
        [cell.songview setFrame:CGRectMake(0, 60, SCREEN_WIDTH, 60)];
    }else{
        cell.message.text = @"";
        [cell.songview setFrame:CGRectMake(0, 20, SCREEN_WIDTH, 60)];
    }
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-50, 20)];
    [tempLabel setFont:[UIFont fontWithName:Font_Next_Bold size:15]];
    tempLabel.text = cell.songName.text;
    [tempLabel sizeToFit];
    UILabel *tempArtist = [[UILabel alloc] init];
    [tempArtist setFont:[UIFont fontWithName:Font_Next_Bold size:12]];
    tempArtist.text = cell.Artist.text;
    [tempArtist sizeToFit];
    
    int maxWidtg = tempArtist.frame.size.width >tempLabel.frame.size.width ? tempArtist.frame.size.width:tempLabel.frame.size.width;
    if (maxWidtg >SCREEN_WIDTH-50) {
        [cell.songImage setFrame:CGRectMake(SCREEN_WIDTH-30, 23, 15, 15)];
    }else{
        [cell.songImage setFrame:CGRectMake(maxWidtg+40, 23, 15, 15)];
    }
    UIColor *color = Color_Action_Button_2;
//    if (indexPath.row%3 == 0) {
//        color = Color_Action_Button_1;
//    }else if(indexPath.row%3 == 1){
//        color = Color_Action_Button_2;
//    }else{
//        color = Color_Action_Button_3;
//    }
    [cell.songName setTextColor:color];
    [cell.Artist setTextColor:color];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = draftArray[indexPath.row];
    MuzzikObject *mobject = [MuzzikObject shareClass];
    music *localMusic = [music new];
    userInfo *user = [userInfo shareClass];
    user.poController = self;
    localMusic.music_id = [dic objectForKey:@"music_id"];
    localMusic.name = [dic objectForKey:@"music_name"];
    localMusic.artist = [dic objectForKey:@"music_artist"];
    localMusic.key  =   [dic objectForKey:@"music_key"];
    mobject.music = localMusic;
    if ([[dic allKeys] containsObject:@"image"]) {
        mobject.image = [UIImage imageWithData:[dic objectForKey:@"image"]];
    }
    //[MuzzikItem getLyricByMusic:localMusic];
    
    MessageStepViewController *msgvc = [[MessageStepViewController alloc] init];
    msgvc.message = [dic objectForKey:@"message"];
    NSMutableArray * array = [NSMutableArray arrayWithArray:draftArray];
    [array removeObjectAtIndex:indexPath.row];
    draftArray = [array copy];
    [MuzzikItem addMuzzikDraftsToLocal:draftArray];
    [self.navigationController pushViewController:msgvc animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = draftArray[indexPath.row];
    if ([[dic objectForKey:@"message"] length]>0) {
        return 120;
    }else{
        return 80;
    }
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return draftArray.count;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSMutableArray * array = [NSMutableArray arrayWithArray:draftArray];
        [array removeObjectAtIndex:indexPath.row];
        draftArray = [array copy];
        [MuzzikItem addMuzzikDraftsToLocal:draftArray];
         [tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
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
