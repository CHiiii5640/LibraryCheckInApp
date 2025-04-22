import SwiftUI

struct PageTransition: ViewModifier {
    @State private var isActive = false
    let animation: Animation

    init(animation: Animation = .easeInOut(duration: 0.3)) {
        self.animation = animation
    }

    func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(isActive ? 1 : 0)
                .scaleEffect(isActive ? 1 : 0.95)
        }
        .onAppear {
            withAnimation(animation) {
                isActive = true
            }
        }
    }
}

struct NavigationTransition<Content: View>: View {
    @State private var isActive = false
    let animation: Animation
    let content: () -> Content

    init(animation: Animation = .easeInOut(duration: 0.3), @ViewBuilder content: @escaping () -> Content) {
        self.animation = animation
        self.content = content
    }

    var body: some View {
        NavigationView {
            ZStack {
                if isActive {
                    content()
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .onAppear {
                withAnimation(animation) {
                    isActive = true
                }
            }
        }
    }
}

extension View {
    func withPageTransition(animation: Animation = .easeInOut(duration: 0.3)) -> some View {
        self.modifier(PageTransition(animation: animation))
    }
}
