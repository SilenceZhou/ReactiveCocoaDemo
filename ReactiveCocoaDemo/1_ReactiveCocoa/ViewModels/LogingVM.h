//
//  LogingVM.h
//  1_ReactiveCocoa
//
//  Created by SilenceZhou on 2017/9/28.
//  Copyright © 2017年 silence. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogingVM : NSObject

@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *pwd;

@property (nonatomic, strong, readonly) RACSignal *loginEnableSiganl; /**< 处理登录按钮是否允许点击 */
@property (nonatomic, strong, readonly) RACCommand *loginCommand;/** 登录按钮命令 */

@end
