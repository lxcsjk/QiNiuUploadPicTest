//
//  UploadImageTool.m
//  SportJX
//
//  Created by Chendy on 15/12/22.
//  Copyright © 2015年 Chendy. All rights reserved.
//

#import "UploadImageTool.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "QiniuUploadHelper.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>

@implementation UploadImageTool


#pragma mark - Helpers

// 上传之前获取到图片名 还有UIImage 并且压缩
-(void)uploadPHImg:(NSArray *)assets{
    
    NSMutableArray *picImgList = [NSMutableArray new];
    NSMutableArray *picImgNameList = [NSMutableArray new];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    options.synchronous  = YES;
    
    for (int i = 0; i < assets.count; i++) {
        [_lock lock];
        [[PHImageManager defaultManager] requestImageForAsset:assets[i] targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            
            NSString *filename = [[NSFileManager defaultManager] displayNameAtPath:[[info objectForKey:@"PHImageFileURLKey"] path]];
            
            NSData *data;
            
            data = UIImageJPEGRepresentation(result, 1.0);
            if (data.length > 2*1024*1024) {
                data = UIImageJPEGRepresentation(result, 0.2);
            }
            
            if (data == nil) {
                data = UIImagePNGRepresentation(result);
            }
            
            NSDate *senddate = [NSDate date];
            double b = (double)[senddate timeIntervalSince1970]*1000;
            long num = [[NSNumber numberWithDouble:b] longValue];
            NSString *date2 = [NSString stringWithFormat:@"%ld",num];
            
            [picImgList addObject:data];
            [picImgNameList addObject:filename == nil ?[NSString stringWithFormat:@"%@.PNG",date2]:filename];
            
            [_lock unlock];
        }];
    }
    
    NSArray *data = [picImgList copy];
    NSArray *dataName = [picImgNameList copy];
    
    
    NSString *url = [NSString stringWithFormat:@"%@%@",URL27,UPLOADIMG];
    NSDictionary *para = [[NSMutableDictionary alloc]init];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/plain",@"text/javascript",nil];
    [manager.requestSerializer setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forHTTPHeaderField:@"session"];
    [manager POST:url parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSDictionary *token = dic[@"data"];
        DLog(@"token     %@",token[@"token"]);
        
        
        [UploadImageTool uploadPHImages:data dataName:dataName token:token[@"token"] progress:^(CGFloat progress) {
            DLog(@"上传图片进度     ==============================================================   %f",progress);
        } success:^(NSArray *urlArr) {
            picUrlListArray = [urlArr mutableCopy];
            [self uploadHandouts:crouseId];
            
        } failure:^{
            
        }];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [util mpdText:@"图片上传失败" showView:hud];
        DLog(@"responseString ======= %@",operation.responseString);
    }];
}

//上传单张图片
+ (void)uploadImage:(UIImage *)image token:(NSString *)token progress:(QNUpProgressHandler)progress success:(void (^)(NSString *url))success failure:(void (^)())failure {
    
    NSData *data;
    
    data = UIImageJPEGRepresentation(image, 1.0);
    if (data.length > 2*1024*1024) {
        data = UIImageJPEGRepresentation(image, 0.2);
    }
    
    QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil
                                               progressHandler:progress
                                                        params:nil
                                                      checkCrc:NO
                                            cancellationSignal:nil];
    QNUploadManager *uploadManager = [QNUploadManager sharedInstanceWithConfiguration:nil];
    
    [uploadManager putData:data
                       key:nil
                     token:token
                  complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                      NSLog(@" QNResponseInfo ======   %@", info);
                      NSLog(@" resp ======   %@", resp);
                      NSLog(@" key ======   %@", key);
                      
                      if (info.statusCode == 200 && resp) {
                          NSString *url= resp[@"url"];
                          if (success) {
                              
                              success(url);
                          }
                      }
                      else {
                          if (failure) {
                              
                              failure();
                          }
                      }
                      
                  } option:opt];
    
}

+ (void)uploadPHImage:(NSData *)data dataName:(NSString *)filename token:(NSString *)token progress:(QNUpProgressHandler)progress success:(void (^)(NSDictionary *url))success failure:(void (^)())failure {
    
    QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil
                                               progressHandler:progress
                                                        params:nil
                                                      checkCrc:NO
                                            cancellationSignal:nil];
    QNUploadManager *uploadManager = [QNUploadManager sharedInstanceWithConfiguration:nil];


        
        [uploadManager putData:data
                           key:nil
                         token:token
                      complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          
                          NSMutableDictionary *dic = [resp mutableCopy];
                          [dic setValue:filename forKey:@"name"];
                          NSDictionary *dics = [dic copy];
                          
                          if (info.statusCode == 200 && resp) {
                              if (success) {
                                  
                                  success(dics);
                              }
                          }
                          else {
                              if (failure) {
                                  
                                  failure();
                              }
                          }
                          
                      } option:opt];
        
    
}


////上传多张图片
//+ (void)uploadImages:(NSArray *)imageArray token:(NSString *)token progress:(void (^)(CGFloat))progress success:(void (^)(NSArray *))success failure:(void (^)())failure {
//
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//
//    __block CGFloat totalProgress = 0.0f;
//    __block CGFloat partProgress = 1.0f / [imageArray count];
//    __block NSUInteger currentIndex = 0;
//
//    QiniuUploadHelper *uploadHelper = [QiniuUploadHelper sharedUploadHelper];
//    __weak typeof(uploadHelper) weakHelper = uploadHelper;
//
//    uploadHelper.singleFailureBlock = ^() {
//        failure();
//        return;
//    };
//    uploadHelper.singleSuccessBlock  = ^(NSString *url) {
//        [array addObject:url];
//        totalProgress += partProgress;
//        progress(totalProgress);
//        currentIndex++;
//        if ([array count] == [imageArray count]) {
//            success([array copy]);
//            return;
//        }
//        else {
//            NSLog(@"---%ld",(unsigned long)currentIndex);
//
//            if (currentIndex<imageArray.count) {
//
//                 [UploadImageTool uploadImage:imageArray[currentIndex] token:token progress:nil success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
//            }
//
//        }
//    };
//
//    [UploadImageTool uploadImage:imageArray[0] token:token progress:nil success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
//}

//上传多张图片
+ (void)uploadPHImages:(NSArray *)imageArray dataName:(NSArray *)picNameList token:(NSString *)token progress:(void (^)(CGFloat))progress success:(void (^)(NSArray *))success failure:(void (^)())failure {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    __block CGFloat totalProgress = 0.0f;
    __block CGFloat partProgress = 1.0f / [imageArray count];
    __block NSUInteger currentIndex = 0;
    
    QiniuUploadHelper *uploadHelper = [QiniuUploadHelper sharedUploadHelper];
    __weak typeof(uploadHelper) weakHelper = uploadHelper;
    
    uploadHelper.singleFailureBlock = ^() {
        failure();
        return;
    };
    uploadHelper.singleSuccessBlock  = ^(NSDictionary *url) {
        [array addObject:url];
        totalProgress += partProgress;
        progress(totalProgress);
        currentIndex++;
        if ([array count] == [imageArray count]) {
            success([array copy]);
            return;
        }
        else {
            NSLog(@"---%ld",(unsigned long)currentIndex);
            
            if (currentIndex<imageArray.count) {
                
                [UploadImageTool uploadPHImage:imageArray[currentIndex] dataName:picNameList[currentIndex] token:token progress:nil success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
            }
            
        }
    };
    
    [UploadImageTool uploadPHImage:imageArray[0] dataName:picNameList[0] token:token progress:nil success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
}



//# mark -- 必须设置获取七牛token服务器地址,然后获取token返回 --(确认设置后,删除此行)
//获取七牛的token
//+ (void)getQiniuUploadToken:(void (^)(NSString *))success failure:(void (^)())failure {
//
//    //网络请求七牛token
//
//     //服务器地址
//    NSString *aPath = [NSString stringWithFormat:@"%@api/getQiniuUpToken",@""];
//
//     //获取七牛token
//    [[VCOAPIClient sharedClient] requestJsonDataWithPath:aPath withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
//
//        if (data) {
//
//            if (success) {
//
//                success([data objectForKey:@"data"]);
//            }
//
//        }
//        else {
//
//            if (failure) {
//
//                failure();
//            }
//
//        }
//    }];
//
//}


@end
