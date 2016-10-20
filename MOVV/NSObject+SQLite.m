//
//  NSObject+SQLite.m
//  SalesBookLite
//
//  Created by Erika Thorsen on 17/02/14.
//  Copyright (c) 2014 Siller AG. All rights reserved.
//

#import "NSObject+SQLite.h"

@implementation NSObject (SQLite)

- (BOOL)isValid
{
    BOOL valid = ![self isEqual:[NSNull null]];
    if ([self respondsToSelector:@selector(length)]) {
        valid = valid && [self performSelector:@selector(length)] > 0;
    } else if ([self respondsToSelector:@selector(count)]) {
        valid = valid && [self performSelector:@selector(count)] > 0;
    }
    return valid;
}

@end
