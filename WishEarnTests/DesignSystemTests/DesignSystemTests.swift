import Foundation
import SwiftUI
import UIKit
import XCTest
@testable import WishEarn

final class DesignSystemTests: XCTestCase {
    func testSemanticTextContrastInLightAndDark() {
        let pairs: [(String, Color, Color, Double)] = [
            ("textPrimary / canvas", AppColors.textPrimary, AppColors.canvas, 7),
            ("textSecondary / canvas", AppColors.textSecondary, AppColors.canvas, 4.5),
            ("textTertiary / canvas", AppColors.textTertiary, AppColors.canvas, 4.5),
            ("textPrimary / surface", AppColors.textPrimary, AppColors.surface, 7),
            ("textSecondary / surface", AppColors.textSecondary, AppColors.surface, 4.5),
            ("textTertiary / surface", AppColors.textTertiary, AppColors.surface, 4.5),
            ("textPrimary / elevated", AppColors.textPrimary, AppColors.elevated, 7),
            ("textSecondary / elevated", AppColors.textSecondary, AppColors.elevated, 4.5),
            ("textTertiary / elevated", AppColors.textTertiary, AppColors.elevated, 4.5)
        ]

        assertContrast(pairs, styles: [.light, .dark])
    }

    func testActionAndStateContrastInLightAndDark() {
        let pairs: [(String, Color, Color, Double)] = [
            ("primary / surface", AppColors.primary, AppColors.surface, 4.5),
            ("primary / elevated", AppColors.primary, AppColors.elevated, 4.5),
            ("primary / primarySoft", AppColors.primary, AppColors.primarySoft, 4.5),
            ("onPrimary / primary", AppColors.onPrimary, AppColors.primary, 4.5),
            ("onPrimary / primaryPressed", AppColors.onPrimary, AppColors.primaryPressed, 4.5),
            ("onCoral / coral", AppColors.onCoral, AppColors.coral, 4.5),
            ("coralText / surface", AppColors.coralText, AppColors.surface, 4.5),
            ("coralText / coralSoft", AppColors.coralText, AppColors.coralSoft, 4.5),
            ("chipText / chipFill", AppColors.chipText, AppColors.chipFill, 4.5),
            ("chipTextMuted / chipFill", AppColors.chipTextMuted, AppColors.chipFill, 4.5),
            ("success / surface", AppColors.success, AppColors.surface, 4.5),
            ("warning / surface", AppColors.warning, AppColors.surface, 4.5),
            ("danger / surface", AppColors.danger, AppColors.surface, 4.5)
        ]

        assertContrast(pairs, styles: [.light, .dark])
    }

    func testWishThemeContrastInLightAndDark() {
        let pairs = WishTheme.allCases.map { theme in
            (
                "onTint / \(theme.rawValue)",
                theme.onTint,
                theme.tint,
                4.5
            )
        }

        assertContrast(pairs, styles: [.light, .dark])

        let softPairs = WishTheme.allCases.map { theme in
            (
                "onSoftTint / softTint \(theme.rawValue)",
                theme.onSoftTint,
                theme.softTint,
                3.0
            )
        }

        assertContrast(softPairs, styles: [.light, .dark])
    }

    func testWishThemeAssignmentIsStable() {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000021")!

        XCTAssertEqual(WishTheme.forID(id), WishTheme.forID(id))
    }

    func testLayoutTokensMatchDesignContract() {
        XCTAssertEqual(AppSpacing.screenInset, 24)
        XCTAssertEqual(AppSpacing.hero, 40)
        XCTAssertEqual(AppRadius.sm, 8)
        XCTAssertEqual(AppRadius.md, 14)
        XCTAssertEqual(AppRadius.lg, 20)
        XCTAssertEqual(AppRadius.xl, 26)
        XCTAssertEqual(AppLayout.touchTarget, 44)
        XCTAssertEqual(AppLayout.buttonHeight, 56)
    }

    private func assertContrast(
        _ pairs: [(String, Color, Color, Double)],
        styles: [UIUserInterfaceStyle],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for style in styles {
            for (name, foreground, background, minimum) in pairs {
                let ratio = contrastRatio(
                    foreground: foreground,
                    background: background,
                    style: style
                )
                let appearance = style == .dark ? "dark" : "light"

                XCTAssertGreaterThanOrEqual(
                    ratio,
                    minimum,
                    "\(name) in \(appearance) has contrast \(String(format: "%.2f", ratio)); expected >= \(minimum)",
                    file: file,
                    line: line
                )
            }
        }
    }

    private func contrastRatio(
        foreground: Color,
        background: Color,
        style: UIUserInterfaceStyle
    ) -> Double {
        let traits = UITraitCollection(userInterfaceStyle: style)
        let foregroundColor = UIColor(foreground).resolvedColor(with: traits)
        let backgroundColor = UIColor(background).resolvedColor(with: traits)
        let foregroundLuminance = relativeLuminance(of: foregroundColor)
        let backgroundLuminance = relativeLuminance(of: backgroundColor)
        let lighter = max(foregroundLuminance, backgroundLuminance)
        let darker = min(foregroundLuminance, backgroundLuminance)
        return (lighter + 0.05) / (darker + 0.05)
    }

    private func relativeLuminance(of color: UIColor) -> Double {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            XCTFail("Unable to resolve color components for \(color)")
            return 0
        }

        return 0.2126 * linearized(red)
            + 0.7152 * linearized(green)
            + 0.0722 * linearized(blue)
    }

    private func linearized(_ component: CGFloat) -> Double {
        let value = Double(component)
        if value <= 0.04045 {
            return value / 12.92
        }
        return pow((value + 0.055) / 1.055, 2.4)
    }
}
