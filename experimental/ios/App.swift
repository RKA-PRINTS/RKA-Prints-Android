import UIKit
import WebKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "RKA Prints", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = BrowserController()
        self.window = window
        window.makeKeyAndVisible()
    }
}

final class BrowserController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private let home = URL(string: "https://rkaprints.web.app/")!
    private let allowedHosts: Set<String> = ["rkaprints.web.app", "rka-prints-invoice-maker.firebaseapp.com", "rka-prints-invoice-maker.web.app"]
    private var webView: WKWebView!
    private var backItem: UIBarButtonItem!
    private var forwardItem: UIBarButtonItem!
    private var observations: [NSKeyValueObservation] = []
    private let progress = UIProgressView(progressViewStyle: .default)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false

        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        backItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(back))
        backItem.accessibilityLabel = "Back"
        forwardItem = UIBarButtonItem(image: UIImage(systemName: "chevron.forward"), style: .plain, target: self, action: #selector(forward))
        forwardItem.accessibilityLabel = "Forward"
        let reloadItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
        reloadItem.accessibilityLabel = "Reload website"
        let safari = UIBarButtonItem(image: UIImage(systemName: "safari"), style: .plain, target: self, action: #selector(openSafari))
        safari.accessibilityLabel = "Open in browser"
        toolbar.items = [backItem, .flexibleSpace(), forwardItem, .flexibleSpace(), reloadItem, .flexibleSpace(), safari]
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.tintColor = UIColor(red: 3/255, green: 131/255, blue: 113/255, alpha: 1)
        view.addSubview(webView)
        view.addSubview(toolbar)
        view.addSubview(progress)
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            progress.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            progress.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            progress.topAnchor.constraint(equalTo: webView.topAnchor)
        ])
        observations = [
            webView.observe(\.canGoBack, options: [.initial, .new]) { [weak self] view, _ in self?.backItem.isEnabled = view.canGoBack },
            webView.observe(\.canGoForward, options: [.initial, .new]) { [weak self] view, _ in self?.forwardItem.isEnabled = view.canGoForward },
            webView.observe(\.estimatedProgress, options: [.new]) { [weak self] view, _ in self?.progress.progress = Float(view.estimatedProgress) },
            webView.observe(\.isLoading, options: [.initial, .new]) { [weak self] view, _ in self?.progress.isHidden = !view.isLoading }
        ]
        webView.load(URLRequest(url: home))
    }

    @objc private func back() { webView.goBack() }
    @objc private func forward() { webView.goForward() }
    @objc private func reload() { if webView.url == nil { webView.load(URLRequest(url: home)) } else { webView.reload() } }
    @objc private func openSafari() { openExternal(webView.url ?? home) }

    private func isInternal(_ url: URL) -> Bool { url.scheme?.lowercased() == "https" && allowedHosts.contains(url.host?.lowercased() ?? "") }
    private func openExternal(_ url: URL) {
        guard ["http", "https", "mailto", "tel"].contains(url.scheme?.lowercased() ?? "") else { return }
        UIApplication.shared.open(url)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { decisionHandler(.cancel); return }
        if navigationAction.targetFrame?.isMainFrame == false { decisionHandler(.allow); return }
        if isInternal(url) {
            if navigationAction.targetFrame == nil { webView.load(navigationAction.request); decisionHandler(.cancel) }
            else { decisionHandler(.allow) }
        } else {
            if navigationAction.navigationType == .linkActivated { openExternal(url) }
            decisionHandler(.cancel)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if !navigationResponse.canShowMIMEType {
            decisionHandler(.cancel)
            showMessage("Open this download in your browser using the browser button below.")
        } else { decisionHandler(.allow) }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { showLoadError(error) }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { showLoadError(error) }
    private func showLoadError(_ error: Error) {
        if (error as NSError).code == NSURLErrorCancelled { return }
        showMessage("Unable to load the website. Check your internet connection and use Reload to try again.")
    }
    private func showMessage(_ message: String) {
        guard presentedViewController == nil else { return }
        let alert = UIAlertController(title: "RKA Prints", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        guard presentedViewController == nil else { completionHandler(); return }
        let alert = UIAlertController(title: "Website message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        present(alert, animated: true)
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        guard presentedViewController == nil else { completionHandler(false); return }
        let alert = UIAlertController(title: "Website confirmation", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(false) })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
        present(alert, animated: true)
    }
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        guard presentedViewController == nil else { completionHandler(nil); return }
        let alert = UIAlertController(title: "Website input", message: prompt, preferredStyle: .alert)
        alert.addTextField { $0.text = defaultText }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(nil) })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(alert.textFields?.first?.text) })
        present(alert, animated: true)
    }
}
