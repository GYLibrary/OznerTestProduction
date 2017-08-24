//
//  ServerController.m
//  CocoSocketDemo
//
///
//  Created by ZGY on 2017/6/5.
//  Copyright © 2017年 macpro. All rights reserved.
//
//  Author:        Airfight
//  My GitHub:     https://github.com/airfight
//  My Blog:       http://airfight.github.io/
//  My Jane book:  http://www.jianshu.com/users/17d6a01e3361
//  Current Time:  2017/6/5  上午11:16
//  GiantForJade:  Efforts to do my best
//  Real developers ship.

#import "ServerController.h"
#import <GCDAsyncSocket.h>
#import <ifaddrs.h>
#import <arpa/inet.h>


@interface ServerController ()<GCDAsyncSocketDelegate>

@property (weak, nonatomic) IBOutlet UITextField *portF;
@property (weak, nonatomic) IBOutlet UITextField *messageTF;
@property (weak, nonatomic) IBOutlet UITextView *showContentMessageTV;

// 服务器socket(开放端口,监听客户端socket的链接)
@property (strong, nonatomic) GCDAsyncSocket *serverSocket;
// 保存客户端socket
@property (strong, nonatomic) GCDAsyncSocket *clientSocket;
@property (weak, nonatomic) IBOutlet UILabel *ipLb;

@property (strong,nonatomic) NSMutableArray *clientSockets;

@end

@implementation ServerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 1.初始化服务器socket, 在主线程里回调
    self.serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    _ipLb.text = [self getIPAddress];
    _clientSockets = [[NSMutableArray alloc] init];
    
}
- (IBAction)startNotice:(id)sender {
    // 2.开放哪一个端口
    NSError *error = nil;
    BOOL result = [self.serverSocket acceptOnPort:self.portF.text.integerValue error:&error];
//    BOOL result = [self.serverSocket acceptOnInterface:@"192.168.1.122" port:self.portF.text.integerValue error:&error];
    if (result && error == nil) {
        // 开放成功
        [self showMessageWithStr:@"开放成功"];
    }
    
}

// socket是保存的客户端scket, 表示给这个socket客户端发送消息
- (IBAction)sendMessage:(id)sender {
    NSData *data = [self.messageTF.text dataUsingEncoding:NSUTF8StringEncoding];
    // withTimeout -1 : 无穷大,一直等
    // tag : 消息标记
    [self.clientSocket writeData:data withTimeout:- 1 tag:0];
    
}
- (IBAction)clearMessageAction:(id)sender {
    
    self.showContentMessageTV.text = NULL;
    
}

// socket是客户端socket, 表示从哪一个客户端读取消息
- (IBAction)receiveMessage:(id)sender {
    
    [self.clientSocket readDataWithTimeout:11 tag:0];
    
}

 // 信息展示
- (void)showMessageWithStr:(NSString *)str {
    self.showContentMessageTV.text = [self.showContentMessageTV.text stringByAppendingFormat:@"%@\n", str];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 服务器socketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
// 保存客户端的socket
    self.clientSocket = newSocket;
//    for (GCDAsyncSocket *item in self.clientSockets) {
//        
//        if ([item.localHost isEqualToString:newSocket.localHost]) {
//            [self.clientSockets removeObject:item];
//            continue;
//        }
//        
//    }
//    
//    [self.clientSockets addObject:newSocket];
    [self showMessageWithStr:@"链接成功"];
    [self showMessageWithStr:[NSString stringWithFormat:@"服务器地址: %@ -端口: %d", newSocket.connectedHost, newSocket.connectedPort]];
    [self.clientSocket readDataWithTimeout:- 1 tag:0];
}

// 收到消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [self showMessageWithStr:text];
    [self.clientSocket readDataWithTimeout:- 1 tag:0];
    
    //成功收到消息后回复 客户端
    [self.clientSocket writeData:data withTimeout:- 1 tag:0];
    
}

// Get IP Address
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
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
