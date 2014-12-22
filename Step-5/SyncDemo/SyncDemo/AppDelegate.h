//
//  AppDelegate.h
//  SyncDemo
//
//  Created by Sagar Shah on 17/12/14.
//  Copyright (c) 2014 Ishi Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSFNanoStoreQueue.h"
#import "AFHTTPRequestOperationManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSFNanoStoreQueue *nanoStoreQueue;
@property (strong, nonatomic) AFHTTPRequestOperationManager *operationManager;

@end

