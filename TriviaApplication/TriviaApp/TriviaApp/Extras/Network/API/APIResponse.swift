//
//  APIResponse.swift
//  BingLine
//
//  Created by Shahid Saleem on 2/17/21.
//

import Foundation
import SwiftyJSON

extension API{
    /*
     if let jsonData = data?.rawString()?.data(using: .utf8)
     {
     do {
     let userObj = try JSONDecoder().decodeJson(User.self, from: jsonData)
     userObj.access_token = parameters?.dictionary?["data"]!["token"].string
     return userObj as AnyObject
     }catch{
     print(error as Any)
     return User() as AnyObject
     }
     }else{
     return User() as AnyObject
     }
     let data =  parameters?.dictionary?["successData"]
     let response:ChatObject = decodeJson(data) ?? ChatObject()
     return Response.init(data: response as AnyObject,message)
     if let response:[SlotModel] = decodeJson(data), isSuccess{
         return Response.init(data: response as AnyObject,message,isSuccess)
     }else{Us
         return Response.init(data: nil,message,isSuccess)
     }
     */
    func handleResponse(parameters : JSON?) -> Response {
        
//        let message = parameters?.dictionary?["message"]?.rawValue as? String ?? ""
//        let key = parameters?.dictionary?["status"]?.rawValue as? String ?? ""
//        let isSuccess = key == "success" ? true : (key == "1" ? true : false)
        let data = parameters//?.dictionary?["data"]
        
//MARK:- All my Respnses
        
        switch self {
        
        case .getCategories:
            if let items:[CategoryModel] = decodeJson(data?["trivia_categories"]){
                DataManager.sharedInstance.categories = items
                return Response.init(data: items as AnyObject, "", true)
            }
            return Response.init(data: nil, "", false)
        case .getQuestion:
            if let items:[QuestionModel] = decodeJson(data?["results"]){
                return Response.init(data: items as AnyObject, "", true)
            }
            return Response.init(data: nil, "", false)
        }
    }
}

enum APIValidation : String{
    case None
    case Success = "1"
    case ServerIssue = "500"
    case Failed = "0"
    case TokenInvalid = "401"
}

enum APIResponse {
    case Success(Response?)
    case Failure(String?)
    case Progress(Double?)
}

class Response {
    var data :AnyObject?
    var message:String = ""
    var isSuccess:Bool = false
    init(data:AnyObject?,_ message:String = "",_ isSuccess:Bool = false) {
        self.data = data
        self.message = message
        self.isSuccess = isSuccess
    }
}

func decodeJson<T: Decodable>(_ dataJS: JSON?) -> T?{
    if let data = dataJS?.rawString()?.data(using: .utf8){
        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            return model
        } catch {
            print(error as Any)
            return nil
        }
    }else{
        print("Error Parsing JSON")
        return nil
    }
}
func decodeJson<T: Decodable>(_ dataJS: String?) -> T?{
    if let data = dataJS?.data(using: .utf8){
        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            return model
        } catch {
            print(error as Any)
            return nil
        }
    }else{
        print("Error Parsing String")
        return nil
    }
}
