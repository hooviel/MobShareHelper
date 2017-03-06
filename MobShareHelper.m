//
//  MobShareHelper.m
//  ebuy
//
//  Created by David on 15/10/15.
//  Copyright (c) 2015年 VeryApps. All rights reserved.
//

#import "MobShareHelper.h"

#import <CoreTelephony/CoreTelephonyDefines.h>
#import <MessageUI/MessageUI.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>

//＝＝＝＝＝＝＝＝＝＝ShareSDK头文件＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/SSDKPlatform.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
//以下是ShareSDK必须添加的依赖库：
//1、libicucore.dylib
//2、libz.dylib
//3、libstdc++.dylib
//4、JavaScriptCore.framework

//＝＝＝＝＝＝＝＝＝＝以下是各个平台SDK的头文件，根据需要继承的平台添加＝＝＝
//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
//以下是腾讯SDK的依赖库：
//libsqlite3.dylib

//微信SDK头文件
#import "WXApi.h"
//以下是微信SDK的依赖库：
//libsqlite3.dylib
#import "SVProgressHUD.h"

@implementation MobShareHelper

NSString * const ShareSDKAppId = @"cf4c9292b040";

/**
 *  初始化ShareSDK设置
 */
+ (void)setup
{
    // -------------- 设置ShareSDK
    NSArray *arrPlatforms = @[@(SSDKPlatformTypeSinaWeibo),
                              @(SSDKPlatformTypeMail),
                              @(SSDKPlatformTypeSMS),
                              @(SSDKPlatformTypeCopy),
                              @(SSDKPlatformTypeWechat),
                              @(SSDKPlatformTypeQQ),
//                              @(SSDKPlatformTypeFacebook),
//                              @(SSDKPlatformTypeTwitter)
                              ];
    [ShareSDK registerApp:ShareSDKAppId activePlatforms:arrPlatforms onImport:^(SSDKPlatformType platformType) {
        switch (platformType)
        {
            case SSDKPlatformTypeWechat:
                [ShareSDKConnector connectWeChat:[WXApi class]];
                break;
            case SSDKPlatformTypeQQ:
                [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                break;
            default:
                break;
        }
    } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
        NSLog(@"plat:%@", @(platformType));
        switch (platformType)
        {
            case SSDKPlatformTypeSinaWeibo:
                //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                [appInfo SSDKSetupSinaWeiboByAppKey:@"968715022"
                                          appSecret:@"f07802748aff21e59d8fc66472865190"
                                        redirectUri:@"http://www.veryapps.com"
                                           authType:SSDKAuthTypeBoth];
                break;
            case SSDKPlatformTypeWechat:
                [appInfo SSDKSetupWeChatByAppId:@"wx4093deaed584c154"
                                      appSecret:@"b1709c93788441b38ea640a66f16b40f"];
                break;
            case SSDKPlatformTypeQQ:
                [appInfo SSDKSetupQQByAppId:@"1104926809"
                                     appKey:@"uXSzzXX4JrCDRP3x"
                                   authType:SSDKAuthTypeBoth];
                break;
            default:
                break;
        }
    }];
    
}

/**
 *  设置分享参数
 *
 *  @param platformType 分享类型
 *  @param image   图片集合,传入参数可以为单张图片信息，也可以为一个NSArray，数组元素可以为UIImage、NSString（图片路径）、NSURL（图片路径）、SSDKImage，
 *                  如: @"http://mob.com/Assets/images/logo.png?v=20150320" 或 @[@"http://mob.com/Assets/images/logo.png?v=20150320"]
 *  @param title    标题
 *  @param url      网页路径/应用路径
 *  @param content  分享的主体内容，当content=nil，分享内容默认为：title+" "+url
 *  @param completion   分享结束的回调
 */

+ (void)shareTo:(SSDKPlatformType)platformType image:(id)image title:(NSString *)title url:(NSString *)url content:(NSString *)content completion:(void(^)(NSString *msg, NSError *error))completion
{
    NSString *tbl = @"ShareSDKUI_Localizable";
    NSBundle *bundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ShareSDKUI.bundle"]];
    
    if (SSDKPlatformTypeCopy==platformType) {
        // 复制
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        if (url.length>0) {
            pasteboard.string = [url copy];
        }
        else if (image) {
            pasteboard.image = image;
        }
        if (completion) {
            NSString *msg = [NSString stringWithFormat:@"%@", NSLocalizedStringFromTableInBundle(@"Copied", tbl, bundle, NULL)];
            completion(msg, nil);
        }
        return;
    }
    
    SSDKContentType contentType = SSDKContentTypeAuto;
    NSURL *aUrl;
    if (url.length>0) {
        aUrl = [NSURL URLWithString:url];
    }
    
    contentType = SSDKContentTypeWebPage;
    
    switch (platformType) {
        case SSDKPlatformTypeMail:
        case SSDKPlatformTypeSMS:
        case SSDKPlatformTypeSinaWeibo:{
            contentType = SSDKContentTypeAuto;
        } break;
        case SSDKPlatformTypeFacebook:
        case SSDKPlatformTypeTwitter:
        case SSDKPlatformSubTypeWechatSession:
        case SSDKPlatformSubTypeWechatTimeline:
        case SSDKPlatformSubTypeQQFriend:
        case SSDKPlatformSubTypeQZone: {
            contentType = aUrl?SSDKContentTypeWebPage:SSDKContentTypeAuto;
        } break;
        default: break;
    }
    
    // 分享参数
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:content images:image url:aUrl title:title type:contentType];
    
    [ShareSDK share:platformType parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        
        if (completion) {
            NSString *key = [NSString stringWithFormat:@"ShareType_%@", @(platformType)];
            NSString *snsName = NSLocalizedStringFromTableInBundle(key, tbl, bundle, NULL);
            switch (state) {
                case SSDKResponseStateSuccess:
                {
                    completion([NSString stringWithFormat:@"%@:%@", snsName, NSLocalizedStringFromTableInBundle(@"ShareSucceed", tbl, bundle, NULL)], nil);
                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@:%@", snsName, @"分享成功"]];
                }break;
                case SSDKResponseStateFail:
                {
                    NSString *msg = [NSString stringWithFormat:@"%@:%@", snsName, error.userInfo[@"error_message"]];
                    NSError *err = [NSError errorWithDomain:error.domain code:error.code userInfo:@{NSLocalizedFailureReasonErrorKey:msg}];
                    [SVProgressHUD showErrorWithStatus:msg];
                    completion(msg, err);
                }break;
                default:
                    break;
            }
        }
    }];
}

@end
