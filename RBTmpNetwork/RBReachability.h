//
//  PDReachability.h
//  Pudding
//
//  Created by baxiang on 16/9/3.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

typedef NS_ENUM(NSUInteger, PDReachabilityStatus) {
    PDReachabilityStatusNone  = 0,
    PDReachabilityStatusWWAN  = 1,
    PDReachabilityStatusWiFi  = 2,
};

typedef NS_ENUM(NSUInteger, PDReachabilityWWANStatus) {
    PDReachabilityWWANStatusNone  = 0,
    PDReachabilityWWANStatus2G = 2,
    PDReachabilityWWANStatus3G = 3,
    PDReachabilityWWANStatus4G = 4,
};


/**
   检测当前网络状态
 */
@interface RBReachability : NSObject

@property (nonatomic, assign, readonly) SCNetworkReachabilityFlags flags;                           ///< Current flags.
@property (nonatomic, assign, readonly) PDReachabilityStatus status;                                ///< Current status.
@property (nonatomic, assign, readonly) PDReachabilityWWANStatus wwanStatus NS_AVAILABLE_IOS(7_0);  ///< Current WWAN status.
@property (nonatomic, assign, readonly, getter=isReachable) BOOL reachable;

@property (nonatomic, copy) void (^notifyBlock)(RBReachability *reachability);

+ (instancetype)reachability;
+ (instancetype)reachabilityForLocalWifi;
+ (instancetype)reachabilityWithHostname:(NSString *)hostname;
+ (instancetype)reachabilityWithAddress:(const struct sockaddr*)hostAddress;
@end
