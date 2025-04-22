import SwiftUI

@main
struct LibraryCheckInAppApp: App {
    @StateObject private var transitionManager = TransitionManager()
    @StateObject private var recordManager = StudyRecordManager()
    @State private var isShowingSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isShowingSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                } else {
                    MainTabView()
                        .environmentObject(transitionManager)
                        .environmentObject(recordManager)
                        .transition(transitionManager.getTransition())
                        .zIndex(0)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: isShowingSplash)
            .onAppear {
                // 2秒後隱藏啟動畫面
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        isShowingSplash = false
                    }
                }
            }
        }
    }
}

// 啟動畫面視圖
struct SplashScreenView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "book.closed")
                    .font(.system(size: 80))
                    .foregroundColor(Color("AppPrimaryColor"))
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                
                Text("圖書館打卡")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("AppPrimaryColor"))
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                isAnimating = true
            }
        }
    }
} 
