import SwiftUI
import WebKit

struct ContentView: View {
    @StateObject private var browser = BrowserModel()
    @State private var showShare = false

    var body: some View {
        ZStack {
            Color(red: 0.025, green: 0.045, blue: 0.07).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("FAWAZPHO").font(.headline).foregroundStyle(.white)
                    Spacer()
                    Button { browser.reload() } label: { Image(systemName: "arrow.clockwise") }
                    Button { showShare = true } label: { Image(systemName: "square.and.arrow.up") }
                }
                .foregroundStyle(.white).padding(.horizontal).padding(.vertical, 10)
                WebView(model: browser)
            }
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(items: [browser.currentURL ?? URL(string: "https://www.fawazpho.com")!])
        }
    }
}

final class BrowserModel: ObservableObject {
    let webView: WKWebView
    @Published var currentURL: URL?
    init() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        let url = URL(string: "https://www.fawazpho.com")!
        currentURL = url
        webView.load(URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData))
    }
    func reload() { webView.reload() }
}

struct WebView: UIViewRepresentable {
    @ObservedObject var model: BrowserModel
    func makeCoordinator() -> Coordinator { Coordinator(model: model) }
    func makeUIView(context: Context) -> WKWebView {
        model.webView.navigationDelegate = context.coordinator
        return model.webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    final class Coordinator: NSObject, WKNavigationDelegate {
        let model: BrowserModel
        init(model: BrowserModel) { self.model = model }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { model.currentURL = webView.url }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController { UIActivityViewController(activityItems: items, applicationActivities: nil) }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
