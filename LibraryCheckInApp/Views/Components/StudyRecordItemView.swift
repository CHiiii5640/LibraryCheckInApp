import SwiftUI
// Removed unnecessary module import

struct StudyRecordItemView: View {
    var record: StudyRecord
    var isToday: Bool
    var showStreak: Bool
    var streakCount: Int
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "zh_Hant")
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "zh_Hant")
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(dateFormatter.string(from: record.date))
                    .font(.system(size: 15, weight: .medium))
                
                if isToday {
                    Text("（今天）")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                
                if showStreak && streakCount > 0 {
                    Spacer()
                    
                    Text("連續\(streakCount)天")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("PrimaryColor"))
                        .cornerRadius(12)
                }
            }
            
            Text("到館時間：\(timeFormatter.string(from: record.date))")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            Text("學習位置：\(record.location)")
                .foregroundColor(.secondary)
                .font(.system(size: 14))
            
            if !record.note.isEmpty {
                Text("備註：\(record.note)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            } else {
                Text("備註：無")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(.leading, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Rectangle()
                .fill(Color.clear)
                .overlay(
                    Rectangle()
                        .fill(Color("PrimaryColor"))
                        .frame(width: 2)
                        .padding(.vertical, 8),
                    alignment: .leading
                )
        )
    }
}
