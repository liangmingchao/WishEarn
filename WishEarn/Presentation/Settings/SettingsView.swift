import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    let dataExportService: DataExportService

    @State private var exportDocument = WishEarnExportDocument()
    @State private var isExporting = false
    @State private var exportError: AppError?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header

                sectionLabel("数据")
                    .padding(.top, AppSpacing.xxl)

                HairlineDivider()

                infoRow(title: "数据存储", value: "仅保存在本机")

                HairlineDivider()

                exportRow

                HairlineDivider()

                Text("导出为 JSON 文件，包含心愿、条件、行动记录、解锁事件和暂停区间；不包含图片二进制，仅保留图片路径。")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, AppSpacing.md)

                sectionLabel("隐私")
                    .padding(.top, AppSpacing.xxl)

                HairlineDivider()

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(AppColors.chipText)
                            .accessibilityHidden(true)

                        Text("不收集个人数据")
                            .font(AppTypography.callout.weight(.semibold))
                            .foregroundStyle(AppColors.textPrimary)
                    }

                    Text("心愿、条件与行动记录只保存在当前设备，不会上传到服务器。")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, AppSpacing.md)

                HairlineDivider()

                sectionLabel("关于")
                    .padding(.top, AppSpacing.xxl)

                HairlineDivider()

                infoRow(title: "版本", value: appVersion)

                HairlineDivider()

                Text("WishEarn · 让每一份想要，都有值得付出的努力。")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)
                    .padding(.top, AppSpacing.lg)
            }
            .padding(.horizontal, AppSpacing.screenInset)
            .padding(.bottom, AppSpacing.xxl)
        }
        .appScreenBackground()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
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

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("我的")
                .font(AppTypography.display)
                .tracking(-1.2)
                .foregroundStyle(AppColors.textPrimary)
                .padding(.top, AppSpacing.sm)

            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(AppColors.primarySoft)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(AppColors.chipText)
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text("WishEarn")
                        .font(AppTypography.callout.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)

                    Text("通过行动解锁心愿奖励")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
            .padding(.top, AppSpacing.lg)
        }
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(AppTypography.kicker)
            .tracking(1)
            .foregroundStyle(AppColors.textTertiary)
            .padding(.bottom, AppSpacing.sm)
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textPrimary)

            Spacer(minLength: AppSpacing.sm)

            Text(value)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textTertiary)
        }
        .frame(minHeight: 52)
    }

    private var exportRow: some View {
        Button {
            exportData()
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Text("导出数据")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Text("JSON")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("导出数据")
        .accessibilityHint("导出为 JSON 文件")
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
