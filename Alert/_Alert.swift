import SwiftUI

struct _Alert<V>: ViewModifier where V: AlertView {

    // Binding
    @Binding var isPresented: Bool

    // Actions
    var onDismiss: () -> Void

    // ViewBuilder
    @ViewBuilder var view: V

    // State
    @State private var presentFullScreenCover: Bool = false
    @State private var animateView: Bool = false

    func body(content: Content) -> some SwiftUI.View {
        let screenHeight = screenSize.height
        let animateView = animateView

        GeometryReader { proxy in
            content
                .fullScreenCover(isPresented: $presentFullScreenCover, onDismiss: onDismiss) {
                    ZStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.5))
                            .ignoresSafeArea()
                            .opacity(animateView ? 1.0 : 0)

                        view
                            .onDismiss { isPresented = false }
                            .background(TransparentBackground())
                            .offset(y: offset(proxy, screenHeight, animateView))
                            .task {
                                guard !animateView else { return }
                                withAnimation(.bouncy(duration: 0.4, extraBounce: 0.05)) {
                                    self.animateView = true
                                }
                            }
                            .ignoresSafeArea(.container, edges: .all)
                            .padding(.horizontal, 16.0)
                    }
                }
                .onChange(of: isPresented) { value in
                    if value {
                        toggleView(true)
                    } else {
                        Task {
                            withAnimation(.snappy(duration: 0.45, extraBounce: 0)) {
                                self.animateView = false
                            }

                            await withCheckedContinuation { continuation in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                                    continuation.resume()
                                }
                            }

                            toggleView(false)
                        }
                    }
                }
        }
    }

    private func toggleView(_ status: Bool) {
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            presentFullScreenCover = status
        }
    }

    nonisolated private func offset(_ proxy: GeometryProxy,
                                    _ screenHeight: CGFloat,
                                    _ animateView: Bool) -> CGFloat {
        let height = proxy.size.height
        return animateView ? 0 : (height + screenHeight) / 2
    }

    private var screenSize: CGSize {
        if let screenSize = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.size {
            return screenSize
        }

        return .zero
    }
}