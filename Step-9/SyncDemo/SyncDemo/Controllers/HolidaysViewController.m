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
#import "AddHolidayViewController.h"

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
    
    self.operationManager = [AFHTTPRequestOperationManager manager];
    [self.operationManager.requestSerializer setValue:kApplicationIDValue forHTTPHeaderField:kApplicationIDKey];
    [self.operationManager.requestSerializer setValue:kRestAPIValue forHTTPHeaderField:kRestAPIKey];
    
    self.holidayTableView.separatorInset = UIEdgeInsetsZero;
    if ([self.holidayTableView respondsToSelector:@selector(layoutMargins)]) {
        self.holidayTableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    holidaysArray = [[NSMutableArray alloc] init];
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [self fetchLocalHolidays];
    [self startAutoupdateHolidays];
    [self initiateReachabilityCheck];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UINavigationController *navigationController = [segue destinationViewController];
    AddHolidayViewController *addHolidayController = (AddHolidayViewController *) [navigationController topViewController];
    addHolidayController.holidaysController = self;
}

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
            
            if (holiday.objectID == nil)
                [holiday save];
            
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

- (NSArray *)localHolidays {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Holiday *holiday = (Holiday *)evaluatedObject;
        return (holiday.objectID == nil);
    }];
    return [holidaysArray filteredArrayUsingPredicate:predicate];
}

- (NSArray *)serverHolidays {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Holiday *holiday = (Holiday *)evaluatedObject;
        return (holiday.objectID != nil);
    }];
    return [holidaysArray filteredArrayUsingPredicate:predicate];
}

- (void)parseHolidaysResultAndDisplay:(NSArray *)results {
    
    NSArray *parsedHolidays = [HolidayHelper parseHolidays:results];
    
    NSMutableArray *localHolidays = [[NSMutableArray alloc] initWithArray:[self localHolidays]];
    NSMutableArray *existingHolidays = [[NSMutableArray alloc] initWithArray:[self serverHolidays]];
    
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
    
    [holidaysArray addObjectsFromArray:localHolidays];
    
    NSMutableIndexSet *deletedObjectIndexSet = [[NSMutableIndexSet alloc] init];
    for (int  i = 0; i < existingHolidays.count; i++) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %d", i];
        NSArray *array = [keepedObjectIndexesArray filteredArrayUsingPredicate:predicate];
        if (array.count == 0) {
            [deletedObjectIndexSet addIndex:i];
        }
    }
    
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

- (void)addHoliday:(Holiday *)holiday {
    [appDelegate.nanoStoreQueue inStore:^(NSFNanoStore *store) {
        [store addObject:holiday error:nil];
    }];
    
    [holidaysArray addObject:holiday];
    [self.holidayTableView reloadData];
    
    [holiday save];
}

- (void)initiateReachabilityCheck {
    
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                
                for (Holiday *holiday in holidaysArray) {
                    if (holiday.objectID == nil)
                        [holiday save];
                }
                
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
            default:
                break;
        }
    }];
    
    [reachabilityManager startMonitoring];
}

- (void)dealloc {
    self.holidayTableView = nil;
    
    if ([_holidayFetchOperation isExecuting]) {
        [_holidayFetchOperation cancel];
    }
    
    self.holidayFetchOperation = nil;
}

@end
