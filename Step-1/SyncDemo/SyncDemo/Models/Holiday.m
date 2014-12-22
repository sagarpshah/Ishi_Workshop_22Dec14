//
//  Holiday.m
//  SyncDemo
//
//  Created by Sagar Shah on 17/12/14.
//  Copyright (c) 2014 Ishi Systems. All rights reserved.
//

#import "Holiday.h"

@implementation Holiday

- (id)initNanoObjectFromDictionaryRepresentation:(NSDictionary *)theDictionary forKey:(NSString *)aKey store:(NSFNanoStore *)theStore {
    if (self = [super initNanoObjectFromDictionaryRepresentation:theDictionary forKey:aKey store:theStore]) {
        if (theDictionary != nil) {
        }
    }
    
    return self;
}

- (NSDictionary *)nanoObjectDictionaryRepresentation {
    NSMutableDictionary *representation = [[NSMutableDictionary alloc] initWithDictionary:[super nanoObjectDictionaryRepresentation]];
    
    return representation;
}

- (id)rootObject {
    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"Holiday - %@", self.key];
}

@end
