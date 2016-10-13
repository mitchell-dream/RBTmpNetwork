
//  PDNetworkRequest.h
//  Pudding
//
//  Created by baxiang on 16/8/29.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RBNetworkRequest;
@class PDNetworkResponse;
#import "RBNetworkConfig.h"

typedef NS_ENUM(NSUInteger, PDRequestState)
{
    PDRequestStateWaiting = 0,
    PDRequestStateRunning ,
    PDRequestStateSuspended ,
    PDRequestStateCanceling ,
    PDRequestStateCompleted
};

typedef void(^PDRequestCompletionBlock)(__kindof RBNetworkRequest *requestTask,id response,NSError *error);
typedef void(^PDRequestProgressBlock)(__kindof RBNetworkRequest *task,NSProgress *progress);
//typedef void(^PDRequestCacheCompletion)(__kindof PDNetworkRequest *task, id cacheData);

@protocol RBRequestDelegate <NSObject>

@optional

- (void)requestWillStart:(RBNetworkRequest *)request;
- (void)requestDidSuccess:(RBNetworkRequest *)request;
- (void)requestDidFailure:(RBNetworkRequest *)request;
@end

@interface RBNetworkRequest : NSObject
/**
 *  BaseURL
 */
@property (nonatomic, copy) NSString *requestBaseURL;
/**
 *  requestURL
 */
@property (nonatomic, strong) NSString *requestURL;
/**
 *  request Method
 */
@property (nonatomic, assign) PDRequestMethod requestMethod;
/**
 *  Timeout
 */
@property (nonatomic, assign) NSTimeInterval requestTimeout;
@property (nonatomic,strong)  NSDictionary *requestParameters;
@property (nonatomic, strong) NSURLSessionTask *sessionTask;
@property (nonatomic, assign) PDRequestSerializerType  requestSerializer;
@property (nonatomic, assign) PDResponseSerializerType responseSerializer;
@property (nonatomic, copy)   NSDictionary<NSString *,NSString *>*  requestHeaders;
//任务类型
@property (nonatomic, assign) PDNetworkTaskType taskType;
/**
 *  请求的缓存策略
 */
@property (nonatomic, assign) PDNetworkCachePolicy cachePolicy;
/**
 *  是否是缓存数据
 */
@property (nonatomic,  assign) BOOL isCacheData;
#pragma mark - block
/**
 *  成功的的block
 */
@property (nonatomic,  copy) PDRequestCompletionBlock completionBlock;

// 上传或者下载进度
@property (nonatomic,  copy) PDRequestProgressBlock progerssBlock;
// delegate
@property (nonatomic, weak) id <RBRequestDelegate> delegate;
/**
 *  网络请求的结果
 */
@property (nonatomic,assign) PDRequestState requestState;
//@property (nonatomic, strong) Class responseModelClass;
@property (nonatomic, strong) NSString *responseCodeKey;
@property (nonatomic, strong) NSString *responseMessageKey;
@property (nonatomic, strong) NSString *responseContentDataKey;

@property (nonatomic, copy) NSIndexSet *acceptableStatusCodes;
/**
 *  开始任务
 */
-(void) start;
/**
 *  结束任务
 */
-(void)stop;
-(void)startWithCompletionBlock:(PDRequestCompletionBlock)completionBlock;

-(instancetype)initWithURLString:(NSString *)URLString method:(PDRequestMethod)method params:(NSDictionary *)paramters;
- (void)clearRequestBlock;
- (NSString *)httpMethodString;


@end
