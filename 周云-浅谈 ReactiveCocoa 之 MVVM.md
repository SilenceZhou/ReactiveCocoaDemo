# 浅谈 ReactiveCocoa 之 MVVM

[TOC]


>**简介** ：
>
>1. ReactiveCocoa(简称：RAC)为一个开源函数响应式编程框架；
>
>2. 使用场景：通过RAC可以更加方便编程进行MVVM设计模式编程；
>
>3. 核心机制为信号（信号流）。
>
>4. [Demo地址](https://github.com/SilenceZhou/ReactiveCocoaDemo)
>
> 5. 由于Swift和OC版本存在的差异性比较大，维护团队直接给拆了一下： Swift版本（ReactiveSwift）和 OC版本（ReactiveCocoa）
>
> 6. 写该篇文章的初衷： 如果使用RAC 和 如果借助RAC来逐步实现MVC到MVVM的迁移。



##一、ReactiveCocoa初见

###1. 编程思想
1、编程思想： [ReactiveCocoa](https://github.com/ReactiveCocoa)是函数式编程（Functional Programming）和响应式编程（Reactive Programming）集大成者；

2、实现关键： 每个方法必须有返回值（本身对象）,把函数或者Block当做参数,block参数（需要操作的值）block返回值（操作结果）；

###2.ReactiveCocoa初见

0、如何集成就略了（直接拉入项目或者CocoaPods）

1、 RACSiganl
>最基本的信号类，默认为冷信号，表示当数据改变时，信号内部会发出数据，只有订阅了（subscribeNext）才会进被触发，代码演示如下：

```
// 1.创建信号
RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        // 3、发送信号信号 
        NSLog(@"信号被订阅 发送信号"); 
        // 4、执行了这一步 订阅信号才会发触发
        [subscriber sendNext:@"heheh"];
        return nil;
    }];
    
    
    // 2.订阅信号 ---必须为订阅
    [signal subscribeNext:^(id  _Nullable x) {
        // 发送信号的内容
        NSLog(@"====%@", x);
    }];
```

2、RACSubscriber 
>订阅者，用于发送信号，这是一个协议，不是一个类，只要遵守这个协议，并且实现方法才能成为订阅者。

3、RACDisposable : 
> 用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它。
>使用场景:不想监听某个信号时，可以通过它主动取消订阅信号

代码演示如下：

```
// 1.创建
RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        // 3、发送信号信号
        NSLog(@"信号被订阅 发送信号"); 
        [subscriber sendNext:@"heheh"];
        return [RACDisposable disposableWithBlock:^{
            // 只要信号取消就会来这里
            // 默认一个信号发送数据完毕就会主动取消订阅
            NSLog(@"信号被取消了");
        }];
    }];
    
    // 2.订阅信号 ---必须为订阅
    RACDisposable *disposable = [signal subscribeNext:^(id  _Nullable x) {
        // 发送信号的内容
        NSLog(@"====%@", x); 
    }];
    
    // 3.取消订阅
    [disposable dispose];
```

4、RACSubject

> 4.1. RACSubject:信号提供者，自己可以充当信号，又能发送信号。
> 4.2. 用场景:通常用来代替代理，有了它，就不必要定义代理了。


5、RACTuple
> 元组类,类似NSArray,用来包装值.

```
RACTuple *tuple = [RACTuple tupleWithObjectsFromArray:@[@"hello111", @"hello222",@"hello333"]];
    
NSLog(@"%@", [tuple objectAtIndex:0]);
    
```

6、RACSequence

> 6.1、RAC中的集合类，用于代替NSArray,NSDictionary,可以使用它来快速遍历数组和字典。

```
1、RACSequence代替数组
- (void)testRACSequenceArr
{
    NSArray * arr = @[@"123", @"asdfas", @1];
    // 订阅集合信号，内部会自动便利所有的元素发出来
    [arr.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
}

2、RACSequence代替字典
- (void)testRACSequenceDict
{
    
    NSDictionary *dict = @{ @"name" : @"张三", @"age" : @22};
    
    [dict.rac_sequence.signal subscribeNext:^(RACTuple * _Nullable x) {
        
        // 方法一、
        // NSLog(@"%@  %@", x[0], x[1]);
        
        // 方法二、
        // 用来解析元组， 宏里面的参数，传需要解析出来的变量名
        // = 右边，放需要解析的元组
        RACTupleUnpack(NSString *key, NSString *value) = x;
        NSLog(@"%@ %@", key, value );
    }];
    
}

```


7、RACCommand
> 7.1、直译为命令，只是一个继承自 NSObject 的类，但是它却可以用来创建和订阅用于响应某些事件的信号。
> 7.2、相对而言比较复杂
> 7.3、使用场景：网络请求（MVVM设计模式中网络模块）
> 7.4、在默认情况下 RACCommand 都是不支持并发操作的，需要在上一次命令执行之后才可以发送下一次操作，如果直接execute:两次，最终也只会执行第一个execute：； 所以谨记 在使用应用中推荐一个网络请求对应一个command；

```
简单使用 - 用于网络请求
- (void)RACCommandSimpleUse
{
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber * _Nullable input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:input];
            // 每次sendNext 记得sendCompleted
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    [[command.executionSignals switchToLatest] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    // 在默认情况下 RACCommand 都是不支持并发操作的，需要在上一次命令执行之后才可以发送下一次操作，如果直接execute:两次，最终也只会执行第一个execute：
    // 所以谨记: 一个command对应一个网络请求
    [command execute:@"网络请求1"];
    // [command execute:@"网络请求2"];

    [RACScheduler.mainThreadScheduler afterDelay:0.5
                                        schedule:^{
                                            [command execute:@"网络请求2"];
                                        }];
}
```

8、RACMulticastConnection
> 8.1、直译为多播连接;
> 8.2、存在的问题普通的信号在执行sendNext:的时候，都会重新再执行以下信号的创建，当你想在一个请求完成后 进行分多级刷新UI 或者 做一些别的操作，如果直接用普通的信号进行sendNext：时候，则会进行多次网络请求操作；
> 8.3、项目中使用到的场景比较少；

```

-(void)RACMulticastConnectionUse
{
    // 1、通过信号创建链接
    RACMulticastConnection *connection = [[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"完毕");
        
        [subscriber sendNext:@"Send Request"];
        // 每次sendNext 记得sendCompleted
        // [subscriber sendCompleted];
        
        return nil;
    }] publish];
    
    //  订阅信号（通过链接转换的信号）一次
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"一次 x : %@", x);
    }];
    
    //  订阅信号（通过链接转换的信号）二次
    [connection.signal subscribeNext:^(id  _Nullable x) {

        NSLog(@"二次 x : %@", x);
    }];
    [connection connect];
    
    // 且只有第一次连接才会有效果
    //    [connection.signal subscribeNext:^(id  _Nullable x) {
    //        NSLog(@"重新连接第一次 x : %@", x);
    //    }];
    //    [connection.signal subscribeNext:^(id  _Nullable x) {
    //        NSLog(@"重新连接第二次 x : %@", x);
    //    }];
    //    [connection connect];
}
```


##二、ReactiveCocoa使用场景

1、代替代理
> 1、对象持有signal， 推荐用这种

```
Code eg.:
- (void)useRACInstandDelegate
{
    [self.redView.btnClickSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
}
```
> 2、使用rac_signalForSelector来进行方方法的执行，类似于系统自带方法performSelector:withObject:，不推荐(硬编码 和 警告)；

```
Code eg.:

- (void)useRACInstandDelegate2
{
    [[self.redView rac_signalForSelector:@selector(btnClick:)] subscribeNext:^(id  _Nullable x) {       
        NSLog(@"红色view上面的按钮点击了");
    }];
}

```


2、代替KVO：

```
- (void)insteadKVO
{
    // 需手动导入：#import "NSObject+RACKVOWrapper.h"
    //  1.代替KVO 方法一
    [self.redView rac_observeKeyPath:@"frame"
                             options:NSKeyValueObservingOptionNew
                            observer:nil block:^(id value,
                                                 NSDictionary *change,
                                                 BOOL causedByDealloc,
                                                 BOOL affectedOnlyLastComponent) {
                                //
                                
                            }];
    // 2.替代KVO 方法二
    [[self.redView rac_valuesForKeyPath:@"frame" observer:nil] subscribeNext:^(id  _Nullable x) {
        // 打印的是NSRect
        NSLog(@"%@", x);
    }];
```

3、监听按钮的点击事件：

```
- (void)monitorBtnClick
{
    UIButton *btn;
    
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
    }];
}
```

4、代替通知：

```
- (void)insteadNotification
{
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        
    }];

}
```


5、监听文本框文案：

```
- (void)insteadTextInput
{
    UITextField *textField;
    [textField.rac_textSignal subscribeNext:^(NSString * _Nullable x) { 
        // 监听到文本的改变      
    }];
}

```

6、处理当界面有多次请求时，需要都获取到数据时，才能展示界面

```

- (void)multiRequestData
{
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        NSLog(@"发送木块一的数据");
        [subscriber sendNext:@"发送木块一的数据"];
        
        return nil;
    }];
    
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        NSLog(@"发送模块二的数据");
        [subscriber sendNext:@"发送模块二的数据"];
        
        return nil;
    }];
    
    
    // 数组：存放信号
    // 当数组中的所有信号都发送完成的时候，才会执行Selector
    // 方法的参数： 必须跟数组一一对应
    // 方法的参数：就是每一个信号发送的数据
    
    [self rac_liftSelector:@selector(updateUIFirstPartData:secondPartData:)
      withSignalsFromArray:@[signal1, signal2]];
}

- (void)updateUIFirstPartData:(NSString *)firstPartData secondPartData:(NSString *)secondPartData
{
    NSLog(@"更新 UI%@ %@",firstPartData , secondPartData);

}
```



##三、浅谈MVVM

> 简介：MVVM,个人理解他就是MVC的升级版，解耦版，它是一种双向绑定（data-binding）：View的变动，自动反映在 ViewModel，反之亦然； MVVM设计模式并不一定要借助RAC来实现，但若使用RAC来实现会更加的简单(因为所有的操作和响应都通过信号来完成对接)；
> M : 最基本的模型数据
> V : 视图 / 控制器
> VM : 处理业务的逻辑（eg:操作事件、数据请求等）

1.项目目录结构的体现（给你一种既视感😆）：
![](media/15063486183673/15065286869074.jpg)

2.具体的实操（由于比较简单的实现，model数据就放在VM里面）

2.1. V(控制器或者视图)里面的写法： 提前对数据进行绑定

```
备注： LoginVc.m 文件， LoginVc.h文件可忽略

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
```

2.2. VM （数据的交互），由于比较简单直接把model放到了VM里面了, 一些数据的逻辑处理， 按钮是否可点击，网络是否要请求等；

```
头文件：LogingVM.h

#import <Foundation/Foundation.h>

@interface LogingVM : NSObject

@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *pwd;

@property (nonatomic, strong, readonly) RACSignal *loginEnableSiganl; /**< 处理登录按钮是否允许点击 */
@property (nonatomic, strong, readonly) RACCommand *loginCommand;/** 登录按钮命令 */

@end


实现文件： LogingVM.m

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

```


3、 通过上面的[登陆示例](https://github.com/SilenceZhou/ReactiveCocoaDemo)，可以感受到RAC在MVVM的便捷性，可测试性（VM）都有一定的提高。

4、如果项目把设计模式由MVC迁移为MVVM，可以分步走，可以理解MVVM是升级版的MVC， 其实就是把以前放在VC 里面处理的逻辑有条理的放到VM里面，Code可测性变高。


