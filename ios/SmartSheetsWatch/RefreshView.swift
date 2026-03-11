import SwiftUI

/// iPhone'dan verileri yeniden çeken refresh ekranı.
struct RefreshView: View {
    @EnvironmentObject var session: WatchSessionManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                if session.isRefreshing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Yükleniyor...")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                } else {
                    Button(action: {
                        session.requestRefresh()
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                            Text("Yenile")
                                .font(.system(size: 13, weight: .semibold))
                        }
                    }
                    .buttonStyle(.plain)

                    Text("iPhone açık olmalı")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .navigationTitle("Senkronize Et")
        }
    }
}
