//
//  MTWebServiceImgFilter.swift
//
//  Created by Adeesh Jain.
//

import UIKit


class MTWebServiceImgFilter: MTWebServiceRequest {
    
   override init(manager : MTWebService, block : @escaping MTWSCompletionBlock) {
        
        super.init(manager: manager, block: block)
        
    }
    
}

class MTWebServiceRequestImageFilter : MTWebServiceImgFilter{
    
    
    
    init(manager : MTWebService, fbUId : String, appId: String, objectId: String, filter: String, filterFileName: String, srcImageUrl:String, s3FileName: String,  block : @escaping MTWSCompletionBlock) {
        
        super.init(manager: manager, block: block)
       
        var encodedImgUrl:String = srcImageUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        encodedImgUrl = encodedImgUrl.replacingOccurrences(of: "&", with: "%26")
        encodedImgUrl = encodedImgUrl.replacingOccurrences(of: "=", with: "%3D")
        
        url = manager.serverBaseURL + MTWebServiceURL.filterImgEndPoint + "?fbuid=\(fbUId)&appid=\(appId)&objectid=\(objectId)&filter=\(filter)&filterfilename=\(filterFileName)&s3filename=\(s3FileName)&imageurl=\(encodedImgUrl)"
        
//        print("Request url is \(url)")
        
    }
    
    override func responseSuccess(data: Any?) {
        
      super.responseSuccess(data: data)
    }
}





