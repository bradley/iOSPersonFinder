//
//  FFPersonListViewController.m
//  PersonFinder
//
//  Created by Bradley Griffith on 6/1/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import "PFPersonListViewController.h"
#import "PFPersonCell.h"
#import "NSArray+alphabeticalSortAndIndexUtilities.h"
#import "NSString+stringStyleUtilities.h"
#import "IndexedDictionary.h"

@interface PFPersonListViewController (){
    BOOL isFiltered;
    NSString *searchString;
    NSDictionary *sortedPeople;
    NSArray *nameIndex;
    NSMutableArray *selectedPeople;
    CGPoint lastOffset;
    NSTimeInterval lastOffsetCapture;
}
@end

@implementation PFPersonListViewController
@synthesize tableView = _tableview;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    selectedPeople = [[NSMutableArray alloc] init];
    
    [self sortAndIndexPeople:_personList];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self dismissKeyboard];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (NSDictionary *)personAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [nameIndex objectAtIndex:indexPath.section];
    NSArray *peopleForKey = [sortedPeople objectForKey:key];
    return [peopleForKey objectAtIndex:indexPath.row];
}

- (void)sortAndIndexPeople:(NSArray *)people {

    if (!isFiltered)
        people = [people sortDictionariesByKey:@"name"];
    
    NSArray *extractedNames = [people valueForKey:@"name"];
    IndexedDictionary *alphabatizedIndexWithKeys;
    alphabatizedIndexWithKeys = [extractedNames indexAlphabeticallyWithObjectFromBlock:^id(NSString *string, int index) {
        NSDictionary *person = [people objectAtIndex:index];
        return person[@"name"] == string ? person : nil;
    }];
    
    sortedPeople = alphabatizedIndexWithKeys.indexedDictionary;
    nameIndex = alphabatizedIndexWithKeys.indexKeys;
    
    if (!isFiltered)
        nameIndex = [nameIndex sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [nameIndex count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [nameIndex objectAtIndex:section];
    NSArray *contactsForKey = [sortedPeople objectForKey:key];
    return [contactsForKey count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[nameIndex objectAtIndex:section] uppercaseString];
}


 // Uncomment this to make the table view display the index on the right side of the screen.
 - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
 return nameIndex;
 }
 

- (PFPersonCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PersonCell";
    PFPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *person = [self personAtIndexPath:indexPath];
    
    NSAttributedString *styledName = [person[@"name"] styleSubstring:searchString
                                                            withSize:17.0 andFont:[UIFont boldSystemFontOfSize:17.0]];
    cell.personName.attributedText = styledName;
    
    cell.selectionCheckMark.hidden = [selectedPeople containsObject:person[@"id"]] ? NO : YES;
    
    return cell;
}

- (void)asynchSetImageForPerson:(NSDictionary *)person atIndex:(NSIndexPath *)indexPath {
    // To be implemented by subclass.
}

#pragma mark - Search bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSArray *foundPeople;
    
    NSArray *allPeople = [_personList.copy sortDictionariesByKey:@"name"];
    
    if (searchText.length > 0) {
        searchString = searchText.copy;
        isFiltered = YES;
        NSArray *extractedNames = [allPeople valueForKey:@"name"];
        
        foundPeople = [extractedNames searchAndOrderUsingPhrase:searchText
                                            withObjectFromBlock:^id(NSString *string, int index) {
                                                NSDictionary *dictionary = [allPeople objectAtIndex:index];
                                                return dictionary[@"name"] == string ? dictionary : nil;
                                            }];
    }
    else {
        searchString = nil;
        isFiltered = NO;
        foundPeople = _personList;
    }
    [self sortAndIndexPeople:foundPeople];
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissKeyboard];
    
    NSDictionary *person = [self personAtIndexPath:indexPath];
    
    PFPersonCell *cell = (PFPersonCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if ([selectedPeople containsObject:person[@"id"]]) {
        [selectedPeople removeObject:person[@"id"]];
        cell.selectionCheckMark.hidden = YES;
    }
    else {
        [selectedPeople addObject:person[@"id"]];
        cell.selectionCheckMark.hidden = NO;
    }
    NSLog(@"%@",person[@"id"]);
}

@end
