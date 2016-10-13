//
//  PDUploadRequest.m
//  Pudding
//
//  Created by baxiang on 16/8/29.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBUploadRequest.h"

@implementation RBUploadRequest

+(void)uploadWithURL:(nullable NSString*)URL parametes:(nullable NSDictionary*)parametes bodyBlock:(nullable PDConstructingBlock)bodyBlock progress:(nullable PDRequestProgressBlock)progressBlock complete:(nullable PDRequestCompletionBlock) completionBlock{
    RBUploadRequest *uploadRequest = [[RBUploadRequest alloc] initWithURLString:URL method:PDRequestMethodPost params:parametes];
    uploadRequest.constructingBodyBlock = bodyBlock;
    uploadRequest.progerssBlock = progressBlock;
    uploadRequest.completionBlock = completionBlock;
    [uploadRequest start];

}
@end
