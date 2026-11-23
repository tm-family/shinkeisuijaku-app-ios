//
//  CardGridLayoutTests.swift
//  ShinkeisuijakuTests
//
//  プレイ画面のカードの並べ方（列の数の選び方・行は高さで等分・縦横比の上限）を、iPhone SE と iPad の大きさで確かめる。
//

import Foundation
@testable import Shinkeisuijaku
import Testing

struct CardGridLayoutTests {
    /// iPhone SE（第 3 世代）で、カードを並べられるおよその大きさ（幅 375 から左右の余白 10 を除き、
    /// 高さ 667 からステータスバー・上下の余白・「あと◯ペア」と説明の 1 行・ヒントとやめるを除いたもの）
    private static let iPhoneSEArea = CGSize(width: 355, height: 490)
    /// iPhone 17 Pro で、カードを並べられるおよその大きさ（幅 402 から左右の余白 10 を除き、高さ 874 から上下の表示と余白を除いたもの）
    private static let iPhoneProArea = CGSize(width: 382, height: 640)
    /// iPad Pro 13-inch の縦で、中身の幅の上限（600）から左右の余白を除いた大きさ
    private static let iPadArea = CGSize(width: Metrics.contentMaxWidth - Metrics.gameHorizontalPadding * 2, height: 1180)

    /// 並べたときの高さ（すき間を含む）
    private func totalHeight(_ layout: CardGridLayout) -> CGFloat {
        layout.cardSize.height * CGFloat(layout.rows) + Metrics.cardSpacing * CGFloat(layout.rows - 1)
    }

    /// 並べたときの幅（すき間を含む）
    private func totalWidth(_ layout: CardGridLayout) -> CGFloat {
        layout.cardSize.width * CGFloat(layout.columns) + Metrics.cardSpacing * CGFloat(layout.columns - 1)
    }

    /// 縦長の画面では、6 ペア（12 枚）は 3 列 × 4 段、8 ペア（16 枚）は 4 列 × 4 段、10 ペア（20 枚）は 4 列 × 5 段
    @Test(arguments: [(Difficulty.easy, 3, 4), (.normal, 4, 4), (.hard, 4, 5)])
    func columnsAndRowsPerDifficulty(difficulty: Difficulty, columns: Int, rows: Int) {
        for area in [Self.iPhoneSEArea, Self.iPhoneProArea] {
            let layout = CardGridLayout(cardCount: difficulty.pairCount * 2, available: area)
            #expect(layout.columns == columns, "\(area)")
            #expect(layout.rows == rows, "\(area)")
        }
    }

    /// 12 枚は、4 列 × 3 段より 3 列 × 4 段の方がカードの正方形の部分が大きい（iPhone SE: 82.75 より 113）
    @Test
    func twelveCardsPickTheLargerSquare() {
        let layout = CardGridLayout(cardCount: 12, available: Self.iPhoneSEArea)
        // 3 列: 幅 (355 - 8 × 2) / 3 = 113、高さ (490 - 8 × 3) / 4 = 116.5
        #expect(layout.columns == 3)
        #expect(layout.cardSize.width == 113)
        #expect(layout.cardSize.height == 116.5)
    }

    /// 横に広い場所では、20 枚を 5 列 × 4 段にする方がカードが大きければ 5 列にする
    @Test
    func wideAreaCanPickFiveColumns() {
        // 4 列: min((600 - 24) / 4, (300 - 32) / 5) = 53.6、5 列: min((600 - 32) / 5, (300 - 24) / 4) = 69
        #expect(CardGridLayout.columns(cardCount: 20, available: CGSize(width: 600, height: 300)) == 5)
    }

    /// 大きさが同じ（差が 0.5 まで）なら 4 列のまま（正方形の場所の 12 枚は、4 列も 3 列も (300 - 24) / 4 = 69）
    @Test
    func tieKeepsFourColumns() {
        #expect(CardGridLayout.columns(cardCount: 12, available: CGSize(width: 300, height: 300)) == 4)
    }

    /// 3〜5 列のどれでも割り切れない枚数は、4 列で並べる（最後の行は埋まらない）
    @Test
    func indivisibleCountUsesFourColumns() {
        let layout = CardGridLayout(cardCount: 14, available: Self.iPhoneSEArea)
        #expect(layout.columns == 4)
        #expect(layout.rows == 4)
    }

    /// iPhone SE の 10 ペア（5 段）は、行を高さで等分してスクロールせずに収まり、カードは押せる大きさ（44 以上）を保つ
    @Test
    func hardFitsOnIPhoneSEWithoutScrolling() {
        let layout = CardGridLayout(cardCount: Difficulty.hard.pairCount * 2, available: Self.iPhoneSEArea)
        #expect(totalHeight(layout) <= Self.iPhoneSEArea.height)
        #expect(totalWidth(layout) <= Self.iPhoneSEArea.width)
        // 縦横比の上限に届かないので、高さで等分したまま: (490 - 8 × 4) / 5
        #expect(layout.cardSize.height == (Self.iPhoneSEArea.height - Metrics.cardSpacing * 4) / 5)
        #expect(layout.cardSize.width >= Metrics.minTapTarget)
        #expect(layout.cardSize.height >= Metrics.minTapTarget)
    }

    /// 高さが余るとき（iPad・8 ペア）は、カードの高さを幅の上限の割合までにする（縦に長くなりすぎない）
    @Test
    func cardHeightIsCappedByAspectRatio() {
        let layout = CardGridLayout(cardCount: Difficulty.normal.pairCount * 2, available: Self.iPadArea)
        // 4 列: (580 - 8 × 3) / 4 = 139。高さで等分すると (1180 - 8 × 3) / 4 = 289 なので、上限の 139 × 1.5 にする
        #expect(layout.columns == 4)
        #expect(layout.cardSize.width == 139)
        #expect(layout.cardSize.height == 139 * Metrics.cardMaxAspectRatio)
        #expect(totalHeight(layout) < Self.iPadArea.height)
    }

    /// どの難易度でも、カードは幅の上限の割合より縦に長くならない
    @Test(arguments: Difficulty.allCases)
    func aspectRatioNeverExceedsLimit(difficulty: Difficulty) {
        for area in [Self.iPhoneSEArea, Self.iPhoneProArea, Self.iPadArea] {
            let layout = CardGridLayout(cardCount: difficulty.pairCount * 2, available: area)
            #expect(layout.cardSize.height <= layout.cardSize.width * Metrics.cardMaxAspectRatio)
        }
    }

    /// 文字を大きくして使える大きさが無くなっても、負の大きさにしない
    @Test
    func zeroAreaGivesZeroSize() {
        let layout = CardGridLayout(cardCount: 20, available: .zero)
        #expect(layout.cardSize == .zero)
    }
}
