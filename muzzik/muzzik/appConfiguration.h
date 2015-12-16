//
//  appConfiguration.h
//  muzzik
//
//  Created by 林清泽 on 15/3/3.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//http://117.121.26.174:8000/api/notify?token=o8SAVQenhKzgD3R5gHxIzl3ahCHPWKY6rJvIT9aMnk0~&type=participate_topic
// 172.11.23.22:8080
#ifndef muzzik_appConfiguration_h
#define muzzik_appConfiguration_h
//手机屏幕
#define SCREEN_WIDTH [ UIScreen mainScreen ].bounds.size.width
#define SCREEN_HEIGHT [ UIScreen mainScreen ].bounds.size.height
#define SquareCELL_Width [ UIScreen mainScreen ].bounds.size.width-60
#define SquareCELL_Height [ UIScreen mainScreen ].bounds.size.height-200
#pragma -mark URL Address
#define URL_Muzzik_download     @"http://www.muzziker.com/download"
#define URL_Muzzik_SharePage    @"http://www.muzziker.com/app/muzzik/"
#define URL_Lyric_Me            @"http://geci.me/api/lyric/"
#define BaseURL                 @"http://117.121.26.174/"
#define BaseURL_GUI             @"http://117.121.26.174:8000/"
//#define BaseURL                 @"http://192.168.1.110:3000/"
#define BaseURL_audio           @"http://7bvaim.com1.z0.glb.clouddn.com/"
#define BaseURL_image           @"http://7bvarm.com1.z0.glb.clouddn.com/"

#define URL_protocol            @"http://www.muzziker.com/about.html"

#define URL_WeiBo_redirectURI   @"http://muzziker.com"
#define URL_QQ_AUTH             @"auth/qq?access_token="
#define URL_WeiBo_AUTH          @"auth/weibo?access_token="
#define URL_WeiChat_AUTH        @"auth/weixin/callback"
#define URL_Muzzik_Trending     @"api/muzzik/trending"

#define URL_check_phone         @"api/user/check"
#define URL_register            @"api/user/register"
#define URL_GetVerifiCode       @"api/user/verifiCode"
#define URL_Login               @"api/user/login"
#define URL_Update_Profile      @"api/user/profile"
#define URL_Upload_Image        @"api/image/upload/params"
#define URL_Upload_audio        @"api/music/upload/params"

#define URL_Reset_Pwd           @"api/user/resetPassword"
#define URL_Get_Moved_music     @"api/user/movedMusic"
#define URL_Get_suggest_muzzik  @"api/muzzik/suggest"
#define URL_Set_Notify          @"api/notify/set"
#define URL_UnMoved             @"api/music/moved/"
#define URL_Music_Search        @"api/music"
#define URL_Friends_get         @"api/user/friends"
#define URL_RecentContact       @"api/user/recentContact"
#define URL_Get_Topic           @"api/topic"
#define URL_Muzzik_new          @"api/muzzik"
#define URL_MovedUsers          @"api/user/byMovedMuzzik/"
#define URL_RepostUsers         @"api/user/byRepostedMuzzik/"
#define URL_ShareUsers          @"api/user/bySharedMuzzik/"
#define URL_Users_search        @"api/user"
#define URL_Topic_search        @"api/topic"
#define URL_User_Follow         @"api/user/follow"                     //post 方法，auth，加id字段
#define URL_user_Unfollow       @"api/user/unfollow"   //同上
#define URL_Classify            @"api/common/musicGenre"
#define URL_Logout              @"api/user/logout"
#define URL_Get_Feed            @"api/muzzik/feeds"
#define URL_Notify              @"api/notify"
#define URL_Read_Notify         @"api/notify/readed"
#define URL_Music_Lyric_get     @"api/music/lyric"
#define URL_New_Notify          @"api/notify/havenew"
#define URL_Moved_Muzziks       @"api/user/movedMuzzik"
#define URL_New_notify_Now      @"api/notify/havenew"
#define URL_Share_Muzzik        @"api/muzzik/share"
//#define URL_check_phone @"http://192.168.1.112:3000/api/user/check"
//#define URL_register @"http://192.168.1.112:3000/api/user/register"
//#define URL_GetVerifiCode @"http://192.168.1.112:3000/api/user/verifiCode"
//#define URL_Login @"http://192.168.1.112:3000/api/user/login"



#pragma -mark App_Color
#define Color_underLine             [UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1]
#define Color_scarlet               [UIColor colorWithRed:171.0/255.0 green:33.0/255.0 blue:31.0/255.0 alpha:1]
#define Color_For_Background        [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1]
#define Color_For_bubble            [UIColor colorWithRed:255.0/255.0 green:125.0/255.0 blue:105.0/255.0 alpha:1]
#define Color_NavigationBar         [UIColor colorWithHexString:@"201f2a"]
#define Color_Orange                [UIColor colorWithHexString:@"f26a3d"]
#define Color_text_gray             [UIColor colorWithHexString:@"666c80"]
#define Color_search_background     [UIColor colorWithHexString:@"323444"]
#define Color_Active_Button_1       [UIColor colorWithHexString:@"f26a3d"]
#define Color_Active_Button_2       [UIColor colorWithHexString:@"ff794d"]
#define Color_Theme_1               [UIColor colorWithHexString:@"201f2a"]
#define Color_Theme_2               [UIColor colorWithHexString:@"323444"]
#define Color_Theme_3               [UIColor colorWithHexString:@"3b4051"]
#define Color_Theme_4               [UIColor colorWithHexString:@"545969"]
#define Color_Theme_5               [UIColor colorWithHexString:@"666c80"]
#define Color_Action_Button_1       [UIColor colorWithHexString:@"f26d7d"]
#define Color_Action_Button_2       [UIColor colorWithHexString:@"fea42c"]
#define Color_Action_Button_3       [UIColor colorWithHexString:@"04a0bf"]
#define Color_Text_1                [UIColor colorWithHexString:@"555555"]
#define Color_Text_2                [UIColor colorWithHexString:@"777777"]
#define Color_Text_3                [UIColor colorWithHexString:@"999999"]
#define Color_Text_4                [UIColor colorWithHexString:@"bbbbbb"]
#define Color_line_1                [UIColor colorWithHexString:@"dddddd"]
#define Color_line_2                [UIColor colorWithHexString:@"f8f8f8"]
#define Color_Additional_1          [UIColor colorWithHexString:@"b98dd9"]
#define Color_Additional_2          [UIColor colorWithHexString:@"30bfa7"]
#define Color_Additional_3          [UIColor colorWithHexString:@"e64e6f"]
#define Color_Additional_4          [UIColor colorWithHexString:@"366ab3"]
#define Color_Additional_5          [UIColor colorWithHexString:@"a8acbb"]




#pragma -mark Notification string
#define String_StatusNotifiation                    @"StatusNotifiation"
#define String_SetSongInformationNotification       @"SetSongInformationNotification"
#define String_WeiBo_Response_Notification          @"weiboresponse"
#define String_SetSongPlayNextNotification          @"notification_play_next"
#define String_MuzzikDataSource_update              @"Muzzik_datasource_update"
#define String_UserDataSource_update                @"User_datasource_update"
#define String_Muzzik_Delete                        @"Muzzik_detail_deleteMuzzik"
#define String_SendNewMuzzikDataSource_update       @"SendNewMuzzikDataSource_update"
#pragma -mark Font_Size

#define Font_Size_Muzzik_Time       7.0
#define Font_Size_Muzzik_Message    15.0
#define Font_size_userName          16.0
#define Constant_String_PlayMode_Once 0
#define Constant_String_PlayMode_Cycle 1
#define Constant_String_PlayMode_Single 2
#define Constant_String_PlayMode_Random 3

#pragma mark Font
#define HeiTiSC_Medium                      @"STHeitiTC-Medium"

#define Font_Next_Regular                   @"AvenirNext-Regular"
#define Font_Next_medium                    @"AvenirNext-Medium"
#define Font_Next_Bold                      @"AvenirNext-Bold"
#define Font_Next_DemiBold                  @"AvenirNext-DemiBold"
#define Font_Next_UltraLight                @"AvenirNext-UltraLight"
#define Font_default_share                  @"HYQuanTangShiF"
#define DocumentsPath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

// 909997353
#define APP_ID @"976583158"
#define UMAPPKEY @"55a7d11367e58e98ba005693"


#define ID_WeiChat_APP @"wx9d1e9620b322ce35"
#define Secret_WeiChat_APP @"8f0094ad31273ba1b6ca45d25bae4910"

#define ID_QQ_APP @"101142713"
#define Key_QQ_APP @"abccb400bf06b9a23fc8326fdeadebf5"

#define Key_WeiBo @"2871037752"
#define Secret_WeiBo @"9f370076f566782489471837ced4f7ef"

#define kAppId           @"3rIHoZnUS56Bu3H9X2FKm1"
#define kAppKey          @"M8W4PliA4EA2Oju4Zo0Z01"
#define kAppSecret       @"uGD286iqV4AUBMY1JndC64"


#pragma -mark string
#define Is_Table_Create @"IsTableCreate"
#define IOS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define SCREEN_TYPE_is_4S [ UIScreen mainScreen ].bounds.size.height == 480.0


#pragma -mark Constant
#define limitHeight 65
#define Play_timeinterval  0.25
#define Font_LineSapce  5
#define Cell_width 60.0
#define Constant_backImage      1     //返回按钮图片
#define Constant_filterImage    2     //筛选按钮图片
#define Constant_markImage      3     //对勾按钮图片
#define Constant_searchImage    4     //搜索按钮图片
#define Constant_nextStep       5     //下一步
#define Constant_submit         6     //提交
#define Constant_camera         7     //自拍
#define Constant_share          8
#define Constant_register       9
#define Constant_manager        10
#define Constant_add            11
#define Constant_save           12
#define Constant_back           13

#define Trend_Po                1
#define Feed_Po                 2

#define SquareList             @"square"
#define MovedList              @"move"
#define ownList                @"own"
#define TempList               @"temp"
#define feedList               @"follow"
#define suggestList            @"suggest"

#pragma -mark HTTP constant
#define PostMethod             @"1"
#define GetMethod              @"2"
#define PutMethod              @"3"
#define DeleteMethod           @"4"

#define Is_Logined              2
#define Is_Not_Logined          1


#define Type_Muzzik_Muzzik      1
#define Type_Muzzik_Music       2


#pragma request Key 常量
#define Parameter_Limit             @"limit"
#define Parameter_tail              @"tail"
#define Parameter_from              @"from"
#define Limit_Constant              @"20"
#define Parameter_page              @"page"
#define UserInfo_description        @"descrip"
#define UserInfo_title              @"title"
#define UserInfo_muzziks            @"muzziks"
#define Constant_userInfo_square    @"square"
#define Constant_userInfo_temp      @"temp"
#define Constant_userInfo_suggest   @"suggest"
#define Constant_userInfo_move      @"move"
#define Constant_userInfo_own       @"own"
#define Constant_userInfo_follow    @"follow"

#define MUSIC_FileName              @"muzzik_musicFileForSaving"
#define Muzzik_Login_Info_Token     @"Muzzik_Login_Info_Token"
#define Image_Size_Small            @"?imageView2/1/w/150/h/150"
#define Image_Size_Big            @"?imageView2/1/w/500/h/500"
#endif
