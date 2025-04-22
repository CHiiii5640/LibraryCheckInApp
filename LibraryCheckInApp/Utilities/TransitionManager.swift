import SwiftUI

// 定義過場動畫類型
enum TransitionType {
    case slide
    case fade
    case scale
}

// 過場動畫管理器
class TransitionManager: ObservableObject {
    @Published var activeTransition: TransitionType = .fade
    
    // 獲取當前選擇的過場動畫
    func getTransition() -> AnyTransition {
        switch activeTransition {
        case .slide:
            return AnyTransition.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        case .fade:
            return AnyTransition.opacity.combined(with: .scale(scale: 0.95))
        case .scale:
            return AnyTransition.scale(scale: 0.9).combined(with: .opacity)
        }
    }
    
    // 設置過場動畫類型
    func setTransition(_ type: TransitionType) {
        withAnimation {
            self.activeTransition = type
        }
    }
}

// 視圖修飾符，用於應用動畫
struct TransitionModifier: ViewModifier {
    let transition: AnyTransition
    let animation: Animation
    
    func body(content: Content) -> some View {
        content
            .transition(transition)
            .animation(animation, value: UUID())
    }
}

// 擴展視圖以添加轉場方法
extension View {
    func withTransition(_ transition: AnyTransition, animation: Animation = .easeInOut(duration: 0.3)) -> some View {
        self.modifier(TransitionModifier(transition: transition, animation: animation))
    }
} 