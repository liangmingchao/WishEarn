import PhotosUI
import SwiftUI
import UIKit
import _PhotosUI_SwiftUI

struct WishEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: WishEditorViewModel

    init(viewModel: WishEditorViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    imageSection

                    EditorField(
                        title: "心愿名称",
                        helperText: viewModel.titleHelperText
                    ) {
                        TextField("例如：Kindle Paperwhite", text: $viewModel.title)
                            .accessibilityIdentifier("wishTitleField")
                    }

                    EditorField(
                        title: "参考价格（选填）",
                        helperText: viewModel.currencySummary,
                        errorText: viewModel.priceValidationMessage
                    ) {
                        HStack(spacing: AppSpacing.xs) {
                            Text(viewModel.currencySymbol)
                                .foregroundStyle(AppColors.textSecondary)
                            TextField("0.00", text: $viewModel.priceText)
                                .keyboardType(.decimalPad)
                        }
                    }

                    EditorField(title: "想要它的原因（选填）") {
                        TextField(
                            "为什么这件事对你重要？",
                            text: $viewModel.descriptionText,
                            axis: .vertical
                        )
                        .lineLimit(3...5)
                    }

                    targetDateSection
                }
                .padding(AppSpacing.lg)
            }
            .appScreenBackground()
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(viewModel.isEditing ? "编辑心愿" : "新建心愿")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.loadExistingImageIfNeeded()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        viewModel.save()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .tint(AppColors.primary)
            .appErrorAlert(error: $viewModel.error)
            .environment(\.locale, Locale(identifier: "zh_CN"))
            .interactiveDismissDisabled(viewModel.isSaving)
            .onChange(of: viewModel.selectedPhotoItem) { _, item in
                Task {
                    await viewModel.loadSelectedImage(from: item)
                }
            }
            .onChange(of: viewModel.isSaved) { _, isSaved in
                if isSaved {
                    dismiss()
                }
            }
        }
    }

    private var imageSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            if let imageData = viewModel.selectedImageData,
               let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipped()
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: AppRadius.md,
                            style: .continuous
                        )
                    )
                    .accessibilityLabel("已选择的心愿照片")

                HStack(spacing: AppSpacing.md) {
                    PhotosPicker(
                        selection: $viewModel.selectedPhotoItem,
                        matching: .images
                    ) {
                        Label("更换照片", systemImage: "photo")
                            .font(AppTypography.callout)
                            .foregroundStyle(AppColors.accent)
                            .frame(minHeight: AppLayout.touchTarget)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button("移除照片", role: .destructive) {
                        viewModel.removeSelectedImage()
                    }
                    .font(AppTypography.callout)
                    .frame(minHeight: AppLayout.touchTarget)
                }
            } else {
                PhotosPicker(
                    selection: $viewModel.selectedPhotoItem,
                    matching: .images
                ) {
                    VStack(spacing: AppSpacing.sm) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 30, weight: .light))
                            .foregroundStyle(AppColors.textTertiary)
                        Text("添加心愿照片")
                            .font(AppTypography.callout)
                            .foregroundStyle(AppColors.accent)
                    }
                    .frame(maxWidth: .infinity, minHeight: 140)
                    .background(
                        AppColors.surfaceSecondary,
                        in: RoundedRectangle(
                            cornerRadius: AppRadius.md,
                            style: .continuous
                        )
                    )
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: AppRadius.md,
                            style: .continuous
                        )
                        .stroke(AppColors.separator, lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("添加心愿照片")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    private var targetDateSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Toggle("设置目标日期（选填）", isOn: $viewModel.hasTargetDate)
                .tint(AppColors.primary)

            if viewModel.hasTargetDate {
                EditorField(
                    title: "目标日期",
                    errorText: viewModel.targetDateValidationMessage
                ) {
                    DatePicker(
                        "目标日期",
                        selection: $viewModel.targetDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                }

                Text("仅作为目标日期记录，不会产生逾期提醒。")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .appCard()
    }
}

#Preview("创建心愿") {
    WishEditorView(viewModel: AppContainer.preview().makeWishEditorViewModel())
}

#Preview("编辑心愿") {
    let container = AppContainer.preview()
    if let wish = try? Wish(
        title: "Kindle Paperwhite",
        description: "睡前阅读",
        targetPrice: 1099,
        createdAt: .now,
        updatedAt: .now
    ) {
        WishEditorView(viewModel: container.makeWishEditorViewModel(wish: wish))
    } else {
        Text("Preview data unavailable")
    }
}

#Preview("创建心愿 — 深色") {
    WishEditorView(viewModel: AppContainer.preview().makeWishEditorViewModel())
        .preferredColorScheme(.dark)
}
