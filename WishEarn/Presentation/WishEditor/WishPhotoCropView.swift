import SwiftUI
import UIKit

struct WishPhotoCropView: View {
    let image: UIImage
    let onCrop: (Data) -> Void
    let onCancel: () -> Void

    @State private var zoom: CGFloat = 1
    @State private var lastZoom: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var cropRect: CGRect = .zero
    @State private var resizeStartRect: CGRect?
    @State private var containerSize: CGSize = .zero
    @State private var isCropping = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.md) {
                cropArea
                bottomBar
            }
            .padding(.bottom, AppSpacing.md)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("裁剪照片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .preferredColorScheme(.dark)
            .interactiveDismissDisabled()
            .alert(
                "无法裁剪照片",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { isPresented in
                        if !isPresented {
                            errorMessage = nil
                        }
                    }
                )
            ) {
                Button("好", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "请换一张照片重试。")
            }
        }
    }

    private var cropArea: some View {
        GeometryReader { proxy in
            let layout = makeLayout(containerSize: proxy.size)

            ZStack {
                Color.black

                Image(uiImage: image)
                    .resizable()
                    .frame(
                        width: layout.imageFrameSize(zoom: zoom).width,
                        height: layout.imageFrameSize(zoom: zoom).height
                    )
                    .position(
                        x: layout.containerSize.width / 2 + offset.width,
                        y: layout.containerSize.height / 2 + offset.height
                    )
                    .accessibilityLabel("裁剪预览")
                    .accessibilityValue("缩放 \(Int((zoom * 100).rounded()))%")
                    .accessibilityHint("拖动调整位置，双指缩放；也可上下轻扫缩放或使用动作移动")
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment:
                            setZoom(zoom * 1.5, layout: layout)
                        case .decrement:
                            setZoom(zoom / 1.5, layout: layout)
                        @unknown default:
                            break
                        }
                    }
                    .accessibilityAction(named: "向左移动") {
                        pan(by: CGSize(width: -32, height: 0), layout: layout)
                    }
                    .accessibilityAction(named: "向右移动") {
                        pan(by: CGSize(width: 32, height: 0), layout: layout)
                    }
                    .accessibilityAction(named: "向上移动") {
                        pan(by: CGSize(width: 0, height: -32), layout: layout)
                    }
                    .accessibilityAction(named: "向下移动") {
                        pan(by: CGSize(width: 0, height: 32), layout: layout)
                    }
                    .gesture(panGesture(layout: layout))

                CropMask(
                    containerSize: layout.containerSize,
                    cropRect: layout.cropRect
                )

                CropGrid(cropRect: layout.cropRect)

                RoundedRectangle(
                    cornerRadius: WishPhotoCropLayout.cornerRadius,
                    style: .continuous
                )
                .stroke(.white.opacity(0.9), lineWidth: 1)
                .frame(width: layout.cropRect.width, height: layout.cropRect.height)
                .position(x: layout.cropRect.midX, y: layout.cropRect.midY)
                .allowsHitTesting(false)

                resizeHandles(layout: layout)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
            .simultaneousGesture(magnificationGesture(layout: layout))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        onCancel()
                    }
                    .accessibilityIdentifier("cropCancelButton")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        applyCrop(layout: layout)
                    }
                    .disabled(isCropping)
                    .accessibilityIdentifier("cropConfirmButton")
                }
            }
            .onAppear {
                syncCropRect(for: proxy.size)
            }
            .onChange(of: proxy.size) { _, newSize in
                syncCropRect(for: newSize)
            }
        }
    }

    private var bottomBar: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: AppSpacing.md) {
                cropInstructions
                Spacer(minLength: AppSpacing.sm)
                resetButton
                freeformBadge
            }

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                cropInstructions
                HStack(spacing: AppSpacing.md) {
                    Spacer()
                    resetButton
                    freeformBadge
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
    }

    private var cropInstructions: some View {
        Text("拖动画面移动，双指缩放；拖动边角调整范围")
            .font(AppTypography.footnote)
            .foregroundStyle(.white.opacity(0.72))
    }

    private var resetButton: some View {
        Button("还原") {
            reset()
        }
        .font(AppTypography.footnote.weight(.semibold))
        .foregroundStyle(.white)
        .frame(minHeight: AppLayout.touchTarget)
        .accessibilityIdentifier("cropResetButton")
    }

    private var freeformBadge: some View {
        Text("自由")
            .font(AppTypography.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.6))
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(.white.opacity(0.1), in: Capsule())
            .accessibilityLabel("自由裁剪")
    }

    private func makeLayout(containerSize: CGSize) -> WishPhotoCropLayout {
        WishPhotoCropLayout(
            containerSize: containerSize,
            imageSize: image.size,
            cropRect: cropRect == .zero ? nil : cropRect
        )
    }

    private func syncCropRect(for newSize: CGSize) {
        containerSize = newSize
        let layout = makeLayout(containerSize: newSize)
        cropRect = layout.cropRect
        offset = layout.clampedOffset(offset, zoom: zoom)
        lastOffset = offset
    }

    private func resizeHandles(layout: WishPhotoCropLayout) -> some View {
        ForEach(WishPhotoCropHandle.allCases) { handle in
            CropHandleView(handle: handle)
                .position(handle.point(in: layout.cropRect))
                .gesture(resizeGesture(handle: handle, layout: layout))
        }
    }

    private func panGesture(layout: WishPhotoCropLayout) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let proposed = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
                offset = layout.clampedOffset(proposed, zoom: zoom)
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    private func magnificationGesture(layout: WishPhotoCropLayout) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let newZoom = min(
                    max(lastZoom * value.magnification, 1),
                    WishPhotoCropLayout.maximumZoom
                )
                zoom = newZoom
                offset = layout.clampedOffset(offset, zoom: newZoom)
            }
            .onEnded { _ in
                lastZoom = zoom
                lastOffset = offset
            }
    }

    private func resizeGesture(
        handle: WishPhotoCropHandle,
        layout: WishPhotoCropLayout
    ) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let start = resizeStartRect ?? layout.cropRect
                resizeStartRect = start

                let newRect = WishPhotoCropLayout.resizedCropRect(
                    from: start,
                    handle: handle,
                    translation: value.translation,
                    cropBounds: layout.imageRect
                )
                cropRect = newRect

                let newLayout = WishPhotoCropLayout(
                    containerSize: layout.containerSize,
                    imageSize: image.size,
                    cropRect: newRect
                )
                offset = newLayout.clampedOffset(offset, zoom: zoom)
                lastOffset = offset
            }
            .onEnded { _ in
                resizeStartRect = nil
            }
    }

    private func reset() {
        let layout = WishPhotoCropLayout(
            containerSize: containerSize,
            imageSize: image.size
        )

        withAnimation(.easeOut(duration: 0.2)) {
            cropRect = layout.cropRect
            zoom = 1
            lastZoom = 1
            offset = layout.clampedOffset(.zero, zoom: 1)
            lastOffset = offset
        }
    }

    private func setZoom(_ newZoom: CGFloat, layout: WishPhotoCropLayout) {
        let clampedZoom = min(
            max(newZoom, 1),
            WishPhotoCropLayout.maximumZoom
        )
        withAnimation(.easeOut(duration: 0.2)) {
            zoom = clampedZoom
            lastZoom = clampedZoom
            offset = layout.clampedOffset(offset, zoom: clampedZoom)
            lastOffset = offset
        }
    }

    private func pan(by delta: CGSize, layout: WishPhotoCropLayout) {
        let proposed = CGSize(
            width: offset.width + delta.width,
            height: offset.height + delta.height
        )
        offset = layout.clampedOffset(proposed, zoom: zoom)
        lastOffset = offset
    }

    private func applyCrop(layout: WishPhotoCropLayout) {
        guard !isCropping else { return }
        isCropping = true
        defer { isCropping = false }

        let visibleRect = layout.visibleImageRect(zoom: zoom, offset: offset)
        guard let data = ImageCropService.crop(image: image, to: visibleRect) else {
            errorMessage = "无法裁剪这张照片，请换一张重试。"
            return
        }

        onCrop(data)
    }
}

private struct CropHandleView: View {
    let handle: WishPhotoCropHandle

    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: 14, height: 14)
            .overlay {
                Circle()
                    .stroke(.black.opacity(0.25), lineWidth: 1)
            }
            .frame(width: AppLayout.touchTarget, height: AppLayout.touchTarget)
            .contentShape(Rectangle())
            .accessibilityLabel(handle.accessibilityLabel)
            .accessibilityHint("拖动调整裁剪范围")
    }
}

private struct CropMask: View {
    let containerSize: CGSize
    let cropRect: CGRect

    var body: some View {
        Path { path in
            path.addRect(CGRect(origin: .zero, size: containerSize))
            path.addRoundedRect(
                in: cropRect,
                cornerSize: CGSize(
                    width: WishPhotoCropLayout.cornerRadius,
                    height: WishPhotoCropLayout.cornerRadius
                )
            )
        }
        .fill(Color.black.opacity(0.62), style: FillStyle(eoFill: true))
        .allowsHitTesting(false)
    }
}

private struct CropGrid: View {
    let cropRect: CGRect

    var body: some View {
        Path { path in
            for fraction in [1.0 / 3.0, 2.0 / 3.0] {
                let x = cropRect.minX + cropRect.width * fraction
                let y = cropRect.minY + cropRect.height * fraction

                path.move(to: CGPoint(x: x, y: cropRect.minY))
                path.addLine(to: CGPoint(x: x, y: cropRect.maxY))
                path.move(to: CGPoint(x: cropRect.minX, y: y))
                path.addLine(to: CGPoint(x: cropRect.maxX, y: y))
            }
        }
        .stroke(.white.opacity(0.18), lineWidth: 0.5)
        .allowsHitTesting(false)
    }
}

#Preview {
    if let image = UIGraphicsImageRenderer(size: CGSize(width: 1200, height: 900))
        .image(actions: { context in
            UIColor.systemIndigo.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1200, height: 900))
            UIColor.systemYellow.setFill()
            context.fill(CGRect(x: 250, y: 180, width: 700, height: 540))
        })
        .jpegData(compressionQuality: 0.9)
        .flatMap(UIImage.init(data:)) {
        WishPhotoCropView(
            image: image,
            onCrop: { _ in },
            onCancel: {}
        )
    }
}
