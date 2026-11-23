//
//  IllustrationTests.swift
//  ShinkeisuijakuTests
//
//  SVG から書き出した絵の部品が揃っているかを確かめる（形そのものは見本の画面で添付の画像と見比べる）。
//

import Foundation
@testable import Shinkeisuijaku
import SwiftUI
import Testing

struct IllustrationTests {
    /// SVG の各図の部品の数（path・circle・ellipse の数）。書き出しで部品が抜けたら気づけるようにする
    private let expectedPartCounts: [Picture: Int] = [
        .cat: 15, .dog: 11, .rabbit: 13, .panda: 10, .frog: 12, .chick: 7, .fox: 9,
        .penguin: 11, .apple: 4, .strawberry: 10, .bear: 9, .pig: 12, .suika: 6, .star: 4
    ]

    /// 14 種類すべてに部品があり、数が SVG と同じ
    @Test
    func everyPictureHasAllParts() {
        for picture in Picture.allCases {
            #expect(IllustrationArt.parts(for: picture).count == expectedPartCounts[picture], "\(picture)")
        }
    }

    /// 部品は 108×108 の枠の中に収まる（座標のずらし忘れで絵が切れないように）
    @Test
    func partsStayInsideTheCanvas() {
        let canvas = CGRect(x: 0, y: 0, width: Metrics.artCanvasSize, height: Metrics.artCanvasSize)
        for picture in Picture.allCases {
            for part in IllustrationArt.parts(for: picture) {
                #expect(canvas.contains(part.path.boundingRect), "\(picture) の部品が枠の外に出ている: \(part.path.boundingRect)")
            }
        }
    }

    /// どの部品も塗りか線のどちらかを持ち、線のある部品は太さがある
    @Test
    func partsArePaintable() {
        for picture in Picture.allCases {
            for part in IllustrationArt.parts(for: picture) {
                #expect(part.fill != nil || part.stroke != nil, "\(picture)")
                if part.stroke != nil {
                    #expect(part.lineWidth > 0, "\(picture)")
                }
            }
        }
    }

    /// SVG の rotate(角度 x y) と同じく、中心のまわりに回しても中心は動かない
    @Test
    func rotationKeepsTheCenter() {
        let rect = CGRect(x: 10, y: 20, width: 20, height: 40)
        let rotated = Path(ellipseIn: rect).rotated(by: 90, around: CGPoint(x: rect.midX, y: rect.midY))
        #expect(abs(rotated.boundingRect.midX - rect.midX) < 0.001)
        #expect(abs(rotated.boundingRect.midY - rect.midY) < 0.001)
        #expect(abs(rotated.boundingRect.width - rect.height) < 0.001)
    }

    /// 正の角度は、SVG と同じく画面の上で時計回り（右向きの線を 90 度回すと下向きになる）
    @Test
    func positiveRotationIsClockwiseOnScreen() {
        var line = Path()
        line.move(to: CGPoint(x: 50, y: 50))
        line.addLine(to: CGPoint(x: 60, y: 50))
        let rotated = line.rotated(by: 90, around: CGPoint(x: 50, y: 50)).boundingRect
        #expect(abs(rotated.minY - 50) < 0.001)
        #expect(abs(rotated.maxY - 60) < 0.001)
        #expect(abs(rotated.midX - 50) < 0.001)
    }

    /// 円弧の向き: スイカの皮は下に膨らむ半円（上の切り口の y = 38 から、下へ半径 44 まで）
    @Test
    func suikaArcBulgesDownward() throws {
        let rind = try #require(IllustrationArt.parts(for: .suika).first).path.boundingRect
        #expect(abs(rind.minY - 38) < 0.001)
        #expect(abs(rind.maxY - 82) < 0.001)
        #expect(abs(rind.minX - 10) < 0.001)
        #expect(abs(rind.maxX - 98) < 0.001)
    }

    /// ヒントの目は 2 つの目（白目・黒目・光・眉）で、線の太さを含めて横長の枠に収まる
    @Test
    func hintEyesFitTheirCanvas() {
        let parts = IllustrationArt.hintEyes
        #expect(parts.count == 8)
        let canvas = CGRect(origin: .zero, size: IllustrationArt.hintEyesCanvasSize)
        for part in parts {
            let painted = part.path.boundingRect.insetBy(dx: -part.lineWidth / 2, dy: -part.lineWidth / 2)
            #expect(canvas.contains(painted), "目の部品が枠の外に出ている: \(painted)")
        }
    }

    /// ヒントの目の白目と眉は、ダークの面でも見える線の色。黒目の輪郭線は絵と同じ
    @Test
    func hintEyesUseLinesVisibleOnSurface() {
        let parts = IllustrationArt.hintEyes
        #expect(parts.filter { $0.stroke == Palette.artLineOnSurface }.count == 4)
        #expect(parts.filter { $0.stroke == Palette.artOutline && $0.lineWidth == Metrics.artOutlineWidth }.count == 2)
    }

    /// 横長の枠の部品を描くときは、縦横比を保って真ん中に寄せる
    @Test
    func partsFitIsCenteredAndKeepsAspect() {
        let fit = IllustrationPartsView.fit(canvas: CGRect(x: 0, y: 0, width: 108, height: 54), into: CGSize(width: 100, height: 100))
        #expect(abs(fit.scale - 100.0 / 108.0) < 0.0001)
        #expect(abs(fit.offset.x) < 0.0001)
        #expect(abs(fit.offset.y - (100 - 54 * 100.0 / 108.0) / 2) < 0.0001)
    }

    /// 原点が 0 でない枠（ぴったりの枠）は、枠の左上が描く場所の左上に来る
    @Test
    func partsFitMovesTheCanvasOriginToTheTopLeft() {
        let canvas = CGRect(x: 10, y: 20, width: 80, height: 80)
        let fit = IllustrationPartsView.fit(canvas: canvas, into: CGSize(width: 160, height: 160))
        #expect(abs(fit.scale - 2) < 0.0001)
        // 枠の左上 (10, 20) は (0, 0) に、右下 (90, 100) は (160, 160) に来る
        #expect(abs(fit.offset.x + canvas.minX * fit.scale) < 0.0001)
        #expect(abs(fit.offset.y + canvas.minY * fit.scale) < 0.0001)
        #expect(abs(fit.offset.x + canvas.maxX * fit.scale - 160) < 0.0001)
        #expect(abs(fit.offset.y + canvas.maxY * fit.scale - 160) < 0.0001)
    }

    /// 改訂版の引き継ぎの一式（`3-illustrations/data/shapes.json` の `cardBox`）の [x, y, 一辺]。
    /// 一式の座標は原点が (-4, -4) の枠なので、アプリの座標（`convert.py` が 4 ずつ足す）では x と y に 4 を足した値になる
    private let handoffCardBoxes: [Picture: [CGFloat]] = [
        .cat: [5.4, 5.4, 89.2], .dog: [5.6, 10.6, 88.8], .rabbit: [2.0, -0.5, 96.1], .panda: [9.4, 11.4, 81.2],
        .frog: [9.4, 12.9, 81.2], .chick: [8.9, 10.4, 82.2], .fox: [5.4, 3.4, 89.2], .penguin: [8.8, 18.8, 82.4],
        .apple: [7.0, 4.0, 86.0], .strawberry: [10.0, 12.5, 80.1], .bear: [9.4, 12.4, 81.2], .pig: [8.7, 16.4, 82.6],
        .suika: [3.4, 9.4, 93.2], .star: [5.5, 3.3, 89.0]
    ]

    /// 一式の表と同じとみなす差。一式は小数 1 桁に丸めてあり、回した楕円（イヌ・ウサギ・ペンギン・ブタ）と星の角の測り方の違いで、
    /// 0.12 ほどずれる（108 の枠で 0.1% ほど。カードの上では 0.1pt ほどなので、見た目は変わらない）
    private let cardBoxTolerance: CGFloat = 0.15

    /// 部品から求めたぴったりの枠は、一式の表と同じ
    @Test(arguments: Picture.allCases)
    func cardBoxMatchesTheHandoff(picture: Picture) throws {
        let expected = try #require(handoffCardBoxes[picture])
        try #require(expected.count == 3)
        let box = IllustrationArt.cardBox(for: picture)
        #expect(abs(box.minX - (expected[0] + 4)) < cardBoxTolerance, "\(picture): \(box)")
        #expect(abs(box.minY - (expected[1] + 4)) < cardBoxTolerance, "\(picture): \(box)")
        #expect(abs(box.width - expected[2]) < cardBoxTolerance, "\(picture): \(box)")
        #expect(box.width == box.height, "\(picture) は正方形")
    }

    /// ぴったりの枠は、線の太さを含めて描いた部分をすべて囲む（カードで絵が切れない）
    @Test(arguments: Picture.allCases)
    func cardBoxContainsEveryPaintedPart(picture: Picture) {
        let box = IllustrationArt.cardBox(for: picture)
        for part in IllustrationArt.parts(for: picture) {
            let painted = IllustrationArt.paintedBounds(of: part)
            #expect(box.contains(painted), "\(picture) の部品が枠の外に出ている: \(painted)")
        }
    }

    /// 正方形の枠は、描いた部分の長い辺に余白を足した一辺で、描いた部分の真ん中に置く
    @Test
    func squareBoxCentersAndPads() {
        let box = IllustrationArt.squareBox(around: CGRect(x: 10, y: 20, width: 60, height: 40), margin: 1.5)
        #expect(box == CGRect(x: 8.5, y: 8.5, width: 63, height: 63))
    }
}
