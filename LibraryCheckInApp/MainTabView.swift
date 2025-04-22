import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var transitionManager: TransitionManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("首頁", systemImage: "house")
                }
                .tag(0)
            
            CalendarView()
                .tabItem {
                    Label("日曆", systemImage: "calendar")
                }
                .tag(1)
            
            StatsView()
                .tabItem {
                    Label("統計", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
        }
        .accentColor(Color("PrimaryColor"))
        .onChange(of: selectedTab) { oldValue, newValue in
            // 當切換標籤時，使用不同的過場動畫
            if oldValue < newValue {
                transitionManager.setTransition(.slide)
            } else {
                transitionManager.setTransition(.fade)
            }
        }
    }
} 