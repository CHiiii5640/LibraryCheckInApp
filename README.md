# LibraryCheckInApp

一款以 SwiftUI 開發的圖書館打卡系統 App，設計簡潔、互動直觀，適合學校或私人圖書館用於紀錄學生／訪客打卡資訊，並具備統計與視覺化展示功能。

## 功能特色

- **啟動畫面動畫**：以動態圖示與縮放效果展示品牌名稱，提升使用者第一印象。
- **多頁籤導覽**：採用 `TabView` 實作主畫面，整合首頁、日曆、統計等模組。
- **打卡地點選擇器**：支援自訂與選擇常用打卡地點。
- **統計資料視覺化**：使用圖表與項目卡片統整打卡記錄。
- **切換動畫**：自定義視圖轉場動畫，提升整體操作體驗。
- **可擴展設計**：透過模組化 View 與 Model 結構，方便後續維護與新增功能。

## 畫面預覽

>  圖示尚未附上，完成後可加上模擬器畫面

## 專案結構

```
LibraryCheckInApp/
├── Components/             # UI元件（例如：CardView, StatItemView）
├── Models/                 # 資料模型（Location, StudyRecord）
├── Views/                  # 主視圖與分頁畫面
├── Resources/              # 資源如 LaunchScreen、顏色與圖示
├── Utilities/              # 公用程式如 TransitionManager
├── LibraryCheckInAppApp.swift # App 主進入點
├── Info.plist              # 設定檔
```

## 開始

### 環境需求

- macOS Ventura 或更新版本
- Xcode 15+
- Swift 5.9+
- 支援 iOS 16+

### 建置方式

```bash
git clone git@github.com:CHiiii5640/LibraryCheckInApp.git
cd LibraryCheckInApp
open LibraryCheckIn.xcodeproj
```

1. 選擇模擬器或裝置。
2. 點擊 ⌘R 執行專案。

## 📦 使用的技術

- SwiftUI
- MVVM 架構
- Custom Animations
- Storyboard (Launch Screen)
- Git + GitHub for version control
