//
//  LogingVM.m
//  1_ReactiveCocoa
//
//  Created by SilenceZhou on 2017/9/28.
//  Copyright © 2017年 silence. All rights reserved.
//

#import "LogingVM.h"

@implementation LogingVM


- (instancetype)init
{
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}


// 初始化操作
- (void)setUp
{
    // 1.登录按钮是否能点击 的信号
    _loginEnableSiganl = [RACSignal combineLatest:@[RACObserve(self, account),
                                                    RACObserve(self, pwd)]
                                           reduce:^id(NSString *account,NSString *pwd){
                                               
                                               return @(account.length && pwd.length);
                                               
                                           }];
    
    // 2.登录点击 信号
    _loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                // 发送数据
                [subscriber sendNext:@"请求登录的数据"];
                [subscriber sendCompleted];
            });
            
            return nil;
            
        }];
    }];
    
    // 3.处理登录请求返回的结果
    [_loginCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 4.处理登录执行过程
    [[_loginCommand.executing skip:1] subscribeNext:^(id x) {
        
        if ([x boolValue] == YES) {
            NSLog(@"登陆成功");
            
        }else{
            NSLog(@"登陆时报");
        }
        
    }];
}

@end
