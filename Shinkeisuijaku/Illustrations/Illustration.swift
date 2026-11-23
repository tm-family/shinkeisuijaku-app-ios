//
//  Illustration.swift
//  Shinkeisuijaku
//
//  14 種類の絵を描く。形は Discussion #4 の Q1 の添付の SVG（ブタは改訂版の引き継ぎの一式で足したもの）を `Tools/illustrations/convert.py` で
//  `Generated/` の Path に変換したもの（手で写さない）。ベクターなので、どの大きさでも崩れない。
//  カードの中では、絵ごとの「ぴったりの枠」（描いた部分に少しの余白を足した正方形）で描き、絵を枠いっぱいに大きく見せる。
//  引き継ぎブックの「軽いゆらぎ」は入れない。
//

import SwiftUI

/// 絵の部品 1 つ（SVG の path・circle・ellipse 1 つ分）。座標は絵の枠（14 種類の絵は 108×108、ヒントの目は 108×54）の中の値
struct IllustrationPart {
    let path: Path
    /// 塗りの色。塗らない線だけの部品は nil
    let fill: Color?
    /// 線の色。線の無い部品は nil
    let stroke: Color?
    /// 線の太さ（絵の枠の大きさのときの値。絵の大きさに合わせて太さも変わる）
    let lineWidth: CGFloat
    /// 線の端を丸くするか（表情の線など）
    let roundCap: Bool
}

/// 絵ごとの部品の並び（下から順に重ねる）
enum IllustrationArt {
    /// 絵の部品。`Generated/` の書き出したコードから引く。
    /// 絵を足したときに書き忘れがコンパイルで分かるよう、辞書ではなく網羅した switch にする（分岐が多いのはそのため）
    static func parts(for picture: Picture) -> [IllustrationPart] { // swiftlint:disable:this cyclomatic_complexity
        switch picture {
        case .cat: cat
        case .dog: dog
        case .rabbit: rabbit
        case .panda: panda
        case .frog: frog
        case .chick: chick
        case .fox: fox
        case .penguin: penguin
        case .apple: apple
        case .strawberry: strawberry
        case .bear: bear
        case .pig: pig
        case .suika: suika
        case .star: star
        }
    }

    /// 絵の元の枠（SVG の 1 つの図の枠。108×108 で、絵のまわりに余白がある）
    static let fullCanvas = CGRect(x: 0, y: 0, width: Metrics.artCanvasSize, height: Metrics.artCanvasSize)

    /// カードに入れるときの、絵ごとの「ぴったりの枠」（改訂版の引き継ぎの一式の `cardBox`）。
    /// 描いた部分（線の太さの半分を含む）の上下左右に `Metrics.artCardBoxMargin` の余白を足し、長い辺に合わせた正方形にして、描いた部分の真ん中に置く。
    /// 一式の値は部品から求めたものなので、値を写さずに部品から求める（一式の表と同じになることは単体テストで確かめる）
    static func cardBox(for picture: Picture) -> CGRect {
        cardBoxes[picture] ?? fullCanvas
    }

    /// 14 種類の絵のぴったりの枠（部品は変わらないので、一度だけ求める）
    private static let cardBoxes: [Picture: CGRect] = Dictionary(uniqueKeysWithValues: Picture.allCases.map { picture in
        (picture, squareBox(around: paintedBounds(of: parts(for: picture)), margin: Metrics.artCardBoxMargin))
    })

    /// 部品を描いたときに色が付く範囲（線のある部品は、線の太さの半分だけ外に広がる。角と端は丸いので、どの向きにも半分）
    static func paintedBounds(of parts: [IllustrationPart]) -> CGRect {
        parts.reduce(CGRect.null) { bounds, part in
            bounds.union(paintedBounds(of: part))
        }
    }

    /// 部品 1 つの色が付く範囲。`Path.boundingRect` は曲線の制御点まで含み、回した楕円（ウサギの耳など）で広くなるので、
    /// 曲線そのものの範囲（`boundingBoxOfPath`）を使う
    static func paintedBounds(of part: IllustrationPart) -> CGRect {
        let spread = part.stroke == nil ? 0 : part.lineWidth / 2
        return part.path.cgPath.boundingBoxOfPath.insetBy(dx: -spread, dy: -spread)
    }

    /// 範囲の上下左右に余白を足し、長い辺に合わせた正方形にして、範囲の真ん中に置く
    static func squareBox(around bounds: CGRect, margin: CGFloat) -> CGRect {
        let side = max(bounds.width, bounds.height) + margin * 2
        return CGRect(x: bounds.midX - side / 2, y: bounds.midY - side / 2, width: side, height: side)
    }
}

/// 絵 1 つ。与えられた大きさの正方形に収まるように拡大・縮小して描く
struct IllustrationView: View {
    let picture: Picture
    /// カード用の、絵ごとのぴったりの枠で描くか（false なら元の枠。まわりに余白がある）
    var tight = false

    var body: some View {
        IllustrationPartsView(
            parts: IllustrationArt.parts(for: picture),
            canvas: tight ? IllustrationArt.cardBox(for: picture) : IllustrationArt.fullCanvas
        )
    }
}

/// 部品の並びを、枠（`canvas`）の縦横比のまま、与えられた大きさに収まるように拡大・縮小して描く
struct IllustrationPartsView: View {
    let parts: [IllustrationPart]
    /// 描く枠（部品の座標で。原点が 0 でない枠なら、その左上を描く場所の左上に合わせる）
    let canvas: CGRect

    init(parts: [IllustrationPart], canvas: CGRect) {
        self.parts = parts
        self.canvas = canvas
    }

    /// 原点が 0 の枠で描く
    init(parts: [IllustrationPart], canvasSize: CGSize) {
        self.init(parts: parts, canvas: CGRect(origin: .zero, size: canvasSize))
    }

    var body: some View {
        Canvas { context, size in
            let fit = Self.fit(canvas: canvas, into: size)
            context.translateBy(x: fit.offset.x, y: fit.offset.y)
            context.scaleBy(x: fit.scale, y: fit.scale)
            for part in parts {
                if let fill = part.fill {
                    context.fill(part.path, with: .color(fill))
                }
                if let stroke = part.stroke {
                    let style = StrokeStyle(lineWidth: part.lineWidth, lineCap: part.roundCap ? .round : .butt, lineJoin: .round)
                    context.stroke(part.path, with: .color(stroke), style: style)
                }
            }
        }
        .aspectRatio(canvas.size, contentMode: .fit)
        // 絵の名前の読み上げは、使う側（カード・スタンプ・ボタン）で状態と合わせて付ける
        .accessibilityHidden(true)
    }

    /// 枠を描く場所に収める倍率と、真ん中に寄せるずれ（縦横比は保つ）。
    /// ずれは倍率を掛ける前の移動で、枠の左上（`canvas.origin`）の分も引く
    static func fit(canvas: CGRect, into size: CGSize) -> (scale: CGFloat, offset: CGPoint) {
        let scale = min(size.width / canvas.width, size.height / canvas.height)
        let offset = CGPoint(
            x: (size.width - canvas.width * scale) / 2 - canvas.minX * scale,
            y: (size.height - canvas.height * scale) / 2 - canvas.minY * scale
        )
        return (scale, offset)
    }
}

extension Path {
    /// 点のまわりに回した Path（SVG の `rotate(角度 x y)`）
    func rotated(by degrees: Double, around center: CGPoint) -> Path {
        let transform = CGAffineTransform(translationX: center.x, y: center.y)
            .rotated(by: degrees * .pi / 180)
            .translatedBy(x: -center.x, y: -center.y)
        return applying(transform)
    }
}

/// 絵の見本の画面。上にヒントの目と「あ」、下に 14 種類の絵。撮影モードで開き、添付の画像・引き継ぎブックと見比べるために使う
struct IllustrationCatalogView: View {
    /// 見本の列の数（添付の画像と同じ 3 列）
    private let columns = 3

    var body: some View {
        ScrollView {
            symbols
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: Metrics.cardSpacing), count: columns),
                spacing: Metrics.cardSpacing
            ) {
                ForEach(Picture.allCases, id: \.self) { picture in
                    VStack(spacing: 0) {
                        IllustrationView(picture: picture)
                            .padding(Metrics.cardSpacing)
                        Text(verbatim: "\(picture.rawValue)（\(picture.name)）")
                            .appFont(Typography.noteStrong)
                            .foregroundStyle(Palette.cardInk)
                            .padding(.bottom, Metrics.cardSpacing)
                    }
                    .background(Palette.cardPicture, in: RoundedRectangle(cornerRadius: Metrics.cardCornerRadius))
                }
            }
            .padding(.horizontal, Metrics.screenHorizontalPadding)
        }
        .background(Palette.background)
    }

    /// ヒントの目（ボタンの見た目に置く）と、「あ」（金と銀のふちのスタンプに置く）
    private var symbols: some View {
        HStack(spacing: Metrics.screenHorizontalPadding) {
            HStack(spacing: Metrics.cardSpacing) {
                HintEyesView()
                    .frame(height: Metrics.hintIconHeight)
                Text("ヒント")
                    .appFont(Typography.button)
                    .foregroundStyle(Palette.text)
            }
            .padding(.horizontal, Metrics.screenHorizontalPadding)
            .frame(minHeight: Metrics.buttonHeight)
            .background(Palette.surface, in: RoundedRectangle(cornerRadius: Metrics.buttonCornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.buttonCornerRadius)
                    .stroke(Palette.border, lineWidth: Metrics.borderWidth)
            }
            symbolStamp(rim: Palette.stampSilver, wash: Palette.stampSilverWash)
            symbolStamp(rim: Palette.stampGold, wash: Palette.stampGoldWash)
        }
        .padding(.vertical, Metrics.screenHorizontalPadding)
    }

    /// 「あ」をふちの付いた丸に置いた見本（スタンプの部品はタスク 11 で作る）
    private func symbolStamp(rim: Color, wash: Color) -> some View {
        HiraganaSymbolView()
            .frame(width: Metrics.stampBookMaxDiameter, height: Metrics.stampBookMaxDiameter)
            .background(wash, in: Circle())
            .overlay { Circle().stroke(rim, lineWidth: Metrics.stampRimWidth) }
    }
}

#Preview {
    IllustrationCatalogView()
}
