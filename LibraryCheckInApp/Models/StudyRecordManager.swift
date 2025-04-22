import Foundation
import SwiftUI

class StudyRecordManager: ObservableObject {
    @Published var records: [StudyRecord] = []
    
    private let recordsKey = "studyRecords"
    
    init() {
        loadRecords()
    }
    
    // 加載記錄
    func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: recordsKey) {
            if let decoded = try? JSONDecoder().decode([StudyRecord].self, from: data) {
                records = decoded
            }
        }
    }
    
    // 保存記錄
    func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: recordsKey)
        }
    }
    
    // 添加記錄
    func addRecord(location: String, date: Date, note: String) {
        let newRecord = StudyRecord(location: location, date: date, note: note)
        records.append(newRecord)
        saveRecords()
    }
    
    // 獲取本月記錄
    func getCurrentMonthRecords() -> [StudyRecord] {
        let calendar = Calendar.current
        let now = Date()
        
        return records.filter { record in
            calendar.isDate(record.date, equalTo: now, toGranularity: .month) &&
            calendar.isDate(record.date, equalTo: now, toGranularity: .year)
        }
    }
    
    // 獲取特定日期的記錄
    func getRecordsForDate(_ date: Date) -> [StudyRecord] {
        let calendar = Calendar.current
        
        return records.filter { record in
            calendar.isDate(record.date, inSameDayAs: date)
        }
    }
    
    // 獲取最近記錄
    func getRecentRecords(limit: Int = 5) -> [StudyRecord] {
        return Array(records.sorted(by: { $0.date > $1.date }).prefix(limit))
    }
    
    // 計算當前連續天數
    func getCurrentStreak() -> Int {
        if records.isEmpty { return 0 }
        
        let calendar = Calendar.current
        
        // 按日期分組並排序
        let sortedDates = records.map { calendar.startOfDay(for: $0.date) }
            .sorted(by: >)
            .map { calendar.dateComponents([.year, .month, .day], from: $0) }
        
        // 獲取不重複日期
        var uniqueDates: [DateComponents] = []
        for date in sortedDates {
            if !uniqueDates.contains(where: { 
                $0.year == date.year && $0.month == date.month && $0.day == date.day 
            }) {
                uniqueDates.append(date)
            }
        }
        
        if uniqueDates.isEmpty { return 0 }
        
        // 檢查最近一天是否是今天或昨天
        let todayComp = calendar.dateComponents([.year, .month, .day], from: Date())
        let yesterdayComp = calendar.dateComponents(
            [.year, .month, .day], 
            from: calendar.date(byAdding: .day, value: -1, to: Date())!
        )
        
        let isRecentToday = uniqueDates[0].year == todayComp.year && 
                          uniqueDates[0].month == todayComp.month && 
                          uniqueDates[0].day == todayComp.day
        
        let isRecentYesterday = uniqueDates[0].year == yesterdayComp.year && 
                              uniqueDates[0].month == yesterdayComp.month && 
                              uniqueDates[0].day == yesterdayComp.day
                              
        if !isRecentToday && !isRecentYesterday {
            return 0
        }
        
        // 計算連續天數
        var streak = 1
        for i in 0..<uniqueDates.count-1 {
            let current = calendar.date(from: uniqueDates[i])!
            let next = calendar.date(from: uniqueDates[i+1])!
            
            let diff = calendar.dateComponents([.day], from: next, to: current).day!
            
            if diff == 1 {
                streak += 1
            } else {
                break
            }
        }
        
        return streak
    }
    
    // 計算最長連續天數
    func getLongestStreak() -> Int {
        if records.isEmpty { return 0 }
        
        let calendar = Calendar.current
        
        // 按日期分組並排序
        let sortedDates = records.map { calendar.startOfDay(for: $0.date) }
            .sorted()
            .map { calendar.dateComponents([.year, .month, .day], from: $0) }
        
        // 獲取不重複日期
        var uniqueDates: [DateComponents] = []
        for date in sortedDates {
            if !uniqueDates.contains(where: { 
                $0.year == date.year && $0.month == date.month && $0.day == date.day 
            }) {
                uniqueDates.append(date)
            }
        }
        
        if uniqueDates.isEmpty { return 0 }
        
        // 計算最長連續天數
        var currentStreak = 1
        var maxStreak = 1
        
        for i in 0..<uniqueDates.count-1 {
            let current = calendar.date(from: uniqueDates[i])!
            let next = calendar.date(from: uniqueDates[i+1])!
            
            let diff = calendar.dateComponents([.day], from: current, to: next).day!
            
            if diff == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    // 計算時段分佈
    func getTimeDistribution() -> (morning: Int, afternoon: Int, evening: Int) {
        let morning = records.filter { Calendar.current.component(.hour, from: $0.date) < 12 }.count
        let afternoon = records.filter { 
            let hour = Calendar.current.component(.hour, from: $0.date)
            return hour >= 12 && hour < 18
        }.count
        let evening = records.filter { Calendar.current.component(.hour, from: $0.date) >= 18 }.count
        
        return (morning, afternoon, evening)
    }
    
    // 獲取過去30天打卡情況
    func getLast30DaysData() -> [(date: Date, hasRecord: Bool)] {
        let calendar = Calendar.current
        var result: [(date: Date, hasRecord: Bool)] = []
        
        for i in (0..<30).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let startOfDay = calendar.startOfDay(for: date)
            let hasRecord = !getRecordsForDate(startOfDay).isEmpty
            
            result.append((date: startOfDay, hasRecord: hasRecord))
        }
        
        return result
    }
    
    // 計算出席率
    func getAttendanceRate() -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        // 本月天數
        let daysPassed = min(calendar.component(.day, from: now), calendar.range(of: .day, in: .month, for: now)?.count ?? 30)
        
        // 本月打卡天數
        let daysWithRecords = Set(
            getCurrentMonthRecords().map { 
                calendar.dateComponents([.year, .month, .day], from: $0.date)
            }
        ).count
        
        if daysPassed == 0 { return 0 }
        return Int((Double(daysWithRecords) / Double(daysPassed)) * 100)
    }
} 