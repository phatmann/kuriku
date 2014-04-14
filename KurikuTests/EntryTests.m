//
//  EntryTests.m
//  KurikuTests
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <InnerBand/InnerBand.h>
#import "Todo.h"
#import "Entry.h"
#import "Journal.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

@interface EntryTests : XCTestCase
@property (nonatomic) Todo *todo;
@end

@implementation EntryTests

- (void)setUp {
    [super setUp];
    [IBCoreDataStore clearAllData];
    [Journal create];
    self.todo = [self createTodo];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_priority_set_when_new {
    assertThatFloat(self.todo.lastEntry.priority, equalToFloat(self.todo.priority));
}

- (void)test_priority_updated_when_todo_priority_changes {
    self.todo.importance = TodoRangeMaxValue;
    assertThatFloat(self.todo.lastEntry.priority, equalToFloat(self.todo.priority));
}

- (void)test_priority_zero_when_inactive {
    assertThatFloat(self.todo.priority, isNot(equalToFloat(0)));
    Entry *entry = self.todo.lastEntry;
    [self.todo createEntry:EntryTypeAction];
    assertThatFloat(entry.priority, equalToFloat(0));
}

- (void)test_priority_zero_for_completed {
    assertThatFloat(self.todo.priority, isNot(equalToFloat(0)));
    Entry *entry = [self.todo createEntry:EntryTypeComplete];
    assertThatFloat(entry.priority, equalToFloat(0));
}

- (void)test_priority_zero_when_start_date {
    assertThatFloat(self.todo.priority, isNot(equalToFloat(0)));
    Entry *entry = [self.todo findOrCreateEntryForStartDate:EntryTypeHold];
    entry.startDate = [[NSDate today] dateByAddingDays:1];
    assertThatFloat(entry.priority, equalToFloat(0));
}

- (Todo *)createTodo {
    Todo *todo = [Todo create];
    todo.title = @"title";
    return todo;
}

@end
