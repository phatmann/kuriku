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

- (Todo *)createTodo {
    Todo *todo = [Todo create];
    todo.title = @"title";
    return todo;
}

@end
