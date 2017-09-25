//
//  Flag.m
//  1_ReactiveCocoa
//
//  Created by SilenceZhou on 2017/8/29.
//  Copyright © 2017年 silence. All rights reserved.
//

#import "Flag.h"

@implementation Flag

+ (instancetype)flagWithDict:(NSDictionary *)dict
{
    
    Flag *flag = [[self alloc] init];
    
    [flag setValuesForKeysWithDictionary:dict];
    
    return flag;
    
    
}

@end
