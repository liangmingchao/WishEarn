import Foundation
import Observation
import PhotosUI
import _PhotosUI_SwiftUI

@MainActor
@Observable
final class WishEditorViewModel {
    private let lifecycleService: WishLifecycleServicing
    private let imageStorage: ImageStorageService
    private let clock: ClockProviding
    private let editingWish: Wish?

    var title = ""
    var descriptionText = ""
    var priceText = ""
    var hasTargetDate = false
    var targetDate = Date()

    var selectedPhotoItem: PhotosPickerItem?
    var selectedImageData: Data?

    private(set) var isSaving = false
    private(set) var isSaved = false
    var error: AppError?

    private var existingImagePath: String?
    private var didLoadExistingImage = false
    private var imageLoadedFromExisting = false
    private var imageRemoved = false

    var isEditing: Bool {
        editingWish != nil
    }

    init(
        lifecycleService: WishLifecycleServicing,
        imageStorage: ImageStorageService,
        clock: ClockProviding,
        editingWish: Wish? = nil
    ) {
        self.lifecycleService = lifecycleService
        self.imageStorage = imageStorage
        self.clock = clock
        self.editingWish = editingWish
        self.existingImagePath = editingWish?.imagePath

        if let editingWish {
            title = editingWish.title
            descriptionText = editingWish.description ?? ""
            if let targetPrice = editingWish.targetPrice {
                priceText = NSDecimalNumber(decimal: targetPrice).stringValue
            }
            hasTargetDate = editingWish.targetDate != nil
            targetDate = editingWish.targetDate ?? clock.now
        }
    }

    func loadExistingImageIfNeeded() {
        guard isEditing, !didLoadExistingImage, let existingImagePath else {
            return
        }

        didLoadExistingImage = true

        do {
            selectedImageData = try imageStorage.loadImageData(at: existingImagePath)
            imageLoadedFromExisting = selectedImageData != nil
        } catch {
            // 已有图片读取失败时显示占位图，不影响编辑其他字段。
            selectedImageData = nil
            imageLoadedFromExisting = false
        }
    }

    func loadSelectedImage(from item: PhotosPickerItem?) async {
        guard let item else {
            selectedImageData = nil
            return
        }

        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                error = .domain(.invalidInput("无法读取所选图片。"))
                return
            }
            selectedImageData = data
            imageLoadedFromExisting = false
            imageRemoved = false
        } catch {
            self.error = AppError.wrap(error)
        }
    }

    func removeSelectedImage() {
        selectedPhotoItem = nil
        selectedImageData = nil
        imageLoadedFromExisting = false
        imageRemoved = true
    }

    func save() {
        guard !isSaving else { return }

        error = nil

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            error = .domain(.invalidInput("请输入心愿名称。"))
            return
        }

        let targetPrice: Decimal?
        let trimmedPrice = priceText
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedPrice.isEmpty {
            targetPrice = nil
        } else {
            guard let parsed = Decimal(string: trimmedPrice, locale: Locale(identifier: "en_US_POSIX")),
                  parsed >= 0 else {
                error = .domain(.invalidInput("参考价格格式不正确。"))
                return
            }
            targetPrice = parsed
        }

        let finalDescription = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTargetDate = hasTargetDate ? targetDate : nil

        if hasTargetDate {
            let today = clock.calendar.startOfDay(for: clock.now)
            guard targetDate >= today else {
                error = .domain(.invalidInput("目标日期不能早于今天。"))
                return
            }
        }

        isSaving = true
        defer { isSaving = false }

        if let editingWish {
            saveEdit(
                editingWish,
                title: trimmedTitle,
                description: finalDescription.isEmpty ? nil : finalDescription,
                targetPrice: targetPrice,
                targetDate: finalTargetDate,
                now: clock.now
            )
        } else {
            saveCreate(
                title: trimmedTitle,
                description: finalDescription.isEmpty ? nil : finalDescription,
                targetPrice: targetPrice,
                targetDate: finalTargetDate,
                now: clock.now
            )
        }
    }

    private func saveCreate(
        title: String,
        description: String?,
        targetPrice: Decimal?,
        targetDate: Date?,
        now: Date
    ) {
        let wishID = UUID()
        var savedImagePath: String?

        do {
            if let selectedImageData {
                savedImagePath = try imageStorage.saveImage(data: selectedImageData, for: wishID)
            }

            let wish = try Wish(
                id: wishID,
                title: title,
                description: description,
                imagePath: savedImagePath,
                targetPrice: targetPrice,
                currencyCode: "CNY",
                targetDate: targetDate,
                createdAt: now,
                updatedAt: now
            )
            try lifecycleService.createWish(wish)
            isSaved = true
        } catch {
            if let savedImagePath {
                do {
                    try imageStorage.deleteImage(at: savedImagePath)
                } catch {
                    // 主操作失败时尽力清理已写入的图片；清理失败不影响主错误提示。
                }
            }
            self.error = AppError.wrap(error)
        }
    }

    private func saveEdit(
        _ wish: Wish,
        title: String,
        description: String?,
        targetPrice: Decimal?,
        targetDate: Date?,
        now: Date
    ) {
        var updated = wish
        var finalImagePath = existingImagePath
        var newlySavedImagePath: String?
        var imagePathToDeleteAfterSave: String?

        do {
            if let newImageData = selectedImageData, !imageLoadedFromExisting {
                let path = try imageStorage.saveImage(data: newImageData, for: wish.id)
                newlySavedImagePath = path
                finalImagePath = path

                if let existingImagePath, existingImagePath != path {
                    imagePathToDeleteAfterSave = existingImagePath
                }
            } else if imageRemoved {
                imagePathToDeleteAfterSave = existingImagePath
                finalImagePath = nil
            }

            try updated.updateDetails(
                title: title,
                description: description,
                imagePath: finalImagePath,
                targetPrice: targetPrice,
                currencyCode: wish.currencyCode,
                targetDate: targetDate,
                now: now
            )
            try lifecycleService.updateWish(updated)
            isSaved = true

            if let imagePathToDeleteAfterSave {
                do {
                    try imageStorage.deleteImage(at: imagePathToDeleteAfterSave)
                } catch {
                    // 旧图片清理失败不影响编辑结果；孤立文件可由后续清理流程处理。
                }
            }
        } catch {
            if let newlySavedImagePath {
                do {
                    try imageStorage.deleteImage(at: newlySavedImagePath)
                } catch {
                    // 编辑失败时尽力清理新写入的图片；清理失败不影响主错误提示。
                }
            }
            self.error = AppError.wrap(error)
        }
    }
}
