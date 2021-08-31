//
//  DownloadDocumentsButton.swift
//  IdentHubSDK
//

import UIKit

/// UIButton for download all documents at once.
final internal class DownloadDocumentsButton: UIButton {

    private enum Constants {
        static let fontSize: CGFloat = 12
        static let height: CGFloat = 36
        static let width: CGFloat = 192
        static let cornerRadius: CGFloat = 4
        static let bigInset: CGFloat = 16
        static let normalInset: CGFloat = 8
    }

    /// Action to download all documents.
    var downloadAllDocumentsAction: (() -> Void)?

    /// Loading documents indicator
    private var activityIndicator = UIActivityIndicatorView(style: .gray)

    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    // MARK: - Public methods -

    func stopAnimation() {
        activityIndicator.stopAnimating()

        self.isEnabled = true
    }

    // MARK: - Internal methods -

    private func configureUI() {
        backgroundColor = UIColor.sdkColor(.base05)
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true

        addConstraints { [
            $0.equalConstant(.height, Constants.height),
            $0.equalConstant(.width, Constants.width)
        ]
        }

        titleLabel?.font = .systemFont(ofSize: Constants.fontSize)
        setTitle(Localizable.Common.downloadAllDocuments, for: .normal)
        setTitleColor(.sdkColor(.base75), for: .normal)

        let image = UIImage.sdkImage(.downloadDocument, type: DownloadDocumentsButton.self)
        setImage(image, for: .normal)
        tintColor = .sdkColor(.base75)
        semanticContentAttribute = .forceRightToLeft
        imageEdgeInsets = UIEdgeInsets(top: Constants.normalInset, left: Constants.bigInset, bottom: Constants.normalInset, right: Constants.normalInset)

        activityIndicator.center = CGPoint(x: Constants.width / 2, y: Constants.height / 2)
        addSubview(activityIndicator)

        addTarget(self, action: #selector(downloadAllDocuments), for: .touchUpInside)
        addTarget(self, action: #selector(highlightButton), for: .touchDown)
    }

    @objc private func downloadAllDocuments() {
        activityIndicator.startAnimating()
        self.isEnabled = false

        downloadAllDocumentsAction?()
        backgroundColor = UIColor.sdkColor(.base05)
    }

    @objc private func highlightButton() {
        backgroundColor = UIColor.sdkColor(.primaryAccent)
    }
}
