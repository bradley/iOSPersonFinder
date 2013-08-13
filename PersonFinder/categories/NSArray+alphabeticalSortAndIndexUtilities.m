//
//  NSArray+alphabeticalSortAndIndexUtilities.m
//  PersonFinder
//
//  Created by Bradley Griffith on 6/3/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import "NSArray+alphabeticalSortAndIndexUtilities.h"

@implementation NSArray (alphabeticalSortAndIndexUtilities)

- (NSArray *)sortedDiacriticalAlphabetical {
    NSArray *sorted = [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString*)obj1 compare:obj2 options:NSDiacriticInsensitiveSearch+NSCaseInsensitiveSearch];
    }];
    return sorted;
}

- (IndexedDictionary *)indexAlphabeticallyWithObjectFromBlock:(useObjectFromBlock)useObjectFromBlock {
    NSMutableDictionary *alphabatizedIndex = [[NSMutableDictionary alloc] init];
    NSMutableArray *indexKeys = [NSMutableArray array];
    NSString *firstChar = nil;
    
    NSUInteger stringCount = [self count];
    
    // We use each string's index in the loop so we do not use fast enumeration.
    for(int i = 0; i < stringCount; i++) {
        NSString *unsectionedString = [self objectAtIndex:i];
        if(![unsectionedString length])continue;
        
        firstChar = [[[unsectionedString decomposedStringWithCanonicalMapping] substringToIndex:1] uppercaseString];
        NSMutableArray *alphabeticalSection = [alphabatizedIndex objectForKey:firstChar];
        if (!alphabeticalSection) {
            alphabeticalSection = [NSMutableArray array];
            [alphabatizedIndex setObject:alphabeticalSection forKey:firstChar];
            [indexKeys addObject:firstChar];
        }
        
        if (useObjectFromBlock) {
            id object = useObjectFromBlock(unsectionedString, i);
            if (!object)
                continue;
            [alphabeticalSection addObject:object];
        }
        else {
            [alphabeticalSection addObject:unsectionedString];
        }
    }
    
    IndexedDictionary *indexedDictionary = [[IndexedDictionary alloc] init];
    indexedDictionary.indexedDictionary = alphabatizedIndex;
    indexedDictionary.indexKeys = indexKeys;
    return indexedDictionary;
}


- (NSArray *)searchAndOrderUsingPhrase:(NSString *)searchPhrase
                   withObjectFromBlock:(useObjectFromBlock)useObjectFromBlock {
    NSArray *searchedItems;
    if (searchPhrase.length > 0) {
        //NSArray *sortedStrings = [self sortedDiacriticalAlphabetical];
        NSArray *sortedStrings = self;
        
        NSMutableArray *foundInFirstWord = [[NSMutableArray alloc] init];
        NSMutableArray *foundInPhrase = [[NSMutableArray alloc] init];
        
        NSUInteger stringCount = [sortedStrings count];
        
        // We use each string's index in the loop so we do not use fast enumeration.
        for (int i = 0; i < stringCount; i++) {
            NSString *string = [sortedStrings objectAtIndex:i];
            
            NSRange range = [string rangeOfString:searchPhrase
                                          options:(NSCaseInsensitiveSearch+NSDiacriticInsensitiveSearch+NSAnchoredSearch)];
            if (range.length > 0) {
                if (useObjectFromBlock) {
                    id object = useObjectFromBlock(string, i);
                    if (!object)
                        continue;
                    [foundInFirstWord addObject:object];
                }
                else {
                    [foundInFirstWord addObject:string];
                }
            }
            else {
                range = [string rangeOfString:searchPhrase
                                      options:NSCaseInsensitiveSearch+NSDiacriticInsensitiveSearch];
                if (range.length > 0) {
                    if (useObjectFromBlock) {
                        id object = useObjectFromBlock(string, i);
                        if (!object)
                            continue;
                        [foundInPhrase addObject:object];
                    }
                    else {
                        [foundInPhrase addObject:string];
                    }
                }
            }
        }
        // Combine both sets of search results, with priority to those found in first word.
        searchedItems = [foundInFirstWord arrayByAddingObjectsFromArray:foundInPhrase];
    }
    return searchedItems;
}

- (NSDictionary *)indexDictionariesByKey:(NSString *)key {
    NSArray *extractedKeys = [self valueForKey:key];
    
    IndexedDictionary *indexedDictionaries = [extractedKeys indexAlphabeticallyWithObjectFromBlock:^id(NSString *string, int index) {
                                                   NSDictionary *dictionary = [self objectAtIndex:index];
                                                   return dictionary[key] == string ? dictionary : nil;
                                               }];
    return indexedDictionaries.indexedDictionary;
}

- (NSArray *)sortDictionariesByKey:(NSString *)key {
    NSMutableArray *mutableDictionaries = [NSMutableArray arrayWithArray:self];
    NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:key
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)];
    [mutableDictionaries sortUsingDescriptors:[NSMutableArray arrayWithObjects:alphaDesc, nil]];
    return [NSArray arrayWithArray:mutableDictionaries];
}

@end
