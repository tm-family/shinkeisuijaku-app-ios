//
//  LayoutScaleTests.swift
//  ShinkeisuijakuTests
//
//  iPad で画面全体を大きくする倍率（`LayoutScale`）を、iPhone と iPad の大きさで確かめる。
//

import Foundation
@testable import Shinkeisuijaku
import SwiftUI
import Testing

struct LayoutScaleTests {
    /// iPad の全画面（横も縦も regular）の倍率
    private func regularScale(_ width: CGFloat, _ height: CGFloat) -> CGFloat {
        LayoutScale.value(screenSize: CGSize(width: width, height: height), horizontalSizeClass: .regular, verticalSizeClass: .regular)
    }

    /// iPhone（横が compact）は、どの大きさでも倍率 1（iPhone の見た目を変えない）
    @Test(arguments: [CGSize(width: 375, height: 667), CGSize(width: 402, height: 874), CGSize(width: 440, height: 956)])
    func iPhoneKeepsScaleOne(size: CGSize) {
        #expect(LayoutScale.value(screenSize: size, horizontalSizeClass: .compact, verticalSizeClass: .regular) == 1)
    }

    /// iPad の縦の全画面では、高さの伸び（基準の 874 に対する割合）に合わせる
    @Test(arguments: [
        (CGSize(width: 744, height: 1133), 1133.0 / 874),  // iPad mini
        (CGSize(width: 820, height: 1180), 1180.0 / 874),  // iPad・iPad Air 11 インチ
        (CGSize(width: 1032, height: 1376), 1376.0 / 874)  // iPad Pro 13 インチ
    ])
    func iPadFollowsTheHeight(size: CGSize, expected: CGFloat) {
        let scale = regularScale(size.width, size.height)
        #expect(abs(scale - expected) < 0.0001)
        #expect(scale > 1)
    }

    /// 横に広い窓では、幅の伸びの方が小さければ幅に合わせる（横にはみ出さない）
    @Test
    func wideWindowFollowsTheWidth() {
        #expect(abs(regularScale(500, 1366) - 500.0 / 402) < 0.0001)
    }

    /// 基準より小さい regular の窓でも 1 より小さくしない。とても大きな画面でも上限まで
    @Test
    func scaleIsClamped() {
        #expect(regularScale(700, 600) == 1)
        #expect(regularScale(4000, 4000) == LayoutScale.maximum)
    }

    /// iPad で窓を狭くしたとき（横が compact）と、大きさがまだ分からないときは 1
    @Test
    func compactOrUnknownIsOne() {
        let iPadPro = CGSize(width: 1032, height: 1376)
        #expect(LayoutScale.value(screenSize: iPadPro, horizontalSizeClass: .compact, verticalSizeClass: .regular) == 1)
        #expect(LayoutScale.value(screenSize: iPadPro, horizontalSizeClass: nil, verticalSizeClass: nil) == 1)
        #expect(regularScale(0, 0) == 1)
    }
}
