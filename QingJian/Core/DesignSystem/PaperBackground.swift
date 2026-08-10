import SwiftUI

struct PaperBackground: View {
    var showsArtwork: Bool = true

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                QingTheme.paper
                    .ignoresSafeArea()

                Circle()
                    .fill(QingTheme.apricot.opacity(0.22))
                    .frame(width: proxy.size.width * 0.78)
                    .blur(radius: 36)
                    .offset(x: proxy.size.width * 0.36, y: -proxy.size.height * 0.46)

                Circle()
                    .fill(QingTheme.mistGreen.opacity(0.14))
                    .frame(width: proxy.size.width * 0.92)
                    .blur(radius: 42)
                    .offset(x: -proxy.size.width * 0.42, y: proxy.size.height * 0.42)

                if showsArtwork {
                    Image("PlumBamboo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width * 1.36, height: proxy.size.height * 0.42)
                        .clipped()
                        .blendMode(.multiply)
                        .opacity(0.17)
                        .offset(x: proxy.size.width * 0.25, y: proxy.size.height * 0.38)
                        .accessibilityHidden(true)
                }

                PaperGrain()
                    .opacity(0.22)
                    .accessibilityHidden(true)
            }
        }
        .ignoresSafeArea()
    }
}

private struct PaperGrain: View {
    var body: some View {
        Canvas { context, size in
            for index in 0..<54 {
                let x = CGFloat((index * 43) % 97) / 97 * size.width
                let y = CGFloat((index * 71) % 101) / 101 * size.height
                let dotSize = CGFloat((index % 3) + 1) * 0.55
                let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                context.fill(Path(ellipseIn: rect), with: .color(QingTheme.pineInk.opacity(0.07)))
            }
        }
    }
}

#Preview {
    PaperBackground()
}
