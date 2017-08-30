//
//  MTWebService+Primitives.swift
//
//  Created by Mobile code.
//

import Foundation


enum MTServerUrls: String {
    case development = "https://p948kre9g3.execute-api.us-east-1.amazonaws.com"
}



typealias MTWSCompletionBlock = (_ object : Any?, _ error : Error?) -> Void


