//
//  ViewController.m
//  NSUrl
//
//  Created by Gwyneth Gan on 17/2/8.
//  Copyright © 2017年 Gwyneth. All rights reserved.
//

#import "ViewController.h"
#import "DownloadFile1ViewController.h"
#import "DownloadFile2ViewController.h"
#import "UploadFile1ViewController.h"
#import "UploadFile2ViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    for (int i = 0;i < 4;i++) {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 50+100*i, self.view.frame.size.width-200, 50)];
        btn.tag = i+1;
        [btn setBackgroundColor:[UIColor redColor]];
        [btn addTarget:self action:@selector(choose:) forControlEvents:(UIControlEventTouchUpInside)];
        [self.view addSubview:btn];
    }
}
-(void)choose:(UIButton *)sender{
    if (sender.tag == 1) {
        DownloadFile1ViewController * VC1 = [[DownloadFile1ViewController alloc]init];
        [self presentViewController:VC1 animated:YES completion:^{
            
        }];
    }else if (sender.tag == 2){
        DownloadFile2ViewController * VC2 = [[DownloadFile2ViewController alloc]init];
        [self presentViewController:VC2 animated:YES completion:^{
            
        }];
    }
    else if (sender.tag == 3){
        UploadFile1ViewController * VC3 = [[UploadFile1ViewController alloc]init];
        [self presentViewController:VC3 animated:YES completion:^{
            
        }];
    }
    else if (sender.tag == 4){
        UploadFile2ViewController * VC4 = [[UploadFile2ViewController alloc]init];
        [self presentViewController:VC4 animated:YES completion:^{
            
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
