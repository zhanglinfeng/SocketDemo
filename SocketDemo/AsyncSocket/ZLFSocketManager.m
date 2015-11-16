//
//  ZLFSocketManager.m
//  SocketDemo
//
//  Created by 张林峰 on 15/11/3.
//  Copyright (c) 2015年 张林峰. All rights reserved.
//

#import "ZLFSocketManager.h"

@implementation ZLFSocketManager

- (id)init
{
    self = [super init] ;
    if (self) {
        
    }
    return self ;
}

+ (ZLFSocketManager *) sharedInstance{
    static ZLFSocketManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZLFSocketManager alloc]init];
    });
    return instance;
}

#pragma mark  - 对外接口
//重置socket
- (void)startSocketWith:(NSString *)socketHost socketPort:(UInt16)port {
    
    self.socketHost = socketHost;// host设定
    self.socketPort = port;// port设定
    
    // 在连接前先进行手动断开
    self.socket.userData = SocketOfflineByUser;
    [self cutOffSocket];
    
    // 确保断开后再连，如果对一个正处于连接状态的socket进行连接，会出现崩溃
    self.socket.userData = SocketOfflineByServer;
    [self socketConnectHost];
}

// socket连接
-(void)socketConnectHost{
    
    self.socket    = [[AsyncSocket alloc] initWithDelegate:self];
    
    NSError *error = nil;
    
    [self.socket connectToHost:self.socketHost onPort:self.socketPort withTimeout:3 error:&error];
    
}


// 切断socket
-(void)cutOffSocket{
    
    self.socket.userData = SocketOfflineByUser;// 声明是由用户主动切断
    
    [self.connectTimer invalidate];
    
    [self.socket disconnect];
}

#pragma mark  - 功能函数

// 心跳连接
-(void)longConnectToSocket{
    
    // 根据服务器要求发送固定格式的数据，假设为指令@"longConnect"，但是一般不会是这么简单的指令
    
    NSString *longConnect = @"longConnect";
    
    NSData   *dataStream  = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.socket writeData:dataStream withTimeout:1 tag:1];
    
}

//data转　dictionary
- (id)JSONValue:(NSData *)data {
    NSDictionary *dictionary = nil;
    @try {
        NSError *error;
        dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            NSLog(@"json error when [NSJSONSerialization JSONObjectWithData:options:error:], error %@", error);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"json解析抛出异常");
    }
    @finally {
        
    }
    
    return dictionary;
}

#pragma mark  - 连接成功回调
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString  *)host port:(UInt16)port
{
    NSLog(@"socket连接成功");
    
    // 每隔30s向服务器发送心跳包
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];// 在longConnectToSocket方法中进行长连接需要向服务器发送的讯息
    
    [self.connectTimer fire];
    
}

-(void)onSocketDidDisconnect:(AsyncSocket *)sock {
    NSLog(@"sorry the connect is failure %ld",sock.userData);
    if (sock.userData == SocketOfflineByServer) {
        // 服务器掉线，重连
        [self socketConnectHost];
    }
    else if (sock.userData == SocketOfflineByUser) {
        // 如果由用户断开，不进行重连
        return;
    }
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // 对得到的data值进行解析与转换即可
    
    //创建通知
    NSDictionary *dic = [self JSONValue:data];
    NSNotification *notification =[NSNotification notificationWithName:@"socketDidReadData" object:nil userInfo:dic];
    
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    [self.socket readDataWithTimeout:30 tag:0];
}

@end
