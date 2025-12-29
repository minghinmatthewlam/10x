import XCTest
import SwiftData
@testable import TenX

final class TenXStoreTests: XCTestCase {
    @MainActor
    func testAllowsCreateDayEntryWithSingleDraft() throws {
        let context = TestContainerFactory.makeContext()
        let store = TenXStore(context: context)
        let todayKey = DayKey.make()

        let drafts = [TenXStore.FocusDraft(title: "One", goalUUID: nil, carriedFromDayKey: nil)]

        XCTAssertNoThrow(try store.createDayEntry(todayKey: todayKey, drafts: drafts))
        let entry = try store.fetchDayEntry(dayKey: todayKey)
        XCTAssertEqual(entry?.sortedFocuses.count, 1)
    }

    @MainActor
    func testRejectsEmptyDrafts() throws {
        let context = TestContainerFactory.makeContext()
        let store = TenXStore(context: context)
        let todayKey = DayKey.make()

        let drafts = [
            TenXStore.FocusDraft(title: " ", goalUUID: nil, carriedFromDayKey: nil),
            TenXStore.FocusDraft(title: "", goalUUID: nil, carriedFromDayKey: nil)
        ]

        XCTAssertThrowsError(try store.createDayEntry(todayKey: todayKey, drafts: drafts))
    }

    @MainActor
    func testCannotAddFourthGoal() throws {
        let context = TestContainerFactory.makeContext()
        let store = TenXStore(context: context)

        try store.createGoal(title: "Goal 1")
        try store.createGoal(title: "Goal 2")
        try store.createGoal(title: "Goal 3")

        XCTAssertThrowsError(try store.createGoal(title: "Goal 4"))
    }

    @MainActor
    func testGoalTitleLengthLimit() throws {
        let context = TestContainerFactory.makeContext()
        let store = TenXStore(context: context)

        let longTitle = String(repeating: "A", count: AppConstants.maxGoalTitleLength + 1)
        XCTAssertThrowsError(try store.createGoal(title: longTitle))
    }

    @MainActor
    func testCannotArchiveLastActiveGoal() throws {
        let context = TestContainerFactory.makeContext()
        let store = TenXStore(context: context)

        try store.createGoal(title: "Only")
        let goal = try store.fetchActiveGoals().first!

        XCTAssertThrowsError(try store.archiveGoal(goal))
    }

    @MainActor
    func testCarryoverDraftsReturnsUnfinishedAndCapsAtThree() throws {
        let context = TestContainerFactory.makeContext()
        let store = TenXStore(context: context)

        try store.createGoal(title: "Goal")
        let goal = try store.fetchActiveGoals().first!

        let todayKey = DayKey.make()
        let yesterdayKey = DayKey.previous(dayKey: todayKey)

        let drafts = [
            TenXStore.FocusDraft(title: "One", goalUUID: goal.uuid, carriedFromDayKey: nil),
            TenXStore.FocusDraft(title: "Two", goalUUID: goal.uuid, carriedFromDayKey: nil),
            TenXStore.FocusDraft(title: "Three", goalUUID: goal.uuid, carriedFromDayKey: nil)
        ]

        try store.createDayEntry(todayKey: yesterdayKey, drafts: drafts)
        let yesterday = try store.fetchDayEntry(dayKey: yesterdayKey)!
        if let first = yesterday.sortedFocuses.first {
            try store.toggleCompletion(first)
        }

        let extra = DailyFocus(title: "Extra", sortOrder: 3)
        extra.goal = goal
        extra.day = yesterday
        yesterday.focuses.append(extra)
        context.insert(extra)
        try context.save()

        let carryover = try store.carryoverDraftsIfNeeded(todayKey: todayKey)
        XCTAssertEqual(carryover.count, 3)
        XCTAssertTrue(carryover.allSatisfy { !$0.title.isEmpty })
    }

    @MainActor
    func testFocusTitleLengthLimit() throws {
        let context = TestContainerFactory.makeContext()
        let store = TenXStore(context: context)

        try store.createGoal(title: "Goal")
        let goal = try store.fetchActiveGoals().first!

        let longTitle = String(repeating: "B", count: AppConstants.maxFocusTitleLength + 1)
        let drafts = [
            TenXStore.FocusDraft(title: longTitle, goalUUID: goal.uuid, carriedFromDayKey: nil),
            TenXStore.FocusDraft(title: "Two", goalUUID: goal.uuid, carriedFromDayKey: nil),
            TenXStore.FocusDraft(title: "Three", goalUUID: goal.uuid, carriedFromDayKey: nil)
        ]

        XCTAssertThrowsError(try store.createDayEntry(todayKey: DayKey.make(), drafts: drafts))
    }
}
