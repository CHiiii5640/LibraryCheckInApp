import SwiftUI

struct LocationPicker: View {
    @Binding var selectedLocation: StudyLocation
    @State private var isShowingSheet = false
    @State private var customLocation = ""
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.appPrimary)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: selectedLocation.iconName)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("學習位置")
                    .font(.system(size: 15, weight: .medium))
                
                Text(selectedLocation.name)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                isShowingSheet = true
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(AppTheme.smallCornerRadius)
        .sheet(isPresented: $isShowingSheet) {
            LocationPickerSheet(selectedLocation: $selectedLocation, customLocation: $customLocation)
        }
    }
}

struct LocationPickerSheet: View {
    @Binding var selectedLocation: StudyLocation
    @Binding var customLocation: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(StudyLocation.defaultLocations) { location in
                        Button(action: {
                            selectedLocation = location
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: location.iconName)
                                    .foregroundColor(.appPrimary)
                                    .frame(width: 24)
                                
                                Text(location.name)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedLocation.id == location.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.appPrimary)
                                }
                            }
                        }
                    }
                }
                
                Section("新增位置") {
                    HStack {
                        TextField("其他位置...", text: $customLocation)
                        
                        Button("新增") {
                            if !customLocation.isEmpty {
                                selectedLocation = StudyLocation(name: customLocation, iconName: "building")
                                customLocation = ""
                                dismiss()
                            }
                        }
                        .disabled(customLocation.isEmpty)
                    }
                }
            }
            .navigationTitle("選擇位置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
} 