//
//  NSObject+SQLite.h
//  SalesBookLite
//
//  Created by Erika Thorsen on 17/02/14.
//  Copyright (c) 2014 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SQLite)

/**
 * Checks if a value returned from the DB is valid, i.e. not NSNull and has content
 *
 * @return BOOL saying if valid or not
 */
- (BOOL)isValid;

@end
