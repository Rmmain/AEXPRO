//
//  ContentView.swift
//  AEXPRO
//
//  KIS AI Monitor shell — left pane is the result viewport.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 0) {
            headerBar
            HStack(spacing: 0) {
                ResultViewportView()
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 1)
                sidePanel
                    .frame(width: 400)
            }
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }

    private var headerBar: some View {
        HStack {
            Text("KIS AI Monitor")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black)
    }

    /// Compact companion panel so the viewport is seen in context.
    /// Visual chrome only — not a functional rewrite of the chat.
    private var sidePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ESIAKIS · Échange enregistré")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.55))
                    HStack(spacing: 6) {
                        Circle().fill(Color.orange).frame(width: 7, height: 7)
                        Text("Esiakis (KIS Native)")
                            .font(.system(size: 13, weight: .semibold))
                    }
                }
                Spacer()
                Text("Esiakis (KIS Native)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(MonitorTheme.signal)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.07, green: 0.16, blue: 0.22))
                .overlay(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ESIAKIS · échange de création")
                            .font(.system(size: 14, weight: .bold))
                        Text("Le panneau de gauche montre le résultat 3D de cette demande. Fond studio, grille et chrome ont été retravaillés pour une lecture plus claire.")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.78))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                }
                .frame(minHeight: 120)
                .padding(.horizontal, 12)

            Spacer()
        }
        .background(Color(red: 0.05, green: 0.06, blue: 0.08))
    }
}

#Preview {
    ContentView()
}
