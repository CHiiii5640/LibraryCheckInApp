import SwiftUI

struct StudyRecordItemView: View {
    let record: StudyRecord
    var isToday: Bool = false
    var showStreak: Bool = false
    var streakCount: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatDate(record.date))
                    .font(.system(size: 15, weight: .medium))
                
                if isToday {
                    Text("（今天）")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                
                if showStreak && streakCount > 0 {
                    Spacer()
                    
                    Text("連續\(streakCount)天")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.appPrimary)
                        .cornerRadius(12)
                }
            }
            
            Text("到館時間：\(formatTime(record.date))")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            if let note = record.note, !note.isEmpty {
                Text("備註：\(note)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Rectangle()
                .fill(Color.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
                .overlay(
                    Rectangle()
                        .fill(Color.appPrimary)
                        .frame(width: 3)
                        .padding(.vertical, 8),
                    alignment: .leading
                )
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
} 