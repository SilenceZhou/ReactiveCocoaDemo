//
//  RedView.h
//  1_ReactiveCocoa
//
//  Created by SilenceZhou on 2017/8/27.
//  Copyright © 2017年 silence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedView : UIView

@property (nonatomic, strong) RACSubject *btnClickSignal;

@end
