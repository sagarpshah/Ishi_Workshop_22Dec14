//
//  HolidayTableViewCell.m
//  SyncDemo
//
//  Created by Sagar Shah on 17/12/14.
//  Copyright (c) 2014 Ishi Systems. All rights reserved.
//

#import "HolidayTableViewCell.h"

@implementation HolidayTableViewCell

- (void)awakeFromNib {
    self.separatorInset = UIEdgeInsetsZero;
    if ([self respondsToSelector:@selector(layoutMargins)]) {
        self.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)dealloc {
    self.holidayTitleLabel = nil;
    self.holidayDateLabel = nil;
}

@end
