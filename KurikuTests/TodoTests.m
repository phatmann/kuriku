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
- (void)updateVolume;
@end

@implementation Entry(Testing)
- (NSDate *)createDate {return entryDate ?  entryDate : [self primitiveValueForKey:@"createDate"];}
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

- (void)test_update_volume_when_urgency_changes {
    float oldVolume = self.todo.volume;
    self.todo.urgency = 1;
    assertThatFloat(self.todo.volume, isNot(equalToFloat(oldVolume)));
}

- (void)test_initial_volume {
    assertThatFloat(self.todo.volume, equalToFloat(0.5f));
}

- (void)test_warm_volume {
    self.todo.urgency = 0.5;
    assertThatFloat(self.todo.volume, equalToFloat(0.75f));
}

- (void)test_hot_volume {
    self.todo.urgency = 1.0;
    assertThatFloat(self.todo.volume, equalToFloat(1.0f));
}

- (void)test_fresh_volume {
    entryDate = [[NSDate today] dateByAddingDays:-1];
    [self.todo updateVolume];
    assertThatFloat(self.todo.volume, equalToFloat(0.5f));
}

- (void)test_stale_volume{
    entryDate = [NSDate dateFromTodayWithDays:-TodoMaxStaleDaysAfterLastEntryDate];
    [self.todo updateVolume];
    assertThatFloat(self.todo.volume, equalToFloat(1.0f));
}

- (void)test_update_all_volumes_when_volume_version_changes {
    Todo *todo1 = self.todo;
    Todo *todo2 = [self createTodo];
    float oldVolume1 = todo1.volume;
    float oldVolume2 = todo2.volume;
    
    assertThatFloat(oldVolume1, isNot(equalToFloat(0)));
    assertThatFloat(oldVolume2, isNot(equalToFloat(0)));
    
    todo1.volume = 0;
    todo2.volume = 0;
    
    [[IBCoreDataStore mainStore] setMetadataObject:@(0) forKey:@"TodoVolumeVersion"];
    [Todo updateVolumeForAllTodosIfNeeded];
    
    assertThatFloat(todo1.volume, equalToFloat(oldVolume1));
    assertThatFloat(todo2.volume, equalToFloat(oldVolume2));
}

- (void)test_update_todos_ready_to_start {
    Todo *todo = self.todo;
    todo.startDate = [NSDate today];
    
    Todo *todo2 = [self createTodo];
    todo2.startDate = [[NSDate today] dateByAddingDays:1];
    
    Todo *todo3 = [self createTodo];
    
    [Todo updateAllTodosReadyToStart];
    
    assertThatInt(todo.lastEntry.type, equalToInt(EntryTypeReady));
    assertThat(todo.startDate, is(nilValue()));
    
    assertThatInt(todo2.lastEntry.type, equalToInt(EntryTypeNew));
    assertThatInt(todo3.lastEntry.type, equalToInt(EntryTypeNew));
}

- (void)test_urgency_due_today {
    self.todo.dueDate = [NSDate today];
    assertThatFloat(self.todo.urgency, equalToFloat(1.0));
}

- (void)test_no_urgency_when_no_due_date {
    assertThatFloat(self.todo.urgency, equalToFloat(0));
}

- (void)test_urgency_with_distant_due_date {
    self.todo.dueDate = [[NSDate today] dateByAddingDays:120];
    assertThatFloat(self.todo.urgency, lessThan(@(0.0)));
}

- (void)test_urgency_with_past_due_date {
    self.todo.dueDate = [[NSDate today] dateByAddingDays:-14];
    assertThatFloat(self.todo.urgency, greaterThan(@(1.0)));
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

- (void)test_volume_zero_when_start_date {
    self.todo.startDate = [NSDate dateFromTodayWithDays:1];
    assertThatFloat(self.todo.volume, closeTo(0.5f, 0.1f));
}

- (void)test_volume_with_distant_due_date {
    self.todo.dueDate = [[NSDate today] dateByAddingDays:365];
    assertThatFloat(self.todo.volume, equalToFloat(0.5f));
}

- (void)test_staleness_for_old_todo {
    entryDate = [[NSDate today] dateByAddingDays:-TodoMaxStaleDaysAfterLastEntryDate];
    assertThatFloat(self.todo.staleness, equalToFloat(1.0f));
}

- (void)test_staleness_for_aging_todo {
    entryDate = [[NSDate today] dateByAddingDays:-TodoMaxStaleDaysAfterLastEntryDate/2];
    assertThatFloat(self.todo.staleness, closeTo(0.5f, 0.1f));
}

- (void)test_staleness_for_young_todo {
    entryDate = [[NSDate today] dateByAddingDays:-1];
    assertThatFloat(self.todo.staleness, equalToFloat(0.0f));
}

- (void)test_staleness_for_new_todo {
    assertThatFloat(self.todo.staleness, equalToFloat(0.0f));
}

- (void)test_frostiness_for_frozen_todo {
    self.todo.startDate = [[NSDate today] dateByAddingDays:60];
    assertThatFloat(self.todo.frostiness, closeTo(1.0f, 0.1));
}

- (void)test_frostiness_for_thawing_todo {
    self.todo.startDate = [[NSDate today] dateByAddingDays:15];
    assertThatFloat(self.todo.frostiness, closeTo(0.2f, 0.2f));
}

- (void)test_frostiness_for_thawed_todo {
    self.todo.startDate = [NSDate today];
    assertThatFloat(self.todo.frostiness, equalToFloat(0.0f));
}

- (void)test_frostiness_for_barely_cold_todo {
    self.todo.startDate = [[NSDate today] dateByAddingDays:1];
    assertThatFloat(self.todo.frostiness, isNot(equalToFloat(0.0f)));
}

- (void)test_frostiness_with_past_start_date {
    self.todo.startDate = [[NSDate today] dateByAddingDays:-10];
    assertThatFloat(self.todo.frostiness, lessThan(@(0.0f)));
}

- (void)test_frostiness_with_distant_start_date {
    self.todo.startDate = [[NSDate today] dateByAddingDays:120];
    assertThatFloat(self.todo.frostiness, greaterThan(@(1.0f)));
}

- (void)test_temperature_for_new_todo {
    assertThatFloat(self.todo.temperature, equalToFloat(0.0f));
}

- (void)test_temperature_for_frozen_todo {
    self.todo.startDate = [[NSDate today] dateByAddingDays:60];
    assertThatFloat(self.todo.temperature, closeTo(-1.0f, 0.1f));
}

- (void)test_temperature_for_urgent_todo {
    self.todo.dueDate = [NSDate today];
    assertThatFloat(self.todo.temperature, equalToFloat(1.0f));
}

- (void)test_temperature_for_urgent_stale_todo {
    entryDate = [[NSDate today] dateByAddingDays:-TodoMaxStaleDaysAfterLastEntryDate / 2];
    self.todo.dueDate = [[NSDate today] dateByAddingDays:7];
    assertThatFloat(self.todo.temperature, equalToFloat(0.5f));
}

- (void)test_remove_start_date_when_completed {
    self.todo.startDate = [[NSDate today] dateByAddingDays:1];
    [self.todo createEntry:EntryTypeComplete];
    assertThat(self.todo.startDate, is(nilValue()));
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



