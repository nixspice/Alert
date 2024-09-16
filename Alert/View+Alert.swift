import SwiftUI

public protocol AlertView: SwiftUI.View {
    func onDismiss(with: @escaping () -> Void) -> Self
}

public extension SwiftUI.View {
    @ViewBuilder
    func showAlert<Content: AlertView>(_ isPresented: Binding<Bool>,
                                       onDismiss: @escaping () -> Void = {},
                                       @ViewBuilder content: @escaping () -> Content) -> some SwiftUI.View {
        self
            .modifier(
                _Alert(isPresented: isPresented,
                       onDismiss: onDismiss,
                       view: content)
            )
    }
}