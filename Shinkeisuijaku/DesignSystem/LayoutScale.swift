//
//  LayoutScale.swift
//  Shinkeisuijaku
//
//  iPad で画面全体を大きくする倍率。引き継ぎブックの寸法と文字は iPhone の画面の値なので、iPad の全画面ではそのままだと
//  画面の大きさの割に小さく、まわりが大きく空く。iPad の全画面のときだけ、画面の大きさに合わせた倍率を寸法と文字に掛けて、
//  iPhone の見た目をそのまま大きくする（iPhone では倍率 1 のままで、見た目を変えない）。
//  倍率は環境値（`layoutScale`）で配り、画面は寸法のトークンの長さに掛けて使う（比率・透明度・角度・絵の枠の中の座標には掛けない）。
//

import SwiftUI

/// 寸法と文字に掛ける倍率の決まり（View から切り離して確かめられるようにする）
enum LayoutScale {
    /// 倍率 1 の画面の大きさ（iPhone 17 Pro の縦の画面。iPhone の見た目はこの大きさで確かめている）
    static let referenceSize = CGSize(width: 402, height: 874)
    /// 倍率の上限（今の iPad で一番大きい 13 インチの縦で、およそ 1.57）
    static let maximum: CGFloat = 1.6

    /// 倍率を求める。iPad の全画面（横も縦も regular）のときだけ、画面の幅と高さのうち、基準の画面に比べて伸びが小さい方に合わせる
    /// （縦の画面の iPad は高さの伸びの方が小さいので、高さに合わせると縦にはみ出さない）。1 から `maximum` までに収める。
    /// iPhone と、iPad で窓を狭くしたとき（横が compact）は 1
    /// - Parameters:
    ///   - screenSize: 窓の大きさ（安全領域を含む）
    static func value(
        screenSize: CGSize,
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass?
    ) -> CGFloat {
        guard horizontalSizeClass == .regular, verticalSizeClass == .regular,
              screenSize.width > 0, screenSize.height > 0 else {
            return 1
        }
        let ratio = min(screenSize.width / referenceSize.width, screenSize.height / referenceSize.height)
        return min(max(ratio, 1), maximum)
    }
}

extension EnvironmentValues {
    /// 寸法と文字に掛ける倍率（iPhone は 1。iPad の全画面では 1 より大きい）。`providesLayoutScale()` が窓の大きさから求めて配る
    @Entry var layoutScale: CGFloat = 1
}

extension View {
    /// 窓の大きさと画面の幅の区分から倍率を求めて、中の画面に配る。アプリの一番外（窓の中身）に 1 回だけ付ける
    func providesLayoutScale() -> some View {
        modifier(LayoutScaleProvider())
    }
}

/// 窓の大きさを読んで、倍率を環境値に入れる
private struct LayoutScaleProvider: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    func body(content: Content) -> some View {
        GeometryReader { proxy in
            let insets = proxy.safeAreaInsets
            let screenSize = CGSize(
                width: proxy.size.width + insets.leading + insets.trailing,
                height: proxy.size.height + insets.top + insets.bottom
            )
            content
                // 中身の大きさと置き方は変えない（読み取りの枠いっぱいに、真ん中に置く）
                .frame(width: proxy.size.width, height: proxy.size.height)
                .environment(
                    \.layoutScale,
                    LayoutScale.value(
                        screenSize: screenSize,
                        horizontalSizeClass: horizontalSizeClass,
                        verticalSizeClass: verticalSizeClass
                    )
                )
        }
    }
}
