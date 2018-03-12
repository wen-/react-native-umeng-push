//
//  RCTUmengPush.m
//  RCTUmengPush
//
//  Created by user on 16/4/24.
//  Copyright © 2016年 react-native-umeng-push. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCTUmengPush.h"
#import "UMessage.h"
#import "UMCommon.h"
#import "UMConfigure.h"
#import "RCTEventDispatcher.h"

#define UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define _IPHONE80_ 80000

static NSString * const DidReceiveMessage = @"DidReceiveMessage";
static NSString * const DidOpenMessage = @"DidOpenMessage";
static RCTUmengPush *_instance = nil;

@interface RCTUmengPush ()
@property (nonatomic, copy) NSString *deviceToken;
@end
@implementation RCTUmengPush

@synthesize bridge = _bridge;
RCT_EXPORT_MODULE()

- (NSString *)checkErrorMessage:(NSInteger)code
{
    switch (code) {
        case 1:
            return @"响应出错";
            break;
        case 2:
            return @"操作失败";
            break;
        case 3:
            return @"参数非法";
            break;
        case 4:
            return @"条件不足(如:还未获取device_token，添加tag是不成功的)";
            break;
        case 5:
            return @"服务器限定操作";
            break;
        default:
            break;
    }
    return nil;
}

- (void)handleResponse:(id  _Nonnull)responseObject remain:(NSInteger)remain error:(NSError * _Nonnull)error completion:(RCTResponseSenderBlock)completion
{
    if (completion) {
        if (error) {
            NSString *msg = [self checkErrorMessage:error.code];
            if (msg.length == 0) {
                msg = error.localizedDescription;
            }
            completion(@[@(error.code), @(remain)]);
        } else {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *retDict = responseObject;
                if ([retDict[@"success"] isEqualToString:@"ok"]) {
                    completion(@[@200, @(remain)]);
                } else {
                    completion(@[@(-1), @(remain)]);
                }
            } else {
                completion(@[@(-1), @(remain)]);
            }
            
        }
    }
}

- (void)handleGetTagResponse:(NSSet * _Nonnull)responseTags remain:(NSInteger)remain error:(NSError * _Nonnull)error completion:(RCTResponseSenderBlock)completion
{
    if (completion) {
        if (error) {
            NSString *msg = [self checkErrorMessage:error.code];
            if (msg.length == 0) {
                msg = error.localizedDescription;
            }
            completion(@[@(error.code), @(remain), @[]]);
        } else {
            if ([responseTags isKindOfClass:[NSSet class]]) {
                NSArray *retList = responseTags.allObjects;
                completion(@[@200, @(remain), retList]);
            } else {
                completion(@[@(-1), @(remain), @[]]);
            }
        }
    }
}
- (void)handleAliasResponse:(id  _Nonnull)responseObject error:(NSError * _Nonnull)error completion:(RCTResponseSenderBlock)completion
{
    if (completion) {
        if (error) {
            NSString *msg = [self checkErrorMessage:error.code];
            if (msg.length == 0) {
                msg = error.localizedDescription;
            }
            completion(@[@(error.code)]);
        } else {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *retDict = responseObject;
                if ([retDict[@"success"] isEqualToString:@"ok"]) {
                    completion(@[@200]);
                } else {
                    completion(@[@(-1)]);
                }
            } else {
                completion(@[@(-1)]);
            }
            
        }
    }
}

RCT_EXPORT_METHOD(addTag:(NSString *)tag response:(RCTResponseSenderBlock)completion)
{
    [UMessage addTags:tag response:^(id  _Nonnull responseObject, NSInteger remain, NSError * _Nonnull error) {
        [self handleResponse:responseObject remain:remain error:error completion:completion];
    }];
}

RCT_EXPORT_METHOD(deleteTag:(NSString *)tag response:(RCTResponseSenderBlock)completion)
{
    [UMessage deleteTags:tag response:^(id  _Nonnull responseObject, NSInteger remain, NSError * _Nonnull error) {
        [self handleResponse:responseObject remain:remain error:error completion:completion];
    }];
}

RCT_EXPORT_METHOD(listTag:(RCTResponseSenderBlock)completion)
{
    [UMessage getTags:^(NSSet * _Nonnull responseTags, NSInteger remain, NSError * _Nonnull error) {
        [self handleGetTagResponse:responseTags remain:remain error:error completion:completion];
    }];
}

RCT_EXPORT_METHOD(addAlias:(NSString *)name type:(NSString *)type response:(RCTResponseSenderBlock)completion)
{
    [UMessage addAlias:name type:type response:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
        [self handleAliasResponse:responseObject error:error completion:completion];
    }];
}

RCT_EXPORT_METHOD(addExclusiveAlias:(NSString *)name type:(NSString *)type response:(RCTResponseSenderBlock)completion)
{
    [UMessage setAlias:name type:type response:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
        [self handleAliasResponse:responseObject error:error completion:completion];
    }];
}

RCT_EXPORT_METHOD(deleteAlias:(NSString *)name type:(NSString *)type response:(RCTResponseSenderBlock)completion)
{
    [UMessage removeAlias:name type:type response:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
        [self handleAliasResponse:responseObject error:error completion:completion];
    }];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_instance == nil) {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_instance == nil) {
            _instance = [super allocWithZone:zone];
            [_instance setupUMessage];
        }
    });
    return _instance;
}

+ (dispatch_queue_t)sharedMethodQueue {
    static dispatch_queue_t methodQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        methodQueue = dispatch_queue_create("com.liuchungui.react-native-umeng-push", DISPATCH_QUEUE_SERIAL);
    });
    return methodQueue;
}

- (dispatch_queue_t)methodQueue {
    return [RCTUmengPush sharedMethodQueue];
}

- (NSDictionary<NSString *, id> *)constantsToExport {
    return @{
             DidReceiveMessage: DidReceiveMessage,
             DidOpenMessage: DidOpenMessage,
             };
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self.bridge.eventDispatcher sendAppEventWithName:DidReceiveMessage body:userInfo];
}

- (void)didOpenRemoteNotification:(NSDictionary *)userInfo {
    [self.bridge.eventDispatcher sendAppEventWithName:DidOpenMessage body:userInfo];
}

RCT_EXPORT_METHOD(setAutoAlert:(BOOL)value) {
    [UMessage setAutoAlert:value];
}

RCT_EXPORT_METHOD(getDeviceToken:(RCTResponseSenderBlock)callback) {
    NSString *deviceToken = self.deviceToken;
    if(deviceToken == nil) {
        deviceToken = @"";
    }
    callback(@[deviceToken]);
}

/**
 *  初始化UM的一些配置
 */
- (void)setupUMessage {
    [UMessage setAutoAlert:NO];
}

+ (void)initWithAppkey:(NSString *)appkey channel:(NSString *)channel
{
    SEL sel = NSSelectorFromString(@"setWraperType:wrapperVersion:");
    if ([UMConfigure respondsToSelector:sel]) {
        [UMConfigure performSelector:sel withObject:@"react-native" withObject:@"1.0"];
    }
    [UMConfigure initWithAppkey:appkey channel:channel];
}

+ (void)application:(UIApplication *)application didRegisterDeviceToken:(NSData *)deviceToken {
    [RCTUmengPush sharedInstance].deviceToken = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                                  stringByReplacingOccurrencesOfString: @">" withString: @""]
                                                 stringByReplacingOccurrencesOfString: @" " withString: @""];
    [UMessage registerDeviceToken:deviceToken];
}
//iOS10之前使用这个方法接收通知
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [UMessage didReceiveRemoteNotification:userInfo];
    //send event
    if (application.applicationState == UIApplicationStateInactive) {
        [[RCTUmengPush sharedInstance] didOpenRemoteNotification:userInfo];
    }
    else {
        [[RCTUmengPush sharedInstance] didReceiveRemoteNotification:userInfo];
    }
}

//iOS10新增：处理前台收到通知的代理方法
+(void)userNotificationCenterActive:(NSDictionary *)userInfo{
	[[RCTUmengPush sharedInstance] didReceiveRemoteNotification:userInfo];
}

+(void)userNotificationCenter:(NSDictionary *)userInfo{
	[[RCTUmengPush sharedInstance] didOpenRemoteNotification:userInfo];
}

+ (void)didReceiveRemoteNotificationWhenFirstLaunchApp:(NSDictionary *)launchOptions {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), [self sharedMethodQueue], ^{
        //判断当前模块是否正在加载，已经加载成功，则发送事件
        if(![RCTUmengPush sharedInstance].bridge.isLoading) {
            [UMessage didReceiveRemoteNotification:launchOptions];
            [[RCTUmengPush sharedInstance] didOpenRemoteNotification:launchOptions];
        }
        else {
            [self didReceiveRemoteNotificationWhenFirstLaunchApp:launchOptions];
        }
    });
}

@end
