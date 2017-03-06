//
//  MobShareHelper.h
//  YouYou
//
//  Created by David on 15/5/6.
//  Copyright (c) 2015年 VeryApps. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ShareSDK/SSDKTypeDefine.h>

@interface MobShareHelper : NSObject

/**
 *  初始化ShareSDK设置
 */
+ (void)setup;

+ (void)shareTo:(SSDKPlatformType)platformType image:(id)image title:(NSString *)title url:(NSString *)url content:(NSString *)content completion:(void(^)(NSString *msg, NSError *error))completion;

@end
