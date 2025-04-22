import SwiftUI
import Charts

struct StatsView: View {
    @StateObject private var recordManager = StudyRecordManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // 學習趨勢卡片
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("學習趨勢")
                                .font(.system(size: 17, weight: .semibold))
                            
                            if #available(iOS 16.0, *) {
                                ChartView(recordManager: recordManager)
                                    .frame(height: 200)
                            } else {
                                LegacyChartView()
                                    .frame(height: 200)
                            }
                            
                            Text("顯示最近30天到館記錄統計")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    
                    // 學習分析卡片
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("學習分析")
                                .font(.system(size: 17, weight: .semibold))
                            
                            let currentMonth = recordManager.getCurrentMonthRecords().count
                            let totalDaysInMonth = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
                            let currentDay = Calendar.current.component(.day, from: Date())
                            let attendanceRate = Int((Double(currentMonth) / Double(min(currentDay, totalDaysInMonth))) * 100)
                            
                            StatGridView(stats: [
                                ("\(currentMonth)", "本月到館"),
                                ("\(attendanceRate)%", "出席率"),
                                ("\(recordManager.getCurrentStreak())", "連續天數"),
                                ("\(recordManager.getLongestStreak())", "最長連續")
                            ])
                        }
                    }
                    
                    // 到館時段分析卡片
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("到館時段分析")
                                .font(.system(size: 17, weight: .semibold))
                            
                            let timeDistribution = recordManager.getTimeDistribution()
                            let total = timeDistribution.morning + timeDistribution.afternoon + timeDistribution.evening
                            
                            // 避免除以0
                            let morningPercent = total > 0 ? Int((Double(timeDistribution.morning) / Double(total)) * 100) : 0
                            let afternoonPercent = total > 0 ? Int((Double(timeDistribution.afternoon) / Double(total)) * 100) : 0
                            let eveningPercent = total > 0 ? Int((Double(timeDistribution.evening) / Double(total)) * 100) : 0
                            
                            HStack(alignment: .center, spacing: 0) {
                                VStack {
                                    Text("\(morningPercent)%")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.appPrimary)
                                    
                                    Text("上午")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                
                                VStack {
                                    Text("\(afternoonPercent)%")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.appPrimary)
                                    
                                    Text("下午")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                
                                VStack {
                                    Text("\(eveningPercent)%")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.appPrimary)
                                    
                                    Text("晚上")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .padding(.bottom, 16)
            }
            .background(Color.appBackground.edgesIgnoringSafeArea(.all))
            .navigationTitle("學習統計")
        }
    }
}

@available(iOS 16.0, *)
struct ChartView: View {
    let recordManager: StudyRecordManager
    
    private var chartData: [ChartItem] {
        var data = [ChartItem]()
        let calendar = Calendar.current
        let endDate = Date()
        
        for day in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -day, to: endDate)!
            let hasRecord = !recordManager.getRecordsByDate(date).isEmpty
            data.append(ChartItem(date: date, hasRecord: hasRecord ? 1 : 0))
        }
        
        return data.reversed()
    }
    
    var body: some View {
        Chart {
            ForEach(chartData) { item in
                LineMark(
                    x: .value("日期", item.date, unit: .day),
                    y: .value("記錄", item.hasRecord)
                )
                .foregroundStyle(Color.appPrimary)
                .symbol(.circle)
            }
            
            RuleMark(y: .value("記錄", 0))
                .foregroundStyle(.gray.opacity(0.3))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 5)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.day().month())
            }
        }
        .chartYAxis {
            AxisMarks(values: [0, 1]) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if value.index == 1 {
                        Text("有")
                    } else {
                        Text("無")
                    }
                }
            }
        }
    }
}

struct LegacyChartView: View {
    var body: some View {
        VStack {
            Image(systemName: "chart.line")
                .font(.system(size: 48))
                .foregroundColor(Color(.systemGray4))
            
            Text("iOS 16及以上版本提供更詳細圖表")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(AppTheme.smallCornerRadius)
    }
}

struct ChartItem: Identifiable {
    let id = UUID()
    let date: Date
    let hasRecord: Int
} 