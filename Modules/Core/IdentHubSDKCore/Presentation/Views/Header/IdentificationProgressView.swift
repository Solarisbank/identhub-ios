//
//  IdentificationProgressView.swift
//  IdentHubSDKCore
//

import UIKit

/// List of all possible steps to follow.
public enum CurrentStep {
    case phoneVerification
    case bankVerification
    case documents
}

/// View representing the current progress.
private class LineProgressView: UIView {

    init() {
        super.init(frame: .zero)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp() {
        backgroundColor = AppColor.base10.color
        layer.cornerRadius = 2
        addConstraints { [
            $0.equalConstant(.height, 2)
        ]
        }
    }
}

/// View which displays current step.
internal class IdentificationProgressView: UIView {

    private typealias StepProgress = (currentStep: String, nextStep: String, stepNumber: Int)

    enum Constants {
        enum FontSize {
            static let medium: CGFloat = 14
            static let small: CGFloat = 11
            static let tiny: CGFloat = 10
        }

        enum ConstraintsOffset {
            static let extended: CGFloat = 40
            static let normal: CGFloat = 16
            static let small: CGFloat = 12
            static let tiny: CGFloat = 6
        }

        enum Size {
            static let spacing: CGFloat = 4
            static let height: CGFloat = 89
        }
    }

    override var intrinsicContentSize: CGSize {
        .init(width: UIView.noIntrinsicMetric, height: Constants.Size.height)
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(Constants.FontSize.tiny)
        label.textColor = AppColor.base50.color
        label.text = Localizable.IdentificationProgressView.identificationProgress.uppercased()
        return label
    }()

    private lazy var currentStepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.FontSize.medium, weight: .bold)
        label.textColor = AppColor.base100.color
        return label
    }()

    private lazy var nextStepLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = label.font.withSize(Constants.FontSize.small)
        label.textColor = AppColor.base50.color
        return label
    }()

    private lazy var progressBarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = Constants.Size.spacing
        stackView.addArrangedSubview(LineProgressView())
        stackView.addArrangedSubview(LineProgressView())
        stackView.addArrangedSubview(LineProgressView())
        return stackView
    }()

    /// Initialize the bar with the current progress.
    init(currentStep: CurrentStep, activeColor: UIColor) {
        super.init(frame: .zero)
        backgroundColor = AppColor.background.color
        configureUI()
        setCurrentStep(currentStep, activeColor: activeColor)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppColor.background.color
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubviews([
            titleLabel,
            currentStepLabel,
            nextStepLabel,
            progressBarStackView
        ])

        titleLabel.addConstraints { [
            $0.equal(.top, constant: Constants.ConstraintsOffset.extended),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        currentStepLabel.addConstraints { [
            $0.equalTo(titleLabel, .top, .bottom, constant: Constants.ConstraintsOffset.tiny),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal)
        ]
        }

        nextStepLabel.addConstraints { [
            $0.equalTo(currentStepLabel, .leading, .trailing, constant: Constants.ConstraintsOffset.normal),
            $0.equalTo(currentStepLabel, .centerY, .centerY),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        progressBarStackView.addConstraints { [
            $0.equalTo(currentStepLabel, .top, .bottom, constant: Constants.ConstraintsOffset.small),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal),
            $0.equal(.bottom)
        ]
        }
    }

    func setCurrentStep(_ currentStep: CurrentStep, activeColor: UIColor) {
        let details = step(currentStep)
        currentStepLabel.text = details.currentStep

        if !details.nextStep.isEmpty {
            nextStepLabel.text = "\(Localizable.Common.next): \(details.nextStep)"
        }

        for index in 0..<details.stepNumber {
            progressBarStackView.arrangedSubviews[index].backgroundColor = activeColor
        }
    }

    private func step(_ step: CurrentStep) -> StepProgress {
        switch step {
        case .phoneVerification:
            return (currentStep: Localizable.IdentificationProgressView.phoneVerification, nextStep: Localizable.IdentificationProgressView.bankVerification, stepNumber: 1)
        case .bankVerification:
            return (currentStep: Localizable.IdentificationProgressView.bankVerification, nextStep: Localizable.IdentificationProgressView.documents, stepNumber: 2)
        case .documents:
            return (currentStep: Localizable.IdentificationProgressView.documents, nextStep: "", stepNumber: 3)
        }
    }
}
