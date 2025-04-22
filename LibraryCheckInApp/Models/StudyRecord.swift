import Foundation

struct StudyRecord: Identifiable, Codable {
    var id = UUID()
    var location: String
    var date: Date
    var note: String
    var timestamp: Date
    
    init(location: String, date: Date, note: String) {
        self.location = location
        self.date = date
        self.note = note
        self.timestamp = Date()
    }
} 