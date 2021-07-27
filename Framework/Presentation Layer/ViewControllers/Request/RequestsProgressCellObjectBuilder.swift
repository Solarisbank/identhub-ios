//
//  RequestsProgressCellObjectBuilder.swift
//  IdentHubSDK
//

import Foundation

final class RequestsProgressCellObjectBuilder {

    // MARK: - Private attributes -
    private let requestsType: RequestsType

    // MARK: - Init methods -
    init(type: RequestsType) {
        self.requestsType = type
    }

    // MARK: - Public methods -

    func buildContent() -> [ProgressCellObject] {

        switch self.requestsType {
        case .initateFlow:
            return buildInitData()
        case .uploadData:
            return buildUploadData()
        case .confirmation:
            return buildConfirmData()
        }
    }
}

// MARK: - Internal methods -

extension RequestsProgressCellObjectBuilder {

    private func buildInitData() -> [ProgressCellObject] {
        let defineIdent = ProgressCellObject(title: Localizable.Initial.define, visibleSeparator: true)
        let obtainInfo = ProgressCellObject(title: Localizable.Initial.info, visibleSeparator: false)
        let registerMethod = ProgressCellObject(title: Localizable.Initial.register, visibleSeparator: false)
        let fetchData = ProgressCellObject(title: Localizable.Initial.prefetch, visibleSeparator: false)

        return [defineIdent, obtainInfo, registerMethod, fetchData]
    }

    private func buildUploadData() -> [ProgressCellObject] {
        let locationData = ProgressCellObject(title: Localizable.Upload.location, visibleSeparator: true)
        let prepareData = ProgressCellObject(title: Localizable.Upload.preparation, visibleSeparator: false)
        let uploadData = ProgressCellObject(title: Localizable.Upload.uploading, visibleSeparator: false)

        return [locationData, prepareData, uploadData]
    }

    private func buildConfirmData() -> [ProgressCellObject] {
        let verification = ProgressCellObject(title: Localizable.Verification.processTitle, visibleSeparator: true)

        return [verification]
    }
}
