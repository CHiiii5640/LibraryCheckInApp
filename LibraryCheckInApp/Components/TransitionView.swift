import SwiftUI

struct TransitionView<Content: View>: View {
    @EnvironmentObject var transitionManager: TransitionManager
    @State private var isActive = false
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if isActive {
                content
                    .transition(transitionManager.getTransition())
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                isActive = true
            }
        }
    }
}

struct SlideTransition<Content: View>: View {
    @State private var isActive = false
    let direction: Edge
    let content: Content
    
    init(direction: Edge = .trailing, @ViewBuilder content: () -> Content) {
        self.direction = direction
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if isActive {
                content
                    .transition(.asymmetric(
                        insertion: .move(edge: direction),
                        removal: .move(edge: direction.opposite)
                    ))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                isActive = true
            }
        }
    }
}

extension Edge {
    var opposite: Edge {
        switch self {
        case .top: return .bottom
        case .leading: return .trailing
        case .bottom: return .top
        case .trailing: return .leading
        }
    }
} 