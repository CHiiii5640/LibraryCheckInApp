import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var recordManager: StudyRecordManager
    @State private var selectedMonth = Date()
    
    private let calendar = Calendar.current
    private let weekdays = ["一", "二", "三", "四", "五", "六", "日"]
    
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "zh_Hant")
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 日曆
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(monthFormatter.string(from: selectedMonth))
                            .font(.system(size: 17, weight: .semibold))
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.primary)
                        }
                        
                        Button(action: {
                            withAnimation {
                                selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    // 星期頭
                    HStack(spacing: 0) {
                        ForEach(weekdays, id: \.self) { weekday in
                            Text(weekday)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // 日曆網格
                    let days = getDaysInMonth()
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(0..<days.count, id: \.self) { index in
                            if let day = days[index] {
                                let date = getDate(forDay: day)
                                let hasRecord = !recordManager.getRecordsForDate(date).isEmpty
                                let isToday = calendar.isDateInToday(date)
                                
                                CalendarDayItemView(
                                    day: day,
                                    isToday: isToday,
                                    hasRecord: hasRecord,
                                    onTap: {
                                        showDayDetails(forDay: day)
                                    }
                                )
                            } else {
                                CalendarDayItemView(
                                    day: nil,
                                    isToday: false,
                                    hasRecord: false,
                                    onTap: {}
                                )
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                
                // 最近記錄
                VStack(alignment: .leading, spacing: 12) {
                    Text("最近到館記錄")
                        .font(.system(size: 17, weight: .semibold))
                    
                    VStack(spacing: 8) {
                        let recentRecords = recordManager.getRecentRecords()
                        let streak = recordManager.getCurrentStreak()
                        
                        if recentRecords.isEmpty {
                            Text("暫無學習記錄")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                        } else {
                            ForEach(Array(recentRecords.enumerated()), id: \.element.id) { index, record in
                                let isToday = calendar.isDateInToday(record.date)
                                
                                StudyRecordItemView(
                                    record: record,
                                    isToday: isToday,
                                    showStreak: index == 0,
                                    streakCount: streak
                                )
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            }
            .padding(16)
        }
    }
    
    // 獲取選定月份的天數數組
    private func getDaysInMonth() -> [Int?] {
        let range = calendar.range(of: .day, in: .month, for: selectedMonth)!
        let numDays = range.count
        
        let firstDay = calendar.component(.weekday, from: calendar.dateInterval(of: .month, for: selectedMonth)!.start)
        // 將週日(1)轉換為週日(7)，使週一為1
        let firstWeekday = firstDay == 1 ? 7 : firstDay - 1
        
        var days = Array(repeating: nil as Int?, count: 42) // 6週 x 7天
        
        for day in 1...numDays {
            let index = day + firstWeekday - 2
            days[index] = day
        }
        
        return days
    }
    
    // 根據日期獲取完整日期
    private func getDate(forDay day: Int) -> Date {
        var components = calendar.dateComponents([.year, .month], from: selectedMonth)
        components.day = day
        return calendar.date(from: components)!
    }
    
    // 顯示某天詳情
    private func showDayDetails(forDay day: Int) {
        let date = getDate(forDay: day)
        let records = recordManager.getRecordsForDate(date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月d日"
        dateFormatter.locale = Locale(identifier: "zh_Hant")
        
        let dateString = dateFormatter.string(from: date)
        
        if records.isEmpty {
            // 沒有記錄，使用系統提示框
            let alertController = UIAlertController(
                title: "\(dateString) 沒有學習記錄",
                message: nil,
                preferredStyle: .alert
            )
            
            alertController.addAction(UIAlertAction(title: "確定", style: .default))
            
            UIApplication.shared.windows.first?.rootViewController?.present(
                alertController, animated: true)
        } else {
            // 有記錄，顯示詳情
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            timeFormatter.locale = Locale(identifier: "zh_Hant")
            
            var message = ""
            for (index, record) in records.enumerated() {
                let timeString = timeFormatter.string(from: record.date)
                message += "\(index + 1). 時間：\(timeString)\n   位置：\(record.location)\n   備註：\(record.note.isEmpty ? "無" : record.note)\n\n"
            }
            
            let alertController = UIAlertController(
                title: "\(dateString) 學習記錄",
                message: message,
                preferredStyle: .alert
            )
            
            alertController.addAction(UIAlertAction(title: "確定", style: .default))
            
            UIApplication.shared.windows.first?.rootViewController?.present(
                alertController, animated: true)
        }
    }
} 