//
//  IMMessageDispatcher.m
//  muzzik
//
//  Created by muzzik on 16/2/1.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "IMMessageDispatcher.h"
#import "IMConversationViewcontroller.h"
#import "NotificationCenterViewController.h"
#import "RDVTabBarItem.h"
#import "FeedViewController.h"
#import "DetaiMuzzikVC.h"
#import "UserHomePage.h"
#import "userDetailInfo.h"
#import "TopicVC.h"

#import "IMSynMusicMessage.h"
#import "IMShareMessage.h"
#import "IMEnterMessage.h"
#import "IMListenMessage.h"
#import "Utils_IM.h"
@implementation IMMessageDispatcher

+(void)processTextMessageByRCMessage:(RCMessage *)message{
    userInfo *user = [userInfo shareClass];
    Message *coreMessage;
    Conversation *newCon ;
    UserCore *newUser;
    RCUserInfo *info;
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    RCTextMessage *textMessage = (RCTextMessage *)message.content;
    NSDictionary *infoDic = [IMMessageDispatcher decodeUserinfoRawdic:textMessage.extra];
    if (infoDic) {
        info = [[RCUserInfo alloc] initWithUserId:[infoDic objectForKey:@"_id"] name:[infoDic objectForKey:@"name"] portrait:[infoDic objectForKey:@"avatar"]];
        textMessage.senderUserInfo = info;
        newUser = [appdelegate getNewUserWithuserinfo:info];
        
    }
    
    //NSLog(@"%@ %@ %@",textMessage.senderUserInfo.name,textMessage.senderUserInfo.portraitUri,textMessage.senderUserInfo.userId);
    
    coreMessage = [appdelegate getNewMessage];
    
    coreMessage.messageType = Type_IM_TextMessage;
    coreMessage.messageContent = textMessage.content;
    coreMessage.abstractString = textMessage.content;
    coreMessage.messageUser = newUser;
    coreMessage.sendTime = [NSDate dateWithTimeIntervalSince1970:message.sentTime/1000];
    coreMessage.messageId = [NSNumber numberWithLong:message.messageId];
    coreMessage.sendStatue = Statue_OK;
    
    coreMessage.isOwner = [NSNumber numberWithBool:NO];
    
    // [self.managedObjectContext save:nil];
    newCon = [appdelegate getConversationByUserInfo:info];
    [newCon addMessagesObject:coreMessage];
    // [self.managedObjectContext save:nil];
    newCon.unReadMessage = [NSNumber numberWithInt:[newCon.unReadMessage intValue] +1];
    if ([coreMessage.abstractString length] >0) {
        newCon.abstractString = coreMessage.abstractString;
    }
    if (!newCon.sendTime) {
        coreMessage.needsToShowTime = [NSNumber numberWithBool:YES];
        newCon.sendTime =[NSDate date];
        
        
    }else if([self checkLimitedTime:coreMessage.sendTime oldDate:newCon.sendTime]){
        newCon.sendTime = coreMessage.sendTime;
        coreMessage.needsToShowTime = [NSNumber numberWithBool:YES];
    }else{
        newCon.sendTime = coreMessage.sendTime;
        coreMessage.needsToShowTime = [NSNumber numberWithBool:NO];
    }
    [appdelegate.managedObjectContext save:nil];
    if (![user.account.myConversation.firstObject.targetId isEqualToString:message.targetId]) {
        [user.account removeMyConversationObject:newCon];
        [user.account insertObject:newCon inMyConversationAtIndex:0];
    }
    [appdelegate.managedObjectContext save:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *nac = (UINavigationController *)appdelegate.tabviewController.selectedViewController;
        if (nac == appdelegate.notifyVC) {
            if ([nac.viewControllers.lastObject isKindOfClass:[NotificationCenterViewController class]]) {
                NotificationCenterViewController *notifyvc = (NotificationCenterViewController *)nac.viewControllers.lastObject ;
                [notifyvc newMessageArrive];
            }else if([nac.viewControllers.lastObject isKindOfClass:[IMConversationViewcontroller class]]){
                //handle message
                IMConversationViewcontroller* vc =(IMConversationViewcontroller *)nac.viewControllers.lastObject;
                if ([vc.con.targetId isEqualToString:message.targetId]) {
                    [vc receiveInserCellWithMessage:coreMessage];
                }
                
            }
        }
        else{
            //设置红点
            RDVTabBarItem *item = [[[appdelegate.tabviewController tabBar] items] objectAtIndex:3];
            UIImage *selectedimage = [UIImage imageNamed:@"tabbarNotification_Selected"];
            UIImage *unselectedimage = [UIImage imageNamed:@"tabbarGetNotifucation"];
            [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
            user.targetUserinfo = info;
            user.notificationType = NotificationType_IM;
            user.notificationMessage = [NSString stringWithFormat:@"%@: %@",info.name,coreMessage.abstractString];
            NSLog(@"%@",nac.viewControllers.lastObject);
            if ([nac.viewControllers.lastObject isKindOfClass:[FeedViewController class]] || [nac.viewControllers.lastObject isKindOfClass:[DetaiMuzzikVC class]] || [nac.viewControllers.lastObject isKindOfClass:[userDetailInfo class]]  || [nac.viewControllers.lastObject isKindOfClass:[UserHomePage class]]||[nac.viewControllers.lastObject isKindOfClass:[TopicVC class]]  ){
                [MuzzikItem showNewNotifyByText:user.notificationMessage ];
            }
            
        }
    });

}

+(void)processShareMessageByRCMessage:(RCMessage *)message{
    
    userInfo *user = [userInfo shareClass];
    Message *coreMessage;
    Conversation *newCon ;
    UserCore *newUser;
    RCUserInfo *info;
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    IMShareMessage *shareMessage = (IMShareMessage *)message.content;
    
    NSDictionary *infoDic = [IMMessageDispatcher decodeUserinfoRawdic:shareMessage.extra];
    if (infoDic) {
        info = [[RCUserInfo alloc] initWithUserId:[infoDic objectForKey:@"_id"] name:[infoDic objectForKey:@"name"] portrait:[infoDic objectForKey:@"avatar"]];
        shareMessage.senderUserInfo = info;
        newUser = [appdelegate getNewUserWithuserinfo:info];
    }
    coreMessage = [appdelegate getNewMessage];
    coreMessage.messageData =[shareMessage.jsonStr  dataUsingEncoding:NSUTF8StringEncoding];
    coreMessage.messageType = Type_IM_ShareMuzzik;
    coreMessage.abstractString = @"[Muzzik]";
    
    coreMessage.messageUser = newUser;
    coreMessage.sendTime = [NSDate dateWithTimeIntervalSince1970:message.sentTime/1000];
    coreMessage.messageId = [NSNumber numberWithLong:message.messageId];
    coreMessage.sendStatue = Statue_OK;
    
    coreMessage.isOwner = [NSNumber numberWithBool:NO];
    
    // [self.managedObjectContext save:nil];
    newCon = [appdelegate getConversationByUserInfo:info];
    [newCon addMessagesObject:coreMessage];
    // [self.managedObjectContext save:nil];
    newCon.unReadMessage = [NSNumber numberWithInt:[newCon.unReadMessage intValue] +1];
     newCon.abstractString = coreMessage.abstractString;
    if (!newCon.sendTime) {
        coreMessage.needsToShowTime = [NSNumber numberWithBool:YES];
        newCon.sendTime =[NSDate date];
        
        
    }else if([self checkLimitedTime:coreMessage.sendTime oldDate:newCon.sendTime]){
        newCon.sendTime = coreMessage.sendTime;
        coreMessage.needsToShowTime = [NSNumber numberWithBool:YES];
    }else{
        newCon.sendTime = coreMessage.sendTime;
        coreMessage.needsToShowTime = [NSNumber numberWithBool:NO];
    }
    [appdelegate.managedObjectContext save:nil];
    if (![user.account.myConversation.firstObject.targetId isEqualToString:message.targetId]) {
        [user.account removeMyConversationObject:newCon];
        [user.account insertObject:newCon inMyConversationAtIndex:0];
    }
    [appdelegate.managedObjectContext save:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *nac = (UINavigationController *)appdelegate.tabviewController.selectedViewController;
        if (nac == appdelegate.notifyVC) {
            if ([nac.viewControllers.lastObject isKindOfClass:[NotificationCenterViewController class]]) {
                NotificationCenterViewController *notifyvc = (NotificationCenterViewController *)nac.viewControllers.lastObject ;
                [notifyvc newMessageArrive];
            }else if([nac.viewControllers.lastObject isKindOfClass:[IMConversationViewcontroller class]]){
                //handle message
                IMConversationViewcontroller* vc =(IMConversationViewcontroller *)nac.viewControllers.lastObject;
                if ([vc.con.targetId isEqualToString:message.targetId]) {
                    [vc receiveInserCellWithMessage:coreMessage];
                }
                
            }
        }
        else{
            //设置红点
            RDVTabBarItem *item = [[[appdelegate.tabviewController tabBar] items] objectAtIndex:3];
            UIImage *selectedimage = [UIImage imageNamed:@"tabbarNotification_Selected"];
            UIImage *unselectedimage = [UIImage imageNamed:@"tabbarGetNotifucation"];
            [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
            user.targetUserinfo = info;
            user.notificationType = NotificationType_IM;
            user.notificationMessage = [NSString stringWithFormat:@"%@: %@",info.name,coreMessage.abstractString];
            NSLog(@"%@",nac.viewControllers.lastObject);
            if ([nac.viewControllers.lastObject isKindOfClass:[FeedViewController class]] || [nac.viewControllers.lastObject isKindOfClass:[DetaiMuzzikVC class]] || [nac.viewControllers.lastObject isKindOfClass:[userDetailInfo class]]  || [nac.viewControllers.lastObject isKindOfClass:[UserHomePage class]]||[nac.viewControllers.lastObject isKindOfClass:[TopicVC class]]  ){
                [MuzzikItem showNewNotifyByText:user.notificationMessage ];
            }
            
        }
    });

    
    
    
}

+(void)processEnterMessageByRCMessage:(RCMessage *)message{
    userInfo *user = [userInfo shareClass];
    Message *coreMessage;
    Conversation *newCon ;
    UserCore *newUser;
    RCUserInfo *info;
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    
    IMEnterMessage *shareMessage = (IMEnterMessage *)message.content;
    
    NSDictionary *infoDic = [IMMessageDispatcher decodeUserinfoRawdic:shareMessage.extra];
    
    if (infoDic) {
        info = [[RCUserInfo alloc] initWithUserId:[infoDic objectForKey:@"_id"] name:[infoDic objectForKey:@"name"] portrait:[infoDic objectForKey:@"avatar"]];
        shareMessage.senderUserInfo = info;
        newUser = [appdelegate getNewUserWithuserinfo:info];
    }
    
    NSDictionary *enterDic = [NSJSONSerialization JSONObjectWithData:[shareMessage.jsonStr  dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"%@",enterDic);
    NSLog(@"same:%d",[user.listenUser containsObject:newUser]);
    if ([[enterDic objectForKey:@"watch"] boolValue]) {
        [user.listenUser addObject:newUser];
        
        if ([Globle shareGloble].isPlaying) {
            IMSynMusicMessage *listenmessage = [[IMSynMusicMessage alloc] init];
            listenmessage.extra = [Utils_IM DataTOjsonString:[NSDictionary dictionaryWithObjectsAndKeys:user.name,@"name",user.avatar,@"avatar",user.uid,@"_id", nil]];
            muzzik *playMuzzik = [MuzzikPlayer shareClass].playingMuzzik;
            listenmessage.jsonStr = [Utils_IM DataTOjsonString:[NSDictionary dictionaryWithObjectsAndKeys:playMuzzik.music.music_id,@"_id",playMuzzik.music.name,@"name",playMuzzik.music.artist,@"artist",playMuzzik.music.key,@"key",user.rootId,@"root", nil]];
            [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:newUser.user_id content:listenmessage pushContent:nil success:^(long messageId) {
                NSLog(@"%d",messageId);
            } error:^(RCErrorCode nErrorCode, long messageId) {
                NSLog(@"%d",nErrorCode);
            } ];
        }
        
    }else{
        [user.listenUser removeObject:newUser];
    }
    coreMessage = [appdelegate getNewMessage];
    coreMessage.messageData =[shareMessage.jsonStr  dataUsingEncoding:NSUTF8StringEncoding];
    coreMessage.messageType = Type_IM_Enter;
    coreMessage.messageUser = newUser;
    coreMessage.sendTime = [NSDate dateWithTimeIntervalSince1970:message.sentTime/1000];
    coreMessage.messageId = [NSNumber numberWithLong:message.messageId];
    coreMessage.sendStatue = Statue_OK;
    
    coreMessage.isOwner = [NSNumber numberWithBool:NO];
    
    // [self.managedObjectContext save:nil];
    
    BOOL contained = NO;
    for (NSInteger i = 0; i < user.account.myConversation.count; i++) {
        Conversation * tempCon = [user.account.myConversation objectAtIndex:i];
        if ([info.userId isEqualToString:tempCon.targetId]) {
            newCon = tempCon;
            contained = YES;
            break;
        }
    }
    if(contained){
        if (![newCon.targetUser.name isEqualToString:info.name] || ![newCon.targetUser.avatar isEqualToString:info.portraitUri]) {
            newCon.targetUser.name = info.name;
            newCon.targetUser.avatar = info.portraitUri;
            [appdelegate.managedObjectContext save:nil];
        }
        
    }else{
        
        newCon = [appdelegate getNewConversationWithTargetId:info.userId];
        newCon.targetId = info.userId;
        
        newCon.targetUser = [appdelegate getNewUserWithuserinfo:info];
    }
    [newCon addMessagesObject:coreMessage];
    // [self.managedObjectContext save:nil];
    if (!newCon.sendTime) {
        coreMessage.needsToShowTime = [NSNumber numberWithBool:YES];
        newCon.sendTime =[NSDate date];

    }else if([self checkLimitedTime:coreMessage.sendTime oldDate:newCon.sendTime]){
        newCon.sendTime = coreMessage.sendTime;
        coreMessage.needsToShowTime = [NSNumber numberWithBool:YES];
    }else{
        newCon.sendTime = coreMessage.sendTime;
        coreMessage.needsToShowTime = [NSNumber numberWithBool:NO];
    }
    [appdelegate.managedObjectContext save:nil];
    if (![user.account.myConversation.firstObject.targetId isEqualToString:message.targetId]) {
        [user.account removeMyConversationObject:newCon];
        [user.account insertObject:newCon inMyConversationAtIndex:0];
    }
    [appdelegate.managedObjectContext save:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *nac = (UINavigationController *)appdelegate.tabviewController.selectedViewController;
        if (nac == appdelegate.notifyVC) {
            if ([nac.viewControllers.lastObject isKindOfClass:[NotificationCenterViewController class]]) {
                NotificationCenterViewController *notifyvc = (NotificationCenterViewController *)nac.viewControllers.lastObject ;
                [notifyvc newMessageArrive];
            }else if([nac.viewControllers.lastObject isKindOfClass:[IMConversationViewcontroller class]]){
                //handle message
                IMConversationViewcontroller* vc =(IMConversationViewcontroller *)nac.viewControllers.lastObject;
                if ([vc.con.targetId isEqualToString:message.targetId]) {
                    [vc receiveInserCellWithMessage:coreMessage];
                }
                
            }
        }
    });
    
}


+(void)processSynMusicMessageByRCMessage:(RCMessage *)message{
    userInfo *user = [userInfo shareClass];
    UserCore *newUser;
    RCUserInfo *info;
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    
    IMSynMusicMessage *shareMessage = (IMSynMusicMessage *)message.content;
    
    NSDictionary *infoDic = [IMMessageDispatcher decodeUserinfoRawdic:shareMessage.extra];
    
    if (infoDic) {
        info = [[RCUserInfo alloc] initWithUserId:[infoDic objectForKey:@"_id"] name:[infoDic objectForKey:@"name"] portrait:[infoDic objectForKey:@"avatar"]];
        shareMessage.senderUserInfo = info;
        newUser = [appdelegate getNewUserWithuserinfo:info];
    }
    
    NSDictionary *musicDic = [NSJSONSerialization JSONObjectWithData:[shareMessage.jsonStr  dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    if (musicDic) {
        if ([info.userId isEqualToString:user.listenToUid]) {
            muzzik *playMuzzik = [MuzzikPlayer shareClass].playingMuzzik;
            if (![[musicDic objectForKey:@"root"] isEqualToString:user.uid] &&![playMuzzik.music.key isEqualToString:[musicDic objectForKey:@"key"]]) {
                muzzik *newmuzzik = [muzzik new];
                newmuzzik.music = [music new];
                newmuzzik.music.music_id = [musicDic objectForKey:@"_id"];
                newmuzzik.music.artist = [musicDic objectForKey:@"artist"];
                newmuzzik.music.key = [musicDic objectForKey:@"key"];
                newmuzzik.music.name = [musicDic objectForKey:@"name"];
                [[MuzzikPlayer shareClass] playSongWithSongModel:newmuzzik Title:@"跟着听"];
            }
        }
        UINavigationController *nac = (UINavigationController *) appdelegate.tabviewController.selectedViewController;
        if ([nac.viewControllers.lastObject isKindOfClass:[IMConversationViewcontroller class]]) {
            IMConversationViewcontroller *imvc = (IMConversationViewcontroller *)nac.viewControllers.lastObject;
            if ([imvc.con.targetId isEqualToString:info.userId]) {
                [imvc updateSynMusicMessage:musicDic];
            }
        }
    }
}

+(void)processListenToMessageByRCMessage:(RCMessage *)message{
    userInfo *user = [userInfo shareClass];
    UserCore *newUser;
    RCUserInfo *info;
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    
    IMListenMessage *shareMessage = (IMListenMessage *)message.content;
    
    NSDictionary *infoDic = [IMMessageDispatcher decodeUserinfoRawdic:shareMessage.extra];
    
    if (infoDic) {
        info = [[RCUserInfo alloc] initWithUserId:[infoDic objectForKey:@"_id"] name:[infoDic objectForKey:@"name"] portrait:[infoDic objectForKey:@"avatar"]];
        shareMessage.senderUserInfo = info;
        newUser = [appdelegate getNewUserWithuserinfo:info];
        [user.listenUser addObject:newUser];
    }
    
}

+(void)processCancelMessageByRCMessage:(RCMessage *)message{
    userInfo *user = [userInfo shareClass];
    UserCore *newUser;
    RCUserInfo *info;
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    
    IMListenMessage *shareMessage = (IMListenMessage *)message.content;
    
    NSDictionary *infoDic = [IMMessageDispatcher decodeUserinfoRawdic:shareMessage.extra];
    
    if (infoDic) {
        info = [[RCUserInfo alloc] initWithUserId:[infoDic objectForKey:@"_id"] name:[infoDic objectForKey:@"name"] portrait:[infoDic objectForKey:@"avatar"]];
        shareMessage.senderUserInfo = info;
        newUser = [appdelegate getNewUserWithuserinfo:info];
        if ([user.listenUser containsObject:newUser]) {
            [user.listenUser removeObject:newUser];
        }
        
    }
}

+(NSDictionary *) decodeUserinfoRawdic:(NSString *)rawString{
    if (rawString) {
        NSData *dicData = [rawString dataUsingEncoding:NSUTF8StringEncoding];
        if (dicData) {
            return [NSJSONSerialization JSONObjectWithData:dicData options:NSJSONReadingMutableContainers error:nil];
        }
    }
    return nil;
}

+(BOOL) checkLimitedTime:(NSDate *)new oldDate:(NSDate *)old{
    NSTimeInterval newInterval = [new timeIntervalSinceReferenceDate];
    NSTimeInterval oldInterval = [old timeIntervalSinceReferenceDate];
    if (newInterval - oldInterval > 300) {
        return YES;
    }else{
        return NO;
    }
}
@end
