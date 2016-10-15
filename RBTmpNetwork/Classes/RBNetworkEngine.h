//
//  PDNetworkEngine.h
//  Pudding
//
//  Created by baxiang on 16/8/29.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RBNetworkRequest.h"
#import "RBDownloadRequest.h"
@interface RBNetworkEngine : NSObject
+ (RBNetworkEngine *)defaultEngine;
- (void)executeRequestTask:(RBNetworkRequest *)request;
- (void)cancelTask:(RBNetworkRequest *)httpTask;
- (void)cancelAllTask;


-(void)POST:(NSString*)URLString parameters:(NSDictionary*)paramters CompletionBlock:(PDRequestCompletionBlock)completionBlock;
@end
