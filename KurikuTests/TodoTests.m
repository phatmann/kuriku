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
#import "NSDate+Kuriku.h"
#import "NSObject+SupersequentImplementation.h"
#import "NSDate+UnitTests.h"

static NSDate *mockUpdateDate;

@interface Todo(Testing)
+ (NSDate *)dailyUpdatedOn;
@end

@implementation Todo(Mock)
- (NSDate *)updateDate {return mockUpdateDate ?  mockUpdateDate : [self primitiveValueForKey:@"updateDate"];}
@end

@interface TodoTests : XCTestCase
@property (nonatomic) Todo *todo;
@end

@implementation TodoTests

- (void)setUp {
    [super setUp];
    [IBCoreDataStore clearAllData];
    [Journal create];
    mockUpdateDate = nil;
    self.todo = [self createTodo];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_insert_create_entry {
    NSOrderedSet *entries = self.todo.entries;
    assertThatFloat(entries.count, equalToFloat(1));
    Entry *entry = [entries firstObject];
    assertThatFloat(entry.type, equalToFloat(EntryTypeNew));
}

- (void)test_insert_new_entry_deactivates_previous_entry {
    Entry *entry1 = [self.todo.entries firstObject];
    assertThatFloat(entry1.state, equalToFloat(EntryStateActive));
    
    Entry *entry2 = [self.todo createEntry:EntryTypeAction];
    assertThatFloat(entry1.state, equalToFloat(EntryStateInactive));
    assertThatFloat(entry2.state, equalToFloat(EntryStateActive));
}
    
- (void)test_delete_all_entries_when_deleting_todo {
    [self.todo destroy];
    assertThatFloat([[Entry all] count], equalToFloat(0));
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
    assertThatFloat(entry1.state, equalToFloat(EntryStateActive));
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
    assertThatFloat(self.todo.lastEntry.type, equalToFloat(EntryTypeNew));
}

- (void)test_delete_completion_entry_deletes_subsequent_ready_and_completed_entries {
    Entry *completionEntry = [self.todo createEntry:EntryTypeComplete];
    [self.todo createEntry:EntryTypeReady];
    [self.todo createEntry:EntryTypeAction];
    [self.todo createEntry:EntryTypeComplete];
    [self.todo createEntry:EntryTypeReady];
    assertThatFloat(self.todo.entries.count, equalToFloat(6));
    completionEntry.todo = nil;
    assertThatFloat(self.todo.entries.count, equalToFloat(2));
}

- (void)test_delete_ready_entry_deletes_subsequent_ready_and_completion_entries {
    [self.todo createEntry:EntryTypeComplete];
    Entry *readyEntry = [self.todo createEntry:EntryTypeReady];
    [self.todo createEntry:EntryTypeAction];
    [self.todo createEntry:EntryTypeComplete];
    [self.todo createEntry:EntryTypeReady];
    assertThatFloat(self.todo.entries.count, equalToFloat(6));
    readyEntry.todo = nil;
    assertThatFloat(self.todo.entries.count, equalToFloat(3));
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

- (void)test_initial_temperature {
    assertThatFloat(self.todo.temperature, equalToFloat(TodoColdMaxTemperature + 1));
}

- (void)test_update_todos_ready_to_start {
    Todo *todo = self.todo;
    todo.startDate = [NSDate today];
    
    Todo *todo2 = [self createTodo];
    todo2.startDate = [[NSDate today] dateByAddingDays:1];
    
    Todo *todo3 = [self createTodo];
    
    [Todo updateAllTodosReadyToStart];
    
    assertThatFloat(todo.lastEntry.type, equalToFloat(EntryTypeReady));
    assertThat(todo.startDate, is(nilValue()));
    
    assertThatFloat(todo2.lastEntry.type, equalToFloat(EntryTypeNew));
    assertThatFloat(todo3.lastEntry.type, equalToFloat(EntryTypeNew));
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

- (void)test_staleness_for_old_todo {
    mockUpdateDate = [[NSDate today] dateByAddingDays:-TodoMaxStaleDaysAfterLastUpdate];
    assertThatFloat(self.todo.staleness, equalToFloat(1.0f));
}

- (void)test_staleness_for_aging_todo {
    mockUpdateDate = [[NSDate today] dateByAddingDays:-TodoMaxStaleDaysAfterLastUpdate/2];
    assertThatFloat(self.todo.staleness, closeTo(0.5f, 0.1f));
}

- (void)test_staleness_for_young_todo {
    mockUpdateDate = [[NSDate today] dateByAddingDays:-1];
    assertThatFloat(self.todo.staleness, equalToFloat(0.0f));
}

- (void)test_staleness_for_new_todo {
    assertThatFloat(self.todo.staleness, equalToFloat(0.0f));
}

- (void)test_remove_start_date_when_completed {
    self.todo.startDate = [[NSDate today] dateByAddingDays:1];
    [self.todo createEntry:EntryTypeComplete];
    assertThat(self.todo.startDate, is(nilValue()));
}

- (void)test_daily_update_later_hot_temperature {
    self.todo.temperature = TodoNormalMaxTemperature + 1;
    
    NSDate *twoWeeksAgo = [NSDate dateFromTodayWithDays:-14];
    id todo = [OCMockObject mockForClass:[Todo class]];
    [[[todo stub] andReturn:twoWeeksAgo] dailyUpdatedOn];
    
    [Todo dailyUpdate];
    assertThatFloat(self.todo.temperature, equalToFloat(100));
    
    [todo stopMocking];
}

- (void)test_daily_update_soon_hot_temperature {
    self.todo.temperature = TodoNormalMaxTemperature + 1;
    
    NSDate *yesterday = [NSDate dateFromTodayWithDays:-1];
    id todo = [OCMockObject mockForClass:[Todo class]];
    [[[todo stub] andReturn:yesterday] dailyUpdatedOn];
    
    [Todo dailyUpdate];
    assertThatFloat(self.todo.temperature, greaterThan(@(TodoNormalMaxTemperature + 1)));
    
    [todo stopMocking];
}

- (void)test_daily_update_later_temperature_from_staleness {
    self.todo.temperature = TodoColdMaxTemperature + 1;
    mockUpdateDate = [NSDate dateFromTodayWithDays:-TodoMinStaleDaysAfterLastUpdate];
    
    NSDate *whileAgo = [NSDate dateFromTodayWithDays:-TodoMaxStaleDaysAfterLastUpdate];
    id todo = [OCMockObject mockForClass:[Todo class]];
    [[[todo stub] andReturn:whileAgo] dailyUpdatedOn];
    
    [Todo dailyUpdate];
    assertThatFloat(self.todo.temperature, equalToFloat(75));
    
    [todo stopMocking];
}

- (void)test_daily_update_soon_temperature_from_staleness {
    self.todo.temperature = TodoColdMaxTemperature + 1;
    mockUpdateDate = [NSDate dateFromTodayWithDays:-TodoMinStaleDaysAfterLastUpdate];
    
    NSDate *yesterday = [NSDate dateFromTodayWithDays:-1];
    id todo = [OCMockObject mockForClass:[Todo class]];
    [[[todo stub] andReturn:yesterday] dailyUpdatedOn];
    
    [Todo dailyUpdate];
    assertThatFloat(self.todo.temperature, greaterThan(@(TodoColdMaxTemperature + 1)));
    
    [todo stopMocking];
}

- (void)test_daily_update_later_temperature_from_frostiness {
    self.todo.temperature = TodoFrozenMaxTemperature + 1;
    
    NSDate *whileAgo = [NSDate dateFromTodayWithDays:-60];
    id todo = [OCMockObject mockForClass:[Todo class]];
    [[[todo stub] andReturn:whileAgo] dailyUpdatedOn];
    
    [Todo dailyUpdate];
    assertThatFloat(self.todo.temperature, equalToFloat(50));
    
    [todo stopMocking];
}

- (void)test_daily_update_soon_temperature_from_frostiness {
    self.todo.temperature = TodoFrozenMaxTemperature + 1;
    
    NSDate *yesterday = [NSDate dateFromTodayWithDays:-1];
    id todo = [OCMockObject mockForClass:[Todo class]];
    [[[todo stub] andReturn:yesterday] dailyUpdatedOn];
    
    [Todo dailyUpdate];
    assertThatFloat(self.todo.temperature, greaterThan(@(TodoFrozenMaxTemperature + 1)));
    
    [todo stopMocking];
}

- (void)test_setting_distant_start_date_freezes_todo {
    self.todo.startDate = [NSDate dateFromTodayWithDays:62];
    assertThatFloat(self.todo.temperature, equalToFloat(TodoMinTemperature));
}

- (void)test_setting_near_start_date_cools_todo {
    self.todo.startDate = [NSDate dateFromTodayWithDays:1];
    assertThatFloat(self.todo.temperature, greaterThan(@(TodoFrozenMaxTemperature)));
    assertThatFloat(self.todo.temperature, lessThanOrEqualTo(@(TodoColdMaxTemperature)));
}

- (void)test_setting_near_due_date_warms_todo {
    self.todo.dueDate = [NSDate today];
    assertThatFloat(self.todo.temperature, equalToFloat(TodoMaxTemperature));
}

- (void)test_thaw_when_approaching_start_date {
    self.todo.startDate = [NSDate dateFromTodayWithDays:67];
    NSDate *oneWeekFromNow = [NSDate dateFromTodayWithDays:7];
    id date = [NSDate createNiceMockDate];
    [[[date stub] andReturn:oneWeekFromNow] today];
    [Todo dailyUpdate];
    assertThatFloat(self.todo.temperature, equalToFloat(TodoFrozenMaxTemperature + 1));
    [NSDate releaseInstance];
}

- (void)test_warm_when_approaching_due_date {
    self.todo.dueDate = [NSDate dateFromTodayWithDays:21];
    NSDate *oneWeekFromNow = [NSDate dateFromTodayWithDays:7];
    id date = [NSDate createNiceMockDate];
    [[[date stub] andReturn:oneWeekFromNow] today];
    [Todo dailyUpdate];
    assertThatFloat(self.todo.temperature, equalToFloat(TodoNormalMaxTemperature + 1));
}

#pragma mark -

- (Todo *)createTodo {
    Todo *todo = [Todo create];
    todo.title = @"title";
    return todo;
}

@end



