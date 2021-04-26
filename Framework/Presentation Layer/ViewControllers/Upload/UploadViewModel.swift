//
//  UploadViewModel.swift
//  IdentHubSDK
//

import Foundation

final class UploadViewModel: BaseFourthlineViewModel {

}

extension UploadViewModel: StepsProgressViewDataSource {

    func currentStep() -> Int {
        FourthlineSteps.upload.rawValue
    }
}
