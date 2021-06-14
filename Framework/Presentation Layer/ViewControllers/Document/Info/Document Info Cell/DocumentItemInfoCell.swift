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
        configureInformUI(data.content.isEmpty)
    }
}

// MARK: - Text field delegate methods -

extension DocumentItemInfoCell: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        cellContent?.content = textField.text ?? ""

        didEdited?(cellContent)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)

        contentDidChanged(text)

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

            if let date = data.prefilledDate {
                datePicker.date = date
            }

            contentTF.text = data.content
            contentTF.inputView = datePicker
            contentTF.inputAccessoryView = createToolbar()
        }

        contentTF.delegate = self
    }

    private func createToolbar() -> UIToolbar {

        let toolBar = UIToolbar()

        toolBar.sizeToFit()

        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))

        toolBar.setItems([doneBtn], animated: true)

        return toolBar
    }

    @objc func donePressed() {
        contentTF.text = datePicker.date.defaultDateString()
        cellContent?.prefilledDate = datePicker.date
        contentDidChanged(contentTF.text)
        self.endEditing(true)
    }

    private func configureInformUI(_ isEmpty: Bool) {
        infoLbl.text = obtainInfoText(isEmpty)
        infoLbl.textColor = obtainInfoTextColor(isEmpty)
        infoIcon.image = obtainInfoIcon(isEmpty)
    }

    private func obtainInfoIcon(_ isEmpty: Bool) -> UIImage? {
        let iconName = isEmpty ? "document_info_warning_icon" : "document_info_icon"

        return UIImage(named: iconName, in: Bundle.current, compatibleWith: nil)
    }

    private func obtainInfoText(_ isEmpty: Bool) -> String {
        isEmpty ? "please enter" : "please confirm"
    }

    private func obtainInfoTextColor(_ isEmpty: Bool) -> UIColor {
        isEmpty ? UIColor.sdkColor(.primaryAccentLighten) : UIColor.sdkColor(.secondaryAccentLighten)
    }

    private func contentDidChanged(_ text: String?) {

        if cellContent?.type == .number {
            configureInformUI(text?.isEmpty ?? true)
        } else {
            if let _ = text?.dateFromString() {
                configureInformUI(false)
            } else {
                configureInformUI(true)
            }
        }
    }
}
