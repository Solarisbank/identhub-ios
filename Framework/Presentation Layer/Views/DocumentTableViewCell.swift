//
//  DocumentTableViewCell.swift
//  IdentHubSDK
//

import UIKit

/// UITableViewCell which display a cell for a single document.
final internal class DocumentTableViewCell: UITableViewCell {

    /// DocumentTableViewCell reuse identifier.
    static let ReuseIdentifier = "DocumentTableViewCell"

    enum Constants {
        enum FontSize {
            static let normal: CGFloat = 14
            static let small: CGFloat = 10
        }

        enum ConstraintsOffset {
            static let extended: CGFloat = 40
            static let normal: CGFloat = 12
            static let small: CGFloat = 8
            static let tiny: CGFloat = 4
            static let sides: CGFloat = 16
        }

        enum Size {
            static let cornerRadius: CGFloat = 4
            static let height: CGFloat = 36
            static let width: CGFloat = 36
            static let heightSmall: CGFloat = 20
            static let widthSmall: CGFloat = 20
        }
    }

    /// The method that will fire when the preview button is clicked.
    var previewAction: ((_ cell: DocumentTableViewCell) -> Void)?

    /// The method that will fire when the download button is clicked.
    var downloadAction: ((_ cell: DocumentTableViewCell) -> Void)?

    private lazy var documentImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.sdkColor(.base100)
        label.font = label.font.withSize(Constants.FontSize.normal)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var fileNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.sdkColor(.base50)
        label.font = label.font.withSize(Constants.FontSize.small)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var previewActivityView: UIActivityIndicatorView = {
        UIActivityIndicatorView(style: .gray)
    }()

    private lazy var previewDocumentButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.sdkColor(.base05)
        let layer = button.layer
        layer.cornerRadius = Constants.Size.cornerRadius
        layer.masksToBounds = true
        let image = UIImage.sdkImage(.seeDocument, type: DocumentTableViewCell.self)
        button.setImage(image, for: .normal)
        previewActivityView.center = CGPoint(x: Constants.Size.width / 2, y: Constants.Size.height / 2)
        button.addSubview(previewActivityView)
        return button
    }()

    private lazy var downloadActivityView: UIActivityIndicatorView = {
        UIActivityIndicatorView(style: .gray)
    }()

    private lazy var downloadDocumentButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.sdkColor(.base05)
        let layer = button.layer
        layer.cornerRadius = Constants.Size.cornerRadius
        layer.masksToBounds = true
        let image = UIImage.sdkImage(.downloadDocument, type: DocumentTableViewCell.self)
        button.setImage(image, for: .normal)
        downloadActivityView.center = CGPoint(x: Constants.Size.width / 2, y: Constants.Size.height / 2)
        button.addSubview(downloadActivityView)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        contentView.backgroundColor = .sdkColor(.black0)

        contentView.addSubviews([
            downloadDocumentButton,
            previewDocumentButton,
            titleLabel,
            fileNameLabel,
            documentImageView
        ])

        downloadDocumentButton.addConstraints { [
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.sides),
            $0.equal(.top, constant: Constants.ConstraintsOffset.small),
            $0.equalConstant(.height, Constants.Size.height),
            $0.equalConstant(.width, Constants.Size.width)
        ]
        }

        previewDocumentButton.addConstraints { [
            $0.equalTo(downloadDocumentButton, .trailing, .leading, constant: -Constants.ConstraintsOffset.sides),
            $0.equalTo(downloadDocumentButton, .centerY, .centerY),
            $0.equalConstant(.height, Constants.Size.height),
            $0.equalConstant(.width, Constants.Size.width)
        ]
        }

        titleLabel.addConstraints { [
            $0.equalTo(previewDocumentButton, .trailing, .leading, constant: -Constants.ConstraintsOffset.sides),
            $0.equalTo(previewDocumentButton, .centerY, .centerY)
        ]
        }

        fileNameLabel.addConstraints { [
            $0.equalTo(titleLabel, .top, .bottom, constant: Constants.ConstraintsOffset.tiny),
            $0.equalTo(titleLabel, .leading, .leading),
            $0.equalTo(titleLabel, .trailing, .trailing),
            $0.equal(.bottom, constant: -Constants.ConstraintsOffset.small)
        ]
        }

        documentImageView.addConstraints { [
            $0.equalTo(titleLabel, .trailing, .leading, constant: -Constants.ConstraintsOffset.normal),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.sides),
            $0.equalConstant(.height, Constants.Size.heightSmall),
            $0.equalConstant(.width, Constants.Size.widthSmall),
            $0.equalTo(downloadDocumentButton, .centerY, .centerY)
        ]
        }

        previewDocumentButton.addTarget(self, action: #selector(previewButtonClicked), for: .touchUpInside)
        downloadDocumentButton.addTarget(self, action: #selector(downloadButtonClicked), for: .touchUpInside)
        downloadDocumentButton.addTarget(self, action: #selector(highlightDownloadButton), for: .touchDown)
    }

    @objc private func previewButtonClicked() {
        previewAction?(self)

        previewActivityView.startAnimating()
        previewDocumentButton.isEnabled = false
    }

    @objc private func downloadButtonClicked() {
        downloadAction?(self)
        downloadDocumentButton.backgroundColor = UIColor.sdkColor(.base05)

        downloadActivityView.startAnimating()
        downloadDocumentButton.isEnabled = false
    }

    @objc private func highlightDownloadButton() {
        downloadDocumentButton.backgroundColor = UIColor.sdkColor(.primaryAccent)
    }

    /// Set up document cell.
    ///
    /// - Parameters:
    ///     - document: Document fetched in the cell.
    ///     - isDocumentSigned: Whether the document is signed.
    func setCell(document: ContractDocument, isDocumentSigned: Bool) {
        titleLabel.attributedText = document.documentType.withBoldText(document.documentType)
        fileNameLabel.text = document.name

        if isDocumentSigned {
            documentImageView.image = UIImage.sdkImage(.documentSigned, type: DocumentTableViewCell.self)?.withRenderingMode(.alwaysTemplate)
            documentImageView.tintColor = .sdkColor(.success)
        } else {
            documentImageView.image = UIImage.sdkImage(.documentNotSigned, type: DocumentTableViewCell.self)?.withRenderingMode(.alwaysTemplate)
            documentImageView.tintColor = .sdkColor(.base25)
        }
    }

    func stopActivityAnimation() {
        previewDocumentButton.isEnabled = true
        downloadDocumentButton.isEnabled = true

        previewActivityView.stopAnimating()
        downloadActivityView.stopAnimating()
    }
}
