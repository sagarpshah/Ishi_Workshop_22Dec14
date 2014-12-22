//
//  HolidaysViewController.m
//  SyncDemo
//
//  Created by Sagar Shah on 17/12/14.
//  Copyright (c) 2014 Ishi Systems. All rights reserved.
//

#import "HolidaysViewController.h"
#import "HolidayTableViewCell.h"
#import "AFHTTPRequestOperation.h"
#import "Constants.h"
#import "Holiday.h"
#import "AppDelegate.h"
#import "HolidayHelper.h"
#import "AFHTTPRequestOperationManager.h"

#define HOLIDAY_UPDATE_INTERVAL 10.0

@interface HolidaysViewController () {
    NSMutableArray *holidaysArray;
    AppDelegate *appDelegate;
    
    NSTimer *updateTimer;
}

@property (strong, nonatomic) AFHTTPRequestOperation *holidayFetchOperation;
@property (strong, nonatomic) AFHTTPRequestOperationManager *operationManager;

@end

@implementation HolidaysViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.holidayTableView.separatorInset = UIEdgeInsetsZero;
    if ([self.holidayTableView respondsToSelector:@selector(layoutMargins)]) {
        self.holidayTableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    holidaysArray = [[NSMutableArray alloc] init];
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [self fetchLocalHolidays];
    [self startAutoupdateHolidays];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)startAutoupdateHolidays {
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:HOLIDAY_UPDATE_INTERVAL target:self selector:@selector(fetchHolidays) userInfo:nil repeats:YES];
    [updateTimer fire];
}

- (void)stopAutoupdateHolidays {
    [updateTimer invalidate];
    updateTimer = nil;
}

- (void)fetchLocalHolidays {
    [appDelegate.nanoStoreQueue inStore:^(NSFNanoStore *store) {
        NSFNanoSearch *search = [NSFNanoSearch searchWithStore:store];
        search.filterClass = NSStringFromClass([Holiday class]);
        
        NSDictionary *searchResults = [search searchObjectsWithReturnType:NSFReturnObjects error:nil];
        for (NSString *key in [searchResults allKeys]) {
            Holiday *holiday = [searchResults objectForKey:key];
            [holidaysArray addObject:holiday];
        }
    }];
}

- (void)fetchHolidays {
    if ([_holidayFetchOperation isExecuting]) {
        [_holidayFetchOperation cancel];
        _holidayFetchOperation = nil;
    }
    
    NSString *parseRestAPIURLString = [kServerBaseURL stringByAppendingString:kServerAPIPath];
    NSString *retrieveHolidaysURLString = [parseRestAPIURLString stringByAppendingString:NSStringFromClass([Holiday class])];
    
    __weak __typeof(self) weakSelf = self;
    
    self.holidayFetchOperation = [self.operationManager GET:retrieveHolidaysURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf parseHolidaysResultAndDisplay:[responseObject objectForKey:@"results"]];
        
        if (operation == _holidayFetchOperation) {
            strongSelf.holidayFetchOperation = nil;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (operation == _holidayFetchOperation) {
            __typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.holidayFetchOperation = nil;
        }
    }];
}

- (void)parseHolidaysResultAndDisplay:(NSArray *)results {
    
//////    **** Step - 1 **** Parse all holidays from server & save it.
    
//    NSArray *parsedHolidays = [HolidayHelper parseHolidays:results];
//    [holidaysArray setArray:parsedHolidays];
    
//////
    
//////    **** Step - 2 **** Parse all holidays from server & update existing
    
    NSArray *parsedHolidays = [HolidayHelper parseHolidays:results];
    
    NSArray *existingHolidays = [[NSMutableArray alloc] initWithArray:holidaysArray];
    [holidaysArray removeAllObjects];
    
    NSMutableArray *keepedObjectIndexesArray = [[NSMutableArray alloc] init];
    
    for (Holiday *holiday in parsedHolidays) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.objectID LIKE %@", holiday.objectID];
        NSArray *array = [existingHolidays filteredArrayUsingPredicate:predicate];
        if (array.count) {
            Holiday *existingHoliday = [array objectAtIndex:0];
            [existingHoliday setHoliday:holiday];
            [holidaysArray addObject:existingHoliday];
            
            NSInteger index = [existingHolidays indexOfObject:existingHoliday];
            [keepedObjectIndexesArray addObject:[NSNumber numberWithInteger:index]];
        } else {
            [holidaysArray addObject:holiday];
        }
    }
    
    NSMutableIndexSet *deletedObjectIndexSet = [[NSMutableIndexSet alloc] init];
    for (int  i = 0; i < existingHolidays.count; i++) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %d", i];
        NSArray *array = [keepedObjectIndexesArray filteredArrayUsingPredicate:predicate];
        if (array.count == 0) {
            [deletedObjectIndexSet addIndex:i];
        }
    }
    
/////
    
    [appDelegate.nanoStoreQueue inStore:^(NSFNanoStore *store) {
        [store addObjectsFromArray:holidaysArray error:nil];
        [store removeObjectsInArray:[existingHolidays objectsAtIndexes:deletedObjectIndexSet] error:nil];
    }];
    
    [_holidayTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return holidaysArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"HolidayTableViewCell";
    
    HolidayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    Holiday *holiday = [holidaysArray objectAtIndex:indexPath.row];
    
    cell.holidayTitleLabel.text = holiday.name;
    cell.holidayDateLabel.text = holiday.formattedDate;
    
    return cell;
}

- (void)dealloc {
    self.holidayTableView = nil;
    
    if ([_holidayFetchOperation isExecuting]) {
        [_holidayFetchOperation cancel];
    }
    
    self.holidayFetchOperation = nil;
}

@end
