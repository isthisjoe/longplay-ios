//
//  APIClient.swift
//  Longplay
//
//  Created by Joe Nguyen on 23/08/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import Alamofire

typealias APIClientCompletedBlock = (_ result:AnyObject?) -> ()
typealias APIClientFailedBlock = (_ errorMessage:String?) -> ()

class APIClient {
    
    func getAlbumList(_ completed:APIClientCompletedBlock, failed:APIClientFailedBlock) {
        
//        Alamofire.request("http://blooming-hollows-5367.herokuapp.com/albums.json",
//                          method: HTTPMethod.get,
//                          parameters: nil,
//                          encoding: JSONEncoding.default,
//                          headers: nil)
        
        
        Alamofire.request("http://blooming-hollows-5367.herokuapp.com/albums.json",
                          method: HTTPMethod.get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: nil).responseJSON { (dataResponse: DataResponse<Any>) in
                            print(dataResponse)
                            debugPrint(dataResponse)
        }
        
//        Alamofire.request(.GET,
//            "http://blooming-hollows-5367.herokuapp.com/albums.json",
//            parameters: nil,
//            encoding: ParameterEncoding.JSON,
//            headers: nil).responseJSON { request, response, result, error in
//                print(result)
//                debugPrint(result)
//        }
    }
}
