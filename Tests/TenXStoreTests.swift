import XCTest
import SwiftData
@testable import TenX

final class TenXStoreTests: XCTestCase {
    @MainActor
    func testCreateDayEntryAllowsOneToThreeFocuses() throws {
        let context = TestContainerFactory.makeContext()
        let store = TenXStore(context: context)
        let todayKey = DayKey.make()

        let drafts = [
            TenXStore.FocusDraft(title: "One", carriedFromDayKey: nil, tag: nil),
            TenXStore.FocusDraft(title: "Two", carriedFromDayKey: nil, tag: nil),
            TenXStore.FocusDraft(title: "", carriedFromDayKey: nil, tag: nil)
        ]

        XCTAssertNoThrow(try store.createDayEntry(todayKey: todayKey, drafts: drafts))
        let entry = try store.fetchDayEntry(dayKey: todayKey)
        XCTAssertEqual(entry?.sortedFocuses.count, 2)
    }

    @MainActor
    func testRejectsEmptyDrafts() throws {
        let context = TestContainerFactory.makeContext()
        let store = TenXStore(context: context)
        let todayKey = DayKey.make()

        let drafts = [
            TenXStore.FocusDraft(title: " ", carriedFromDayKey: nil, tag: nil),
            TenXStore.FocusDraft(title: "", carriedFromDayKey: nil, tag: nil)
        ]

        XCTAssertThrowsError(try store.createDayEntry(todayKey: todayKey, drafts: drafts))
    }

    @MainActor
    func testCarryoverDraftsReturnsUnfinishedAndCapsAtThree() throws {
        let context = TestContainerFactory.makeContext()
        let store = TenXStore(context: context)

        let todayKey = DayKey.make()
        let yesterdayKey = DayKey.previous(dayKey: todayKey)

        let drafts = [
            TenXStore.FocusDraft(title: "One", carriedFromDayKey: nil, tag: nil),
            TenXStore.FocusDraft(title: "Two", carriedFromDayKey: nil, tag: nil),
            TenXStore.FocusDraft(title: "Three", carriedFromDayKey: nil, tag: nil)
        ]

        try store.createDayEntry(todayKey: yesterdayKey, drafts: drafts)
        let yesterday = try XCTUnwrap(store.fetchDayEntry(dayKey: yesterdayKey))
        if let first = yesterday.sortedFocuses.first {
            try store.toggleCompletion(first)
        }

        let extra = DailyFocus(title: "Extra", sortOrder: 3)
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

        let longTitle = String(repeating: "B", count: AppConstants.maxFocusTitleLength + 1)
        let drafts = [
            TenXStore.FocusDraft(title: longTitle, carriedFromDayKey: nil, tag: nil),
            TenXStore.FocusDraft(title: "Two", carriedFromDayKey: nil, tag: nil),
            TenXStore.FocusDraft(title: "Three", carriedFromDayKey: nil, tag: nil)
        ]

        XCTAssertThrowsError(try store.createDayEntry(todayKey: DayKey.make(), drafts: drafts))
    }
}
