//
//  MonitorTheme.swift
//  AEXPRO
//
//  Palette for the KIS AI Monitor result viewport.
//

import SwiftUI

enum MonitorTheme {
    /// Cool studio backdrop — reads as a 3D stage, not a blank page.
    static let studioDeep = Color(red: 0.07, green: 0.09, blue: 0.12)
    static let studioMid = Color(red: 0.13, green: 0.17, blue: 0.22)
    static let studioLift = Color(red: 0.18, green: 0.23, blue: 0.28)

    /// Cyan used across the live engine badge and empty-state glow.
    static let signal = Color(red: 0.35, green: 0.82, blue: 0.78)
    static let signalSoft = Color(red: 0.45, green: 0.78, blue: 0.92)

    static let gridLine = Color.white.opacity(0.07)
    static let gridAccent = Color(red: 0.35, green: 0.82, blue: 0.78).opacity(0.18)

    static let chromeFill = Color.white.opacity(0.08)
    static let chromeStroke = Color.white.opacity(0.16)
    static let chromeText = Color.white.opacity(0.92)
    static let chromeMuted = Color.white.opacity(0.58)

    static let axisX = Color(red: 0.95, green: 0.38, blue: 0.38)
    static let axisY = Color(red: 0.42, green: 0.86, blue: 0.52)
    static let axisZ = Color(red: 0.38, green: 0.62, blue: 0.98)
}
