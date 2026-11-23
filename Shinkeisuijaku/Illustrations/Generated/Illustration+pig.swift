//
//  Illustration+pig.swift
//  Shinkeisuijaku
//
//  Tools/illustrations/convert.py が Tools/illustrations/illustrations.svg から書き出したコード。手で直さない。
//

import SwiftUI

extension IllustrationArt {
    /// ブタ（SVG の `<g id="pig">`）
    static let pig: [IllustrationPart] = [
        IllustrationPart(
            path: Path(ellipseIn: CGRect(x: 14, y: 27, width: 26, height: 18)).rotated(by: -38, around: CGPoint(x: 27, y: 36)),
            fill: Palette.artRose,
            stroke: Palette.artOutline,
            lineWidth: Metrics.artOutlineWidth,
            roundCap: false
        ),
        IllustrationPart(
            path: Path(ellipseIn: CGRect(x: 68, y: 27, width: 26, height: 18)).rotated(by: 38, around: CGPoint(x: 81, y: 36)),
            fill: Palette.artRose,
            stroke: Palette.artOutline,
            lineWidth: Metrics.artOutlineWidth,
            roundCap: false
        ),
        IllustrationPart(
            path: Path(ellipseIn: CGRect(x: 21, y: 32.5, width: 14, height: 9)).rotated(by: -38, around: CGPoint(x: 28, y: 37)),
            fill: Palette.artPink,
            stroke: Palette.artOutline,
            lineWidth: Metrics.artOutlineWidth,
            roundCap: false
        ),
        IllustrationPart(
            path: Path(ellipseIn: CGRect(x: 73, y: 32.5, width: 14, height: 9)).rotated(by: 38, around: CGPoint(x: 80, y: 37)),
            fill: Palette.artPink,
            stroke: Palette.artOutline,
            lineWidth: Metrics.artOutlineWidth,
            roundCap: false
        ),
        IllustrationPart(
            path: Path(ellipseIn: CGRect(x: 20, y: 30, width: 68, height: 68)),
            fill: Palette.artRose,
            stroke: Palette.artOutline,
            lineWidth: Metrics.artOutlineWidth,
            roundCap: false
        ),
        IllustrationPart(
            path: Path(ellipseIn: CGRect(x: 26, y: 67, width: 10, height: 10)),
            fill: Palette.artPink,
            stroke: Palette.artOutline,
            lineWidth: Metrics.artOutlineWidth,
            roundCap: false
        ),
        IllustrationPart(
            path: Path(ellipseIn: CGRect(x: 72, y: 67, width: 10, height: 10)),
            fill: Palette.artPink,
            stroke: Palette.artOutline,
            lineWidth: Metrics.artOutlineWidth,
            roundCap: false
        ),
        IllustrationPart(
            path: Path(ellipseIn: CGRect(x: 39, y: 63, width: 30, height: 22)),
            fill: Palette.artPink,
            stroke: Palette.artOutline,
            lineWidth: Metrics.artOutlineWidth,
            roundCap: false
        ),
        IllustrationPart(
            path: Path(ellipseIn: CGRect(x: 45.4, y: 70, width: 5.2, height: 8)),
            fill: Palette.artDark,
            stroke: Palette.artOutline,
            lineWidth: Metrics.artOutlineWidth,
            roundCap: false
        ),
        IllustrationPart(
            path: Path(ellipseIn: CGRect(x: 57.4, y: 70, width: 5.2, height: 8)),
            fill: Palette.artDark,
            stroke: Palette.artOutline,
            lineWidth: Metrics.artOutlineWidth,
            roundCap: false
        ),
        IllustrationPart(
            path: Path(ellipseIn: CGRect(x: 35.5, y: 53.5, width: 9, height: 9)),
            fill: Palette.artDark,
            stroke: Palette.artOutline,
            lineWidth: Metrics.artOutlineWidth,
            roundCap: false
        ),
        IllustrationPart(
            path: Path(ellipseIn: CGRect(x: 63.5, y: 53.5, width: 9, height: 9)),
            fill: Palette.artDark,
            stroke: Palette.artOutline,
            lineWidth: Metrics.artOutlineWidth,
            roundCap: false
        )
    ]
}
