import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var pageTitle = "圖書館打卡"
    
    // 頁面標題對應
    private let pageTitles = ["圖書館打卡", "到館日曆", "學習統計"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 主內容區域
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(0)
                    
                    CalendarView()
                        .tag(1)
                    
                    StatsView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onChange(of: selectedTab) { oldTab,newTab in
                    pageTitle = pageTitles[newTab]
                }
                
                // 底部導航欄
                HStack {
                    TabButtonView(
                        title: "首頁",
                        icon: "house.fill",
                        isSelected: selectedTab == 0
                    ) {
                        selectedTab = 0
                    }
                    
                    TabButtonView(
                        title: "日曆",
                        icon: "calendar",
                        isSelected: selectedTab == 1
                    ) {
                        selectedTab = 1
                    }
                    
                    TabButtonView(
                        title: "統計",
                        icon: "chart.line.uptrend.xyaxis",
                        isSelected: selectedTab == 2
                    ) {
                        selectedTab = 2
                    }
                }
                .padding(.vertical, 8)
                .background(Color.white)
                .overlay(
                    Divider().opacity(0.3),
                    alignment: .top
                )
            }
            .navigationBarTitle(pageTitle, displayMode: .inline)
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            setupAppearance()
            
            // 請求通知許可
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
            
            // 設置定期提醒
            setupReminders()
        }
    }
    
    // 設置全局UI樣式
    private func setupAppearance() {
        // 定義主要顏色
        UINavigationBar.appearance().tintColor = UIColor(named: "PrimaryColor")
        
        // 導航欄背景
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = .systemBackground
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
    
    // 設置提醒
    private func setupReminders() {
        // 清除已有的提醒
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // 設置每天9點的提醒
        let content = UNMutableNotificationContent()
        content.title = "學習提醒"
        content.body = "別忘了今天去圖書館學習，保持連續打卡記錄！"
        content.sound = .default
        
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

// 底部標籤按鈕
struct TabButtonView: View {
    var title: String
    var icon: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                
                Text(title)
                    .font(.system(size: 10))
            }
            .foregroundColor(isSelected ? Color("PrimaryColor") : Color.gray)
            .frame(maxWidth: .infinity)
        }
    }
} 
