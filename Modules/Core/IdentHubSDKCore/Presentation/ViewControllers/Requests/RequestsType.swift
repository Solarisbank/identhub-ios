//
//  RequestsType.swift
//  IdentHubSDKCore
//

import Foundation

public enum InitStep: Int {
    case defineMethod = 0, obtainInfo, registerMethod, fetchPersonData, fetchLocation, fetchIPAddress
}

public enum DataFetchStep: Int {
    case fetchPersonData = 0, location, fetchIPAddress
}

public enum UploadSteps: Int {
    case prepareData = 0, uploadData
}

public enum VerificationSteps: Int {
    case verification = 0
}
