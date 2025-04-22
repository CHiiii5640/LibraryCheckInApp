import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var recordManager: StudyRecordManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 學習趨勢
                VStack(alignment: .leading, spacing: 12) {
                    Text("學習趨勢")
                        .font(.system(size: 17, weight: .semibold))
                    
                    if #available(iOS 16.0, *) {
                        TrendChartView(data: recordManager.getLast30DaysData())
                            .frame(height: 200)
                    } else {
                        // iOS 16 前的備用視圖
                        LegacyTrendChartView(data: recordManager.getLast30DaysData())
                            .frame(height: 200)
                    }
                    
                    Text("顯示最近30天到館記錄統計")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                
                // 學習分析
                VStack(alignment: .leading, spacing: 12) {
                    Text("學習分析")
                        .font(.system(size: 17, weight: .semibold))
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        StatItemView(
                            value: "\(recordManager.getCurrentMonthRecords().count)",
                            label: "本月到館"
                        )
                        
                        StatItemView(
                            value: "\(recordManager.getAttendanceRate())%",
                            label: "出席率"
                        )
                        
                        StatItemView(
                            value: "\(recordManager.getCurrentStreak())",
                            label: "連續天數"
                        )
                        
                        StatItemView(
                            value: "\(recordManager.getLongestStreak())",
                            label: "最長連續"
                        )
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                
                // 到館時段分析
                VStack(alignment: .leading, spacing: 12) {
                    Text("到館時段分析")
                        .font(.system(size: 17, weight: .semibold))
                    
                    HStack(spacing: 0) {
                        let distribution = recordManager.getTimeDistribution()
                        let total = distribution.morning + distribution.afternoon + distribution.evening
                        
                        let morningPercent = total > 0 ? Int((Double(distribution.morning) / Double(total)) * 100) : 0
                        let afternoonPercent = total > 0 ? Int((Double(distribution.afternoon) / Double(total)) * 100) : 0
                        let eveningPercent = total > 0 ? Int((Double(distribution.evening) / Double(total)) * 100) : 0
                        
                        VStack {
                            Text("\(morningPercent)%")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(Color("PrimaryColor"))
                            
                            Text("上午")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("\(afternoonPercent)%")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(Color("PrimaryColor"))
                            
                            Text("下午")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("\(eveningPercent)%")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(Color("PrimaryColor"))
                            
                            Text("晚上")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 8)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            }
            .padding(16)
        }
    }
}

// iOS 16+ 使用新的 Charts 框架
@available(iOS 16.0, *)
struct TrendChartView: View {
    var data: [(date: Date, hasRecord: Bool)]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    private let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "zh_Hant")
        return formatter
    }()
    
    var body: some View {
        Chart {
            ForEach(data.indices, id: \.self) { index in
                LineMark(
                    x: .value("日期", data[index].date),
                    y: .value("記錄", data[index].hasRecord ? 1 : 0)
                )
                .foregroundStyle(Color("PrimaryColor"))
                .symbol {
                    if data[index].hasRecord {
                        Circle()
                            .fill(Color("PrimaryColor"))
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 5)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(dateFormatter.string(from: date))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 1]) { value in
                AxisValueLabel {
                    if value.as(Int.self) == 1 {
                        Text("有")
                    } else {
                        Text("無")
                    }
                }
            }
        }
    }
}

// 舊版 iOS 的簡易圖表视圖
struct LegacyTrendChartView: View {
    var data: [(date: Date, hasRecord: Bool)]
    
    private let calendar = Calendar.current
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景網格
                VStack(spacing: 0) {
                    Divider()
                    Spacer()
                    Divider()
                }
                
                // 數據點和連接線
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let stepX = width / CGFloat(data.count - 1)
                    
                    var startPoint = true
                    
                    for i in 0..<data.count {
                        let x = CGFloat(i) * stepX
                        let y = data[i].hasRecord ? height * 0.2 : height * 0.8
                        
                        if startPoint {
                            path.move(to: CGPoint(x: x, y: y))
                            startPoint = false
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color("PrimaryColor"), lineWidth: 2)
                
                // 數據點
                ForEach(0..<data.count, id: \.self) { i in
                    if data[i].hasRecord {
                        Circle()
                            .fill(Color("PrimaryColor"))
                            .frame(width: 8, height: 8)
                            .position(
                                x: CGFloat(i) * (geometry.size.width / CGFloat(data.count - 1)),
                                y: geometry.size.height * 0.2
                            )
                    }
                }
                
                // X軸標籤
                HStack(spacing: 0) {
                    ForEach(0..<6) { i in
                        let index = i * 5
                        if index < data.count {
                            Text("\(calendar.component(.day, from: data[index].date))")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height - 10)
                
                // Y軸標籤
                VStack {
                    Text("有")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("無")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .position(x: 15, y: geometry.size.height / 2)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
} 