//
//  FourthlineDocumentType.swift
//  IdentHubSDKCore
//

import Foundation

public enum FourthlineDocumentType : Int {

    /// Passport
    case passport

    /// ID Card
    case idCard

    /// Drivers License
    case driversLicense

    /// Residence Permit
    case residencePermit

    /// Paper ID
    case paperId

    /// French ID Card
    case frenchIdCard

    /// This is the default value and must be set to one of the other options in order to have a valid `DocumentType`.
    /// - Note: it was added for ObjectiveC compatibility to represent nil value (ObjC does not support optional enumerations).
    case undefined

}

/// Enumeration with all Fourthline flow steps
public enum FourthlineProgressStep: Int {
    case selfie = 0, document, confirm, upload, result
}
