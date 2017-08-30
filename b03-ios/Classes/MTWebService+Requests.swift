//
//  MTWebService+Requests.swift
//
//  Created by Adeesh Jain
//

import Foundation

extension MTWebService{
    
    //MARK: Filter APIs
    func getFilteredImage(fbUId : String, appId: String, objectId: String, filter: String, filterFileName: String, srcImageUrl:String, s3FileName: String,  block : @escaping MTWSCompletionBlock){
        
        let service = MTWebServiceRequestImageFilter(manager : self, fbUId : fbUId, appId: appId, objectId: objectId, filter: filter, filterFileName: filterFileName, srcImageUrl:srcImageUrl, s3FileName: s3FileName,  block : block)
        
        self.startRequest(service: service)
    }
    
    
}




