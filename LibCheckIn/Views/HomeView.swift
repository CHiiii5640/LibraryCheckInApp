import SwiftUI

struct HomeView: View {
    @StateObject private var recordManager = StudyRecordManager()
    @State private var selectedLocation = StudyLocation.default
    @State private var studyDate = Date()
    @State private var studyNote = ""
    @State private var isShowingSuccess = false
    
    private var isCheckedInToday: Bool {
        !recordManager.getRecordsByDate(Date()).isEmpty
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 EEEE"
        formatter.locale = Locale(identifier: "zh_Hant")
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // 時鐘區域
                    CardView {
                        VStack(spacing: 8) {
                            Text(formattedTime)
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.appPrimary)
                                .monospacedDigit()
                                .onAppear {
                                    // 創建計時器更新時間
                                    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                                        // 強制更新視圖
                                        withAnimation {
                                            studyDate = Date()
                                        }
                                    }
                                    timer.tolerance = 0.1
                                }
                            
                            Text(formattedDate)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        
                        // 位置選擇
                        LocationPicker(selectedLocation: $selectedLocation)
                            .padding(.bottom, 16)
                        
                        // 學習時間選擇
                        VStack(alignment: .leading, spacing: 5) {
                            Text("學習時間")
                                .font(.system(size: 15, weight: .medium))
                            
                            HStack {
                                DatePicker("", selection: $studyDate)
                                    .labelsHidden()
                                
                                Button(action: {
                                    studyDate = Date()
                                }) {
                                    Text("現在")
                                        .font(.system(size: 13))
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 7)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(AppTheme.smallCornerRadius)
                        
                        // 備註
                        TextField("備註：今天學習了什麼？", text: $studyNote)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(AppTheme.smallCornerRadius)
                            .padding(.vertical, 16)
                        
                        // 打卡按鈕
                        Button(action: recordStudy) {
                            HStack {
                                Image(systemName: "book.closed")
                                Text("記錄學習")
                            }
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isCheckedInToday ? Color(.systemGray) : Color.appSuccess)
                            .cornerRadius(24)
                        }
                        .disabled(isCheckedInToday)
                    }
                    
                    // 統計卡片
                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("學習統計")
                                .font(.system(size: 17, weight: .semibold))
                            
                            StatGridView(stats: [
                                ("\(recordManager.getCurrentMonthRecords().count)", "本月到館次數"),
                                ("\(recordManager.getCurrentStreak())", "目前連續天數"),
                                ("\(recordManager.records.count)", "本學期總次數"),
                                ("\(recordManager.getLongestStreak())", "最長連續記錄")
                            ])
                        }
                    }
                }
                .padding(.bottom, 16)
            }
            .background(Color.appBackground.edgesIgnoringSafeArea(.all))
            .navigationTitle("圖書館打卡")
            .alert("學習記錄成功！", isPresented: $isShowingSuccess) {
                Button("確定", role: .cancel) { }
            } message: {
                Text("已記錄到 \(selectedLocation.name)")
            }
        }
    }
    
    private func recordStudy() {
        let record = StudyRecord(
            location: selectedLocation.name,
            date: studyDate,
            note: studyNote.isEmpty ? nil : studyNote
        )
        
        recordManager.addRecord(record)
        studyNote = ""
        isShowingSuccess = true
    }
} 