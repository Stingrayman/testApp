//
//  BonjourTVController.m
//  bojoureBrowser
//
//  Created by Alik on 12/11/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "BonjourTVController.h"
#import "BonjourDVController.h"

@interface BonjourTVController () < NSNetServiceDelegate, NSNetServiceBrowserDelegate>

@property (nonatomic, strong) NSNetServiceBrowser *browser;
@property (nonatomic, strong) NSNetService *netService;
@property (nonatomic, strong) NSMutableArray *serviceGroup;
@property (nonatomic, strong) NSMutableDictionary *serviceList;

@end

//As service type used '_http._tcp' string. You can write your own service name that you're looking for or visit link for list of Bonjour service types being used by Mac OS X: https://developer.apple.com/library/mac/qa/qa1312/_index.html

//--start List of constants used in app --
static NSString *const cellIdentifier = @"Cell";
static NSString *const serviceType = @"_http._tcp";
static NSString *const serviceDomain = @"";
//--end List of constants used in app --

@implementation BonjourTVController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _serviceGroup = [[NSMutableArray alloc]init];
    _serviceList = [[NSMutableDictionary alloc]init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self browserService];
}

-(void)browserService
{
    self.browser = [[NSNetServiceBrowser alloc]init];
    
    self.netService.delegate = self;
    self.browser.delegate = self;
    
    [[self browser] searchForServicesOfType:serviceType inDomain:serviceDomain];
}

-(void)resolveIPAddress:(NSNetService *)service
{
    NSNetService *remoteService = service;
    remoteService.delegate = self;
    [remoteService resolveWithTimeout:0];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NSMutableDictionary *serviceList = [self serviceList];
    NSString *type = [aNetService type];
    NSMutableArray *service = [serviceList objectForKey:type];
    
    if(service == nil)
    {
        //Add Services list
        service = [[NSMutableArray alloc]initWithObjects:aNetService, nil];
        [serviceList setValue:service forKey:type];
        
        //Add Services types
        NSMutableArray *serviceGroup = [self serviceGroup];
        [serviceGroup addObject:type];
        
        [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:[serviceGroup indexOfObject:type]] withRowAnimation: UITableViewRowAnimationRight];
    }
    
    else if(![service containsObject:aNetService])
    {
        //Add service
        [service addObject:aNetService];
        [[self tableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[service indexOfObject:aNetService] inSection:[[self serviceGroup] indexOfObject:type]]] withRowAnimation:UITableViewRowAnimationRight];
    }
     [self resolveIPAddress:aNetService];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NSMutableDictionary *serviceList = [self serviceList];
    NSString *type = [aNetService type];
    NSMutableArray *services = [serviceList objectForKey:type];
    
    if([services count] == 1)
    {
        [serviceList removeObjectForKey:type];
        
        NSMutableArray *serviceGroup = [self serviceGroup];
        NSUInteger index = [serviceGroup indexOfObject:type];
        [[self tableView]deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
        [serviceGroup removeObject:aNetService];
    }
    else if ([services containsObject:aNetService])
    {
        //Remove service
        NSUInteger index = [services indexOfObject:aNetService];
        //string below must be at that line for proper work app
        [services removeObjectAtIndex:index];
        NSArray *arr = @[[NSIndexPath indexPathForRow:index inSection:[[self serviceGroup]indexOfObject:type]]];
        [[self tableView]deleteRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationRight];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self serviceList]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self serviceList]objectForKey:[[self serviceGroup]objectAtIndex:section ]]count ];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self serviceGroup] objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Configure the cell...
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //--display the name of each service---
    
    if(self.serviceGroup != nil)
    {
        NSNetService *service = [[[self serviceList] objectForKey:[[self serviceGroup]objectAtIndex:[indexPath section]]]objectAtIndex:[indexPath row]];
        
        cell.textLabel.text = [service name];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNetService *service = [[[self serviceList] objectForKey:[[self serviceGroup] objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
    
    BonjourDVController *serviceDetail = [[BonjourDVController  alloc]initWithService:service];
    [[self navigationController]pushViewController:serviceDetail animated:YES];
}


-(NSMutableArray *)serviceGroup
{
    if (_serviceGroup == nil)
    {
        _serviceGroup = [NSMutableArray new];
    }
    return _serviceGroup;
}

-(NSMutableDictionary *)serviceList
{
    if (_serviceList == nil)
    {
        _serviceList = [NSMutableDictionary new];
    }
    return _serviceList;
}

@end
