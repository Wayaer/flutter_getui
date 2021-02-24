#import "GeTuiPlugin.h"
#import <GTSDK/GeTuiSdk.h>
#import <PushKit/PushKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

@interface  GeTuiPlugin()<GeTuiSdkDelegate,UNUserNotificationCenterDelegate,PKPushRegistryDelegate> {
    NSDictionary *_launchNotification;
}

@end

@implementation GeTuiPlugin{
    FlutterMethodChannel* _channel;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"get_tui"
                                     binaryMessenger:[registrar messenger]];
    GeTuiPlugin* plugin = [[GeTuiPlugin alloc] initWithGeTuiPlugin:channel];
    [registrar addApplicationDelegate:plugin];
    [registrar addMethodCallDelegate:plugin channel:channel];
    
}

- (id)initWithGeTuiPlugin :(FlutterMethodChannel*)channel {
    self = [super init];
    _channel=channel;
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if([@"initSDK" isEqualToString:call.method]) {
        [self registerRemoteNotification];
        [self initSDK:call result:result];
    } else if([@"bindAlias" isEqualToString:call.method]) {
        [self bindAlias:call result:result];
    } else if([@"unbindAlias" isEqualToString:call.method]) {
        [self unbindAlias:call result:result];
    } else if([@"setTag" isEqualToString:call.method]) {
        [self setTag:call result:result];
    } else if([@"getClientId" isEqualToString:call.method]) {
        result([GeTuiSdk clientId]);
    } else if([@"setBadge" isEqualToString:call.method]) {
        [self setBadge:call result:result];
    } else if([@"resetBadge" isEqualToString:call.method]) {
        [GeTuiSdk resetBadge];
    } else if([@"setLocalBadge" isEqualToString:call.method]) {
        [self setLocalBadge:call result:result];
    } else if([@"getLaunchNotification" isEqualToString:call.method]) {
        result(_launchNotification ?: @{});
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)initSDK:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *ConfigurationInfo = call.arguments;
    // [ GTSdk ]：使用APPID/APPKEY/APPSECRENT启动个推
    [GeTuiSdk startSdkWithAppId:ConfigurationInfo[@"appId"] appKey:ConfigurationInfo[@"appKey"] appSecret:ConfigurationInfo[@"appSecret"] delegate:self];
    if (@available(iOS 10.0, *)) {
        [GeTuiSdk registerRemoteNotification:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)];
    } else {
        // Fallback on earlier versions
    }
    // 注册VoipToken
    [self voipRegistration];
}

- (void)registerRemoteNotification {
    /*
     警告：Xcode8的需要手动开启“TARGETS -> Capabilities -> Push Notifications”
     */
    
    /*
     警告：该方法需要开发者自定义，以下代码根据APP支持的iOS系统不同，代码可以对应修改。
     以下为演示代码，注意根据实际需要修改，注意测试支持的iOS系统都能获取到DeviceToken
     */
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 // Xcode 8编译会调用
        if (@available(iOS 10.0, *)) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate = self;
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
                //if (!error)//NSLog(@"GeTui request authorization succeeded!");
                
            }];
        } else {
            // Fallback on earlier versions
        }
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#else // Xcode 7编译会调用
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (launchOptions != nil)
        _launchNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    return YES;
}

#pragma mark - 远程通知(推送)回调

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // [3]:向个推服务器注册deviceToken 为了方便开发者，建议使用新方法
    //    [GeTuiSdk registerDeviceTokenData:deviceToken];
    NSString *token = [self getHexStringForData:deviceToken];
    //  NSLog(@"\n>>>[DeviceToken(NSString)]: %@\n\n", token);
    [_channel invokeMethod:@"onRegisterDeviceToken" arguments:token];
}

/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // NSLog(@"didFailToRegisterForRemoteNotificationsWithError");
    [_channel invokeMethod:@"onRegisterDeviceToken" arguments:@"Register Error"];
}

#pragma mark - iOS 10中收到推送消息

/// 通知展示（iOS10及以上版本）
/// @param center center
/// @param notification notification
/// @param completionHandler completionHandler
- (void)GeTuiSdkNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification completionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    // [ 参考代码，开发者注意根据实际需求自行修改 ] 根据APP需要，判断是否要提示用户Badge、Sound、Alert等
    //completionHandler(UNNotificationPresentationOptionNone); 若不显示通知，则无法点击通知
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

/// 点击通知
/// @param userInfo apns通知内容
/// @param center UNUserNotificationCenter（iOS10及以上版本）
/// @param response UNNotificationResponse（iOS10及以上版本）
/// @param completionHandler 用来在后台状态下进行操作（iOS10以下版本）
- (void)GeTuiSdkDidReceiveNotification:(NSDictionary *)userInfo notificationCenter:(UNUserNotificationCenter *)center response:(UNNotificationResponse *)response fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler  API_AVAILABLE(ios(10.0)){
    [_channel invokeMethod:@"onReceiveNotificationResponse" arguments:userInfo];
    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo];
    if(completionHandler) {
        // [ 参考代码，开发者注意根据实际需求自行修改 ] 根据APP需要自行修改参数值
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

#pragma mark - AppLink

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nonnull))restorationHandler {
    //系统用 NSUserActivityTypeBrowsingWeb 表示对应的 universal HTTP links 触发
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL* webUrl = userActivity.webpageURL;
        
        //处理个推APPLink回执统计
        //APPLink url 示例：https://link.applk.cn/getui?n=payload&p=mid， 其中 n=payload 字段存储下发的透传信息，可以根据透传内容进行业务操作。
        NSString* payload = [GeTuiSdk handleApplinkFeedback:webUrl];
        if (payload) {
            // NSLog(@"个推APPLink中携带的透传payload信息: %@,URL : %@", payload, webUrl);
            //用户可根据具体 payload 进行业务处理
            [_channel invokeMethod:@"onAppLinkPayload" arguments:payload];
        }
    }
    return NO;
}

#pragma mark - VOIP接入

/** 注册VOIP服务 */
- (void)voipRegistration {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    PKPushRegistry *voipRegistry = [[PKPushRegistry alloc] initWithQueue:mainQueue];
    voipRegistry.delegate = self;
    // Set the push type to VoIP
    if (@available(iOS 9.0, *)) {
        voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    } else {
        // Fallback on earlier versions
    }
}

// 实现 PKPushRegistryDelegate 协议方法

/** 系统返回VOIPToken，并提交个推服务器 */
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type {
    //向个推服务器注册 VoipToken 为了方便开发者，建议使用新方法
    [GeTuiSdk registerVoipTokenCredentials:credentials.token];
    
    NSString *token = [self getHexStringForData:credentials.token];
    // NSLog(@"\n>>[VoipToken(NSString)]: %@", token);
    [_channel invokeMethod:@"onRegisterVoIpToken" arguments:token];
}

/** 接收VOIP推送中的payload进行业务逻辑处理（一般在这里调起本地通知实现连续响铃、接收视频呼叫请求等操作），并执行个推VOIP回执统计 */
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type {
    // 个推VOIP回执统计
    [GeTuiSdk handleVoipNotification:payload.dictionaryPayload];
    
    // 接受VOIP推送中的payload内容进行具体业务逻辑处理
    // NSLog(@"[Voip Payload]:%@,%@", payload, payload.dictionaryPayload);
    [_channel invokeMethod:@"onReceiveVoIpPayLoad" arguments:payload.dictionaryPayload];
}

#pragma mark - GeTuiSdkDelegate

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    // [ GTSdk ]：个推SDK已注册，返回clientId
    // NSLog(@">>[GTSdk RegisterClient]:%@", clientId);
    if ([clientId isEqualToString:@""]) return;
    
    [_channel invokeMethod:@"onReceiveClientId" arguments:clientId];
}

/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceiveSlience:(NSDictionary *)userInfo fromGetui:(BOOL)fromGetui offLine:(BOOL)offLine appId:(NSString *)appId taskId:(NSString *)taskId msgId:(NSString *)msgId fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    // [ GTSdk ]：汇报个推自定义事件(反馈透传消息)
    [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId];
    // 透传消息不会有alert，需要自己定义
    NSString * payload = [userInfo objectForKey:@"payload"];
    NSData * jsonData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * payloadDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    if (@available(iOS 10.0, *)) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [payloadDic objectForKey:@"title"];
        content.body = [payloadDic objectForKey:@"content"];
        content.userInfo = payloadDic;
        content.sound = [UNNotificationSound defaultSound];
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"my_notification" content:content trigger:trigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        }];
    }
    
    // 数据转换
    NSMutableDictionary *payloadMsgDic = [NSMutableDictionary dictionaryWithDictionary:payloadDic];
    [payloadMsgDic setObject:taskId forKey:@"taskId"];
    [payloadMsgDic setObject:@(offLine) forKey:@"offLine"];
    [payloadMsgDic setObject:msgId forKey:@"messageId"];
    //  NSLog(@"%@", payloadMsgDic);
    [_channel invokeMethod:@"onReceivePayload" arguments:[payloadMsgDic copy]];
}

#pragma mark - GTSDKfunction

- (void)bindAlias:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *ConfigurationInfo = call.arguments;
    [GeTuiSdk bindAlias:ConfigurationInfo[@"alias"] andSequenceNum:ConfigurationInfo[@"aSn"]];
}

- (void)unbindAlias:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *ConfigurationInfo = call.arguments;
    [GeTuiSdk unbindAlias:ConfigurationInfo[@"alias"] andSequenceNum:ConfigurationInfo[@"aSn"] andIsSelf:ConfigurationInfo[@"isSelf"]];
}

- (void)setTag:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *ConfigurationInfo = call.arguments;
    [GeTuiSdk setTags:ConfigurationInfo[@"tags"]];
}

- (void)setBadge:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *ConfigurationInfo = call.arguments;
    NSUInteger value = [ConfigurationInfo[@"badge"] integerValue];
    [GeTuiSdk setBadge:value];
}

- (void)setLocalBadge:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *ConfigurationInfo = call.arguments;
    NSUInteger value = [ConfigurationInfo[@"badge"] integerValue];
    [UIApplication sharedApplication].applicationIconBadgeNumber = value;
    
}

#pragma mark - utils

- (NSString *)getHexStringForData:(NSData *)data {
    NSUInteger len = [data length];
    char *chars = (char *) [data bytes];
    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < len; i++) {
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
    }
    return hexString;
}

@end
