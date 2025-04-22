import SwiftUI

struct CalendarDayItemView: View {
    var day: Int?
    var isToday: Bool
    var hasRecord: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action: {
            if day != nil {
                onTap()
            }
        }) {
            ZStack {
                if isToday {
                    Circle()
                        .fill(Color("PrimaryColor"))
                        .frame(height: 35)
                } else if hasRecord {
                    Circle()
                        .stroke(Color("SuccessColor"), lineWidth: 2)
                        .frame(height: 35)
                } else {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(height: 35)
                }
                
                if let day = day {
                    Text("\(day)")
                        .font(.system(size: 14))
                        .foregroundColor(isToday ? .white : .primary)
                }
                
                if hasRecord && !isToday {
                    Text("✓")
                        .font(.system(size: 10))
                        .foregroundColor(Color("SuccessColor"))
                        .offset(x: 10, y: -10)
                } else if hasRecord && isToday {
                    Text("✓")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .offset(x: 10, y: -10)
                }
            }
        }
        .disabled(day == nil)
    }
} 