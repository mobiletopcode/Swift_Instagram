//
//  MTWebServiceRequest.swift
//
//  Created by Adeesh Jain.
//

import UIKit



class Weak<T: AnyObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}


class MTWebServiceRequest: NSObject {
    
    var block : MTWSCompletionBlock
    
    var url : String?
    
    var request : URLRequest?
    
    weak var manager : MTWebService?
    
    let concurrentQueue = DispatchQueue(label: "userqueue", attributes: .concurrent)
    
    init(manager : MTWebService, block : @escaping MTWSCompletionBlock) {
        self.block = block
        self.manager = manager
    }
    
    func start(){
        
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        
        guard let url = URL(string: url!) else {
            print("Error: cannot create URL")
            return
        }

        self.request = URLRequest(url: url)
        self.request?.timeoutInterval = 60
        let session = URLSession(configuration: configuration)

        
        // make the request
        let task = session.dataTask(with: request!, completionHandler: { (data, response, error) in
            // do stuff with response, data & error here
            
            if let errorObj = error  {
                print("API error is \(errorObj)")
                self.responseFailed(responseError: errorObj)
                return
            }
            
            if let returnData = String(data: data!, encoding: .utf8) {
                print("response is \(returnData)")
                self.responseSuccess(data: returnData)
            } else {
                self.responseFailed(responseError: NSError(domain: "MTWeb", code: 9999, userInfo: [NSLocalizedDescriptionKey : "NO Response"]))
            }
            
        })
        task.resume()
        
    }
    
    func responseSuccess(data : Any?){
        
        MTWebService.sharedService.closeService(service: self)
        
        DispatchQueue.main.async {
            self.block(data,nil)
        }
        
    }
    

    deinit {
        self.url = nil
        self.request = nil
        print("\(self) deinit")
    }
    
}

extension MTWebServiceRequest{
    
    func responseFailed(responseError : Error?){
        
        DispatchQueue.main.async {
            self.block(nil,responseError)
        }
        
        
    }
    
    
}
