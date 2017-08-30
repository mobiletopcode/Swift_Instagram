//
//  MTWebService.swift
//  Mustage
//
//  Created by Mobile code.
//
//

import UIKit


//All End Points specified over here.
enum MTWebServiceURL{

    static let filterImgEndPoint = "/alg/default"
    
}

class MTWebService: NSObject {
    
    var serviceArray = [Weak<MTWebServiceRequest>]()

    static let sharedService : MTWebService = {
        let instance = MTWebService()
        return instance
    }()
    

    var serverBaseURL = MTServerUrls.development.rawValue
    
    
    private override init() {
        
    }
    
    
    func startRequest(service : MTWebServiceRequest){
        
        service.start()
        serviceArray.append(Weak(value : service))
        print("services started = \(self.serviceArray.count)")
    }
    
    
    func closeService(service : MTWebServiceRequest?){
       
        print("service pending = \(self.serviceArray.count)")
    }
    
    func cancelAllRequests(){
        
        for service in self.serviceArray {
            if let serviceVal = service.value{
                //TODO: Fill it later.
               // self.stopRequest(service: serviceVal)
            }
        }
        print("service pending = \(self.serviceArray.count)")
        self.serviceArray.removeAll()
    }
    
}

