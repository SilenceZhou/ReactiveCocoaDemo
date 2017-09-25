//
//  RedView.m
//  1_ReactiveCocoa
//
//  Created by SilenceZhou on 2017/8/27.
//  Copyright © 2017年 silence. All rights reserved.
//

#import "RedView.h"

@implementation RedView

- (RACSubject *)btnClickSignal
{
    if (!_btnClickSignal) {
        _btnClickSignal = [RACSubject subject];
    }
    return _btnClickSignal;
}



- (IBAction)btnClick:(id)sender
{   
    [self.btnClickSignal sendNext:@"按钮点击"];
}


@end
