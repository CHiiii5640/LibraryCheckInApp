import SwiftUI

struct CalendarView: View {
    @StateObject private var recordManager = StudyRecordManager()
    @State private var selectedMonth = Date()
    @State private var selectedRecord: StudyRecord? = nil
    @State private var isShowingDetail = false
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "zh_Hant")
        return calendar
    }
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: selectedMonth)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // 日曆卡片
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(monthTitle)
                                    .font(.system(size: 17, weight: .semibold))
                                
                                Spacer()
                                
                                HStack(spacing: 16) {
                                    Button(action: previousMonth) {
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Button(action: nextMonth) {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            
                            // 星期標籤
                            HStack {
                                ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { day in
                                    Text(day)
                                        .font(.system(size: 14))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            
                            // 日曆網格
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                                ForEach(daysInMonth(), id: \.self) { day in
                                    if day.day != 0 {
                                        Button(action: {
                                            if day.hasRecord {
                                                showRecordForDay(day.date)
                                            }
                                        }) {
                                            Text("\(day.day)")
                                                .font(.system(size: 14))
                                                .foregroundColor(dayTextColor(day))
                                                .frame(height: 35)
                                                .frame(maxWidth: .infinity)
                                                .background(dayBackground(day))
                                                .cornerRadius(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(day.hasRecord ? Color.appSuccess : Color.clear, lineWidth: 2)
                                                )
                                        }
                                    } else {
                                        Text("")
                                            .frame(height: 35)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }
                    }
                    
                    // 最近記錄卡片
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("最近到館記錄")
                                .font(.system(size: 17, weight: .semibold))
                            
                            if recordManager.records.isEmpty {
                                Text("暫無學習記錄")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 24)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(recordManager.getRecentRecords()) { record in
                                        let isToday = calendar.isDateInToday(record.date)
                                        let showStreak = record == recordManager.getRecentRecords().first
                                        
                                        StudyRecordItemView(
                                            record: record,
                                            isToday: isToday,
                                            showStreak: showStreak,
                                            streakCount: showStreak ? recordManager.getCurrentStreak() : 0
                                        )
                                        .onTapGesture {
                                            selectedRecord = record
                                            isShowingDetail = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 16)
            }
            .background(Color.appBackground.edgesIgnoringSafeArea(.all))
            .navigationTitle("到館日曆")
            .sheet(isPresented: $isShowingDetail) {
                if let record = selectedRecord {
                    RecordDetailView(record: record)
                }
            }
        }
        .onAppear {
            selectedMonth = Date()
        }
    }
    
    private func daysInMonth() -> [CalendarDay] {
        var days = [CalendarDay]()
        
        let range = calendar.range(of: .day, in: .month, for: selectedMonth)!
        let numberOfDays = range.count
        
        // 計算該月第一天是星期幾
        let firstDay = calendar.component(.weekday, from: firstDayOfMonth())
        // 星期天為1，轉成星期一為0
        let firstWeekday = (firstDay + 5) % 7
        
        // 添加空白日
        for _ in 0..<firstWeekday {
            days.append(CalendarDay(day: 0, date: Date(), hasRecord: false))
        }
        
        // 添加日期
        for day in 1...numberOfDays {
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth())!
            let hasRecord = !recordManager.getRecordsByDate(date).isEmpty
            days.append(CalendarDay(day: day, date: date, hasRecord: hasRecord))
        }
        
        return days
    }
    
    private func firstDayOfMonth() -> Date {
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        return calendar.date(from: components)!
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func dayBackground(_ day: CalendarDay) -> Color {
        if calendar.isDateInToday(day.date) {
            return Color.appPrimary
        }
        return Color(.systemGray6)
    }
    
    private func dayTextColor(_ day: CalendarDay) -> Color {
        if calendar.isDateInToday(day.date) {
            return .white
        }
        return .primary
    }
    
    private func showRecordForDay(_ date: Date) {
        let records = recordManager.getRecordsByDate(date)
        if let record = records.first {
            selectedRecord = record
            isShowingDetail = true
        }
    }
}

struct CalendarDay: Hashable {
    let day: Int
    let date: Date
    let hasRecord: Bool
}

struct RecordDetailView: View {
    let record: StudyRecord
    @Environment(\.dismiss) private var dismiss
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 EEEE"
        formatter.locale = Locale(identifier: "zh_Hant")
        return formatter.string(from: record.date)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: record.date)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("日期")
                        Spacer()
                        Text(formattedDate)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("時間")
                        Spacer()
                        Text(formattedTime)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("位置")
                        Spacer()
                        Text(record.location)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let note = record.note, !note.isEmpty {
                    Section("備註") {
                        Text(note)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("學習記錄詳情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
} 