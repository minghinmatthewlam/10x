import SwiftUI

struct FocusReorderDropDelegate: DropDelegate {
    let target: DailyFocus
    @Binding var items: [DailyFocus]
    @Binding var draggedItem: DailyFocus?
    @Binding var isReordering: Bool
    let onMoveCompleted: ([DailyFocus]) -> Void

    func dropEntered(info: DropInfo) {
        guard let draggedItem, draggedItem.uuid != target.uuid else { return }
        guard let fromIndex = items.firstIndex(where: { $0.uuid == draggedItem.uuid }),
              let toIndex = items.firstIndex(where: { $0.uuid == target.uuid }) else { return }
        isReordering = true
        withAnimation(.spring(response: 0.2, dampingFraction: 0.9)) {
            items.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        isReordering = false
        draggedItem = nil
        onMoveCompleted(items)
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}
