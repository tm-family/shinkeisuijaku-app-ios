//
//  CardFaceLayoutTests.swift
//  ShinkeisuijakuTests
//
//  カードの表の中身の大きさ（改訂版の引き継ぎブックの「カードの中の絵」と「ひらがなカードの文字」）を確かめる。
//

import Foundation
@testable import Shinkeisuijaku
import Testing

struct CardFaceLayoutTests {
    /// 縦に長いカードでは、絵はカードの幅の 95%（高さの 98% より小さい）
    @Test
    func pictureFillsNinetyFivePercentOfTheWidth() {
        let layout = CardFaceLayout(cardSize: CGSize(width: 80, height: 110))
        #expect(layout.pictureSide == 80 * 0.95)
    }

    /// 横に広いカードで高さが足りないときは、絵を高さの 98% までにする
    @Test
    func pictureIsLimitedByTheHeight() {
        let layout = CardFaceLayout(cardSize: CGSize(width: 120, height: 100))
        #expect(layout.pictureSide == 100 * 0.98)
    }

    /// 言葉つきの絵は、高さから言葉の分（短辺の 24%）を引いた大きさまで。縦に長ければ幅の 95% のまま
    @Test
    func pictureWithWordLeavesRoomForTheWord() {
        let tall = CardFaceLayout(cardSize: CGSize(width: 80, height: 110))
        #expect(tall.pictureSideWithWord == 80 * 0.95)
        let square = CardFaceLayout(cardSize: CGSize(width: 100, height: 100))
        #expect(square.pictureSideWithWord == 100 - 100 * 0.24)
        #expect(square.pictureSideWithWord < square.pictureSide)
    }

    /// ひらがなの文字はカードの短辺の 88%、言葉は短辺の 15%
    @Test
    func letterAndWordFollowTheShortSide() {
        let layout = CardFaceLayout(cardSize: CGSize(width: 90, height: 120))
        #expect(layout.shortSide == 90)
        #expect(Typography.cardLetterRatio == 0.88)
        #expect(Typography.cardWordRatio == 0.15)
    }

    /// 大きさが無いカードでも、負の大きさにしない
    @Test
    func zeroSizeGivesZero() {
        let layout = CardFaceLayout(cardSize: .zero)
        #expect(layout.pictureSide == 0)
        #expect(layout.pictureSideWithWord == 0)
    }
}
