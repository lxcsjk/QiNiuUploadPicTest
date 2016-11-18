//
//  ViewController.m
//  QiNiuUploadImage
//
//  Created by Chendy on 16/7/11.
//  Copyright © 2016年 Chendy. All rights reserved.
//

#import "ViewController.h"
#import "UploadImageTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* 此项目没有加入七牛获取Token地址,请在UploadImageTool.m 中getQiniuUploadToken方法中设置你在七牛服务器中的token获取地址,使用网络请求 */
    //单张上传
    UIImage *image1 = [UIImage imageNamed:@"1.jpg"];
    UIImage *image2 = [UIImage imageNamed:@"1.jpg"];
    UIImage *image3 = [UIImage imageNamed:@"1.jpg"];

//
//    [UploadImageTool uploadImage:image progress:nil success:^(NSString *url) {
//        
//        NSLog(@"qin niu --%@",url);
//        
//    } failure:^{
//        
//        NSLog(@" --->> error:   ");
//        
//    }];
    
    //多张上传
    NSArray *imageArr = @[image1,image2,image3];
    
    [UploadImageTool uploadImages:imageArr progress:^(CGFloat progress) {
        
        NSLog(@"qin niu --%f",progress);
        
    } success:^(NSArray *urlArr) {
        
        NSLog(@"qin niu --%@",urlArr);
        
    } failure:^{

        NSLog(@" --->> error:   ");
        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
