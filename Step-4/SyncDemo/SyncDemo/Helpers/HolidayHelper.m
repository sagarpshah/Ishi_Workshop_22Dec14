//
//  HolidayHelper.m
//  SyncDemo
//
//  Created by Sagar Shah on 20/12/14.
//  Copyright (c) 2014 Ishi Systems. All rights reserved.
//

#import "HolidayHelper.h"

@implementation HolidayHelper

+ (NSDictionary *)apiRepresentationDictionaryForHoliday:(Holiday *)holiday {
    NSMutableDictionary *representation = [[NSMutableDictionary alloc] init];
    
    return representation;
}

+ (NSMutableArray *)parseHolidays:(NSArray *)results {
    NSMutableArray *holidays = [[NSMutableArray alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
    
    for (NSDictionary *dict in results) {
        Holiday *holiday = [[Holiday alloc] init];
        
        holiday.objectID = [dict objectForKey:@"objectId"];
        holiday.name = [dict objectForKey:@"name"];
        holiday.details = [dict objectForKey:@"details"];
        
        NSString *dateString = [[dict objectForKey:@"date"] objectForKey:@"iso"];
        holiday.date = [dateFormatter dateFromString:dateString];
        
        [holidays addObject:holiday];
    }
    
    return holidays;
}

@end
