//
//  ResultViewportView.swift
//  AEXPRO
//
//  Left pane: visual result of the user request (3D / pièce).
//  Style-only treatment — studio lighting, grid, readable chrome.
//

import SwiftUI

struct ResultViewportView: View {
    var pieceCount: Int = 0
    var engineName: String = "KIS 3D ENGINE"
    var engineProfile: String = "Base Easy"

    var body: some View {
        ZStack {
            StudioBackdrop()
            PerspectiveGrid()
            CenterGlow()
            if pieceCount == 0 {
                EmptyResultState()
            }
            VStack {
                topChrome
                Spacer()
                bottomChrome
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 0, style: .continuous))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.35), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 18)
                .allowsHitTesting(false)
        }
    }

    private var topChrome: some View {
        HStack(alignment: .top, spacing: 12) {
            EngineStatusBadge(
                engineName: engineName,
                engineProfile: engineProfile,
                pieceCount: pieceCount
            )
            Spacer()
            ViewportToolbar()
        }
    }

    private var bottomChrome: some View {
        HStack(alignment: .bottom) {
            AxisGizmo()
            Spacer()
            HintCapsule()
        }
    }
}

// MARK: - Backdrop

private struct StudioBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    MonitorTheme.studioLift,
                    MonitorTheme.studioMid,
                    MonitorTheme.studioDeep
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [
                    MonitorTheme.signalSoft.opacity(0.16),
                    Color.clear
                ],
                center: UnitPoint(x: 0.5, y: 0.42),
                startRadius: 10,
                endRadius: 380
            )
            LinearGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.45)],
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

private struct CenterGlow: View {
    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.10),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 180
                )
            )
            .frame(width: 420, height: 220)
            .offset(y: 40)
            .blur(radius: 8)
            .allowsHitTesting(false)
    }
}

private struct PerspectiveGrid: View {
    var body: some View {
        Canvas { context, size in
            let horizonY = size.height * 0.46
            let vanish = CGPoint(x: size.width * 0.5, y: horizonY)
            let floorTop = horizonY + 8
            let cols = 16
            let rows = 10

            var floor = Path()
            floor.move(to: CGPoint(x: 0, y: size.height))
            floor.addLine(to: CGPoint(x: size.width, y: size.height))
            floor.addLine(to: CGPoint(x: size.width * 0.72, y: floorTop))
            floor.addLine(to: CGPoint(x: size.width * 0.28, y: floorTop))
            floor.closeSubpath()
            context.fill(
                floor,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.03),
                        Color.black.opacity(0.15)
                    ]),
                    startPoint: CGPoint(x: size.width / 2, y: floorTop),
                    endPoint: CGPoint(x: size.width / 2, y: size.height)
                )
            )

            for i in 0...cols {
                let t = CGFloat(i) / CGFloat(cols)
                let xBottom = size.width * t
                var line = Path()
                line.move(to: CGPoint(x: xBottom, y: size.height))
                line.addLine(to: vanish)
                context.stroke(
                    line,
                    with: .color(MonitorTheme.gridLine),
                    lineWidth: i == cols / 2 ? 1.1 : 0.6
                )
            }

            for j in 0...rows {
                let depth = CGFloat(j) / CGFloat(rows)
                let y = floorTop + pow(depth, 1.35) * (size.height - floorTop)
                let spread = 0.22 + depth * 0.28
                var line = Path()
                line.move(to: CGPoint(x: size.width * (0.5 - spread), y: y))
                line.addLine(to: CGPoint(x: size.width * (0.5 + spread), y: y))
                context.stroke(
                    line,
                    with: .color(j == 0 ? MonitorTheme.gridAccent : MonitorTheme.gridLine),
                    lineWidth: j == 0 ? 1.2 : 0.55
                )
            }
        }
        .allowsHitTesting(false)
        .opacity(0.9)
    }
}

// MARK: - Empty state

private struct EmptyResultState: View {
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(MonitorTheme.signal.opacity(0.12))
                    .frame(width: 92, height: 92)
                Circle()
                    .stroke(MonitorTheme.signal.opacity(0.35), lineWidth: 1)
                    .frame(width: 92, height: 92)
                Image(systemName: "cube.transparent")
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(MonitorTheme.signal)
            }
            Text("Résultat de la demande")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(MonitorTheme.chromeText)
            Text("Le modèle 3D apparaîtra ici dès qu’une pièce\nsera générée à partir de votre prompt.")
                .font(.system(size: 13, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundStyle(MonitorTheme.chromeMuted)
                .lineSpacing(3)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 26)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(MonitorTheme.chromeStroke, lineWidth: 1)
        )
        .shadow(color: MonitorTheme.signal.opacity(0.12), radius: 28, y: 8)
        .offset(y: -12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Aucun modèle. Le résultat de la demande s’affichera dans cette vue 3D.")
    }
}

// MARK: - Chrome

private struct EngineStatusBadge: View {
    let engineName: String
    let engineProfile: String
    let pieceCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Circle()
                    .fill(MonitorTheme.signal)
                    .frame(width: 8, height: 8)
                    .shadow(color: MonitorTheme.signal.opacity(0.9), radius: 5)
                Text("\(engineName)  ·  \(engineProfile)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(MonitorTheme.chromeText)
            }
            Text(pieceCount == 0 ? "Aucune pièce" : "\(pieceCount) pièce(s)")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(MonitorTheme.chromeMuted)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(MonitorTheme.chromeStroke, lineWidth: 1)
        )
    }
}

private struct ViewportToolbar: View {
    var body: some View {
        HStack(spacing: 8) {
            tool("camera.metering.center.weighted", label: "Caméra")
            tool("cube", label: "Vue modèle")
            tool("grid", label: "Grille")
            tool("trash", label: "Effacer", destructive: true)
        }
        .padding(6)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(MonitorTheme.chromeStroke, lineWidth: 1))
    }

    private func tool(_ systemName: String, label: String, destructive: Bool = false) -> some View {
        Button(action: {}) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(destructive ? Color.red.opacity(0.85) : MonitorTheme.chromeText)
                .frame(width: 34, height: 34)
                .background(
                    Circle().fill(MonitorTheme.chromeFill)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

private struct AxisGizmo: View {
    var body: some View {
        HStack(spacing: 10) {
            axis("X", MonitorTheme.axisX)
            axis("Y", MonitorTheme.axisY)
            axis("Z", MonitorTheme.axisZ)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(MonitorTheme.chromeStroke, lineWidth: 1))
        .accessibilityHidden(true)
    }

    private func axis(_ label: String, _ color: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
    }
}

private struct HintCapsule: View {
    var body: some View {
        Text("Vue résultat  ·  pincer pour zoomer  ·  glisser pour orbiter")
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundStyle(MonitorTheme.chromeMuted)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(MonitorTheme.chromeStroke, lineWidth: 1))
    }
}

#Preview {
    ResultViewportView()
        .frame(width: 780, height: 720)
}
