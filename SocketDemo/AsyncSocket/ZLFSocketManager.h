//
//  ZLFSocketManager.h
//  SocketDemo
//
//  Created by 张林峰 on 15/11/3.
//  Copyright (c) 2015年 张林峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

typedef NS_ENUM(NSInteger, SocketOffLineType) {
    SocketOfflineByServer,// 服务器掉线，默认为0
    SocketOfflineByUser,  // 用户主动cut
};

@interface ZLFSocketManager : NSObject<AsyncSocketDelegate>

@property (nonatomic, strong) AsyncSocket    *socket;       // socket
@property (nonatomic, copy  ) NSString       *socketHost;   // socket的Host(连接时host与port都是由服务器指定,请与服务器端开发人员交流)
@property (nonatomic, assign) UInt16         socketPort;    // socket的prot
@property (nonatomic, retain) NSTimer        *connectTimer; // 计时器

+ (ZLFSocketManager *) sharedInstance;

#pragma mark  - 对外接口
//开始并连接socket
- (void)startSocketWith:(NSString *)socketHost socketPort:(UInt16)port;

// socket连接
-(void)socketConnectHost;

// 断开socket连接
-(void)cutOffSocket;

@end
