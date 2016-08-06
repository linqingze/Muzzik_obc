//
//  Muzzik_Configure_Luc.h
//  muzzik
//
//  Created by muzzik on 15/12/28.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#ifndef Muzzik_Configure_Luc_h
#define Muzzik_Configure_Luc_h


#define AppKey_RongClound   @"pgyu6atqy0stu"
#define AppKey_UMeng        @"55a7d11367e58e98ba005693"

#pragma mark -URL

#define URL_RongClound_Token        @"api/user/rongCloudToken"
#define URL_IM_FriendList           @"api/user/friends"

//直接加进链接 friendId="xxxx"
#define URL_Create_Friendship       @"api/user/friendship/"
#define URL_Check_Friendship        @"api/user/friendship/check/"

//参数 { friendId:"xxx"}
#define URL_Freeze_Friendship       @"api/user/friendship/freeze "
#define URL_Unfreeze_Friendship     @"api/user/friendship/unfreeze"
#define URL_Blacklist               @"api/user/friendship/blacklist"

#endif /* Muzzik_Configure_Luc_h */
