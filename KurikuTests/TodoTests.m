//
//  TodoTests.m
//  KurikuTests
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <InnerBand/InnerBand.h>
#import "Journal.h"
#import "Todo.h"
#import "Entry.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

@interface TodoTests : XCTestCase
@property (nonatomic) Todo *todo;
@end

@implementation TodoTests

- (void)setUp {
    [super setUp];
    [IBCoreDataStore clearAllData];
    [Journal create];
    self.todo = [self createTodo];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_insert_create_entry {
    NSSet *entries = self.todo.entries;
    assertThatInteger(entries.count, equalToInteger(1));
    Entry *entry = [entries anyObject];
    assertThatInteger(entry.type, equalToInteger(EntryTypeCreate));
}

- (void)test_insert_ready_entry_if_no_entries {
    [self.todo removeEntries:self.todo.entries];
    NSSet *entries = self.todo.entries;
    assertThatInteger(entries.count, equalToInteger(1));
    Entry *entry = [entries anyObject];
    assertThatInteger(entry.type, equalToInteger(EntryTypeReady));
}

- (void)test_insert_ready_entry_when_status_changes_from_hold_to_normal {
    self.todo.status = TodoStatusHold;
    self.todo.status = TodoStatusNormal;
    assertThatInteger(self.todo.lastEntryType, equalToInteger(EntryTypeReady));
}

- (void)test_insert_ready_entry_when_status_changes_from_completed_to_normal {
    self.todo.status = TodoStatusCompleted;
    self.todo.status = TodoStatusNormal;
    assertThatInteger(self.todo.lastEntryType, equalToInteger(EntryTypeReady));
}


- (void)test_insert_complete_entry_when_status_changes_to_completed {
    self.todo.status = TodoStatusCompleted;
    assertThatInteger(self.todo.lastEntryType, equalToInteger(EntryTypeComplete));
}

- (void)test_insert_hold_entry_when_status_changes_to_hold {
    self.todo.status = TodoStatusHold;
    assertThatInteger(self.todo.lastEntryType, equalToInteger(EntryTypeHold));
}
    
- (void)test_delete_all_entries_when_deleting_todo {
    [self.todo destroy];
    assertThatInteger([[Entry all] count], equalToInteger(0));
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
    self.todo.importance = 0;
    assertThatFloat(self.todo.priority, isNot(equalToFloat(oldPriority)));
}

- (void)test_update_priority_when_urgency_changes {
    float oldPriority = self.todo.priority;
    self.todo.urgency = 1;
    assertThatFloat(self.todo.priority, isNot(equalToFloat(oldPriority)));
}

- (void)test_update_priority_when_commitment_changes {
    float oldPriority = self.todo.priority;
    self.todo.commitment = 0;
    assertThatFloat(self.todo.priority, isNot(equalToFloat(oldPriority)));
}

- (void)test_calculate_priority1 {
    self.todo.importance = 0;
    self.todo.urgency    = 0;
    self.todo.commitment = TodoCommitmentMust;
    assertThatFloat(self.todo.priority, equalToFloat(0));
}

- (void)test_calculate_priority2 {
    self.todo.importance = 2;
    self.todo.urgency    = 0;
    self.todo.commitment = TodoCommitmentMust;
    assertThatFloat(self.todo.priority, equalToFloat(2.0/8.0));
}

- (void)test_calculate_priority3 {
    self.todo.importance = 0;
    self.todo.urgency    = 2;
    self.todo.commitment = TodoCommitmentMust;
    assertThatFloat(self.todo.priority, equalToFloat(2.0/8.0));
}

- (void)test_calculate_priority4 {
    self.todo.importance = 2;
    self.todo.urgency    = 2;
    self.todo.commitment = TodoCommitmentMust;
    assertThatFloat(self.todo.priority, equalToFloat(4.0/8.0));
}

- (void)test_calculate_priority5 {
    self.todo.importance = 2;
    self.todo.urgency    = 2;
    self.todo.commitment = TodoCommitmentMaybe;
    assertThatFloat(self.todo.priority, equalToFloat(4.0/8.0 - 9));
}

- (void)test_calculate_priority6 {
    self.todo.importance = 2;
    self.todo.urgency    = 2;
    self.todo.commitment = TodoCommitmentToday;
    assertThatFloat(self.todo.priority, equalToFloat(4.0/8.0 + 9));
}

- (void)test_calculate_priority7 {
    self.todo.importance = TodoRangeMaxValue;
    self.todo.urgency    = TodoRangeMaxValue;
    self.todo.commitment = TodoCommitmentDefaultValue;
    assertThatFloat(self.todo.priority, equalToFloat(1.0));
}

- (void)test_update_all_priorities_when_priority_version_changes {
    Todo *todo1 = self.todo;
    Todo *todo2 = [self createTodo];
    float oldPriority1 = todo1.priority;
    float oldPriority2 = todo2.priority;
    todo1.priority = 0;
    todo2.priority = 0;
    
    [[IBCoreDataStore mainStore] setMetadataObject:@(0) forKey:@"PriorityVersion"];
    [Todo updateAllPrioritiesIfNeeded];
    
    assertThatFloat(todo1.priority, equalToFloat(oldPriority1));
    assertThatFloat(todo2.priority, equalToFloat(oldPriority2));
}

- (void)test_set_status_to_normal_after_status_changes_to_completed_with_immediate_repeat {
    self.todo.repeatDays = 0;
    self.todo.status = TodoStatusCompleted;
    assertThatInteger(self.todo.status, equalToInteger(TodoStatusNormal));
}

- (void)test_does_not_set_status_to_normal_after_status_changes_to_completed_with_no_repeat {
    self.todo.repeatDays = -1;
    self.todo.status = TodoStatusCompleted;
    assertThatInteger(self.todo.status, equalToInteger(TodoStatusCompleted));
}

- (void)test_set_hold_date_when_status_changes_to_completed_with_repeat {
    self.todo.repeatDays = 1;
    self.todo.status = TodoStatusCompleted;
    NSDate *oneDayFromToday = [[NSDate today] dateByAddingDays:1];
    assertThat(self.todo.holdDate, is(oneDayFromToday));
}

- (void)test_clear_hold_date_when_status_changes_to_not_hold {
    self.todo.holdDate = [[NSDate today] dateByAddingDays:1];
    self.todo.status = TodoStatusNormal;
    assertThat(self.todo.holdDate, is(nilValue()));
}

- (void)test_update_urgency_when_due_date_changes {
    self.todo.dueDate = [NSDate today];
    assertThatInteger(self.todo.urgency, equalToInteger(TodoRangeMaxValue));
}

- (void)test_clear_urgency_when_due_date_cleared {
    self.todo.dueDate = [NSDate today];
    self.todo.dueDate = nil;
    assertThatInteger(self.todo.urgency, equalToInteger(0));
}

- (void)test_set_status_to_hold_when_hold_date_set {
    self.todo.holdDate = [[NSDate today] dateByAddingDays:1];
    assertThatInteger(self.todo.status, equalToInteger(TodoStatusHold));
}

- (void)test_set_status_to_normal_when_hold_date_cleared {
    self.todo.holdDate = [[NSDate today] dateByAddingDays:1];
    self.todo.holdDate = nil;
    assertThatInteger(self.todo.status, equalToInteger(TodoStatusNormal));
}

- (void)test_get_entries_by_date {
    Entry *entry1 = [self.todo.entries anyObject];
    [NSThread sleepForTimeInterval:0.1];
    Entry *entry2 = [self.todo createEntry:EntryTypeTakeAction];
    [NSThread sleepForTimeInterval:0.1];
    Entry *entry3 = [self.todo createEntry:EntryTypeTakeAction];
    NSArray *entries = [self.todo entriesByDate];
    
    assertThat(entries[0], is(entry1));
    assertThat(entries[1], is(entry2));
    assertThat(entries[2], is(entry3));
}

- (void)test_get_entries_by_date_after_changes {
    Entry *createEntry = [self.todo.entries anyObject];
    Entry *entry1 = [self.todo createEntry:EntryTypeTakeAction];
    assertThat(self.todo.entriesByDate, is(@[createEntry, entry1]));
    Entry *entry2 = [self.todo createEntry:EntryTypeTakeAction];
    assertThat(self.todo.entriesByDate, is(@[createEntry, entry1, entry2]));
}

- (void)test_get_last_entry_date {
    [self.todo createEntry:EntryTypeTakeAction];
    assertThatInteger(self.todo.lastEntryType, equalToInteger(EntryTypeTakeAction));
}

- (void)test_get_last_entry_type {
    Entry *entry = [self.todo createEntry:EntryTypeTakeAction];
    assertThat(self.todo.lastEntryDate, is(entry.timestamp));
}

- (void)test_update_urgency_from_due_date {
    
}

- (void)test_daily_update_all_urgencies_from_due_date {
    
}

- (void)test_daily_update_all_statuses_from_hold_date {
    
}

- (void)test_calculate_urgency_if_due_date {
    
}

- (void)test_calculate_urgency_if_no_due_date {
    
}

#pragma mark -

- (Todo *)createTodo {
    Todo *todo = [Todo create];
    todo.title = @"title";
    return todo;
}

@end
