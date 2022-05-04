//
//  DocumentItemInfoCell.swift
//  IdentHubSDK
//

import UIKit

class DocumentItemInfoCell: UITableViewCell {

    // MARK: - Outlets -
    @IBOutlet var borderView: UIView! {
        didSet {
            configureBorderView()
        }
    }
    @IBOutlet var contentTitle: UILabel!
    @IBOutlet var contentTF: UITextField!
    @IBOutlet var infoLbl: UILabel!
    @IBOutlet var infoIcon: UIImageView!

    var didEdited: ((DocumentItemInfo?) -> Void)?
    private let datePicker: UIDatePicker = UIDatePicker()
    private var cellContent: DocumentItemInfo?

    // MARK: - Public methods -
    func configure(with data: DocumentItemInfo) {

        cellContent = data
        contentTitle.text = data.title

        configureContentField(with: data)
        contentDidChange()
    }
}

// MARK: - Text field delegate methods -

extension DocumentItemInfoCell: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text?.trimmingCharacters(in: CharacterSet.whitespaces) {

            cellContent?.content = text

            didEdited?(cellContent)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        cellContent?.content = text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
        contentDidChange()
        return true
    }
}

// MARK: - Internal methods -
extension DocumentItemInfoCell {

    private func configureBorderView() {
        borderView.layer.borderWidth = 2
        borderView.layer.borderColor = UIColor.sdkColor(.base100).cgColor
        borderView.layer.cornerRadius = 5
    }

    private func configureContentField(with data: DocumentItemInfo) {

        contentTF.text = data.content

        if data.type != .number {

            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }

            datePicker.datePickerMode = .date
            datePicker.timeZone = TimeZone(secondsFromGMT: 0)

            if let date = data.prefilledDate {
                datePicker.date = date
            }

            contentTF.text = data.content
            contentTF.inputView = datePicker
            contentTF.inputAccessoryView = createToolbar()
        } else {
            contentTF.inputView = nil
            contentTF.inputAccessoryView = nil
        }

        contentTF.delegate = self
    }

    private func createToolbar() -> UIToolbar {

        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))

        toolBar.sizeToFit()

        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))

        toolBar.setItems([doneBtn], animated: false)

        return toolBar
    }

    @objc func donePressed() {
        contentTF.text = datePicker.date.defaultDateString()
        cellContent?.prefilledDate = datePicker.date
        contentDidChange()
        self.endEditing(true)
    }

    private func configureInformUI(_ contentStatus: DocumentItemInfoStatus) {
        infoLbl.text = contentStatus.description
        infoLbl.textColor = obtainInfoTextColor(contentStatus)
        infoIcon.image = obtainInfoIcon(contentStatus)
    }

    private func obtainInfoIcon(_ contentStatus: DocumentItemInfoStatus) -> UIImage? {
        let iconName = (contentStatus == DocumentItemInfoStatus.valid) ? "document_info_icon" : "document_info_warning_icon"

        return UIImage(named: iconName, in: Bundle.current, compatibleWith: nil)
    }

    private func obtainInfoTextColor(_ status: DocumentItemInfoStatus) -> UIColor {
        (status == DocumentItemInfoStatus.valid) ? UIColor.sdkColor(.secondaryAccentLighten) : UIColor.sdkColor(.primaryAccentLighten)
    }

    private func contentDidChange() {
        guard let _ = cellContent?.type else { return }
        configureInformUI(cellContent!.getStatus())
    }
}
 
