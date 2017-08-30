//
//  MTWebService+Errors.swift
//
//  Created by Adeesh Jain
//

import Foundation


extension Error{
    
    public func title() -> String?{
        
        
        return nil
    }
    
    public func message() -> String?{
        
        var message : String?
        
        let error = self as NSError
        let errormessage  = error.userInfo["message"] as? String
        let code = error.code
        
        switch code {
        case -1009:
            message = MTNetworkMessage.kHTTPNoInternetMessage
            break
            
        case -1001:
            message = MTNetworkMessage.kHTTPTimeoutMessage
            break
            
        case -1003:
            message = MTNetworkMessage.kHTTPHostNotFoundErrorMessage
            break
            
        case 500:
            message = MTNetworkMessage.kServerFailureMessage
            break
            
        default:
            message = MTNetworkMessage.kHTTPUnknownErrorMessage
            
            if errormessage != nil{
                message = errormessage
            }
        }
        
        return message
    }
    
}
