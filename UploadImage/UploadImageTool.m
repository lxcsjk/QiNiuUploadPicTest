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


#define QiNiuBaseUrl @"http://7xozpn.com2.z0.glb.qiniucdn.com/"
@implementation UploadImageTool


#pragma mark - Helpers

//上传单张图片
+ (void)uploadImage:(UIImage *)image progress:(QNUpProgressHandler)progress success:(void (^)(NSString *url))success failure:(void (^)())failure {
    
    NSString *token = @"nJFlB1tTkoMkNfcac3cNyeYC7VTTxis_UrumXtuq:mOHV4vc76N_5zBhm_CXVKnkzDYY=:eyJmc2l6ZUxpbWl0IjoxMDQ4NTc2MCwic2NvcGUiOiJmaWxlIiwicmV0dXJuQm9keSI6IntcIm5hbWVcIjogJChmbmFtZSksXCJ1cmxcIjpcImh0dHA6Ly9kYWRhLmNvbS8kKGtleSlcIixcImtleVwiOiAkKGtleSksIFwiaGFzaFwiOiAkKGV0YWcpLCBcIndcIjogJChpbWFnZUluZm8ud2lkdGgpLCBcImhcIjogJChpbWFnZUluZm8uaGVpZ2h0KSxcInNpemVcIjokKGZzaXplKX0iLCJkZWFkbGluZSI6MTQ3MzgzNzU5MH0=";
    
        NSData *data = UIImageJPEGRepresentation(image, 0.01);
        
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

//上传多张图片
+ (void)uploadImages:(NSArray *)imageArray progress:(void (^)(CGFloat))progress success:(void (^)(NSArray *))success failure:(void (^)())failure {
    
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
    uploadHelper.singleSuccessBlock  = ^(NSString *url) {
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
                
                 [UploadImageTool uploadImage:imageArray[currentIndex] progress:nil success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
            }
           
        }
    };
    
    [UploadImageTool uploadImage:imageArray[0] progress:nil success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
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
