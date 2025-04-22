import SwiftUI

struct LocationPickerView: View {
    @Binding var selectedLocation: String
    @State private var showingLocationPicker = false
    @State private var customLocation = ""
    
    let locations = [
        "校區中央圖書館",
        "理工學院圖書館",
        "社科院圖書館",
        "商學院圖書館",
        "醫學院圖書館",
        "法學院圖書館"
    ]
    
    let icons = [
        "book.fill",
        "flask.fill",
        "building.columns.fill",
        "chart.line.uptrend.xyaxis",
        "heart.fill",
        "scale.3d"
    ]
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color("PrimaryColor"))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "book.fill")
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("學習位置")
                    .font(.system(size: 15, weight: .medium))
                
                Text(selectedLocation)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Button(action: {
                showingLocationPicker = true
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showingLocationPicker) {
            NavigationView {
                List {
                    ForEach(0..<locations.count, id: \.self) { index in
                        Button(action: {
                            selectedLocation = locations[index]
                            showingLocationPicker = false
                        }) {
                            HStack {
                                Image(systemName: icons[index])
                                    .foregroundColor(Color("PrimaryColor"))
                                Text(locations[index])
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedLocation == locations[index] {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color("PrimaryColor"))
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("自定義位置")) {
                        HStack {
                            TextField("輸入其他位置...", text: $customLocation)
                            
                            Button(action: {
                                if !customLocation.isEmpty {
                                    selectedLocation = customLocation
                                    customLocation = ""
                                    showingLocationPicker = false
                                }
                            }) {
                                Text("添加")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color("PrimaryColor"))
                                    .cornerRadius(8)
                            }
                            .disabled(customLocation.isEmpty)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("選擇位置")
                .navigationBarItems(
                    trailing: Button("關閉") {
                        showingLocationPicker = false
                    }
                )
            }
        }
    }
} 