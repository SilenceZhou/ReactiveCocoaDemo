//
//  LoginVc.m
//  1_ReactiveCocoa
//
//  Created by SilenceZhou on 2017/9/28.
//  Copyright © 2017年 silence. All rights reserved.
//

#import "LoginVc.h"
#import "LogingVM.h"

@interface LoginVc ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
@property (weak, nonatomic) IBOutlet UIButton *LoginBtn;
@property (nonatomic, strong) LogingVM *loginVM;

@end

@implementation LoginVc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initRac];
    
}

- (void)initRac
{
    // 1. 绑定信号
    RAC(self.loginVM, account) = self.userNameTF.rac_textSignal;
    RAC(self.loginVM, pwd) = self.pwdTF.rac_textSignal;
    
    // 2. 登陆按钮能否点击
    RAC(_LoginBtn,enabled) = self.loginVM.loginEnableSiganl;
    
    // 3. 监听登录按钮点击
    [[_LoginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        // 处理登录事件 => 发送登陆请求
        [self.loginVM.loginCommand execute:nil];
    }];
}

- (LogingVM *)loginVM
{
    if (!_loginVM) {
        _loginVM = [[LogingVM alloc] init];
    }
    return _loginVM;
}

@end
