//
//  StampView.swift
//  Shinkeisuijaku
//
//  スタンプの部品。通常・銀・金・まだ・パス専用の鍵（引き継ぎブックの 6・7 ページ）と、クリア画面の大きなスタンプ。
//  見た目はデザイントークンと絵の部品だけで作る。読み上げは使う側（スタンプちょう・クリア）で付ける。
//

import SwiftUI

/// スタンプの枠 1 つの状態
enum StampSlot: Equatable {
    /// もらったスタンプ
    case owned(Stamp)
    /// まだ持っていない枠（点線の丸）
    case empty
    /// パスを買う前のパス専用の枠（点線の丸に鍵）
    case locked
}

/// スタンプの見た目の決まり（View から切り離して確かめられるようにする）
enum StampStyle {
    /// 通常のスタンプの絵の色（「絵の色に合う淡い地」の元にする色）。
    /// 絵を足したときに書き忘れがコンパイルで分かるよう、網羅した switch にする（分岐が多いのはそのため）
    static func mainColor(of picture: Picture) -> Color { // swiftlint:disable:this cyclomatic_complexity
        switch picture {
        case .cat: Palette.artGray
        case .dog: Palette.artTan
        case .rabbit: Palette.artPink
        case .panda: Palette.artDark
        case .frog: Palette.artGreen
        case .chick: Palette.artYellow
        case .fox: Palette.artOrange
        case .penguin: Palette.artBlue
        case .apple: Palette.artRed
        case .strawberry: Palette.artBerry
        case .bear: Palette.artBrown
        // ブタは通常のスタンプに無い（引き継ぎの一式の「絵が使われる場所」）。絵を足したときの書き忘れを防ぐ switch なので、顔の色にしておく
        case .pig: Palette.artRose
        case .suika: Palette.artGreen
        case .star: Palette.artYellow
        }
    }

    /// 点線（まだのスタンプ・パス専用の鍵・クリア画面のふち）の線。太さと線の長さ・間に倍率（`layoutScale`）を掛ける
    static func dashedStroke(lineWidth: CGFloat, scale: CGFloat) -> StrokeStyle {
        StrokeStyle(lineWidth: lineWidth * scale, dash: Metrics.stampDash.map { $0 * scale })
    }

    /// 銀と金のふちの色と地の色
    static func rimColors(of rim: StampRim) -> (rim: Color, wash: Color) {
        switch rim {
        case .silver: (Palette.stampSilver, Palette.stampSilverWash)
        case .gold: (Palette.stampGold, Palette.stampGoldWash)
        }
    }
}

/// スタンプ 1 つ（スタンプちょうの枠）。`diameter` の丸に描く
struct StampView: View {
    let slot: StampSlot
    /// 丸の直径。nil ならスタンプちょうの直径の上限（iPad の全画面では倍率を掛けた大きさ）
    var diameter: CGFloat?

    @Environment(\.layoutScale) private var layoutScale

    /// 描く丸の直径
    private var side: CGFloat {
        diameter ?? Metrics.stampBookMaxDiameter * layoutScale
    }

    /// 丸の外側の影のぼかしとずれ
    private var shadowRadius: CGFloat {
        Metrics.stampShadowRadius * layoutScale
    }

    private var shadowOffsetY: CGFloat {
        Metrics.stampShadowOffsetY * layoutScale
    }

    var body: some View {
        content
            .frame(width: side, height: side)
            .accessibilityHidden(true)
    }

    @ViewBuilder private var content: some View {
        switch slot {
        case let .owned(.regular(picture)):
            ZStack {
                Circle().fill(Palette.artWhite)
                Circle().fill(StampStyle.mainColor(of: picture).opacity(Palette.stampWashOpacity))
                IllustrationView(picture: picture)
                    .frame(width: side * Metrics.stampPictureRatio)
            }
            // 中の絵や文字に影を付けず、丸の外側にだけ付ける
            .compositingGroup()
            .shadow(color: Palette.stampShadow, radius: shadowRadius, y: shadowOffsetY)
        case let .owned(.pass(course, rim)):
            let colors = StampStyle.rimColors(of: rim)
            ZStack {
                Circle().fill(colors.wash)
                Circle().strokeBorder(colors.rim, lineWidth: Metrics.stampRimWidth * layoutScale)
                courseSymbol(course)
            }
            // 中の絵や文字に影を付けず、丸の外側にだけ付ける
            .compositingGroup()
            .shadow(color: Palette.stampShadow, radius: shadowRadius, y: shadowOffsetY)
        case .empty:
            dashedCircle(Palette.stampEmpty)
        case .locked:
            ZStack {
                dashedCircle(Palette.stampGold)
                LockShape()
                    .fill(Palette.stampLock)
                    .frame(width: side * Metrics.stampLockRatio, height: side * Metrics.stampLockRatio)
            }
        }
    }

    /// コースのシンボル（どうぶつはネコ、ひらがなは「あ」）
    @ViewBuilder private func courseSymbol(_ course: Course) -> some View {
        switch course {
        case .animals:
            IllustrationView(picture: .cat)
                .frame(width: side * Metrics.stampPictureRatio)
        case .hiragana:
            HiraganaSymbolView()
                .frame(width: side, height: side)
        }
    }

    private func dashedCircle(_ color: Color) -> some View {
        Circle()
            .strokeBorder(color, style: StampStyle.dashedStroke(lineWidth: Metrics.stampDashedLineWidth, scale: layoutScale))
    }
}

/// クリア画面の大きなスタンプ（直径 124・8 度かたむける・点線の青いふち 3）
struct ClearStampView: View {
    let stamp: Stamp
    /// 読み上げ（もらったスタンプの名前。`ClearOutcome.stampAccessibilityLabel`）。nil なら飾りとして読み上げない
    var accessibilityLabel: String?

    @Environment(\.layoutScale) private var layoutScale

    var body: some View {
        StampView(slot: .owned(stamp), diameter: Metrics.clearStampDiameter * layoutScale)
            .padding(Metrics.clearStampRingGap * layoutScale)
            .overlay {
                Circle()
                    .strokeBorder(
                        Palette.accent,
                        style: StampStyle.dashedStroke(lineWidth: Metrics.clearStampBorderWidth, scale: layoutScale)
                    )
            }
            .rotationEffect(.degrees(Metrics.clearStampRotationDegrees))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: accessibilityLabel ?? ""))
            .accessibilityAddTraits(.isImage)
            .accessibilityHidden(accessibilityLabel == nil)
    }
}

/// 南京錠の形（パス専用の枠の鍵）。引き継ぎブックの 6 ページの見本のように、つると胴を同じ太さの線で描く。
/// 線の太さを含めて与えた枠に収まる塗りの形を返す（`fill` で描く）。
/// `Shape` の `path(in:)` は隔離のない要件なので、既定の MainActor に隔離しない（Xcode 27.1 ではビルドエラーになる）
nonisolated struct LockShape: Shape {
    /// 線の太さ（枠の幅に対する割合）
    static let lineRatio: CGFloat = 0.14

    func path(in rect: CGRect) -> Path {
        let line = rect.width * Self.lineRatio
        // 線の真ん中が通る枠。線の太さの半分だけ内側にして、はみ出さないようにする
        let inner = rect.insetBy(dx: line / 2, dy: line / 2)
        let body = CGRect(x: inner.minX, y: inner.minY + inner.height * 0.45, width: inner.width, height: inner.height * 0.55)
        let radius = inner.width * 0.28
        var outline = Path(roundedRect: body, cornerRadius: inner.width * 0.18)
        outline.move(to: CGPoint(x: inner.midX - radius, y: body.minY))
        outline.addLine(to: CGPoint(x: inner.midX - radius, y: inner.minY + radius))
        outline.addArc(
            center: CGPoint(x: inner.midX, y: inner.minY + radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        outline.addLine(to: CGPoint(x: inner.midX + radius, y: body.minY))
        return outline.strokedPath(StrokeStyle(lineWidth: line, lineCap: .round, lineJoin: .round))
    }
}

/// スタンプの部品を並べた見本の画面。撮影モードで開き、引き継ぎブックの 6 ページと見比べるために使う
struct StampCatalogView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.screenHorizontalPadding) {
                Text("スタンプちょう（直径 80）")
                    .appFont(Typography.body)
                    .foregroundStyle(Palette.muted)
                HStack(spacing: Metrics.cardSpacing) {
                    StampView(slot: .owned(.regular(.cat)))
                    StampView(slot: .owned(.pass(.animals, .silver)))
                    StampView(slot: .owned(.pass(.hiragana, .gold)))
                    StampView(slot: .empty)
                }
                HStack(spacing: Metrics.cardSpacing) {
                    StampView(slot: .locked)
                    StampView(slot: .owned(.pass(.hiragana, .silver)))
                    StampView(slot: .owned(.pass(.animals, .gold)))
                }
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: Metrics.cardSpacing), count: Metrics.cardColumns),
                    spacing: Metrics.cardSpacing
                ) {
                    ForEach(Stamp.regularStamps, id: \.id) { stamp in
                        StampView(slot: .owned(stamp), diameter: Metrics.stampBookMinDiameter)
                    }
                }
                Text("クリア画面（直径 124・8 度）")
                    .appFont(Typography.body)
                    .foregroundStyle(Palette.muted)
                HStack(spacing: Metrics.screenHorizontalPadding) {
                    ClearStampView(stamp: .regular(.fox))
                    ClearStampView(stamp: .pass(.hiragana, .gold))
                }
            }
            .padding(.horizontal, Metrics.screenHorizontalPadding)
        }
        .background(Palette.background)
    }
}

#Preview {
    StampCatalogView()
}
