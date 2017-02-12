//
//  DownloadFile2ViewController.m
//  NSUrl
//
//  Created by Gwyneth Gan on 17/2/10.
//  Copyright © 2017年 Gwyneth. All rights reserved.
//

#import "DownloadFile2ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
@interface DownloadFile2ViewController ()<NSURLSessionDataDelegate>

//播放器
@property(nonatomic,strong)MPMoviePlayerViewController * playVC;
// 需要下载文件的总大小
@property(nonatomic,assign)NSInteger totalLength;
// 已经下载文件的大小
@property(nonatomic,assign)NSInteger currentLength;
//需要下载文件的名称
@property (nonatomic, copy) NSString * fileName;
//需要下载文件的路径
@property (nonatomic, copy) NSString * filePath;
//处理文件的句柄
@property (nonatomic, strong) NSFileHandle * handle;
//处理文件的输出流
@property (nonatomic, strong) NSOutputStream * stream;

@property(nonatomic,strong)NSURLSession * session;
//下载任务
@property(nonatomic,strong)NSURLSessionDataTask * dataTask;
// 进度条
@property(nonatomic,strong)UIProgressView * progressV;
//进度百分比
@property (nonatomic, strong) UILabel * progressLable;
// 播放按钮
@property(nonatomic,strong)UIButton * playBtn;
// 下载按钮
@property(nonatomic,strong)UIButton * downloadBtn;

@end

@implementation DownloadFile2ViewController

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
    
    _downloadBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 200, 80, 50)];
    [_downloadBtn setTitle:@"Start" forState:(UIControlStateNormal)];
    [_downloadBtn setBackgroundColor:[UIColor redColor]];
    [_downloadBtn addTarget:self action:@selector(Click:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_downloadBtn];
    
    _playBtn = [[UIButton alloc]initWithFrame:CGRectMake(150, 200, 80, 50)];
    [_playBtn setTitle:@"Play" forState:(UIControlStateNormal)];
    [_playBtn setBackgroundColor:[UIColor redColor]];
    [_playBtn addTarget:self action:@selector(Play:) forControlEvents:(UIControlEventTouchUpInside)];
    _playBtn.hidden = YES;
    [self.view addSubview:_playBtn];
    
    //请求路径
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_02.mp4"];
    //创建请求对象,断点下载需要设置请求头,因此要可变的 NSMutableURLRequest;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",self.currentLength];
    // 设置请求头
    /*
     表示头500个字节：Range: bytes=0-499
     表示第二个500字节：Range: bytes=500-999
     表示最后500个字节：Range: bytes=-500
     表示500字节以后的范围：Range: bytes=500-
     */
    //告知服务器从哪开始下载
    [request setValue:range forHTTPHeaderField:@"Range"];
    //设置代理并发送请求
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    _dataTask = [session dataTaskWithRequest:request];
    
}
#pragma mark -- 播放
-(void)Play:(UIButton *)sender{
    _playVC = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:_filePath]];
    [self presentViewController:_playVC animated:YES completion:^{
        
    }];
    [_playVC.moviePlayer play];
}
#pragma mark -- 下载数据
-(void)Click:(UIButton *)sender{
    if([sender.titleLabel.text isEqualToString:@"Start"]){
        [_dataTask resume];
        [_downloadBtn setTitle:@"Pause" forState:(UIControlStateNormal)];
    }else if([sender.titleLabel.text isEqualToString:@"Pause"]){
        [_dataTask suspend];
        [_downloadBtn setTitle:@"Continue" forState:(UIControlStateNormal)];
    }else if([sender.titleLabel.text isEqualToString:@"Continue"]){
         [_dataTask resume];
        [_downloadBtn setTitle:@"Pause" forState:(UIControlStateNormal)];
    }
}
#pragma mark -- delegateForSessionData
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    if (_currentLength > 0) {
        return;
    }
    _totalLength = response.expectedContentLength;
    _fileName = response.suggestedFilename;
    _filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:_fileName];
    NSFileManager * manage = [NSFileManager defaultManager];
    [manage createFileAtPath:_filePath contents:nil attributes:nil];
    _handle = [NSFileHandle fileHandleForWritingAtPath:_filePath];
    //或采用输出流处理
//    _stream = [[NSOutputStream alloc]initToFileAtPath:_filePath append:YES];
//    [_stream open];
    completionHandler(NSURLSessionResponseAllow);
}
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    _currentLength += data.length;
    CGFloat value = (CGFloat)_currentLength/_totalLength;
    _progressLable.text = [NSString stringWithFormat:@"%.0f%@",value*100,@"%"];
    _progressV.progress = value;
    [_handle seekToEndOfFile];
    [_handle writeData:data];
    //写入输出流
//    [_stream write:data.bytes maxLength:_currentLength];
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error == nil) {
        [_downloadBtn setTitle:@"Complete" forState:(UIControlStateNormal)];
//        [_handle closeFile];
        _handle = nil;
        
        _playBtn.hidden = NO;
    }
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
