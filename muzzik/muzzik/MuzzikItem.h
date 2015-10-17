//
//  UuCheck.h
//  ShopUU
//
//  Created by kevin's mac on 14-10-23.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCryptor.h>
@interface MuzzikItem : NSObject


+(MuzzikItem *) shareClass;
+ (BOOL)isPureInt:(NSString*)string;
+(BOOL)checkIsPhoneNumForString:(NSString *)string;
+(BOOL)checkIsShipingNumForString:(NSString *)string;
+ (UIImage *)buttonImageFromColor:(UIColor *)color;
+(void) showView:(UILabel *)view Text:(NSString *)string;
+(void) showTipsAtView:(UIView *)view xPoint:(CGFloat)x yPoint:(CGFloat) y text:(NSString *)text;
+(void) alterInAndOutWithView:(UIView*)view;
+(void) showWarnOnView:(UIView *)view text:(NSString *)text;

+(void) showNewNotifyByText:(NSString *)text;

+(float) heightForLabel: (UIView *)view WithText: (NSString *) strText;
+(float) heightForTextView: (UITextView *)textView WithText: (NSString *) strText;
+(float) heightForAttributeString: (UILabel *)Label WithText: (NSMutableAttributedString *) strText;

+ (NSString *)base64StringFromText:(NSString *)text withKey:(NSString*)key;   //对文本进行加密
+ (NSString *)textFromBase64String:(NSString *)base64 withKey:(NSString*)key; //对文本进行解密
+ (UIImage*) createImageWithColor: (UIColor*) color;      //创建图片

#pragma -mark 本地持久化数据
+ (void)addMessageToLocal:(NSDictionary *)message;
+ (void)addObjectToLocal:(id)string ForKey:(NSString *)key;
+ (void)removeMessageFromLocal:(NSString *)string;

+ (NSArray *)getArrayFromLocalForKey:(NSString *)key;
+ (NSDictionary *)getDictionaryFromLocalForKey:(NSString *)key;
+ (NSData *)getDataFromLocalKey:(NSString *)key;

+ (NSArray *)muzzikDraftsFromLocal;
+ (void)addMuzzikDraftsToLocal:(NSArray *)message;

+(NSString *)getStringForKey:(NSString *)key;
+ (NSDictionary *)messageFromLocal;
+(BOOL)isLocalMusicContainKey:(NSString *)key;
+(BOOL)isLocalLyricContainKey:(NSString *)key;
+(BOOL)isLocaPictureContainKey:(NSString *)key;

+ (void)addMusicAddressToLocal:(NSString *) address Key:(NSString *)key;
+ (void)addLyricAddressToLocal:(NSString *) address Key:(NSString *)key;
+ (void)addPictureAddressToLocal:(NSString *) address Key:(NSString *)key;

+(void)getLyricByMusic:(music *)localMusic;
+(BOOL) saveMusicData:(NSData *)data MusicKey:(NSString *)key;
+ (BOOL) saveImageToCacheDir:(NSString *)directoryPath Image:(UIImage *)image imageName:(NSString *)imageName ImageType:(NSString *)imageType;
+(NSData*) loadImageData:(NSString *)directoryPath Name:(NSString *)imageName;
//加下划线
+(void)addLineOnView:(UIView *)view heightPoint:(CGFloat)height toLeft:(CGFloat)left toRight:(CGFloat)right withColor:(UIColor*)color;
+(void)addLabelOnView:(UIView *)view localPoint:(CGFloat)local toLeft:(CGFloat)left toRight:(CGFloat)right height:(CGFloat)height withColor:(UIColor*)color font:(UIFont*)font text:(NSString *) text;
+(NSAttributedString *)formatAttrItem:(NSString *)content color:(UIColor *)color font:(UIFont *)font;

+(UIImage*)convertViewToImage:(UIView*)v;
+ (NSString *)transtromTime:(NSString *)time;
+(NSString *)transtromTimeWithNum:(double)num;

+(void) showNotifyOnView:(UIView *)view text:(NSString *)text;
+(void) showNotifyOnViewUpon:(UIView *)view text:(NSString *)text;
+(void) showOnView:(UIView *)view Text:(NSString *)string pointY:(CGFloat) pointY;
//处理广播
+(BOOL) checkMutableArray:(NSMutableArray*) array isContainMuzzik:(muzzik *)localMuzzik;
+(BOOL) checkMutableArray:(NSMutableArray*) array isContainUser:(MuzzikUser *)localUser;

+(void)SetUserInfoWithMuzziks:(NSMutableArray *)muzziks title:(NSString *)title description:(NSString *)descrip;
+(NSString*)customFontWithPath:(NSString*)path;

+(NSString *)transtromAstroToChinese:(NSString *)astroEnglish;

+(BOOL)isNetWorkAvailabel;
@end
