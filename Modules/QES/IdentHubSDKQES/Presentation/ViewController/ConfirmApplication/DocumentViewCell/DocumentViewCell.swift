//
//  DocumentViewCell.swift
//  IdentHubSDK
//

import UIKit
import IdentHubSDKCore

class DocumentViewCell: UITableViewCell {
    
    /// Possible document cell view states.
    enum State {
        case normal
        case downloading
    }
    
    // MARK: - Outlets -

    @IBOutlet var documentTitle: UILabel!
    @IBOutlet var shareButtonIcon: UIImageView!
    @IBOutlet var downloadIndicatorView: UIActivityIndicatorView!
    @IBOutlet var downloadBtn: UIButton!
    
    /// The method that will fire when the preview button is clicked.
    var previewAction: (() -> Void)?

    /// The method that will fire when the download button is clicked.
    var downloadAction: (() -> Void)?
    
    /// The current state of the document cell view.
    var state: State = .normal {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 13, right: 0)
        contentView.frame = contentView.frame.inset(by: margins)
    }
    
    
    // MARK: - Public methods -
    
    func didFinishDownloading() {
        state = .normal
    }
    
    func configure(with document: ContractDocument) {
        documentTitle.text = document.name
    }
    
    // MARK: - Actions -
    
    @IBAction func didClickShare(_ sender: UIButton) {
        downloadAction?()
    }
    
    @IBAction func didClickView(_ sender: UIButton) {
        previewAction?()
    }
}

// MARK: - Private -

private extension DocumentViewCell {
    
    private func configureUI() {
        documentTitle.text = Localizable.SignDocuments.ConfirmApplication.docItemTitle
        state = .normal
    }
    
    private func updateUI() {
        switch state {
        case .normal:
            shareButtonIcon.isHidden = false
            downloadIndicatorView.isHidden = true
            downloadIndicatorView.stopAnimating()
            downloadBtn.isEnabled = true
        case .downloading:
            shareButtonIcon.isHidden = true
            downloadIndicatorView.isHidden = false
            downloadIndicatorView.startAnimating()
            downloadBtn.isEnabled = false
        }
    }
}
