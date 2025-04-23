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
    @State private var isContentLoaded = false
    
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
    
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if isContentLoaded {
                    VStack(spacing: 16) {
                        // 時鐘
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
                        
                        // 位置選擇
                        LocationPickerView(selectedLocation: $selectedLocation)
                            .transition(.move(edge: .leading))
                        
                        // 時間選擇
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
                        
                        // 備註
                        TextField("備註：今天學習了什麼？", text: $studyNote)
                            .padding(16)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .transition(.move(edge: .trailing))
                        
                        // 打卡按鈕
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                recordManager.addRecord(
                                    location: selectedLocation,
                                    date: studyDate,
                                    note: studyNote
                                )
                                isRecordSaved = true
                                notificationMessage = "學習記錄成功！"
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
                        }) {
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
                        
                        // 統計
                        VStack(alignment: .leading, spacing: 12) {
                            Text("學習統計")
                                .font(.system(size: 17, weight: .semibold))
                            
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
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                        .transition(.move(edge: .bottom))
                    }
                    .padding(16)
                    .animation(.easeInOut(duration: 0.5).delay(0.1), value: isContentLoaded)
                }
            }
            .onReceive(timer) { _ in
                currentTime = Date()
            }
            .overlay(
                Group {
                    if showingNotification {
                        VStack {
                            Text(notificationMessage)
                                .padding()
                                .background(Color("SuccessColor"))
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
            )
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
}
