//
//  ViewController.m
//  SocketDemo
//
//  Created by 张林峰 on 15/11/3.
//  Copyright (c) 2015年 张林峰. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //注册通知
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketDidReadData:) name:@"socketDidReadData" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)socketDidReadData:(NSNotification *)notification {
    
}

@end
