//
//  NSArray+alphabeticalSortAndIndexUtilities.h
//  PersonFinder
//
//  Created by Bradley Griffith on 6/3/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "IndexedDictionary.h"

typedef id (^useObjectFromBlock)(NSString *string, int index);

@interface NSArray (alphabeticalSortAndIndexUtilities)

// Sorts an array of strings alphabetically ignoring accent marks on special characters.
- (NSArray *)sortedDiacriticalAlphabetical;

// Builds a dictionary from an array of strings with alphabetical sections using the first letter of each word.
//
// If an object is given via the withObjectFromBlock block, the array will be of these items and not strings.
- (IndexedDictionary *)indexAlphabeticallyWithObjectFromBlock:(useObjectFromBlock)useObjectFromBlock;

// Searches an array of strings and returns an array of matched items, with
// priority given to words beginning with the search phrase.
//
// If an object is given via the withObjectFromBlock block, the array will be of these items and not strings.
- (NSArray *)searchAndOrderUsingPhrase:(NSString *)searchPhrase
                   withObjectFromBlock:(useObjectFromBlock)useObjectFromBlock;

// Takes an array of dictionaries and indexes them alphabetically using a shared key within each dictionary.
- (NSDictionary *)indexDictionariesByKey:(NSString *)key;

// Takes an array of dictionaries and sorts them alphabetically using a shared key within each dictionary.
- (NSArray *)sortDictionariesByKey:(NSString *)key;
@end
