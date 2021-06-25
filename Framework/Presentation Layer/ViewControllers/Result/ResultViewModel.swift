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
        case .successful:
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
        case .successful:
            return Localizable.Result.successDescription
        case .failed:
            return Localizable.Result.successDescription
        default:
            return ""
        }
    }

    /// Method returns result icon image depends on identification status
    /// - Returns: result image
    func obtainResultImage() -> UIImage? {

        switch self.result?.identificationStatus {
        case .successful:
            return UIImage(named: "result_success", in: Bundle.current, compatibleWith: nil)
        case .failed:
            return UIImage(named: "result_failed", in: Bundle.current, compatibleWith: nil)
        default:
            return UIImage()
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
            return UIColor.sdkColor(.error)
        default:
            return UIColor.sdkColor(.success)
        }
    }
}
