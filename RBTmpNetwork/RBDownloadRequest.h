//
//  PDDownloadRequest.h
//  Pudding
//
//  Created by baxiang on 16/8/29.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBNetworkRequest.h"

@interface RBDownloadRequest : RBNetworkRequest
/**
 *  下载数据的文件名
 */
@property (nonatomic, copy,nullable) NSString *fileName;
/**
 *  存储下载数据的文件夹路径
 */
@property (nonatomic, copy,nullable) NSString *fileFolderPath;
/**
 *   存储下载数据的绝对路径
 */
@property (nonatomic, copy, nullable) NSString *filePath;
/**
 *  下载中断的数据存储路径
 */
@property (nonatomic, copy, nullable) NSString *resumeFilePath;
/**
 *  开始下载时间
 */
@property (nonatomic, strong,nullable) NSDate *downloadDate;
/**
 *  已下载数据
 */
@property (nonatomic, strong, nullable) NSData *resumeData;
/**
 *  当前下载的 NSURLSessionDownloadTask
 */
@property (nonatomic, strong, nullable) NSURLSessionDownloadTask *downloadTask;

/*
 *  已下载数据大小
 */
@property (nonatomic, assign) int64_t totalBytesWritten;
/*
 * 下载数据的总大小
 */
@property (nonatomic, assign) int64_t totalBytesExpectedToWrite;
/*
 * 下载速度
 */
@property (nonatomic, assign) int64_t downloadSpeed;
/*
 * 下载的百分比.
 */
@property (nonatomic, assign) float downloadProgress;
/*
 *  下载的剩余时间
 */
@property (nonatomic, assign) int32_t downloadLeft;
+(void)downloadWithURL:(nonnull NSString*)URL parametes:(nullable NSDictionary*)parametes progress:(nullable PDRequestProgressBlock )progressBlock complete:(nullable PDRequestCompletionBlock) completionBlock;
@end
