//
//  APIManager.swift
//  BingLine
//
//  Created by Shahid Saleem on 2/17/21.
//

import Foundation
import SwiftyJSON
import Alamofire

typealias APICompletion = (APIResponse) -> ()

class APIManager: NSObject {
    
    static let sharedInstance = APIManager()
    private lazy var httpClient : HTTPClient = HTTPClient()
    
    func operationWithFile( withApi api : API ,fileUrl:[URL?]?,paramName: [FileParamName],type: [FileSendType], completion : @escaping APICompletion ){
        
        httpClient.withFile(withApi: api, fileUrl: fileUrl, paramName: paramName,type:type,progressCompletation: { (progress) in
            completion(APIResponse.Progress(progress))
        }, success: { (data,headers) in
            self.handleResponse(api:api,data:data,headers: headers,completion: completion)
        }) { (error,headers) in
            self.handleErrors(api:api,error:error,headers: headers,completion: completion)
        }
    }
    
    func removeCall(){
        httpClient.removeCall()
    }
    
    func opertationWithRequest ( withApi api : API , completion : @escaping APICompletion ) {
        
        httpClient.postRequest(withApi: api, success: { (data,headers) in
            self.handleResponse(api:api,data:data,headers: headers,completion: completion)
        }) { (error,headers) in
            self.handleErrors(api:api,error:error,headers: headers,completion: completion)
        }
    }
    
    private func handleErrors(api : API ,error:NSError,headers:Any, completion : @escaping APICompletion ){
        
        print("❌❌❌ API Start ❌❌❌ ")
        print("Url:\(api.url())\nParams: \(String(describing:api.parameters))\nResponse: \(error)\nHeaders: \(headers)")//
        print("-------- API END ------- ")
        completion(APIResponse.Failure(error.localizedDescription))
    }
    
    private func handleResponse(api:API,data:AnyObject?,headers:Any,completion : @escaping APICompletion){
        guard let response = data else {
            completion(APIResponse.Failure(""))
            return
        }
        let json = JSON(response)
        //MARK:- Sir USman
        completion(.Success(api.handleResponse(parameters: json)))
//        completion(APIResponse.Failure(messageRes))
    }
    
    func goToRoot(json:JSON,completion : @escaping APICompletion ){
        completion(APIResponse.Failure("Current user did not login to the application!"))
        DataManager.sharedInstance.logoutUser()
    }
    
}

class ErrorModel :Codable {
//    "details" : null,
//       "validationErrors" : null,
    var code:Int? = 0
    var message:String? = ""
}
