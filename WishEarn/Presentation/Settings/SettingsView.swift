import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    let dataExportService: DataExportService

    @State private var exportDocument = WishEarnExportDocument()
    @State private var isExporting = false
    @State private var exportError: AppError?

    var body: some View {
        List {
            Section {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .fill(AppColors.primarySoft)
                        Image(systemName: "sparkles")
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(AppColors.primary)
                    }
                    .frame(width: 56, height: 56)

                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("WishEarn")
                            .font(AppTypography.title)
                            .foregroundStyle(AppColors.textPrimary)
                        Text("通过行动解锁心愿奖励")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .padding(.vertical, AppSpacing.xs)
                .listRowBackground(Color.clear)
            }

            Section {
                LabeledContent("数据存储", value: "仅保存在本机")
                    .frame(minHeight: 52)

                Button {
                    exportData()
                } label: {
                    HStack(spacing: AppSpacing.sm) {
                        Label("导出数据", systemImage: "square.and.arrow.up")
                            .foregroundStyle(AppColors.primary)

                        Spacer()

                        Text("JSON")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)

                        Image(systemName: "chevron.right")
                            .font(AppTypography.caption.weight(.semibold))
                            .foregroundStyle(AppColors.textTertiary)
                            .accessibilityHidden(true)
                    }
                    .frame(minHeight: 52)
                }
                .accessibilityLabel("导出数据")
                .accessibilityHint("导出为 JSON 文件")
            } header: {
                Text("数据")
            } footer: {
                Text("导出为 JSON 文件，包含心愿、条件、行动记录、解锁事件和暂停区间；不包含图片二进制，仅保留图片路径。")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Section("隐私") {
                Label("不收集个人数据", systemImage: "lock.shield")
                Text("心愿、条件与行动记录只保存在当前设备，不会上传到服务器。")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Section("关于") {
                LabeledContent("版本", value: appVersion)
                    .frame(minHeight: 52)
                Text("WishEarn · 让每一份想要，都有值得付出的努力。")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .scrollContentBackground(.hidden)
        .appScreenBackground()
        .navigationTitle("我的")
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: .json,
            defaultFilename: "WishEarn-Export"
        ) { result in
            if case .failure(let error) = result {
                exportError = AppError.wrap(error)
            }
        }
        .appErrorAlert(error: $exportError)
    }

    private func exportData() {
        do {
            exportDocument = WishEarnExportDocument(data: try dataExportService.exportData())
            isExporting = true
        } catch {
            exportError = AppError.wrap(error)
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.15.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview("Light") {
    let container = AppContainer.preview()
    NavigationStack {
        SettingsView(dataExportService: container.dataExportService)
    }
}

#Preview("Dark") {
    let container = AppContainer.preview()
    NavigationStack {
        SettingsView(dataExportService: container.dataExportService)
    }
    .preferredColorScheme(.dark)
}
