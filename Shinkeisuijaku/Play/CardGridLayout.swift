//
//  CardGridLayout.swift
//  Shinkeisuijaku
//
//  プレイ画面のカードの並べ方（引き継ぎブックの「カードの並び」）。列の数は 3〜5 列のうち、枚数を割り切れて、カードの正方形の部分が
//  いちばん大きくなるものを選ぶ（同じなら 4 列。12 枚はふつう 3 列 × 4 段、16 枚・20 枚は 4 列）。行は使える高さで等分する（iPhone SE の 10 ペアでもスクロールしない）。
//  ただし、カードの高さは幅の `Metrics.cardMaxAspectRatio` 倍までにして、縦に長くなりすぎないようにする（あまった高さは呼び出し側が上下に分ける）。
//  View から切り離した値の型にして、単体テストする。
//

import CoreGraphics

/// カードの並べ方
struct CardGridLayout: Equatable {
    /// 列の数
    let columns: Int
    /// 行の数
    let rows: Int
    /// 1 枚のカードの大きさ
    let cardSize: CGSize

    /// - Parameters:
    ///   - cardCount: カードの枚数
    ///   - available: カードを並べられる大きさ（左右の余白・上と下の表示を除いたもの）
    ///   - scale: iPad の全画面で大きくする倍率（`layoutScale`）。カードどうしのすき間に掛ける
    init(cardCount: Int, available: CGSize, scale: CGFloat = 1) {
        let spacing = Metrics.cardSpacing * scale
        let columns = Self.columns(cardCount: cardCount, available: available, spacing: spacing)
        let rows = Self.rows(cardCount: cardCount, columns: columns)
        let width = Self.cardWidth(columns: columns, available: available, spacing: spacing)
        let evenHeight = Self.evenHeight(rows: rows, available: available, spacing: spacing)
        self.columns = columns
        self.rows = rows
        cardSize = CGSize(width: width, height: min(evenHeight, width * Metrics.cardMaxAspectRatio))
    }

    /// 列の数を選ぶ（引き継ぎブックの `BoardView.columns(count:in:gap:)`）。
    /// 候補（`Metrics.cardColumnCandidates`）のうち枚数を割り切れるものから、カードの正方形の部分（幅と、高さで等分した高さの短い方）が
    /// いちばん大きくなるものを選ぶ。大きさの差が `Metrics.cardColumnTieTolerance` までなら先の候補を残す。割り切れる候補が無ければ基本の列の数
    static func columns(cardCount: Int, available: CGSize, spacing: CGFloat = Metrics.cardSpacing) -> Int {
        var best = Metrics.cardColumns
        var bestSide = -CGFloat.infinity
        for columns in Metrics.cardColumnCandidates where cardCount > 0 && cardCount.isMultiple(of: columns) {
            let side = min(
                cardWidth(columns: columns, available: available, spacing: spacing),
                evenHeight(rows: cardCount / columns, available: available, spacing: spacing)
            )
            if side > bestSide + Metrics.cardColumnTieTolerance {
                best = columns
                bestSide = side
            }
        }
        return best
    }

    /// 行の数（最後の行が埋まらなくても 1 行に数える）
    private static func rows(cardCount: Int, columns: Int) -> Int {
        max((cardCount + columns - 1) / columns, 1)
    }

    /// 列の数で幅を等分したカードの幅。文字を大きくして使える大きさが減っても、負の大きさにしない
    private static func cardWidth(columns: Int, available: CGSize, spacing: CGFloat) -> CGFloat {
        max((available.width - spacing * CGFloat(columns - 1)) / CGFloat(columns), 0)
    }

    /// 行の数で高さを等分したカードの高さ。負の大きさにしない
    private static func evenHeight(rows: Int, available: CGSize, spacing: CGFloat) -> CGFloat {
        max((available.height - spacing * CGFloat(rows - 1)) / CGFloat(rows), 0)
    }
}
