//
//  AddHolidayViewController.m
//  SyncDemo
//
//  Created by Sagar Shah on 17/12/14.
//  Copyright (c) 2014 Ishi Systems. All rights reserved.
//

#import "AddHolidayViewController.h"
#import "Holiday.h"

@interface AddHolidayViewController ()

@end

@implementation AddHolidayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"Cancel"]) {
        
    } else if ([[segue identifier] isEqualToString:@"Save"]) {
        NSString *name = [[_nameTextField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (name.length) {
            Holiday *holiday = [[Holiday alloc] init];
            holiday.name = name;
            holiday.date = [_datePicker date];
            
            [_holidaysController addHoliday:holiday];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc {
    self.nameTextField = nil;
    self.datePicker = nil;
    self.holidaysController = nil;
}

@end
