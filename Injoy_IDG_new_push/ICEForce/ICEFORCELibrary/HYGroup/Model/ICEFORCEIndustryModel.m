//
//  ICEFORCEIndustryModel.m
//  InjoyIDG
//
//  Created by 念念不忘必有回响 on 2019/4/24.
//  Copyright © 2019 Injoy. All rights reserved.
//

#import "ICEFORCEIndustryModel.h"

@implementation ICEFORCEIndustryModel

+(id)modelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (id)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"Model : %@ Undefined Key: %@ and Value:%@", self, key,value);
}

@end
