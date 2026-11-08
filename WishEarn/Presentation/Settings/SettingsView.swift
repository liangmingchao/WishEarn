import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("关于") {
                LabeledContent("应用", value: "WishEarn")
                LabeledContent("版本", value: "0.1.0")
            }

            Section("数据") {
                Label("数据仅保存在本机", systemImage: "lock.shield")
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .scrollContentBackground(.hidden)
        .appScreenBackground()
        .navigationTitle("我的")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
