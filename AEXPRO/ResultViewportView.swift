//
//  ResultViewportView.swift
//  AEXPRO
//
//  Left pane: visual result of the user request (3D / pièce).
//  Studio lighting, a toggleable 3D-space grid, and sample elements that
//  can be placed in the scene from the toolbar.
//

import SwiftUI

struct ResultViewportView: View {
    var engineName: String = "KIS 3D ENGINE"
    var engineProfile: String = "Base Easy"

    /// The 3D-space floor grid is shown by default and can be toggled from the
    /// toolbar "Grille" button.
    @State private var showGrid = true
    /// Elements currently placed in the 3D space. Toggled from the toolbar.
    @State private var elements: [SceneElement] = []

    private var pieceCount: Int { elements.count }

    var body: some View {
        ZStack {
            StudioBackdrop()
            SceneFloor(showGrid: showGrid, elements: elements)
            CenterGlow()
            if elements.isEmpty {
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
            ViewportToolbar(
                showGrid: showGrid,
                hasElements: !elements.isEmpty,
                onToggleGrid: { withAnimation(.easeInOut(duration: 0.2)) { showGrid.toggle() } },
                onToggleElements: toggleElements,
                onClear: { withAnimation(.easeInOut(duration: 0.2)) { elements = [] } }
            )
        }
    }

    private var bottomChrome: some View {
        HStack(alignment: .bottom) {
            AxisGizmo()
            Spacer()
            HintCapsule()
        }
    }

    private func toggleElements() {
        withAnimation(.easeInOut(duration: 0.25)) {
            elements = elements.isEmpty ? SceneElement.sample : []
        }
    }
}

// MARK: - Scene model

/// A single element placed in the 3D viewport, expressed in floor coordinates.
/// `u` is the lateral position (-1 left … 1 right) and `depth` is the distance
/// from the viewer (0 far / near the horizon … 1 near / bottom of the stage).
struct SceneElement: Identifiable {
    let id = UUID()
    var u: CGFloat
    var depth: CGFloat
    var size: CGFloat
    var height: CGFloat
    var color: Color

    static let sample: [SceneElement] = [
        SceneElement(u: -0.45, depth: 0.72, size: 0.10, height: 1.0, color: MonitorTheme.signal),
        SceneElement(u:  0.12, depth: 0.55, size: 0.085, height: 1.35, color: MonitorTheme.signalSoft),
        SceneElement(u:  0.50, depth: 0.82, size: 0.11, height: 0.8, color: MonitorTheme.axisZ),
        SceneElement(u: -0.08, depth: 0.32, size: 0.06, height: 1.1, color: MonitorTheme.axisY),
        SceneElement(u:  0.34, depth: 0.42, size: 0.07, height: 0.95, color: MonitorTheme.axisX)
    ]
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

// MARK: - 3D space (grid + elements)

private struct SceneFloor: View {
    var showGrid: Bool
    var elements: [SceneElement]

    var body: some View {
        Canvas { context, size in
            let horizonY = size.height * 0.46
            let vanish = CGPoint(x: size.width * 0.5, y: horizonY)
            let floorTop = horizonY + 8

            // Project a floor coordinate (u, depth) to a screen point.
            func project(_ u: CGFloat, _ depth: CGFloat) -> CGPoint {
                let spread = 0.22 + depth * 0.28
                let x = size.width * (0.5 + u * spread)
                let y = floorTop + pow(depth, 1.35) * (size.height - floorTop)
                return CGPoint(x: x, y: y)
            }

            if showGrid {
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
                            Color.white.opacity(0.05),
                            Color.black.opacity(0.18)
                        ]),
                        startPoint: CGPoint(x: size.width / 2, y: floorTop),
                        endPoint: CGPoint(x: size.width / 2, y: size.height)
                    )
                )

                let cols = 16
                for i in 0...cols {
                    let t = CGFloat(i) / CGFloat(cols)
                    let xBottom = size.width * t
                    var line = Path()
                    line.move(to: CGPoint(x: xBottom, y: size.height))
                    line.addLine(to: vanish)
                    context.stroke(
                        line,
                        with: .color(i == cols / 2 ? MonitorTheme.gridAccent : Color.white.opacity(0.14)),
                        lineWidth: i == cols / 2 ? 1.6 : 0.9
                    )
                }

                let rows = 10
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
                        lineWidth: j == 0 ? 1.4 : 0.7
                    )
                }
            }

            // Draw elements from far to near so nearer cubes overlap correctly.
            for el in elements.sorted(by: { $0.depth < $1.depth }) {
                let base = project(el.u, el.depth)
                let left = project(el.u - el.size, el.depth)
                let right = project(el.u + el.size, el.depth)
                let w = max(10, right.x - left.x)
                let hgt = w * (0.9 * el.height + 0.3)
                let cx = base.x
                let by = base.y
                let dx = w * 0.28
                let dy = -w * 0.20

                let flb = CGPoint(x: cx - w / 2, y: by)
                let frb = CGPoint(x: cx + w / 2, y: by)
                let flt = CGPoint(x: cx - w / 2, y: by - hgt)
                let frt = CGPoint(x: cx + w / 2, y: by - hgt)
                let blt = CGPoint(x: flt.x + dx, y: flt.y + dy)
                let brt = CGPoint(x: frt.x + dx, y: frt.y + dy)
                let brb = CGPoint(x: frb.x + dx, y: frb.y + dy)

                let shadow = Path(ellipseIn: CGRect(x: cx - w * 0.62, y: by - w * 0.12, width: w * 1.24, height: w * 0.24))
                context.fill(shadow, with: .color(Color.black.opacity(0.30)))

                var rightFace = Path()
                rightFace.addLines([frb, frt, brt, brb])
                rightFace.closeSubpath()
                context.fill(rightFace, with: .color(el.color.opacity(0.55)))

                var topFace = Path()
                topFace.addLines([flt, frt, brt, blt])
                topFace.closeSubpath()
                context.fill(topFace, with: .color(el.color.opacity(0.95)))

                var frontFace = Path()
                frontFace.addLines([flb, frb, frt, flt])
                frontFace.closeSubpath()
                context.fill(frontFace, with: .color(el.color.opacity(0.75)))

                var edges = Path()
                edges.addLines([flb, frb, frt, flt, flb])
                edges.addLines([flt, blt, brt, frt])
                edges.addLines([frb, brb, brt])
                context.stroke(edges, with: .color(Color.white.opacity(0.40)), lineWidth: 1)
            }
        }
        .allowsHitTesting(false)
        .opacity(0.95)
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
            Text("Touchez « Éléments 3D » dans la barre d’outils pour\nafficher des pièces dans l’espace 3D.")
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
        .accessibilityLabel("Aucun modèle. Utilisez le bouton Éléments 3D pour afficher des pièces dans la vue 3D.")
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
    var showGrid: Bool
    var hasElements: Bool
    var onToggleGrid: () -> Void
    var onToggleElements: () -> Void
    var onClear: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            tool("camera.metering.center.weighted", label: "Caméra", action: {})
            tool("cube", label: "Éléments 3D", active: hasElements, action: onToggleElements)
            tool("grid", label: "Grille", active: showGrid, action: onToggleGrid)
            tool("trash", label: "Effacer", destructive: true, action: onClear)
        }
        .padding(6)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(MonitorTheme.chromeStroke, lineWidth: 1))
    }

    private func tool(
        _ systemName: String,
        label: String,
        active: Bool = false,
        destructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(iconColor(active: active, destructive: destructive))
                .frame(width: 34, height: 34)
                .background(
                    Circle().fill(active ? MonitorTheme.signal : MonitorTheme.chromeFill)
                )
                .overlay(
                    Circle()
                        .stroke(MonitorTheme.signal.opacity(active ? 0.9 : 0), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityValue(active ? "activé" : "désactivé")
    }

    private func iconColor(active: Bool, destructive: Bool) -> Color {
        if destructive { return Color.red.opacity(0.85) }
        return active ? MonitorTheme.studioDeep : MonitorTheme.chromeText
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
        Text("Grille & Éléments 3D dans la barre d’outils  ·  pincer pour zoomer")
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
