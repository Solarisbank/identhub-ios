//
//  DocumentPreviewViewController.swift
//  IdentHubSDK
//

import UIKit
import WebKit

/// UIViewController which displays documents preview.
final internal class DocumentPreviewViewController: UIViewController {

    private var documentData: Data

    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.backgroundColor = .sdkColor(.base05)
        return webView
    }()

    init(documentData: Data) {
        self.documentData = documentData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {
        view.addSubview(webView)
        webView.addConstraints { $0.equalEdges() }
        webView.load(documentData, mimeType: "application/pdf", characterEncodingName: "utf-8", baseURL: URL(fileURLWithPath: ""))
    }
}
