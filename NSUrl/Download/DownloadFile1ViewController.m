//
//  DownloadFile1ViewController.m
//  NSUrl
//
//  Created by Gwyneth Gan on 17/2/9.
//  Copyright © 2017年 Gwyneth. All rights reserved.
//

#import "DownloadFile1ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
@interface DownloadFile1ViewController ()<NSURLConnectionDataDelegate>

//播放器
@property(nonatomic,strong)MPMoviePlayerViewController * playVC;
//进度条
@property (nonatomic, strong) UIProgressView * progressV;
//进度百分比
@property (nonatomic, strong) UILabel * progressLable;
//下载按钮
@property (nonatomic, strong) UIButton * downloadBtn;
//播放按钮
@property (nonatomic, strong) UIButton * playBtn;
//网络连接
@property (nonatomic, strong) NSURLConnection * connection;
//需要下载文件的名称
@property (nonatomic, copy) NSString * fileName;
//需要下载文件的路径
@property (nonatomic, copy) NSString * filePath;
//文件句柄
@property (nonatomic, strong) NSFileHandle * fileHandle;
//需要下载的文件
@property (nonatomic, strong) NSMutableData * fileData;
//已经下载的文件大小
@property (nonatomic, assign) NSInteger currentLength;
//下载文件的总大小
@property (nonatomic, assign) NSInteger totalLength;

@end

@implementation DownloadFile1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _fileData = [NSMutableData data];
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
        [self downLoad];
        [_downloadBtn setTitle:@"Pause" forState:(UIControlStateNormal)];
    }else if([sender.titleLabel.text isEqualToString:@"Pause"]){
        [_connection cancel];
        [_downloadBtn setTitle:@"Continue" forState:(UIControlStateNormal)];
    }else if([sender.titleLabel.text isEqualToString:@"Continue"]){
        [self downLoad];
        [_downloadBtn setTitle:@"Pause" forState:(UIControlStateNormal)];
    }
}
#pragma mark -- download
-(void)downLoad{
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
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
}
#pragma mark -- DelegateForNSURLConnection
//接收到服务器响应的时候调用
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    if (self.currentLength > 0) {
        return;
    }
    //获取文件总大小，若暂停后继续下载，则获取的是剩余数据的大小
    _totalLength = response.expectedContentLength;
    _fileName = response.suggestedFilename;
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    // 获得下载文件路径
    _filePath = [caches stringByAppendingPathComponent:response.suggestedFilename];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createFileAtPath:_filePath contents:nil attributes:nil];
    
    //创建句柄
    _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_filePath];
}
//接收正在加载的数据
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_fileHandle seekToEndOfFile];
    [_fileHandle writeData:data];
    _currentLength += data.length;
//    [_fileData appendData:data];
//    _currentLength = _fileData.length;
    CGFloat value = (CGFloat)_currentLength/_totalLength;
    _progressLable.text = [NSString stringWithFormat:@"%.0f%@",value*100,@"%"];
    _progressV.progress = value;
    
}
//数据加载完毕
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [_downloadBtn setTitle:@"Complete" forState:(UIControlStateNormal)];
    _playBtn.hidden = NO;
    [_fileHandle closeFile];
    _fileHandle = nil;
//    //保存下载的文件到沙盒
//    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    //拼接文件全路径
//    NSString *fullPath = [caches stringByAppendingPathComponent:@"demo.mp4"];
//    //写入数据到文件
//    [_fileData writeToFile:fullPath atomically:YES];
}
//请求失败时调用此方法
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Fail");
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
