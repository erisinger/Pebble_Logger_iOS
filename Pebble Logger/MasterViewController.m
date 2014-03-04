//
//  MasterViewController.m
//  Pebble Logger
//
//  Created by Erik Risinger on 2/6/14.
//  Copyright (c) 2014 Erik Risinger. All rights reserved.
//

#import "MasterViewController.h"

//#import "DetailViewController.h"

@interface MasterViewController ()

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController

@synthesize logs;
@synthesize targetWatch;
@synthesize fetchedResultsController;
@synthesize managedObjectContext;

-(void)didPressCancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)didPressSave:(id)sender
{
    DetailViewController *dvc = (DetailViewController *)sender;
    [self.logs addObject:[NSMutableArray arrayWithArray:dvc.log]];
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
}


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addLog::)];
//    self.navigationItem.rightBarButtonItem = addButton;
    
    targetWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:@"708630d3-4f3e-4b36-9076-574542c2b095"];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    
    [targetWatch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
        if (isAppMessagesSupported) {
            NSLog(@"This Pebble supports app message!");
        }
        else {
            NSLog(@":( - This Pebble does not support app message!");
        }
    }];
    
    [targetWatch appMessagesLaunch:^(PBWatch *watch, NSError *error){
        if (!error) {
            NSLog(@"launched!");
        }
    }];
    
    [targetWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update){
        
        //call a method to handle informing the server of a possible handshake -- PENDING
        [self dataHandlerWithWatch:watch data:update];
        return YES;
    }];

}

-(void)dataHandlerWithWatch:(PBWatch *)watch data:(NSDictionary *)data
{
    NSNumber *stamp_s = (NSNumber *)[data objectForKey:@(0)];
    NSNumber *stamp_ms = (NSNumber *)[data objectForKey:@(1)];
    NSNumber *xVal = (NSNumber *)[data objectForKey:@(2)];
    NSNumber *yVal = (NSNumber *)[data objectForKey:@(3)];
    NSNumber *zVal = (NSNumber *)[data objectForKey:@(4)];
    
    PebbleLog *pblog = [NSEntityDescription insertNewObjectForEntityForName:@"PebbleLog" inManagedObjectContext:managedObjectContext];
    pblog.timeStamp = [NSNumber numberWithDouble:stamp_s.doubleValue * 1000 + stamp_ms.doubleValue];
    pblog.xLog = xVal;
    pblog.yLog = yVal;
    pblog.zLog = zVal;
    
    if(![managedObjectContext save:nil]){
        NSLog(@"Error Saving") ;
    }
    else{
        NSLog(@"Logged %lld, %d, %d, %d", pblog.timeStamp.longLongValue, xVal.integerValue, yVal.integerValue, zVal.integerValue);
    }
}

-(IBAction)sendResults:(id)sender
{
    //get document path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    NSString *outputFileName = [docDirectory stringByAppendingPathComponent:@"handshake.csv"];
    
    // Email Subject
    NSString *emailTitle = @"Test Email";
    // Email Content
//    NSString *messageBody = @"<h1>Learning iOS Programming!</h1>"; // Change the message body to HTML
    
    //fetch data to write
    [[self fetchedResultsController] performFetch:nil];
    logs = [NSMutableArray arrayWithArray:[[self fetchedResultsController] fetchedObjects]];
    
    //write body of csv
    NSString *csvBody = [[NSString alloc] init];
    NSString* concatString;
    for (PebbleLog* p in logs)
    {
        concatString = [NSString stringWithFormat:@"%lld, %d, %d, %d\n", p.timeStamp.longLongValue, p.xLog.integerValue/2, p.yLog.integerValue/2, p.zLog.integerValue/2];
        csvBody = [csvBody stringByAppendingString: concatString];
        NSLog(@"%@", concatString);
    }
    
    //write data to file
    NSError *csvError = NULL;
    BOOL written = [csvBody writeToFile:outputFileName atomically:YES encoding:NSUTF8StringEncoding error:&csvError];
    
    if (!written)
        NSLog(@"Writing failed, error=%@", csvError);
    else
        NSLog(@"Data saved! File path =%@", outputFileName);
    
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"erisinger@umass.edu"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
//    [mc setMessageBody:csvBody isHTML:NO];
    [mc addAttachmentData:[NSData dataWithContentsOfFile:outputFileName]
                     mimeType:@"text/csv"
                     fileName:@"handshake.csv"];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    [self dismissViewControllerAnimated:TRUE completion:NULL];
};

-(IBAction)deleteAll:(id)sender
{
    [[self fetchedResultsController] performFetch:nil];
    logs = [NSMutableArray arrayWithArray:[[self fetchedResultsController] fetchedObjects]];
    for (PebbleLog* p in logs)
    {
        [managedObjectContext deleteObject:p];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
//    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
//    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
//    
//    // If appropriate, configure the new managed object.
//    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
//    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
//    
//    // Save the context.
//    NSError *error = nil;
//    if (![context save:&error]) {
//         // Replace this implementation with code to handle the error appropriately.
//         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
    
    else if ([[segue identifier] isEqualToString:@"addLogSegue"])
    {
        DetailViewController *dvc = (DetailViewController *)segue.destinationViewController;
        dvc.delegate = self;
        
        //message the Pebble to prep for logging
        
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PebbleLog" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%lld",[[object valueForKey:@"timeStamp"] longLongValue]];
}

@end
