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
            ("textTertiary / surface", AppColors.textTertiary, AppColors.surface, 4.5)
        ]

        assertContrast(pairs, styles: [.light, .dark])
    }

    func testActionAndStateContrastInLightAndDark() {
        let pairs: [(String, Color, Color, Double)] = [
            ("accent / surface", AppColors.accent, AppColors.surface, 4.5),
            ("accent / accentSoft", AppColors.accent, AppColors.accentSoft, 4.5),
            ("onAccent / accent", AppColors.onAccent, AppColors.accent, 4.5),
            ("success / surface", AppColors.success, AppColors.surface, 4.5),
            ("warning / surface", AppColors.warning, AppColors.surface, 4.5),
            ("danger / surface", AppColors.danger, AppColors.surface, 4.5)
        ]

        assertContrast(pairs, styles: [.light, .dark])
    }

    func testLayoutTokensMatchDesignContract() {
        XCTAssertEqual(AppSpacing.screenInset, 20)
        XCTAssertEqual(AppSpacing.hero, 40)
        XCTAssertEqual(AppRadius.sm, 8)
        XCTAssertEqual(AppRadius.md, 14)
        XCTAssertEqual(AppRadius.lg, 20)
        XCTAssertEqual(AppRadius.xl, 26)
        XCTAssertEqual(AppLayout.touchTarget, 44)
        XCTAssertEqual(AppLayout.buttonHeight, 52)
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
