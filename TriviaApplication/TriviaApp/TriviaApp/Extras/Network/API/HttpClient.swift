//
//  HttpClient.swift
//  BingLine
//
//  Created by Shahid Saleem on 2/17/21.
//

import Foundation
import Alamofire
import SwiftyJSON
import MobileCoreServices

typealias HttpClientSuccess = (AnyObject?,_ header: Any) -> ()
typealias HttpClientFailure = (NSError,_ header: Any) -> ()


class AlamoFireCall {
    static let shared = AlamoFireCall()
    let manager:ServerTrustManager!
    let session:Session!
    init() {
        manager = ServerTrustManager(evaluators: ["opentdb.com":DisabledTrustEvaluator()])
        session = Session(serverTrustManager: manager)//,eventMonitors: [ AlamofireLogger() ]
        //        session.eventMonitor = AlamofireLogger()
    }
}

class HTTPClient {
    
    func withFile(withApi api:API,fileUrl:[URL?]?,paramName:[FileParamName],type:[FileSendType],progressCompletation : @escaping (Double?) -> (),success : @escaping HttpClientSuccess , failure : @escaping HttpClientFailure ){
        let params = api.parameters ?? [String:Any]()
        let method = api.method
        var headers: HTTPHeaders{
            
            if(DataManager.sharedInstance.token != nil){
                return ["Authorization": "Bearer \(DataManager.sharedInstance.token ?? "")",
                        "Content-type": "multipart/form-data","content-type": "multipart/form-data"]//"Accept": "application/json",
            }else{
                return ["Accept": "application/json","Content-Type":"application/json"]
            }
        }
        AlamoFireCall.shared.session.upload(
            multipartFormData: { multiPart in
                for (key, value) in params {
                    if let value = value as? String{
                        multiPart.append(value.data(using: .utf8)!, withName: key)
                    }else if let value = value as? Int{
                        let intValie = try! JSONEncoder().encode(value)
                        multiPart.append(intValie, withName: key)
                    }else if let value = value as? Bool{
                        let boolData = try! JSONEncoder().encode(value)
                        multiPart.append(boolData, withName: key)
                    }
                }
                for item in type {
                    multiPart.append(item.rawValue.data(using: .utf8)!, withName: "type")
                }
                if let linkFiles = fileUrl {
                    for (index,item) in linkFiles.enumerated() {
                        if let linkFile = item {
                            multiPart.append(linkFile, withName: paramName[index].rawValue , fileName: linkFile.lastPathComponent, mimeType: linkFile.mimeType())
                        }
                    }
                    
                }
                
            },
            to: api.url(), method: method , headers: headers)
            .uploadProgress(queue: .main, closure: { progress in
                
                print("Upload Progress: \(progress.fractionCompleted)")
                progressCompletation(progress.fractionCompleted)
            })
            .responseString { (response:DataResponse<String,AFError>) in
                switch(response.result) {
                case .success(let value):
                    success(value.parseJSONString as AnyObject?,headers)
                case .failure(let error):
                    failure(error as NSError,headers)
                }
            }
        
    }
    
    func removeCall(){
        AlamoFireCall.shared.session.cancelAllRequests()
    }
    
    func checkResponse(_ headers: HTTPHeaders,success : @escaping HttpClientSuccess , failure : @escaping HttpClientFailure,response:AFDataResponse<String>){
        switch(response.result) {
        case .success(let value):
            success(value.parseJSONString as AnyObject?,headers)
        case .failure(let error):
            failure(error as NSError,headers)
        }
    }
    
    func postRequest(withApi api : API  , success : @escaping HttpClientSuccess , failure : @escaping HttpClientFailure )  {
        let params = api.parameters
        let method = api.method
        var headers: HTTPHeaders{
            if(DataManager.sharedInstance.token != nil){
                return ["Authorization": "Bearer \(DataManager.sharedInstance.token ?? "")"]//"Accept": "application/json","Content-Type":"application/json"
            }else{
                return []//"Accept": "application/json","Content-Type":"application/json"
            }
        }
        
        AlamoFireCall.shared.session.request(api.url(), method: method, parameters: params, encoding: api.encoding, headers: headers).responseString { response in
            self.checkResponse(headers, success: success, failure: failure, response: response)
        }
    }
}

extension URL {
    func mimeType() -> String {
        let pathExtension = self.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
}
