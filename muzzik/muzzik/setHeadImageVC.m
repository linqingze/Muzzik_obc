//
//  setHeadImageVC.m
//  muzzik
//
//  Created by muzzik on 15/4/15.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
#import "setHeadImageVC.h"
#import "ASIFormDataRequest.h"
#import "setGenderVC.h"
#import "JSImagePickerViewController.h"
#import "NLImageCropperView.h"
@interface setHeadImageVC ()<JSImagePickerViewControllerDelegate,NLImageCropperViewDelegate>{
    NLImageCropperView* _imageCropper;
}
@end
@implementation setHeadImageVC
-(void)viewDidLoad{
    [super viewDidLoad];
    [self initNagationBar:@"上传头像" leftBtn:Constant_backImage rightBtn:2];
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    UIImageView *defaultImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-25,SCREEN_WIDTH/2-50 , 50, 50)];
    [defaultImage setImage:[UIImage imageNamed:@"ThumbnailsImage"]];
    [headerView addSubview:defaultImage];
    UILabel *add = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH/2+23, SCREEN_WIDTH, 15)];
    [add setTextColor:[UIColor colorWithHexString:@"555555"]];
    [add setFont:[UIFont systemFontOfSize:14]];
    [add setText:@"添加头像"];
    add.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:add];
    
    UILabel *add1 = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH/2+49, SCREEN_WIDTH, 15)];
    [add1 setTextColor:[UIColor colorWithHexString:@"777777"]];
    [add1 setFont:[UIFont systemFontOfSize:12]];
    [add1 setText:@"（上传清晰头像，展示更好的自己）"];
    add1.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:add1];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getPicture)];
    [headerView addGestureRecognizer:tap];
    [self.view addSubview:headerView];
    
    headImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    headImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:headImage];
    [MuzzikItem addLineOnView:self.view heightPoint:SCREEN_WIDTH toLeft:0 toRight:0 withColor:Color_underLine];
    notifyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH+15, SCREEN_WIDTH, 20)];
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    NSString *itemStr = @"点击头像，";
    NSAttributedString *item = [self formatAttrItem:itemStr color:[UIColor colorWithHexString:@"a8acbb"] font:font];
    [text appendAttributedString:item];
    NSString *itemStr1 = @"更换头像";
    NSAttributedString *item1 = [self formatAttrItem:itemStr1 color:[UIColor colorWithHexString:@"366ab3"] font:font];
    [text appendAttributedString:item1];
    notifyLabel.attributedText = text;
    notifyLabel.textAlignment = NSTextAlignmentCenter;
    _imageCropper = [[NLImageCropperView alloc] initWithFrame:self.view.bounds];
    _imageCropper.delegate = self;
    
    
//    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-67, SCREEN_HEIGHT-133, 54, 52)];
//    [nextButton setImage:[UIImage imageNamed:@"cycleNext"] forState:UIControlStateNormal];
//    [self.view addSubview: nextButton];
//    [nextButton addTarget:self action:@selector(summitAction) forControlEvents:UIControlEventTouchUpInside];
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
-(void) rightBtnAction:(UIButton *)sender{
    if (userImage == nil) {
        setGenderVC *sethead = [[setGenderVC alloc] init];
        [self.navigationController pushViewController:sethead animated:YES];
    }else{
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@%@",BaseURL,URL_Upload_Image]]];
        
        [requestForm addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@    %@",[weakrequest originalURL],[weakrequest requestHeaders]);
            NSLog(@"%@",[weakrequest responseHeaders]);
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            if ([weakrequest responseStatusCode] == 200) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                
                ASIFormDataRequest *interRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[dic objectForKey:@"url"]]];
                [ASIFormDataRequest clearSession];
                [interRequest setPostFormat:ASIMultipartFormDataPostFormat];
                //[interRequest addRequestHeader:@"boundary" value:@"<frontier>"];
                //[interRequest addRequestHeader:@"Content-Type" value:@"multipart/form-data; charset=utf-8; boundary=0xKhTmLbOuNdArY"];
                //[interRequest addRequestHeader:@"boundary" value:@"<frontier>"];
               // interRequest addRequestHeader:@: value:<#(NSString *)#>
                [interRequest setPostValue:[[dic objectForKey:@"data"] objectForKey:@"token"] forKey:@"token"];
                NSData *imageData = UIImageJPEGRepresentation(userImage, 0.75);
                [interRequest addData:imageData forKey:@"file"];
                __weak ASIFormDataRequest *form = interRequest;
                [interRequest buildRequestHeaders];
                NSLog(@"header:%@",interRequest.requestHeaders);
                [interRequest setCompletionBlock:^{
                    NSDictionary *keydic = [NSJSONSerialization JSONObjectWithData:[form responseData] options:NSJSONReadingMutableContainers error:nil];
                    ASIHTTPRequest *updateImageRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,URL_Update_Profile]]];
                    [updateImageRequest addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[keydic objectForKey:@"key"],@"avatar", nil] Method:PostMethod auth:YES];
                    __weak ASIHTTPRequest *WeakImageRequest = updateImageRequest;
                    [updateImageRequest setCompletionBlock:^{
                        if ([WeakImageRequest responseStatusCode]==200) {
                            userInfo *user = [userInfo shareClass];
                            user.userHeadThumb = userImage;
                            user.avatar = [keydic objectForKey:@"key"];
                            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:user.token,@"token",user.uid,@"_id",user.name,@"name",user.avatar,@"avatar", nil];
                            [MuzzikItem addMessageToLocal:dic];
                            
                            setGenderVC *sethead = [[setGenderVC alloc] init];
                            [self.navigationController pushViewController:sethead animated:YES];
                            //
                            
                        }
                    }];
                    [updateImageRequest setFailedBlock:^{
                        NSLog(@"%@",[WeakImageRequest error]);
                    }];
                    [updateImageRequest startAsynchronous];
                }];
                [interRequest setFailedBlock:^{
                    NSLog(@"%@",[form responseString]);
                }];
                [interRequest startAsynchronous];

            }
            else if([weakrequest responseStatusCode] == 400){
            }
            else if([weakrequest responseStatusCode] == 409){
 
            }
        }];
        [requestForm setFailedBlock:^{
            // [SVProgressHUD showErrorWithStatus:@"network error"];
        }];
        [requestForm startAsynchronous];
    }

}
@end
