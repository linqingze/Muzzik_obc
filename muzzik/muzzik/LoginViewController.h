//
//  LoginViewController.h
//  muzzik
//
//  Created by 林清泽 on 15/4/2.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApiObject.h"
@protocol sendMsgToWeChatViewDelegate <NSObject>
- (void) changeScene:(NSInteger)scene;
- (void) sendTextContent;
- (void) sendImageContent;
- (void) sendLinkContent;
- (void) sendMusicContent;
- (void) sendVideoContent;
- (void) sendAppContent;
- (void) sendNonGifContent;
- (void) sendGifContent;
- (void) sendAuthRequest;
- (void) sendFileContent;
- (void) testUrlLength : (NSString*) length;
- (void) openProfile;
- (void) jumpToBizWebview;
- (void) addCardToWXCardPackage;
- (void) batchAddCardToWXCardPackage;
@end



@interface LoginViewController : AMScrollingNavbarViewController
@end
