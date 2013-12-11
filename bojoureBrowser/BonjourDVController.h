//
//  BonjourDVController.h
//  bojoureBrowser
//
//  Created by Alik on 12/11/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <arpa/inet.h>

@interface BonjourDVController : UITableViewController

@property (nonatomic, strong) NSNetService *service;

-(id)initWithService:(NSNetService*)service;

@end
