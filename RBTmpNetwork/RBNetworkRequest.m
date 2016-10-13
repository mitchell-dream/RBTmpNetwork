//
//  PDNetworkRequest.m
//  Pudding
//
//  Created by baxiang on 16/8/29.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBNetworkRequest.h"
#import "RBNetworkConfig.h"
#import "RBNetworkEngine.h"
@implementation RBNetworkRequest

-(instancetype)init{
    return [self initWithURLString:@"" method:PDRequestMethodGet params:nil];
}
- (instancetype)initWithURLString:(NSString *)URLString
                           method:(PDRequestMethod)method
                           params:(NSDictionary *)paramters{
    if (self = [super init]) {
        _requestURL = URLString;
        _requestMethod = method;
        _requestParameters = paramters;
        self.requestTimeout = [RBNetworkConfig defaultConfig].defaultTimeoutInterval;
        self.requestSerializer = [RBNetworkConfig defaultConfig].defaultRequestSerializer;
        self.responseSerializer = [RBNetworkConfig defaultConfig].defaultResponseSerializer;
        self.requestState = PDRequestStateWaiting;
    }
    return self;
 
}

- (void)requestWillStartTag {
    if ([self.delegate respondsToSelector:@selector(requestWillStart:)]) {
        [self.delegate requestWillStart:self];
    }
}
- (void)start {
    [self requestWillStartTag];
    [[RBNetworkEngine defaultEngine] executeRequestTask:self];
}
- (void)stop {
    [[RBNetworkEngine defaultEngine] cancelTask:self];
}
- (void)startWithCompletionBlock:(PDRequestCompletionBlock)completionBlock{
    self.completionBlock = completionBlock;
    [self start];
}



- (NSString *)httpMethodString
{
    NSString *method = nil;
    switch (self.requestMethod)
    {
        case PDRequestMethodGet:
            method = @"GET";
            break;
        case PDRequestMethodPost:
            method = @"POST";
            break;
        case PDRequestMethodPut:
            method = @"PUT";
            break;
        case PDRequestMethodDelete:
            method = @"DELETE";
            break;
        case PDRequestMethodOptions:
            method = @"OPTIONS";
            break;
        case PDRequestMethodHead:
            method = @"HEAD";
            break;
        default:
            method = @"GET";
            break;
    }
    return method;
}
-(PDRequestState)requestState{
    if (!self.sessionTask) {
        return PDRequestStateWaiting;
    }
    NSURLSessionTaskState currState = self.sessionTask.state;
    switch (currState) {
        case NSURLSessionTaskStateRunning:
            return PDRequestStateRunning;
            break;
        case NSURLSessionTaskStateSuspended:
            return PDRequestStateSuspended;
            break;
        case NSURLSessionTaskStateCanceling:
            return PDRequestStateCanceling;
            break;
        case NSURLSessionTaskStateCompleted:
            return PDRequestStateCompleted;
            break;
        default:
            break;
    }
}
- (void)clearRequestBlock {
    self.completionBlock = nil;
    self.progerssBlock = nil;
}
-(void)dealloc{
    NSLog(@"请求销毁%@",self.class);
   [self clearRequestBlock];
    _delegate = nil;
}
@end
