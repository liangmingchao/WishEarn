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
                    EditorField(title: "心愿名称") {
                        TextField("例如：Kindle Paperwhite", text: $viewModel.title)
                    }

                    EditorField(title: "描述（可选）") {
                        TextField("为什么想要它？", text: $viewModel.descriptionText, axis: .vertical)
                            .lineLimit(3...5)
                    }

                    EditorField(title: "参考价格（可选）") {
                        HStack(spacing: AppSpacing.xs) {
                            Text("¥")
                                .foregroundStyle(AppColors.textSecondary)
                            TextField("0.00", text: $viewModel.priceText)
                                .keyboardType(.decimalPad)
                        }
                    }

                    imageSection

                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Toggle("设置目标日期", isOn: $viewModel.hasTargetDate)
                            .tint(AppColors.primary)

                        if viewModel.hasTargetDate {
                            DatePicker(
                                "目标日期",
                                selection: $viewModel.targetDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                        }
                    }
                    .appCard()

                    Text("币种：人民币（CNY）")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(AppSpacing.lg)
            }
            .appScreenBackground()
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
                    .disabled(viewModel.isSaving)
                }
            }
            .tint(AppColors.primary)
            .appErrorAlert(error: $viewModel.error)
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
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))

                HStack {
                    PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                        Text("更换图片")
                            .font(AppTypography.callout)
                            .foregroundStyle(AppColors.primary)
                    }

                    Spacer()

                    Button("移除图片", role: .destructive) {
                        viewModel.removeSelectedImage()
                    }
                    .font(AppTypography.callout)
                }
            } else {
                PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                    Label("选择图片", systemImage: "photo")
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.primary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
            }
        }
        .appCard()
    }
}

#Preview {
    let container = AppContainer.preview()
    WishEditorView(viewModel: container.makeWishEditorViewModel())
}
