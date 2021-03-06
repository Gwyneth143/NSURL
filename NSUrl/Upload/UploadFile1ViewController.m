//
//  UploadFile1ViewController.m
//  NSUrl
//
//  Created by Gwyneth Gan on 17/2/10.
//  Copyright © 2017年 Gwyneth. All rights reserved.
//

#import "UploadFile1ViewController.h"
#define Boundary  @"----WebKitFormBoundary35cxmtFcIglrlsad"
#define NewLine [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]
@interface UploadFile1ViewController ()<NSURLConnectionDataDelegate>

//网络连接
@property(nonatomic,strong)NSURLConnection * connection;
//进度条
@property (nonatomic, strong) UIProgressView * progressV;
//进度百分比
@property (nonatomic, strong) UILabel * progressLable;
// 上传按钮
@property(nonatomic,strong)UIButton * uploadBtn;

@end

@implementation UploadFile1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _progressV = [[UIProgressView alloc]initWithProgressViewStyle:(UIProgressViewStyleDefault)];
    _progressV.frame = CGRectMake(20, 100, self.view.frame.size.width-40, 10);
    _progressV.trackTintColor = [UIColor blackColor];
    _progressV.progressTintColor = [UIColor cyanColor];
    [_progressV setProgress:0 animated:YES];
    [self.view addSubview:_progressV];
    
    _progressLable = [[UILabel alloc]initWithFrame:CGRectMake(20, 120, 100, 20)];
    [self.view addSubview:_progressLable];
    
    _uploadBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 200, 80, 50)];
    [_uploadBtn setTitle:@"Start" forState:(UIControlStateNormal)];
    [_uploadBtn setBackgroundColor:[UIColor redColor]];
    [_uploadBtn addTarget:self action:@selector(Click:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_uploadBtn];

}
#pragma mark -- 下载数据
-(void)Click:(UIButton *)sender{
    if([sender.titleLabel.text isEqualToString:@"Start"]){
        [self uploadFile];
        [_uploadBtn setTitle:@"Pause" forState:(UIControlStateNormal)];
    }else if([sender.titleLabel.text isEqualToString:@"Pause"]){
        [_connection cancel];
        [_uploadBtn setTitle:@"Continue" forState:(UIControlStateNormal)];
    }else if([sender.titleLabel.text isEqualToString:@"Continue"]){
        [self uploadFile];
        [_uploadBtn setTitle:@"Pause" forState:(UIControlStateNormal)];
    }
}
#pragma mark -- 上传文件
-(void)uploadFile{
    NSURL * url = [NSURL URLWithString:@"http://120.25.226.186:32812/upload"];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    //设置请求头
    NSString *header = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",Boundary];
    [request setValue:header forHTTPHeaderField:@"Content-Type"];
    NSData * bodyData = [self getBody];
    request.HTTPBody = bodyData;
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
}
#pragma mark -- delegateForNSURLConnect
-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    CGFloat value = (CGFloat)totalBytesWritten/totalBytesExpectedToWrite;
    _progressV.progress = value;
    _progressLable.text = [NSString stringWithFormat:@"%.0f%@",value*100,@"%"];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
     [_uploadBtn setTitle:@"Complete" forState:(UIControlStateNormal)];
}
#pragma mark -- 设置请求体
-(NSData *)getBody{
    //设置请求体
    NSMutableData *fileData = [NSMutableData data];
    //文件参数形式
    /*
     --分隔符
     Content-Disposition: form-data; name="file"; filename="123.png"
     Content-Type: image/png
     空行
     文件数据
     */
    NSString *str = [NSString stringWithFormat:@"--%@",Boundary];
    [fileData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:NewLine];
    [fileData appendData:[@"Content-Disposition: form-data; name=\"file\"; filename=\"123.png\"" dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:NewLine];
    [fileData appendData:[@"Content-Type: image/png" dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:NewLine];
    [fileData appendData:NewLine];
    [fileData appendData:NewLine];
    
    UIImage *image = [UIImage imageNamed:@"123"];
    NSData *imageData = UIImagePNGRepresentation(image);
    [fileData appendData:imageData];
    [fileData appendData:NewLine];
    //非文件参数
    /*
     --分隔符
     Content-Disposition: form-data; name="username"
     空行
     yy
     */
    [fileData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:NewLine];
    [fileData appendData:[@"Content-Disposition: form-data; name=\"username\"" dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:NewLine];
    [fileData appendData:NewLine];
    [fileData appendData:NewLine];
    [fileData appendData:[@"yy" dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:NewLine];
    
    //结尾标识
    /*
     --分隔符--
     */
    [fileData appendData:[[NSString stringWithFormat:@"--%@--",Boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:NewLine];
    return fileData;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
