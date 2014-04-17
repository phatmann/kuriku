//
//  TodoTests.m
//  KurikuTests
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#define HC_SHORTHAND

#import <XCTest/XCTest.h>
#import <InnerBand/InnerBand.h>
#import "Journal.h"
#import "Todo.h"
#import "Entry.h"
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>

static NSDate *entryDate;

@interface Todo(Testing)
- (void)updatePriority;
@end

@implementation Entry(Testing)
- (NSDate *)timestamp {return entryDate ?  entryDate : [self primitiveValueForKey:@"timestamp"];}
@end

@interface TodoTests : XCTestCase
@property (nonatomic) Todo *todo;
@end

@implementation TodoTests

- (void)setUp {
    [super setUp];
    [IBCoreDataStore clearAllData];
    [Journal create];
    entryDate = nil;
    self.todo = [self createTodo];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_insert_create_entry {
    NSOrderedSet *entries = self.todo.entries;
    assertThatInteger(entries.count, equalToInteger(1));
    Entry *entry = [entries firstObject];
    assertThatInteger(entry.type, equalToInteger(EntryTypeNew));
}

- (void)test_insert_new_entry_deactivates_previous_entry {
    Entry *entry1 = [self.todo.entries firstObject];
    assertThatInt(entry1.state, equalToInt(EntryStateActive));
    
    Entry *entry2 = [self.todo createEntry:EntryTypeAction];
    assertThatInt(entry1.state, equalToInt(EntryStateInactive));
    assertThatInt(entry2.state, equalToInt(EntryStateActive));
}
    
- (void)test_delete_all_entries_when_deleting_todo {
    [self.todo destroy];
    assertThatInteger([[Entry all] count], equalToInteger(0));
}

- (void)test_delete_todo_if_no_entries {
    for (Entry *entry in [self.todo.entries copy]) {
        entry.todo = nil;
    }
    
    assertThatBool(self.todo.isDeleted, equalToBool(YES));
}

- (void)test_delete_last_entry_activates_previous_entry {
    Entry *entry1 = [self.todo.entries firstObject];
    Entry *entry2 = [self.todo createEntry:EntryTypeAction];
    entry2.todo = nil;
    assertThatInt(entry1.state, equalToInt(EntryStateActive));
}

- (void)test_delete_creation_entry_deletes_todo {
    Entry *creationEntry = [self.todo.entries firstObject];
    [self.todo createEntry:EntryTypeAction];
    [self.todo createEntry:EntryTypeAction];
    creationEntry.todo = nil;
    assertThatBool(self.todo.isDeleted, equalToBool(YES));
}

- (void)test_delete_any_completion_entry_readies_todo {
    Entry *completionEntry = [self.todo createEntry:EntryTypeComplete];
    [self.todo createEntry:EntryTypeReady];
    completionEntry.todo = nil;
    assertThatInt(self.todo.lastEntry.type, equalToInt(EntryTypeNew));
}

- (void)test_delete_completion_entry_deletes_subsequent_ready_and_completed_entries {
    Entry *completionEntry = [self.todo createEntry:EntryTypeComplete];
    [self.todo createEntry:EntryTypeReady];
    [self.todo createEntry:EntryTypeAction];
    [self.todo createEntry:EntryTypeComplete];
    [self.todo createEntry:EntryTypeReady];
    assertThatInt(self.todo.entries.count, equalToInt(6));
    completionEntry.todo = nil;
    assertThatInt(self.todo.entries.count, equalToInt(2));
}

- (void)test_delete_ready_entry_deletes_subsequent_ready_and_completion_entries {
    [self.todo createEntry:EntryTypeComplete];
    Entry *readyEntry = [self.todo createEntry:EntryTypeReady];
    [self.todo createEntry:EntryTypeAction];
    [self.todo createEntry:EntryTypeComplete];
    [self.todo createEntry:EntryTypeReady];
    assertThatInt(self.todo.entries.count, equalToInt(6));
    readyEntry.todo = nil;
    assertThatInt(self.todo.entries.count, equalToInt(3));
}


- (void)test_can_save_a_new_todo_with_title {
    assertThatBool([IBCoreDataStore save], equalToBool(YES));
}
    
- (void)test_cannot_save_a_new_todo_without_title {
    self.todo.title = nil;
    assertThatBool([IBCoreDataStore save], equalToBool(NO));
}
    
- (void)test_cannot_save_a_new_todo_with_blank_title {
    self.todo.title = @"";
    assertThatBool([IBCoreDataStore save], equalToBool(NO));
}

- (void)test_update_priority_when_importance_changes {
    float oldPriority = self.todo.priority;
    assertThatFloat(oldPriority, isNot(equalToFloat(0)));
    self.todo.importance = 0;
    assertThatFloat(self.todo.priority, isNot(equalToFloat(oldPriority)));
}

- (void)test_update_priority_when_urgency_changes {
    float oldPriority = self.todo.priority;
    self.todo.urgency = 1;
    assertThatFloat(self.todo.priority, isNot(equalToFloat(oldPriority)));
}

- (void)test_priority1 {
    self.todo.importance = 0;
    self.todo.urgency    = 0;
    assertThatFloat(self.todo.priority, equalToFloat(0));
}

- (void)test_priority2 {
    self.todo.importance = 0.5;
    self.todo.urgency    = 0;
    assertThatFloat(self.todo.priority, equalToFloat(0.25));
}

- (void)test_priority3 {
    self.todo.importance = 0;
    self.todo.urgency    = 0.5;
    assertThatFloat(self.todo.priority, equalToFloat(self.todo.urgency * 0.5));
}

- (void)test_priority4 {
    self.todo.importance = 0.5;
    self.todo.urgency    = 0.5;
    assertThatFloat(self.todo.priority, equalToFloat(0.25 + self.todo.urgency * 0.5));
}

- (void)test_priority5 {
    self.todo.importance = 1.0;
    self.todo.urgency    = 1.0;
    assertThatFloat(self.todo.priority, equalToFloat(1.0));
}

- (void)test_priority6 {
    self.todo.importance = 0.5;
    entryDate = [[NSDate today] dateByAddingDays:-1];
    [self.todo updatePriority];
    assertThatFloat(self.todo.priority, closeTo(0.25, 0.2));
}

- (void)test_priority7 {
    self.todo.importance = 0.5;
    self.todo.urgency    = 1.0;
    assertThatFloat(self.todo.priority, equalToFloat(0.75));
}

- (void)test_update_all_priorities_when_priority_version_changes {
    Todo *todo1 = self.todo;
    Todo *todo2 = [self createTodo];
    float oldPriority1 = todo1.priority;
    float oldPriority2 = todo2.priority;
    
    assertThatFloat(oldPriority1, isNot(equalToFloat(0)));
    assertThatFloat(oldPriority2, isNot(equalToFloat(0)));
    
    todo1.priority = 0;
    todo2.priority = 0;
    
    [[IBCoreDataStore mainStore] setMetadataObject:@(0) forKey:@"PriorityVersion"];
    [Todo updateAllPrioritiesIfNeeded];
    
    assertThatFloat(todo1.priority, equalToFloat(oldPriority1));
    assertThatFloat(todo2.priority, equalToFloat(oldPriority2));
}

- (void)test_update_todos_ready_to_start {
    Todo *todo = self.todo;
    todo.startDate = [NSDate today];
    
    Todo *todo2 = [self createTodo];
    todo2.startDate = [[NSDate today] dateByAddingDays:1];
    
    Todo *todo3 = [self createTodo];
    
    [Todo updateTodosReadyToStart];
    
    assertThatInt(todo.lastEntry.type, equalToInt(EntryTypeReady));
    assertThat(todo.startDate, is(nilValue()));
    
    assertThatInt(todo2.lastEntry.type, equalToInt(EntryTypeNew));
    assertThatInt(todo3.lastEntry.type, equalToInt(EntryTypeNew));
}

- (void)test_update_urgency_when_due_date_changes {
    self.todo.dueDate = [NSDate today];
    assertThatFloat(self.todo.urgency, equalToFloat(1.0));
}

- (void)test_clear_urgency_when_due_date_cleared {
    self.todo.dueDate = [NSDate today];
    self.todo.dueDate = nil;
    assertThatFloat(self.todo.urgency, equalToFloat(0));
}

- (void)test_get_entries_by_date {
    Entry *entry1 = [self.todo.entries firstObject];
    [NSThread sleepForTimeInterval:0.1];
    Entry *entry2 = [self.todo createEntry:EntryTypeAction];
    [NSThread sleepForTimeInterval:0.1];
    Entry *entry3 = [self.todo createEntry:EntryTypeAction];

    assertThat(self.todo.entries[0], is(entry1));
    assertThat(self.todo.entries[1], is(entry2));
    assertThat(self.todo.entries[2], is(entry3));
}

- (void)test_get_entries_by_date_after_changes {
    Entry *createEntry = [self.todo.entries firstObject];
    Entry *entry1 = [self.todo createEntry:EntryTypeAction];
    assertThat(self.todo.entries.array, is(@[createEntry, entry1]));
    Entry *entry2 = [self.todo createEntry:EntryTypeAction];
    assertThat(self.todo.entries.array, is(@[createEntry, entry1, entry2]));
}

- (void)test_priority_zero_when_start_date {
    assertThatFloat(self.todo.priority, isNot(equalToFloat(0)));
    self.todo.startDate = [[NSDate today] dateByAddingDays:1];
    assertThatFloat(self.todo.priority, equalToFloat(0));
}

- (void)test_staleness_for_old_todo {
    entryDate = [[NSDate today] dateByAddingDays:-kStaleDaysAfterLastEntryDate];
    assertThatFloat(self.todo.staleness, equalToFloat(1.0));
}

- (void)test_staleness_for_aging_todo {
    entryDate = [[NSDate today] dateByAddingDays:-kStaleDaysAfterLastEntryDate/2];
    assertThatFloat(self.todo.staleness, equalToFloat(0.5));
}

- (void)test_staleness_for_young_todo {
    entryDate = [[NSDate today] dateByAddingDays:-kStaleDaysAfterLastEntryDate/4];
    assertThatFloat(self.todo.staleness, closeTo(0.2, 0.2));
}

- (void)test_staleness_for_new_todo {
    assertThatFloat(self.todo.staleness, equalToFloat(0.0));
}

- (void)test_staleness_for_old_unimportant_todo {
    entryDate = [[NSDate today] dateByAddingDays:-kStaleDaysAfterLastEntryDate];
    self.todo.importance = 0.0;
    assertThatFloat(self.todo.staleness, equalToFloat(0.0));
}

- (void)test_frostiness_for_frozen_todo {
    self.todo.startDate = [[NSDate today] dateByAddingDays:kFrostyDaysBeforeStartDate];
    assertThatFloat(self.todo.frostiness, equalToFloat(1.0));
}

- (void)test_frostiness_for_thawing_todo {
    self.todo.startDate = [[NSDate today] dateByAddingDays:kFrostyDaysBeforeStartDate/4];
    assertThatFloat(self.todo.frostiness, closeTo(0.2, 0.2));
}

- (void)test_frostiness_for_thawed_todo {
    self.todo.startDate = [NSDate today];
    assertThatFloat(self.todo.frostiness, equalToFloat(0.0));
}

- (void)test_temperature_for_new_todo {
    assertThatFloat(self.todo.temperature, equalToFloat(0.0));
}

- (void)test_temperature_for_frozen_todo {
    self.todo.startDate = [[NSDate today] dateByAddingDays:kFrostyDaysBeforeStartDate];
    assertThatFloat(self.todo.temperature, equalToFloat(-1.0));
}

- (void)test_temperature_for_urgent_todo {
    self.todo.dueDate = [NSDate today];
    assertThatFloat(self.todo.temperature, equalToFloat(1.0));
}

- (void)test_temperature_for_stale_todo {
    entryDate = [[NSDate today] dateByAddingDays:-kStaleDaysAfterLastEntryDate];
    assertThatFloat(self.todo.temperature, equalToFloat(1.0));
}

- (void)test_temperature_for_urgent_stale_todo {
    entryDate = [[NSDate today] dateByAddingDays:-kStaleDaysAfterLastEntryDate / 2];
    self.todo.dueDate = [[NSDate today] dateByAddingDays:kUrgentDaysBeforeDueDate / 2];
    assertThatFloat(self.todo.temperature, equalToFloat(1.0));
}

- (void)test_update_urgency_from_due_date {
    
}

- (void)test_daily_update_all_urgencies_from_due_date {
    
}

#pragma mark -

- (Todo *)createTodo {
    Todo *todo = [Todo create];
    todo.title = @"title";
    return todo;
}

@end



