//
//  ViewController.m
//  1_ReactiveCocoa
//
//  Created by SilenceZhou on 2017/8/27.
//  Copyright © 2017年 silence. All rights reserved.
//

#import "ViewController.h"
#import "RedView.h"
#import "Flag.h"
#import "NSObject+RACKVOWrapper.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet RedView *redView;

@end

@implementation ViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.redView.frame  = CGRectMake(100, 100, 150, 80);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.redView.backgroundColor = [UIColor blueColor];
    
    [self RACMulticastConnectionUse];
    
}

#pragma mark - RAC常见的宏
- (void)commonMacro
{
    UITextField *textField = [[UITextField alloc]init];
    UILabel *label = [[UILabel alloc] init];
    
    // 最基本的写法
    [textField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        label.text = x;
    }];
    
    // 1
    // 使用宏
    RAC(label, text) = textField.rac_textSignal;
    
    // 2
    // 只要这个对象的属性以改变就会产生信号
    
    [RACObserve(self.view, frame) subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x );
    }];
    //    self.view rac_valuesForKeyPath:<#(nonnull NSString *)#> observer:<#(NSObject * _Nonnull __weak)#>
    
    
    // 3 @weakify(self)  @strongify(self);
    
    //4.包装元组
    RACTuple *tuple = RACTuplePack(@1, @2);
    
    NSLog(@"%@", tuple[0]);
    
    
    
}




#pragma mark - 使用场景

- (void)useRACSence
{
    // 使用场景
    // 1.代替代理
    //    [self useRACInstandDelegate2];
    
    // 2.代理KVO (在block里面处理相关使用)
    // [self insteadKVO];
    
    // 3.监听事件
    // [self monitorBtnClick];
    
    // 4.代替通知
    // [self insteadNotification];
    
    // 5.监听文本框
    // [self insteadTextInput];
    
    // 6.一个界面又多次请求，需要全部请求完成，才刷新界面
    //[self multiRequestData];
}

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


- (void)insteadTextInput
{
    
    UITextField *textField;
    [textField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        
    }];
}

- (void)insteadNotification
{
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        
    }];

}

- (void)monitorBtnClick
{
    UIButton *btn;
    
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
    }];
}



- (void)insteadKVO
{
    // 这个头文件的手动导入： #import "NSObject+RACKVOWrapper.h"
    
    //  1.代替KVO 方法一
    [self.redView rac_observeKeyPath:@"frame"
                             options:NSKeyValueObservingOptionNew
                            observer:nil block:^(id value,
                                                 NSDictionary *change,
                                                 BOOL causedByDealloc,
                                                 BOOL affectedOnlyLastComponent) {
                                //
                                
                            }];
    
    [[self.redView rac_valuesForKeyPath:@"frame" observer:nil] subscribeNext:^(id  _Nullable x) {
        // 打印的是NSRect
        NSLog(@"%@", x);
    }];
    
    
    [self.redView rac_observeKeyPath:@"bounds"
                             options:NSKeyValueObservingOptionNew
                            observer:nil block:^(id value,
                                                 NSDictionary *change,
                                                 BOOL causedByDealloc,
                                                 BOOL affectedOnlyLastComponent) {
                                //
                                
                            }];

}


- (void)useRACInstandDelegate2
{
    
    // 1.代替代理： 1.RACSubject 2.rac_signalForSelector
    // RACSubject 可以传值   rac_signalForSelector不能传值
    
    [[self.redView rac_signalForSelector:@selector(btnClick:)] subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"红色view上面的按钮点击了");
    }];
    
    
}


- (void)RACbaseUse
{
    // 1、signal的基本使用
    //    [self testSignal];
    // 2、
    //    [self testRACDisposable];
    // 3、
    //    [self testRACSubject];
    
    // 4.
    //    [self testReplayerSubject];
    
    // 5. RAC代替代理
    //    [self useRACInstandDelegate];
    
    // 6.元组RACTuple 类似于数组
    //    [self  testTuple];
    
    // 7.1. 集合 数组
    //    [self testRACSequenceArr];
    
    
    // 7.2 集合 字典
    //    [self testRACSequenceDict];
    
    
    // 8.字典转模型
    //    [self highLevelRACSequence];
    
    // 9.RACCommand的简单使用
    // [self RACCommandSimpleUse];
    
    // 10.RACMulticastConnection得用
    
    [self RACMulticastConnectionUse];
    
    
}

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
    [command execute:@"网络请求1"];
    // [command execute:@"网络请求2"];

    [RACScheduler.mainThreadScheduler afterDelay:0.5
                                        schedule:^{
                                            [command execute:@"网络请求2"];
                                        }];
}



// 8.集合类高级使用  （字典转模型）
- (void)highLevelRACSequence
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];;
    
    NSArray * dictArr = [NSArray arrayWithContentsOfFile:filePath];
    
    
    //=========== 第一种方法  =======//
    NSMutableArray *arr = [NSMutableArray array];
    [dictArr.rac_sequence.signal subscribeNext:^(NSDictionary *x) {
        
        [arr addObject:[Flag flagWithDict:x]];
        
    }];
    //！！！！ 注意这个地方还是 异步打印不出来
    //    NSLog(@"%@", arr);
    
    //=========== 第二种方法  =======//
    // 高级用法 -- 能最终打印出来
    // 会把集合中所有元素都映射成一个新的对象
    
    NSArray *arrhehe = [[dictArr.rac_sequence map:^id _Nullable(NSDictionary *value) {
        
        // value : 集合中的元素
        // id ： 返回对象就是映射的值
        return [Flag flagWithDict:value];
    }] array];
    
    
    NSLog(@"arrhehe = %@", arrhehe);
    
    
    
}


// 7.2 集合 字典
- (void)testRACSequenceDict
{
    
    NSDictionary *dict = @{ @"name" : @"张三", @"age" : @22};
    
    [dict.rac_sequence.signal subscribeNext:^(RACTuple * _Nullable x) {
        
        // 有一个快速的宏
//        NSLog(@"%@  %@", x[0], x[1]);
        
        // 用来解析元组， 宏里面的参数，传需要解析出来的变量名
        // = 右边，放需要解析的元组
        RACTupleUnpack(NSString *key, NSString *value) = x;
        NSLog(@"%@ %@", key, value );
        
    }];
    
}


// 7.集合类RACSequence

- (void)testRACSequenceArr
{
    
    NSArray * arr = @[@"123", @"asdfas", @1];
    
    // 订阅集合信号，内部会自动便利所有的元素发出来
    [arr.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
}



// 6.元祖： 类似于数组
- (void)testTuple
{
    RACTuple *tuple = [RACTuple tupleWithObjectsFromArray:@[@"hello111", @"hello222",@"hello333"]];
    
    NSLog(@"%@", [tuple objectAtIndex:0]);
}





// 5.RAC的应用
- (void)useRACInstandDelegate
{
    
    [self.redView.btnClickSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
}




// 4. RAC


- (void)testReplayerSubject
{
    // 1.创建信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    
    
    // 3.发送信号(这一步仅仅是保存数据，不会执行block)
    [replaySubject sendNext:@2];
    
    // 2.订阅信号
    [replaySubject subscribeNext:^(id  _Nullable x) {
        NSLog(@"接收到信号%@", x);
    }];
    
    // 便利所有的值，拿到当前订阅者去发送数据
    
    // 3.发送信号
//    [replaySubject sendNext:@2];
    //  保存值
    //  便利所有的订阅者，发送数据  （父类 RACSubject）
    
    /// !!!!!!!!!!
    //  可以先发送数据，再订阅信号
}


// 3、RACSubject ： 信号提供者， 可发信号又可作为信号

- (void)testRACSubject
{
    
    // 因为他遵循了协议 所以可以自己进行订阅
    RACSubject *subject = [RACSubject subject];
    
    // 订阅
    // 不同信号订阅的方式 和 发送信号的 方式 不一样；
    // 仅仅保存（通过数组）订阅者：
    [subject subscribeNext:^(id  _Nullable x) {
        
        // 接收到数据
        NSLog(@"第一个订阅者接收到数据 %@", x);
        
    }];
    
    
    [subject subscribeNext:^(id  _Nullable x) {
        
        // 接收到数据
        NSLog(@"第二个订阅者接收到数据 %@", x);
        
    }];
    
    
    // 发送
    [subject sendNext:@1];
}


// 2、RACDisposable

- (void)testRACDisposable
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        // 3、发送信号信号
        NSLog(@"信号被订阅 发送信号");  // 先打印
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
    
}

// 1、signal 的基本使用

- (void)testSignal
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        // 3、发送信号信号
        NSLog(@"信号被订阅 发送信号");  // 先打印
        [subscriber sendNext:@"heheh"];
        return nil;
    }];
    
    
    // 2.订阅信号 ---必须为订阅
    [signal subscribeNext:^(id  _Nullable x) {
        // 发送信号的内容
        NSLog(@"====%@", x);
    }];
}


//1.1 分析版本

- (void)testSignalAnalysis
{
    // didSubscribe 被保存了一份
    RACDisposable * (^didSubscribe)(id<RACSubscriber> subscriber) = ^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        // 3、发送信号信号 : 只要订阅者 调用sendNext， 就会执行nextBlock
        NSLog(@"信号被订阅 发送信号");  // 先打印
        [subscriber sendNext:@"heheh"];
        
        return nil;
    };
    
    RACSignal *signal = [RACSignal createSignal:didSubscribe];
    
    // 2.订阅信号 ---必须订阅
    /*   RACSubscriber 一个协议
     
        // subscribeNext的时候会创建一个订阅者
        subscribe的底层执行方式：
        0、先保存nextblock 到订阅者里面
             即：
             ^(id  _Nullable x) {
             // 发送信号的内容
             NSLog(@"====%@", x);
             
             }
     
        1、RACSignal (Subscription)   里面的 subscribeNext:
        2、RACDynamicSignal 里面的 ： subscribe:
        执行： RACDisposable *innerDisposable = self.didSubscribe(subscriber);
     
        nextBlock:
             ^(id  _Nullable x) {
             // 发送信号的内容
             NSLog(@"====%@", x);
             
             }
     
     */
    [signal subscribeNext:^(id  _Nullable x) {
        // 发送信号的内容
        NSLog(@"====%@", x);
        
    }];
    
    [signal subscribeNext:^(id  _Nullable x) {
        // 发送信号的内容
        NSLog(@"====%@", x);
        
    }];
}




@end
