//
//  choosImageVC.m
//  muzzik
//
//  Created by muzzik on 15/4/28.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "choosImageVC.h"
#import "ASIFormDataRequest.h"
#import "JSImagePickerViewController.h"
#import "ChooseLyricVC.h"
#import "NLImageCropperView.h"
@interface choosImageVC ()<JSImagePickerViewControllerDelegate,NLImageCropperViewDelegate>{
    NLImageCropperView* _imageCropper;
}
@end
@implementation choosImageVC
-(void)viewDidLoad{
    [super viewDidLoad];
    [self initNagationBar:@"添加图片（2/3）" leftBtn:Constant_backImage rightBtn:2];
     headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    UIImageView *defaultImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-25,SCREEN_WIDTH/2-50 , 50, 50)];
    [defaultImage setImage:[UIImage imageNamed:@"ThumbnailsImage"]];
    [headerView addSubview:defaultImage];
    UILabel *add = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH/2+23, SCREEN_WIDTH, 15)];
    [add setTextColor:[UIColor colorWithHexString:@"555555"]];
    [add setFont:[UIFont systemFontOfSize:14]];
    [add setText:@"添加图片"];
    add.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:add];
    
    UILabel *add1 = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH/2+49, SCREEN_WIDTH, 15)];
    [add1 setTextColor:[UIColor colorWithHexString:@"777777"]];
    [add1 setFont:[UIFont systemFontOfSize:12]];
    [add1 setText:@"（上传图片，丰富你的Muzzik）"];
    add1.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:add1];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getPicture)];
    [headerView addGestureRecognizer:tap];
    [self.view addSubview:headerView];
    
    headImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    headImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:headImage];
    [MuzzikItem addLineOnView:self.view heightPoint:SCREEN_WIDTH toLeft:13 toRight:13 withColor:Color_underLine];
    notifyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH+15, SCREEN_WIDTH, 30)];
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    NSString *itemStr = @"点击图片，";
    NSAttributedString *item = [self formatAttrItem:itemStr color:[UIColor colorWithHexString:@"a8acbb"] font:font];
    [text appendAttributedString:item];
    NSString *itemStr1 = @"更换";
    NSAttributedString *item1 = [self formatAttrItem:itemStr1 color:[UIColor colorWithHexString:@"366ab3"] font:font];
    [text appendAttributedString:item1];
    notifyLabel.attributedText = text;
    notifyLabel.textAlignment = NSTextAlignmentCenter;
    _imageCropper = [[NLImageCropperView alloc] initWithFrame:self.view.bounds];
    _imageCropper.delegate = self;
}
-(void) getPicture{
    JSImagePickerViewController *imagePicker = [[JSImagePickerViewController alloc] init];
    imagePicker.delegate = self;
    [imagePicker showImagePickerInController:self animated:YES];

   
}
#pragma mark - JSImagePikcerViewControllerDelegate

- (void)imagePickerDidSelectImage:(UIImage *)image {
    [_imageCropper setImage:image];
    CGFloat minLength = image.size.width <image.size.height ? image.size.width : image.size.height;
    if (minLength >200) {
        [_imageCropper setCropRegionRect:CGRectMake(image.size.width/2-100*_imageCropper.scalingFactor, image.size.height/2 - 100*_imageCropper.scalingFactor, 200*_imageCropper.scalingFactor, 200*_imageCropper.scalingFactor)];
    }else{
        [_imageCropper setCropRegionRect:CGRectMake(image.size.width/2-minLength/2, image.size.height/2 - minLength/2, minLength*_imageCropper.scalingFactor, minLength)];
    }
    [self.navigationController.view addSubview:_imageCropper];
}
-(void)userCropImage:(UIImage *)image{
    userImage = image;
    [headImage setImage:image];
    notifyLabel.alpha = 0;
    [self.view addSubview:notifyLabel];
    [UIView animateWithDuration:0.3 animations:^{
        [notifyLabel setAlpha:1];
    }];
}
-(NSAttributedString *)formatAttrItem:(NSString *)content color:(UIColor *)color font:(UIFont *)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.maximumLineHeight = 25.f;
    paragraphStyle.minimumLineHeight = 15.f;
    paragraphStyle.lineHeightMultiple = 20.f;
    
    NSDictionary *attrDict = @{NSParagraphStyleAttributeName: paragraphStyle,
                               NSForegroundColorAttributeName:color,
                               NSFontAttributeName:font};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]
                                          initWithString: content
                                          attributes:attrDict];
    return attrStr;
}
-(void)rightBtnAction:(UIButton *)sender{
    ChooseLyricVC *chooselyricvc = [[ChooseLyricVC alloc] init];
    chooselyricvc.image = headImage.image;
    [self.navigationController pushViewController:chooselyricvc animated:YES];
}
@end
