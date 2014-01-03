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
    [IBCoreDataStore save];
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
    self.todo.title = @"new title";
    [IBCoreDataStore save];
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
    
}

- (void)test_set_hold_date_when_status_changes_to_completed_with_repeat {
    
}

- (void)test_clear_hold_date_when_status_changes_to_not_hold {
    
}

- (void)test_update_urgency_when_due_date_changes {
    
}

- (void)test_clear_urgency_when_due_date_cleared {
    
}

- (void)test_set_status_to_hold_when_hold_date_set {
    
}

- (void)test_set_status_to_normal_when_hold_date_cleared {
    
}

- (void)test_get_entries_by_date {
    
}

- (void)test_get_last_entry_date {
    
}

- (void)test_get_last_entry_type {
    
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

    todo.title      = @"title";
    todo.importance = TodoImportanceDefaultValue;
    todo.urgency    = TodoUrgencyDefaultValue;
    todo.commitment = TodoCommitmentDefaultValue;
    
    return todo;
}

@end
