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
        case .fetchData:
            return buildFetchData()
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
        let fetchPersonData = ProgressCellObject(title: Localizable.Initial.prefetch, visibleSeparator: false)
        let locationData = ProgressCellObject(title: Localizable.FetchData.location, visibleSeparator: false)

        return [defineIdent, obtainInfo, registerMethod, fetchPersonData, locationData]
    }

    private func buildFetchData() -> [ProgressCellObject] {

        let fetchData = ProgressCellObject(title: Localizable.FetchData.person, visibleSeparator: true)
        let locationData = ProgressCellObject(title: Localizable.FetchData.location, visibleSeparator: false)

        return [fetchData, locationData]
    }

    private func buildUploadData() -> [ProgressCellObject] {
        let prepareData = ProgressCellObject(title: Localizable.Upload.preparation, visibleSeparator: true)
        let uploadData = ProgressCellObject(title: Localizable.Upload.uploading, visibleSeparator: false)

        return [prepareData, uploadData]
    }

    private func buildConfirmData() -> [ProgressCellObject] {
        let verification = ProgressCellObject(title: Localizable.Verification.processTitle, visibleSeparator: true)

        return [verification]
    }
}
