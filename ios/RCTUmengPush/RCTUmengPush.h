//
//  RCTUmengPush.h
//  RCTUmengPush
//
//  Created by user on 16/4/24.
//  Copyright © 2016年 react-native-umeng-push. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCTUmengPush : NSObject <RCTBridgeModule>
+ (void)initWithAppkey:(NSString *)appkey channel:(NSString *)channel;
+ (void)application:(UIApplication *)application didRegisterDeviceToken:(NSData *)deviceToken;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
+ (void)userNotificationCenter:(NSDictionary *)userInfo;
+ (void)userNotificationCenterActive:(NSDictionary *)userInfo;
@end
