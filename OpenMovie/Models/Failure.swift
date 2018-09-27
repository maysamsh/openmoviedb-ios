//
//  Failure.swift
//  OpenMovie
//
//  Created by Maysam Shahsavari on 9/17/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//


import Foundation
public enum Failure:Error {
    case invalidURL
    case invalidSearchParameters
    case invalidResults(String)
    case invalidStatusCode(Int?)
}

extension Failure: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("The requested URL is invalid.", comment: "")
        case .invalidSearchParameters:
            return NSLocalizedString("The URL parameters is invalid.", comment: "")
        case .invalidResults(let message):
            return NSLocalizedString(message, comment: "")
        case .invalidStatusCode(let message):
            return NSLocalizedString("Invalid HTTP status code:\(message ?? -1)", comment: "")
        }
    }
}
