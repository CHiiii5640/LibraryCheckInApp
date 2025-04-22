import Foundation

struct StudyRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var location: String
    var date: Date
    var note: String?
    var timestamp: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case id, location, date, note, timestamp
    }
}

class StudyRecordManager: ObservableObject {
    @Published var records: [StudyRecord] = []
    
    private let saveKey = "studyRecords"
    
    init() {
        loadRecords()
    }
    
    func addRecord(_ record: StudyRecord) {
        records.append(record)
        saveRecords()
    }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([StudyRecord].self, from: data) {
                records = decoded
                return
            }
        }
        
        records = []
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    // 獲取最近記錄
    func getRecentRecords(limit: Int = 5) -> [StudyRecord] {
        let sorted = records.sorted { $0.date > $1.date }
        return Array(sorted.prefix(limit))
    }
    
    // 獲取當前月的記錄
    func getCurrentMonthRecords() -> [StudyRecord] {
        let calendar = Calendar.current
        return records.filter { record in
            let components = calendar.dateComponents([.year, .month], from: record.date)
            let currentComponents = calendar.dateComponents([.year, .month], from: Date())
            return components.year == currentComponents.year && components.month == currentComponents.month
        }
    }
    
    // 計算當前連續天數
    func getCurrentStreak() -> Int {
        if records.isEmpty { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // 轉換所有記錄到日期（移除時間）
        let recordDates = Set(records.map { calendar.startOfDay(for: $0.date) })
        
        // 檢查今天或昨天是否有記錄
        if !recordDates.contains(today) && !recordDates.contains(yesterday) {
            return 0 // 如果最近一天不是今天或昨天，連續記錄中斷
        }
        
        // 從今天開始往回計算連續天數
        var streak = 0
        var checkDate = today
        
        if recordDates.contains(today) {
            streak += 1
            checkDate = yesterday
        } else {
            checkDate = today
        }
        
        while true {
            if recordDates.contains(checkDate) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
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
        
        // 轉換所有記錄到日期（移除時間）
        let allDates = records.map { calendar.startOfDay(for: $0.date) }
            .sorted()
            .map { calendar.dateComponents([.year, .month, .day], from: $0) }
        
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 0..<allDates.count-1 {
            let currentDate = calendar.date(from: allDates[i])!
            let nextDate = calendar.date(from: allDates[i+1])!
            
            let days = calendar.dateComponents([.day], from: currentDate, to: nextDate).day!
            
            if days == 1 {
                currentStreak += 1
                maxStreak = max(currentStreak, maxStreak)
            } else if days > 1 {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    // 獲取特定日期的記錄
    func getRecordsByDate(_ date: Date) -> [StudyRecord] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return records.filter { record in
            record.date >= startOfDay && record.date < endOfDay
        }
    }
    
    // 計算時段分佈
    func getTimeDistribution() -> (morning: Int, afternoon: Int, evening: Int) {
        var morning = 0
        var afternoon = 0
        var evening = 0
        
        for record in records {
            let hour = Calendar.current.component(.hour, from: record.date)
            if hour < 12 {
                morning += 1
            } else if hour < 18 {
                afternoon += 1
            } else {
                evening += 1
            }
        }
        
        return (morning, afternoon, evening)
    }
} 