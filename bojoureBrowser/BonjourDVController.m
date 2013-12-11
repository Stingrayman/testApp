//
//  BonjourDVController.m
//  bojoureBrowser
//
//  Created by Alik on 12/11/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "BonjourDVController.h"

@interface BonjourDVController ()

@end

//--start List of constants used in app --
static NSString *const cellIdentifier = @"Cell";

// constants present a service properties - do not change them !!!
static NSString *const name = @"name";
static NSString *const type = @"type";
static NSString *const domain = @"domain";
static NSString *const port = @"port";
static NSString *const addresses = @"addresses";
static NSString *const hostName = @"hostName";
static NSString *const TXTRecordData = @"TXTRecordData";
//--end List of constants used in app --


@implementation BonjourDVController

- (id)initWithService:(NSNetService *)service
{
    if(service == nil)
    {
        self = nil;
    }
    else
    {
        self = [super init];
        if (self != nil)
        {
            _service = service;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self class] infoLabel]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    NSString *info = [[[self class] infoLabel]objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = info;
    
    // to present a text from  Service TXTRecordData 
    if ([info isEqual: TXTRecordData])
    {
        NSString *str = [[NSString alloc]initWithData:[_service TXTRecordData] encoding:NSUTF8StringEncoding];
        
        cell.detailTextLabel.text = str;
    }
    // to present addresse of Service
    else if ([info isEqual: addresses])
    {
        NSData *address = nil;
        struct sockaddr_in *socketAddres = nil;
        NSString *ipString = nil;
        
        for (int i=0; i<[[_service addresses] count];i++)
        {
            address = [[_service addresses] objectAtIndex: i];
            socketAddres = (struct sockaddr_in *) [address bytes];
            ipString = [NSString stringWithFormat:@"%s", inet_ntoa(socketAddres->sin_addr)];
        }
        cell.detailTextLabel.text = ipString;
    }
    else
    {
        cell.detailTextLabel.text = [[[self service]valueForKey:info]description];
    }
    return cell;
}

+ (NSArray *)infoLabel
{
    static NSArray *sArray = nil;
    static dispatch_once_t sToken;
    dispatch_once(&sToken, ^{ sArray = [[NSArray alloc] initWithObjects:name, type, domain, port, addresses, hostName, TXTRecordData, nil]; });
    return sArray;
}

@end
