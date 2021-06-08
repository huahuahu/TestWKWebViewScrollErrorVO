//
//  ViewController.swift
//  TestWebviewScrollVO
//
//  Created by tigerguo on 2021/5/20.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    private var observation: NSKeyValueObservation?

    let webView: WKWebView = {
        let webview = WKWebView(frame: .zero)
        webview.translatesAutoresizingMaskIntoConstraints = false
        webview.scrollView.isScrollEnabled = false
        return webview
    }()

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
//        scrollView.isScrollEnabled q= false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        return scrollView
    }()

    var sizeConstraint: [NSLayoutConstraint] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(webView)

        NSLayoutConstraint.activate([
            scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
        ])

        webView.navigationDelegate = self

        let url = Bundle.main.url(forResource: "test", withExtension: "html")!
        let data = try! Data(contentsOf: url)
        let html = String(data: data, encoding: .utf8)!

        webView.loadHTMLString(html, baseURL: URL(string: "about:blank")!)
//        print("\(html)")
        observeScrollView()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(printVO))
    }

    private func observeScrollView() {
      observation = webView.observe(\WKWebView.scrollView.contentSize, options: .new) { [weak self] _, changes in
        self?.handleScrollViewContentSizeChanged(changes.newValue)
      }
    }

    private func handleScrollViewContentSizeChanged(_ contentSize: CGSize?) {
      guard let contentSize = contentSize else {
        return
      }
        NSLayoutConstraint.deactivate(sizeConstraint)
        sizeConstraint = [
            webView.widthAnchor.constraint(equalToConstant: view.bounds.width),
            // The height is 1823.94 in iPhone XR
            // set height to 1823 would cause vo fail to scroll.
            // we need set height to 1824
            webView.heightAnchor.constraint(equalToConstant: 1823)
        ]
        NSLayoutConstraint.activate(sizeConstraint)
    }

    @objc func printVO() {
        print(webView.value(forKey: "recursiveDescription")!)
        webView.printVOElements()
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (_) in
            self.webView.printVOElements()
        }
    }

}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("\(#function)")

    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("\(#function) \(webView.scrollView.contentSize)")
//        webView.bounds = CGRect.init(origin: .zero, size: webView.scrollView.contentSize)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {

        }
    }

}

extension UIView {
    var accessibilityDescription: String {
        let basic =  "isAccessibilityElement: \(self.isAccessibilityElement), accessibilityLabel \(self.accessibilityLabel), accessibilityValue: \(accessibilityValue), accessibilityHint: \(accessibilityHint), accessibilityTraits \(accessibilityTraits)"
        var container = ""
        let count = self.accessibilityElements?.count ?? 0
        if count != 0 && count != 1 {
            fatalError()
        }
        container = ",elementsCount: \(self.accessibilityElements?.count ?? 0)"
        if let firstVO = accessibilityElements?.first as? NSObject {
            container.append("first vo:\(firstVO)")
            let mirror = Mirror(reflecting: firstVO)
            for child in mirror.children {
                container.append("\(child.label): \(child.value)")
            }
        }

        return basic + container
    }


    func printVOElements() {
        print("\(self), \(self.accessibilityDescription)")
        if let view = self as? UIView {
            for subView in view.subviews {
                subView.printVOElements()
            }

        }
    }

}
