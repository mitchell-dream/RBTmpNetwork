//
//  PDNetworkConfig.h
//  Pudding
//
//  Created by baxiang on 16/8/29.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
UIKIT_EXTERN NSString * PDNetConfig_Msg_List;     //消息中心列表
UIKIT_EXTERN NSString * PDNetConfig_Family_List;  //家庭动态列表

#if DEBUG
#define  PDNetworkAssert(condition,fmt,...) \
if(!(condition)) {\
NSAssert(NO,fmt, ##__VA_ARGS__);\
}
#else
#define  PDNetworkAssert(condition,fmt,...) \
if(!(condition)) {\
NSLog((@"crush in debug :%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);\
}
#endif

typedef NS_ENUM(NSUInteger, PDRequestMethod)
{
    PDRequestMethodGet = 0,
    PDRequestMethodPost,
    PDRequestMethodPut,
    PDRequestMethodDelete,
    PDRequestMethodOptions,
    PDRequestMethodHead
};
typedef NS_ENUM(NSUInteger, PDNetworkTaskType)
{
    PDNetworkTaskTypeRequest = 0,
    PDNetworkTaskTypeDownload ,
    PDNetworkTaskTypeUpload
};
typedef NS_ENUM(NSUInteger, PDNetworkCachePolicy)
{
    PDNetworkCachePolicyIgnoreCache = 0,
    PDNetworkCachePolicyNeedCache
    
};
typedef NS_ENUM(NSInteger , PDRequestSerializerType) {
    PDRequestSerializerTypeHTTP = 0,
    PDRequestSerializerTypeJSON,
};
typedef NS_ENUM(NSInteger , PDResponseSerializerType) {
    PDResponseSerializerTypeHTTP = 0,
    PDResponseSerializerTypeJSON,
};
typedef NS_ENUM(NSInteger , PDRequestPriority) {
    PDRequestPriorityLow = -4L,
    PDRequestPriorityDefault = 0,
    PDRequestPriorityHigh = 4,
};

@interface RBNetworkConfig : NSObject

+ (RBNetworkConfig *)defaultConfig;
/**
 *  url 请求的URL
 */
@property (nonatomic, copy) NSString *baseUrlString;
/**
 *  header 请求头
 */
@property (nonatomic, copy) NSDictionary<NSString *,NSString *>*  baseRequestHeaders;
/**
 *  params 请求参数
 */
@property (nonatomic, copy) NSDictionary<NSString *,NSString *>*  baseRequestParams;
/**
 *   默认PDRequestSerializerTypeHTTP（
 */
@property (nonatomic, assign) PDRequestSerializerType  defaultRequestSerializer;
/**
 *  默认返回数据类型 PDResponseSerializerTypeJSON
 */
@property (nonatomic, assign) PDResponseSerializerType defaultResponseSerializer;
/**
 *  网络请求的最大队列数量
 */
@property (nonatomic, assign) NSInteger maxConcurrentOperationCount;
/**
 *   默认：[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil]
 */
@property (nonatomic, copy) NSSet<NSString *> *acceptableContentTypes;
/**
 *  @brief 请求超时时间，默认20秒
 */
@property (nonatomic, assign) NSTimeInterval defaultTimeoutInterval;
/**
 *  下载数据的路径
 */
@property (nonatomic,copy) NSString *downloadFolderPath;

@property (nonatomic, strong) NSIndexSet *defaultAcceptableStatusCodes;
/**
 *  @brief 是否打开debug日志，默认打开
 */
@property (nonatomic, assign) BOOL enableDebug;
@property (nonatomic, strong) NSString *responseCodeKey;

@property (nonatomic, strong) NSString *responseMessageKey;

@property (nonatomic, strong) NSString *responseContentDataKey;
@end
