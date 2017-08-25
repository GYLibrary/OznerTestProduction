//
//  ClientController.m
//  CocoSocketDemo
//
//
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

#import "ClientController.h"
#import <GCDAsyncSocket.h>
@interface ClientController ()<GCDAsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (weak, nonatomic) IBOutlet UITextField *messageTF;
@property (weak, nonatomic) IBOutlet UITextView *showMessageTF;
// 客户端socket
@property (strong, nonatomic) GCDAsyncSocket *clientSocket;
@end

@implementation ClientController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 1.初始化
    self.clientSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
}

// 开始连接
- (IBAction)connectAction:(id)sender {
    
// 2.链接服务器
//    [self.clientSocket connectToHost:self.addressTF.text onPort:self.portTF.text.integerValue viaInterface:nil withTimeout:-1 error:nil];
//   BOOL reselt =  [self.clientSocket connectToHost:self.addressTF.text onPort:[self.portTF.text integerValue] error:nil];
    uint16_t intA = 9999;
    [self.clientSocket connectToHost:self.addressTF.text onPort:intA error:nil];
//    NSError *error = nil;
//    
//   BOOL reselt =  [self.clientSocket connectToHost:self.addressTF.text onPort:9999 withTimeout:-1 error:&error];
//    
//    if (reselt) {
////        NSLog(@"%@",error);
//        NSLog(@"%@",self.clientSocket.connectedHost);
//        NSLog(@"%hu",self.clientSocket.connectedPort);
//        
//
//    }
    
}
//断开链接
- (IBAction)disConnectedAction:(id)sender {
    
    [self.clientSocket disconnect];
    
}

// 发送消息
- (IBAction)sendMessageAction:(id)sender {
    NSData *data = [self.messageTF.text dataUsingEncoding:NSUTF8StringEncoding];
    // withTimeout -1 : 无穷大,一直等
    // tag : 消息标记
    [self.clientSocket writeData:data withTimeout:- 1 tag:0];
}

// 接收消息
- (IBAction)receiveMessageAction:(id)sender {
     [self.clientSocket readDataWithTimeout:11 tag:0];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    
    [self showMessageWithStr:@"链接成功"];
    
    [self showMessageWithStr:[NSString stringWithFormat:@"服务器IP: %@,port:%hu", host,self.clientSocket.connectedPort]];
    [self.clientSocket readDataWithTimeout:- 1 tag:0];

}



// 收到消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [self.clientSocket readDataWithTimeout:- 1 tag:0];
    
    if (self.messageTF.text == text) {
        
        [self showMessageWithStr:[NSString stringWithFormat:@"产测成功:%@", text]];

    } else {
        [self showMessageWithStr: text];
    }
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (!err) {
        [self showMessageWithStr:[NSString stringWithFormat:@"%@已断开",self.addressTF.text]];

    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];

}

// 信息展示
- (void)showMessageWithStr:(NSString *)str {
    self.showMessageTF.text = [self.showMessageTF.text stringByAppendingFormat:@"%@\n", str];
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
