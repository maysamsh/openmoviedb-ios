//
//  EndPoints.swift
//  OpenMovie
//
//  Created by Maysam Shahsavari on 9/17/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//


import Foundation

enum EndPoints {
    case Search
}

extension EndPoints {
    var path:String {
        let baseURL = "http://www.omdbapi.com"
        
        struct Section {
            static let search = "/?"
        }
        
        switch(self) {
        case .Search:
            return "\(baseURL)\(Section.search)"

        }
        
    }
    
}
