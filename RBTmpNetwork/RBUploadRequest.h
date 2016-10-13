//
//  PDUploadRequest.h
//  Pudding
//
//  Created by baxiang on 16/8/29.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBNetworkRequest.h"
#import <AFNetworking/AFURLRequestSerialization.h>
typedef void (^PDConstructingBlock)(id<AFMultipartFormData> _Nullable formData);
/**
 *  数据上传upload.
 */
@interface RBUploadRequest : RBNetworkRequest
@property (nonatomic, copy, nullable) PDConstructingBlock constructingBodyBlock;
+(void)uploadWithURL:(nullable NSString*)URL parametes:(nullable NSDictionary*)parametes bodyBlock:(nullable PDConstructingBlock)bodyBlock progress:(nullable PDRequestProgressBlock)progressBlock complete:(nullable PDRequestCompletionBlock) completionBlock;
@end
