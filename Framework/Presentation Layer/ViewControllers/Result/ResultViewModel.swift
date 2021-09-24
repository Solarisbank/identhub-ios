//
//  ResultViewModel.swift
//  IdentHubSDK
//

import UIKit

final class ResultViewModel: BaseFourthlineViewModel {

    // MARK: - Public attributes -
    var result: FourthlineIdentificationStatus?

    // MARK: - Public methods -

    /// Method returns title of the result screen depends on fourthline identification status
    /// - Returns: screen title string
    func obtainResultTitle() -> String {
        switch self.result?.identificationStatus {
        case .success:
            return Localizable.Result.successTitle
        case .failed:
            return Localizable.Result.failedTitle
        default:
            return ""
        }
    }

    /// Method returns description of the result screen depends on fourthline identification status
    /// - Returns: screen description string
    func obtainResultDescription() -> String {
        switch self.result?.identificationStatus {
        case .success:
            return Localizable.Result.successDescription
        case .failed:
            return Localizable.Result.failedDescription
        default:
            return ""
        }
    }

    /// Method returns result icon image depends on identification status
    /// - Returns: result image
    func obtainResultImage() -> UIImage? {

        switch self.result?.identificationStatus {
        case .success:
            return UIImage(named: "result_success", in: Bundle.current, compatibleWith: nil)
        case .failed:
            return UIImage(named: "result_failed", in: Bundle.current, compatibleWith: nil)
        default:
            return UIImage()
        }
    }

    func didTriggerClose() {
        if let identResult = result {
            coordinator.perform(action: .complete(result: identResult))
        }
    }
}

// MARK: - Steps progress datasource methods -

extension ResultViewModel: StepsProgressViewDataSource {

    func currentStep() -> Int {
        FourthlineProgressStep.result.rawValue
    }

    func currentStepHightlightColor() -> UIColor {

        switch self.result?.identificationStatus {
        case .failed:
            return .sdkColor(.error)
        default:
            return .sdkColor(.secondaryAccent)
        }
    }
}
