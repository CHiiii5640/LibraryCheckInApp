import SwiftUI

struct StatItemView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.appPrimary)
            
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(AppTheme.smallCornerRadius)
    }
}

struct StatGridView: View {
    let stats: [(value: String, label: String)]
    let columns: Int
    
    init(stats: [(value: String, label: String)], columns: Int = 2) {
        self.stats = stats
        self.columns = columns
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: columns), spacing: 12) {
            ForEach(0..<stats.count, id: \.self) { index in
                StatItemView(value: stats[index].value, label: stats[index].label)
            }
        }
    }
} 