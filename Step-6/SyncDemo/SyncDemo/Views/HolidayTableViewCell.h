//
//  HolidayTableViewCell.h
//  SyncDemo
//
//  Created by Sagar Shah on 17/12/14.
//  Copyright (c) 2014 Ishi Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HolidayTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *holidayTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *holidayDateLabel;

@end
