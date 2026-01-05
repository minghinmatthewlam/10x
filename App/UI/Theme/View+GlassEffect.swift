import SwiftUI

extension View {
    @ViewBuilder
    func tenxGlassCard<S: Shape>(in shape: S) -> some View {
        if #available(iOS 26.0, *) {
            self
                .glassEffect(in: shape)
                .clipShape(shape)
        } else {
            self
                .background(AppColors.card)
                .clipShape(shape)
        }
    }
}
