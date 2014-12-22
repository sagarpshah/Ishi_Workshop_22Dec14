//
//  DismissSegue.m
//  Midas
//
//  Created by Sagar Shah on 17/11/14.
//  Copyright (c) 2014 Ishi Systems. All rights reserved.
//

#import "DismissSegue.h"

@implementation DismissSegue

- (void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
    [sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
