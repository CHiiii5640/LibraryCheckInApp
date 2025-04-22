import Foundation
import SwiftUI

struct StudyLocation: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var iconName: String
    
    static let defaultLocations = [
        StudyLocation(name: "校區中央圖書館", iconName: "book.closed"),
        StudyLocation(name: "理工學院圖書館", iconName: "flask"),
        StudyLocation(name: "社科院圖書館", iconName: "building.columns"),
        StudyLocation(name: "商學院圖書館", iconName: "chart.pie"),
        StudyLocation(name: "醫學院圖書館", iconName: "heart"),
        StudyLocation(name: "法學院圖書館", iconName: "scale.3d")
    ]
    
    static var `default`: StudyLocation {
        defaultLocations[0]
    }
} 