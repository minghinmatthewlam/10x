import XCTest
import SwiftData
@testable import TenXApp

final class TenXStoreTests: XCTestCase {
    @MainActor
    func testCannotCreateDayEntryWithLessThanThreeDrafts() throws {
        let context = TestContainerFactory.makeContext()
        let store = TenXStore(context: context)

        try store.createGoal(title: "Goal")
        let goal = try store.fetchActiveGoals().first

        let drafts = [TenXStore.FocusDraft(title: "One", goalUUID: goal?.uuid, carriedFromDayKey: nil)]

        XCTAssertThrowsError(try store.createDayEntry(todayKey: DayKey.make(), drafts: drafts))
    }

    @MainActor
    func testCannotCreateDayEntryWithMissingGoalLink() throws {
        let context = TestContainerFactory.makeContext()
        let store = TenXStore(context: context)

        try store.createGoal(title: "Goal")

        let drafts = [
            TenXStore.FocusDraft(title: "One", goalUUID: nil, carriedFromDayKey: nil),
            TenXStore.FocusDraft(title: "Two", goalUUID: nil, carriedFromDayKey: nil),
            TenXStore.FocusDraft(title: "Three", goalUUID: nil, carriedFromDayKey: nil)
        ]

        XCTAssertThrowsError(try store.createDayEntry(todayKey: DayKey.make(), drafts: drafts))
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
}
