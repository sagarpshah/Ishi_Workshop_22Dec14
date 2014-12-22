//
//  Holiday.m
//  SyncDemo
//
//  Created by Sagar Shah on 17/12/14.
//  Copyright (c) 2014 Ishi Systems. All rights reserved.
//

#import "Holiday.h"
#import "Constants.h"
#import "AFHTTPRequestOperationManager.h"
#import "AppDelegate.h"

#define ID      @"objectID"
#define NAME    @"nameKey"
#define DETAILS @"detailsKey"
#define DATE    @"dateKey"

@implementation Holiday

- (id)initNanoObjectFromDictionaryRepresentation:(NSDictionary *)theDictionary forKey:(NSString *)aKey store:(NSFNanoStore *)theStore {
    if (self = [super initNanoObjectFromDictionaryRepresentation:theDictionary forKey:aKey store:theStore]) {
        if (theDictionary != nil) {
            self.objectID = [theDictionary objectForKey:ID];
            self.name = [theDictionary objectForKey:NAME];
            self.details = [theDictionary objectForKey:DETAILS];
            self.date = [theDictionary objectForKey:DATE];
        }
    }
    
    return self;
}

- (NSDictionary *)nanoObjectDictionaryRepresentation {
    NSMutableDictionary *representation = [[NSMutableDictionary alloc] initWithDictionary:[super nanoObjectDictionaryRepresentation]];
    
    if (_objectID != nil)
        [representation setObject:_objectID forKey:ID];
    
    if (_name != nil)
        [representation setObject:_name forKey:NAME];
    
    if (_details != nil)
        [representation setObject:_details forKey:DETAILS];
    
    if (_date != nil)
        [representation setObject:_date forKey:DATE];
    
    return representation;
}

- (id)rootObject {
    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"Holiday - %@", self.key];
}

- (void)setHoliday:(Holiday *)aHoliday {
    self.name = aHoliday.name;
    self.details = aHoliday.details;
    self.date = aHoliday.date;
}

- (NSString *)formattedDate {
    if (_formattedDate == nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        _formattedDate = [formatter stringFromDate:_date];
    }
    
    return _formattedDate;
}

- (NSDictionary *)apiRepresentation {
    NSMutableDictionary *representation = [[NSMutableDictionary alloc] init];
    
    if (_name != nil)
        [representation setObject:_name forKey:@"name"];
    
    if (_details != nil)
        [representation setObject:_details forKey:@"details"];
    
    if (_date != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        
        NSString *dateString = [dateFormatter stringFromDate:_date];
        NSDictionary *dateDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Date", @"__type", dateString, @"iso", nil];
        [representation setObject:dateDictionary forKey:@"date"];
    }

    return representation;
}

- (void)save {
    
    if ([_saveOperation isExecuting]) {
        [_saveOperation cancel];
        self.saveOperation = nil;
    }
    
    NSString *parseRestAPIURLString = [kServerBaseURL stringByAppendingString:kServerAPIPath];
    NSString *createHolidayURLString = [parseRestAPIURLString stringByAppendingString:NSStringFromClass([Holiday class])];

    if (_objectID != nil) {
        createHolidayURLString = [createHolidayURLString stringByAppendingFormat:@"/%@", _objectID];
    }
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    self.saveOperation = [appDelegate.operationManager POST:createHolidayURLString parameters:[self apiRepresentation] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.objectID = [responseObject objectForKey:@"objectId"];
        
        [appDelegate.nanoStoreQueue inStore:^(NSFNanoStore *store) {
            [store addObject:self error:nil];
        }];
        
        if (operation == _saveOperation)
            _saveOperation = nil;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (operation == _saveOperation)
            _saveOperation = nil;
    }];
}

- (void)dealloc {
    [self.saveOperation cancel];
    self.saveOperation = nil;
    
    self.objectID = nil;
    self.name = nil;
    self.details = nil;
    self.date = nil;
    self.formattedDate = nil;
}

@end
