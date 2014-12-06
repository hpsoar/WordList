//
//  WordListViewControllerTableViewController.m
//  WordList
//
//  Created by HuangPeng on 11/27/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "WordListViewController.h"
#import "AddWordViewController.h"

@interface WordListViewController () <NSFetchedResultsControllerDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation WordListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title= @"WORDS";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addWord)];
    
    self.view.backgroundColor = RGBCOLOR_HEX(0x3598DC);
    self.tableView.backgroundColor = RGBCOLOR_HEX(0x3598DC);
    
    self.tableView.tableFooterView = [UIView viewWithFrame:CGRectZero andBkColor:nil];
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController == nil) {
        _fetchedResultsController = [[WordDB sharedDB] fetchedResultsControllerSectioned:YES];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

- (void)addWord {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"CANCEL"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Add GRE words", @"Add TOEFL words",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

- (void)addWordFromSource:(RawWordSource)source {
    AddWordViewController *controller = [AddWordViewController new];
    controller.source = source;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self addWordFromSource:kRawWordSourceGRE];
            break;
        case 1:
            [self addWordFromSource:kRawWordSourceTOEFL];
            break;
        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"wordlist_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    WordDefinition *word = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = word.word;
    cell.detailTextLabel.text = [word.definitions stringByReplacingOccurrencesOfString:@"\n" withString:@";"];
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo name];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WordDefinition *word = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[WordDB sharedDB] deleteWord:word];
        
        [[WordDB sharedDB] saveContext];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark -

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (type == NSFetchedResultsChangeDelete) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeInsert) {
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    if (type == NSFetchedResultsChangeDelete) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    if (type == NSFetchedResultsChangeInsert) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
