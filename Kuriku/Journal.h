//
//  Journal.h
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Journal : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *entries;

- (void)createSampleItems;

@end

@interface Journal (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(NSManagedObject *)value;
- (void)removeEntriesObject:(NSManagedObject *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
