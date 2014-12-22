//
//  HolidayHelper.h
//  SyncDemo
//
//  Created by Sagar Shah on 20/12/14.
//  Copyright (c) 2014 Ishi Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Holiday.h"

@interface HolidayHelper : NSObject

+ (NSDictionary *)apiRepresentationDictionaryForHoliday:(Holiday *)holiday;
+ (NSMutableArray *)parseHolidays:(NSArray *)results;

@end
