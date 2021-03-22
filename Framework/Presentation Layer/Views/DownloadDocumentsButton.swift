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

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
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
        setTitleColor(.black, for: .normal)

        let image = UIImage.sdkImage(.downloadDocument, type: DownloadDocumentsButton.self)
        setImage(image, for: .normal)
        semanticContentAttribute = .forceRightToLeft
        imageEdgeInsets = UIEdgeInsets(top: Constants.normalInset, left: Constants.bigInset, bottom: Constants.normalInset, right: Constants.normalInset)

        addTarget(self, action: #selector(downloadAllDocuments), for: .touchUpInside)
    }

    @objc private func downloadAllDocuments() {
        downloadAllDocumentsAction?()
    }
}
