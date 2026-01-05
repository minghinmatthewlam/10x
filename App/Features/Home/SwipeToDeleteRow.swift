import SwiftUI

struct SwipeToDeleteRow<Content: View>: View {
    private let openWidth: CGFloat = 92
    private let cornerRadius: CGFloat = 16
    private let action: () -> Void
    private let content: Content

    @State private var offset: CGFloat = 0
    @State private var isOpen = false
    @State private var rowSize: CGSize = .zero

    init(action: @escaping () -> Void,
         @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            actionBackground
            content
                .contentShape(Rectangle())
                .offset(x: offset)
                .background(rowSizeReader)
                .simultaneousGesture(dragGesture)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var actionBackground: some View {
        let width = max(0, min(maxDragWidth, -offset))
        return RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.red)
            .frame(width: width, height: rowSize.height)
            .overlay(alignment: .trailing) {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                        .font(.tenxIconSmall)
                    if width > 64 {
                        Text("Delete")
                            .font(.tenxTinyBold)
                    }
                }
                .foregroundStyle(.white)
                .padding(.trailing, 14)
                .opacity(width == 0 ? 0 : 1)
            }
            .opacity(width == 0 ? 0 : 1)
    }

    private var rowSizeReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: RowSizeKey.self, value: proxy.size)
        }
        .onPreferenceChange(RowSizeKey.self) { newSize in
            if rowSize != newSize {
                rowSize = newSize
            }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .local)
            .onChanged { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                let translation = value.translation.width
                if translation < 0 {
                    offset = max(translation, -maxDragWidth)
                } else if isOpen {
                    offset = min(translation - openWidth, 0)
                }
            }
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                let translation = value.translation.width
                let fullSwipeThreshold = max(rowSize.width * 0.6, openWidth * 1.4)
                let fullSwipe = -translation > fullSwipeThreshold
                let shouldOpen = -translation > openWidth * 0.5

                if fullSwipe {
                    action()
                    resetOffset()
                } else if shouldOpen {
                    openOffset()
                } else {
                    resetOffset()
                }
            }
    }

    private func openOffset() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            isOpen = true
            offset = -openWidth
        }
    }

    private func resetOffset() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            isOpen = false
            offset = 0
        }
    }

    private var maxDragWidth: CGFloat {
        rowSize.width > 0 ? rowSize.width : openWidth
    }
}

private struct RowSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
