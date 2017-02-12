//
//  URLFunction.m
//  NSUrl
//
//  Created by Gwyneth Gan on 17/2/8.
//  Copyright © 2017年 Gwyneth. All rights reserved.
//

#import "URLFunction.h"
#define StringMark @""
@implementation URLFunction{
    NSData * ResumeData;
    NSURLSessionDownloadTask * downloadTask;
    NSURLSession * downloadSession;
}
//利用NSURLConnection进行"GET"网络请求
-(void)GetTheDataByNSURLConnection{
    //创建URL，网络请求地址
    NSURL * url = [NSURL URLWithString:@"请求的网络地址"];
    //创建网络请求,默认为GET
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSURLResponse * response = nil;
    NSError * error = nil;
    /*
     1.Request：请求对象
     2.Response：若请求成功，则response会有值
     3.Error：若请求出错，则error会有值
     同步请求数据，在主线程执行，可能导致主线程卡顿
     用NSData接受请求到的数据
     */
    NSData * resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"the result is = %@",[[NSString alloc]initWithData:resultData encoding:NSUTF8StringEncoding]);
}
//利用NSURLConnection进行"POST"网络请求
-(void)PostTheDataByNSURLConnection{
    //创建URL，网络请求地址
    NSURL * url = [NSURL URLWithString:@"请求的网络地址"];
    //创建可变的网络请求,以修改请求方法
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    //POST 请求方法，注：要大写字母
    request.HTTPMethod = @"POST";
    //设置参数，参数之间用 & 隔开
    NSString * bodyStr = [NSString stringWithFormat:@"accountID=%@&password=%@",@"123",@"123"];
    //转化为Data
    NSData * bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    //设置请求体
    request.HTTPBody = bodyData;
    //设置请求头,请求头按照请求内容的规定写入
    [request setValue:@"要发送的请求头内容" forHTTPHeaderField:@"请求头"];
    //设置请求超时
    request.timeoutInterval = 10.0;
    /*
     1.Request：请求对象
     2.queue：代码块Block在此队列中执行
     3.Block代码块：response为响应头，请求成功则有值；data为响应体,解析已得到需要的数据；connectionError为连接出错，若请求出错，则connectionError会有值
     异步请求数据，不会导致主线程卡顿
     */
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        //若请求成功
        if (!connectionError) {
            NSLog(@"the result is = %@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        }
        
    }];
}
-(void)GetFromNetWorkByNSURLSession{
    //创建URL
    NSURL * url = [NSURL URLWithString:@"请求地址"];
    /*创建请求Request，默认为'GET'方式，
     1.URL：请求地址
     2.cachePolicy：缓存策略
        **缓存策略包括**
        1.NSURLRequestUseProtocolCachePolicy：缓存策略的逻辑定义在协议中实现
        2.NSURLRequestReloadIgnoringLocalCacheData：忽视本地缓存数据，从原地址加载数据
        3.NSURLRequestReturnCacheDataElseLoad：若本地有缓存，无论数据是否过期，从缓存中获取；若无缓存数据，则从原地址加载
        4.NSURLRequestReturnCacheDataDontLoad：若本地有缓存，无论数据是否过期，从缓存中获取；若无缓存数据，则加载失败，类似于离线模式
        5.NSURLRequestReloadIgnoringLocalAndRemoteCacheData：不仅忽视本地缓存，只要协议允许，它的代理或其它媒介也被命令忽视缓存，*****尚未实现的
        6.NSURLRequestReloadIgnoringCacheData：是NSURLRequestReloadIgnoringLocalCacheData以前的名字
        ***************
     3.timeoutInterval：请求超时时间
     */
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:url cachePolicy:(NSURLRequestReturnCacheDataElseLoad) timeoutInterval:10];
    NSURLSession * session = [NSURLSession sharedSession];
    //创建任务，data为响应体，response为响应头
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
//            NSString * dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"data 转 string = %@",dataString);
            //响应体需JSON序列化
            NSJSONSerialization * jsonData = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:nil];
            NSLog(@"json 解析结果 = %@",jsonData);
        }
    }];
    // 或者使用这个方法，自动将url包装成请求对象，仅限GET请求
    // NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    // NSLog(@"%@---%@",[NSJSONSerialization JSONObjectWithData: data options:kNilOptions error:nil]{
    // }];
    //启动任务
    [task resume];
}
-(void)PostToNetWorkByNSURLSession{
    //创建URL
    NSURL * url = [NSURL URLWithString:@"https://api.weibo.com/2/statuses/update.json"];
    //创建可变请求
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    //设置请求方法
    [request setHTTPMethod:@"POST"];
    //设置请求超时时间
    [request setTimeoutInterval:30];
    //请求体
    NSString * bodyString = @"access_token=23饿3饿3e&status=无限互联";
    NSData * bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    //设置请求体
    [request setHTTPBody:bodyData];
    NSURLSession * session = [NSURLSession  sharedSession];
    //同 'GET' 请求相似
    NSURLSessionDataTask * task  = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSJSONSerialization * jsonData = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:nil];
        NSLog(@"json 解析结果 = %@",jsonData);
    }];
    //启动任务
    [task resume];
}
//代理方法实现网络请求
-(void)GetFromNetWorkWithDelegate{
    NSURL * url = [NSURL URLWithString:@"http://news-at.zhihu.com/api/3/news/latest"];
    NSURLSessionConfiguration * configuartion = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuartion.timeoutIntervalForRequest = 20;
    configuartion.allowsCellularAccess = YES;
    NSOperationQueue * queue = [NSOperationQueue mainQueue];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:configuartion delegate:self delegateQueue:queue];
    NSURLSessionDataTask * task = [session dataTaskWithURL:url];
    [task resume];
}
#pragma mark -- delegateForNSURLSessionDataDelegate
//接受到服务器的响应
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    //允许接收数据
    completionHandler(NSURLSessionResponseAllow);
    /*
     1.NSURLSessionResponseCancel = 0, // 默认,取消加载数据，等同于[task cancel]
     2.NSURLSessionResponseAllow = 1,   // 允许加载继续
     3.NSURLSessionResponseBecomeDownload = 2,//把请求变为下载
     4.NSURLSessionResponseBecomeStream NS_ENUM_AVAILABLE(10_11, 9_0) = 3,//把任务变成一连串的任务
     */
}
// 接收到服务器返回的数据
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    NSLog(@"正在请求数据。。。。");
}
// 请求完成之后调用该方法
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"请求结束");
}
-(void)DownloadFromNetWork{
    NSURL * url = [NSURL URLWithString:@"http://ra01.sycdn.kuwo.cn/resource/n3/32/56/3260586875.mp3"];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask * task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString * filePath = [NSHomeDirectory()stringByAppendingPathComponent:@"Document/.music.mp3"];
        NSURL * fileUrl = [NSURL URLWithString:filePath];
        NSFileManager * manager = [NSFileManager defaultManager];
        BOOL isSuccess = [manager moveItemAtURL:location toURL:fileUrl error:nil];
        if (isSuccess) {
            NSLog(@"isSuccess");
        }
    }];
    [task resume];
}
-(void)DownloadFromNetWorkWithDelegate{
    NSURL * url = [NSURL URLWithString:@"http://ra01.sycdn.kuwo.cn/resource/n3/32/56/3260586875.mp3"];
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask * task = [session downloadTaskWithURL:url];
    [task resume];
}
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    CGFloat value = (int64_t)totalBytesWritten/(int64_t)totalBytesExpectedToWrite;
    NSLog(@"the progress is  = %f",value);
}
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSString * filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Document/music.mp3"];
    NSURL * fileURL = [NSURL fileURLWithPath:filePath];
    NSFileManager * manager = [NSFileManager defaultManager];
    BOOL isSuccess = [manager moveItemAtURL:location toURL:fileURL error:nil];
    if (isSuccess) {
        NSLog(@"下载完成");
    }
}

-(void)UploadToNetWork{
    NSURL * url = [NSURL URLWithString:@"https://api.weibo.com/2/statuses/upload.json"];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:30];
    NSString * contentType = [NSString stringWithFormat:@"multipart/form-data; charset=utf-8;boundary=%@",StringMark];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    NSURLSession * session = [NSURLSession sharedSession];
    NSData * bodyData = [self getBodyData];
    NSURLSessionUploadTask * task = [session uploadTaskWithRequest:request fromData:bodyData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString * result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"result is  = %@",result);
    }];
    [task resume];
}
- (NSData *)getBodyData {
    
    NSMutableString *bodyString = [[NSMutableString alloc] init];
    
    //拼接
    [bodyString appendFormat:@"--%@\r\n",StringMark];
    //（1）拼接access_token
    [bodyString appendFormat:@"Content-Disposition: form-data; name=\"access_token\"\r\n\r\n"];
    [bodyString appendFormat:@"2.00Nx36WDqSQJKBbe72fbff89wtNbKE\r\n"];
    
    [bodyString appendFormat:@"--%@\r\n",StringMark];
    
    //（2）拼接发布的微博的内容
    [bodyString appendFormat:@"Content-disposition: form-data; name=\"status\"\r\n\r\n"];
    [bodyString appendFormat:@"上课好累啊\r\n"];
    
    [bodyString appendFormat:@"--%@\r\n",StringMark];
    
    // （3）设置图片数据
    [bodyString appendFormat:@"Content-disposition: form-data; name=\"pic\"; filename=\"file\"\r\n"];
    [bodyString appendFormat:@"Content-Type: application/octet-stream\r\n\r\n"];
    
    //创建可变的data
    NSMutableData *sumData = [[NSMutableData alloc] init];
    
    //将字符串转换成data
    NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [sumData appendData:data];
    
    //获取图片
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"1.png" ofType:nil];
    NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
    [sumData appendData:imgData];
    
    NSString *lastString = [NSString stringWithFormat:@"\r\n--%@--\r\n",StringMark];
    NSData *lastData = [lastString dataUsingEncoding:NSUTF8StringEncoding];
    [sumData appendData:lastData];
    return sumData;
}
-(void)UploadToWorkWithDelegate{
    NSURL * url = [NSURL URLWithString:@"http://ra01.sycdn.kuwo.cn/resource/n3/32/56/3260586875.mp3"];
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    downloadSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    downloadTask = [downloadSession downloadTaskWithURL:url];
    [downloadTask resume];
}
-(void)pauseAction:(UIButton *)sender{
    [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        ResumeData = resumeData;
    }];
    downloadTask = nil;
}
-(void)ContinueAction:(UIButton *)sender{
    downloadTask  = [downloadSession downloadTaskWithResumeData:ResumeData];
    [downloadTask resume];
}
-(void)BackgroundAction:(UIButton *)sender{
    NSURL * url = [NSURL URLWithString:@"http://www.soge8.com/1424215157/e4eaa401acb097ad2745efe7f8213352.mp3"];
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask * task = [session downloadTaskWithURL:url];
    [task resume];
}
@end
