import SwiftUI
import UIKit
import AudioToolbox

/// 震動回饋類型
enum Vibration {
    case error, success, warning
    // 輕重程度回饋
    case light, medium, heavy, soft, rigid
    // 選擇器切換震動
    case selection
    case oldSchool

    public func vibrate() {
        // Debug: 印出目前觸發的震動類型
        print("Triggering vibration: \(self)")
        switch self {
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .soft:
            guard #available(iOS 13.0, *) else { return }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        case .rigid:
            guard #available(iOS 13.0, *) else { return }
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .oldSchool:
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var recordManager: StudyRecordManager
    @EnvironmentObject var transitionManager: TransitionManager
    @State private var selectedLocation = "校區中央圖書館"
    @State private var studyDate = Date()
    @State private var studyNote = ""
    @State private var isRecordSaved = false
    @State private var showingNotification = false
    @State private var notificationMessage = ""
    @State private var notificationType: NotificationType = .success
    @State private var isContentLoaded = false
    
    // 計時器
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private enum NotificationType {
        case success
        case warning
        
        var color: Color {
            switch self {
            case .success:
                return Color("SuccessColor")
            case .warning:
                return Color.orange
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 EEEE"
        formatter.locale = Locale(identifier: "zh_Hant")
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.locale = Locale(identifier: "zh_Hant")
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if isContentLoaded {
                    mainContentView
                }
            }
            .onReceive(timer) { _ in
                currentTime = Date()
            }
            .overlay(notificationOverlay)
            .navigationTitle("圖書館打卡")
            .onAppear {
                // 延遲載入內容以顯示動畫
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isContentLoaded = true
                    }
                }
            }
        }
    }
    
    // MARK: - 子視圖
    
    // 主內容視圖
    private var mainContentView: some View {
        VStack(spacing: 16) {
            clockView
            
            // 位置選擇
            LocationPickerView(selectedLocation: $selectedLocation)
                .transition(.move(edge: .leading))
            
            timePickerView
            notesField
            checkInButton
            statisticsView
        }
        .padding(16)
        .animation(.easeInOut(duration: 0.5).delay(0.1), value: isContentLoaded)
    }
    
    // 時鐘視圖
    private var clockView: some View {
        VStack(spacing: 8) {
            Text(timeFormatter.string(from: currentTime))
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Color("PrimaryColor"))
                .transition(.scale.combined(with: .opacity))
            
            Text(dateFormatter.string(from: currentTime))
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .transition(.opacity)
        }
        .padding(.vertical, 24)
        .transition(.scale.combined(with: .opacity))
    }
    
    // 時間選擇視圖
    private var timePickerView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("學習時間")
                .font(.system(size: 15, weight: .medium))
            
            HStack {
                DatePicker(
                    "",
                    selection: Binding<Date>(
                        get: { self.studyDate },
                        set: { self.studyDate = $0 }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                
                Button(action: {
                    studyDate = Date()
                }) {
                    Text("現在")
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .transition(.move(edge: .trailing))
    }
    
    // 備註輸入框
    private var notesField: some View {
        TextField("備註：今天學習了什麼？", text: $studyNote)
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .transition(.move(edge: .trailing))
    }
    
    // 打卡按鈕
    private var checkInButton: some View {
        Button(action: handleCheckIn) {
            HStack {
                Image(systemName: "book.closed.fill")
                Text(isRecordSaved ? "已記錄學習" : "記錄學習")
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isRecordSaved ? Color.gray : Color("SuccessColor"))
            .cornerRadius(24)
        }
        .disabled(isRecordSaved)
        .scaleEffect(isRecordSaved ? 0.95 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isRecordSaved)
        .transition(.scale.combined(with: .opacity))
    }
    
    // 統計視圖
    private var statisticsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("學習統計")
                .font(.system(size: 17, weight: .semibold))
            
            statisticsGrid
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .transition(.move(edge: .bottom))
    }
    
    // 統計資料表格
    private var statisticsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatItemView(
                value: "\(recordManager.getCurrentMonthRecords().count)",
                label: "本月到館次數"
            )
            
            StatItemView(
                value: "\(recordManager.getCurrentStreak())",
                label: "目前連續天數"
            )
            
            StatItemView(
                value: "\(recordManager.records.count)",
                label: "本學期總次數"
            )
            
            StatItemView(
                value: "\(recordManager.getLongestStreak())",
                label: "最長連續記錄"
            )
        }
    }
    
    // 通知覆蓋層
    private var notificationOverlay: some View {
        Group {
            if showingNotification {
                VStack {
                    Text(notificationMessage)
                        .padding()
                        .background(notificationType.color)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.top, 16)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showingNotification = false
                                }
                            }
                        }
                    
                    Spacer()
                }
                .transition(.move(edge: .top))
                .animation(.easeInOut, value: showingNotification)
            }
        }
    }
        
    // 處理打卡操作
    private func handleCheckIn() {
        // 檢查選擇的時間是否小於當前時間
        let currentDate = Date()
        
        if studyDate > currentDate {
            // 如果選擇的時間大於當前時間，顯示警告
            notificationMessage = "無法選擇未來時間進行打卡！"
            notificationType = .warning
            showingNotification = true
            Vibration.warning.vibrate()
        } else if studyDate < currentDate.addingTimeInterval(-600) {
            notificationMessage = "只能記錄10分鐘內的學習時間！"
            notificationType = .warning
            showingNotification = true
            Vibration.warning.vibrate()
        } else {
            // 正常記錄學習時間
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                // 創建新的學習記錄
                let newRecord = StudyRecord(
                    location: selectedLocation,
                    date: studyDate,
                    note: studyNote
                )
                
                // 添加記錄
                recordManager.addRecord(newRecord)
                
                isRecordSaved = true
                notificationMessage = "學習記錄成功！"
                notificationType = .success
                showingNotification = true
                studyNote = ""
                Vibration.success.vibrate()
                
                // 5秒後重置按鈕
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation {
                        isRecordSaved = false
                    }
                }
            }
        }
    }
}
