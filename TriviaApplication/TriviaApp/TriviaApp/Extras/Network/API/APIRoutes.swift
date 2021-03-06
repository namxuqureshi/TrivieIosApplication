//
//  APIRoutes.swift
//  BingLine
//
//  Created by Shahid Saleem on 2/17/21.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias OptionalDictionary = [String : Any]?
typealias OptionalDictionaryWithDicParam = [String : [String:Any]]?
typealias OptionalSwiftJSONParameters = [String : JSON]?

infix operator =>
infix operator =|
infix operator =<
infix operator =/

func =>(key : String, json : OptionalSwiftJSONParameters) -> String?{
    return json?[key]?.stringValue
}

func =<(key : String, json : OptionalSwiftJSONParameters) -> Double?{
    return json?[key]?.double
}

func =|(key : String, json : OptionalSwiftJSONParameters) -> [JSON]?{
    return json?[key]?.arrayValue
}

func =/(key : String, json : OptionalSwiftJSONParameters) -> Int?{
    return json?[key]?.intValue
}

prefix operator ¿
prefix func ¿(value : String?) -> String {
    return value.unwrap()
}


protocol Router {
    var route : String { get }
    var baseURL : String { get }
    var parameters : OptionalDictionary { get }
    var method : Alamofire.HTTPMethod { get }
}

enum API {
    
    static func mapKeysAndValues(_ tempKeys : [String],_ tempValues : [Any]) -> [String : Any]{
        
        var params = [String : Any]()
        for (key,value) in zip(tempKeys,tempValues) {
            params[key] = value
        }
        return params
    }
    
    static func mapKeysAndValuesDic(_ tempKeys : [String],_ tempValues : [Any]) -> [String:[String:Any]]{
        var params = [String : [String:Any]]()
        for (key,value) in zip(tempKeys,tempValues) {
            if let itemValue = value as? [String:Any] {
                params[key] = itemValue
            }
        }
        return params
    }
  
    case getCategories
    case getQuestion(amount:Int = 10,catId:Int,difficultyType:QuestionDifficultyType,choiceType:QuestionChoicetype)
//    trivia_categories
  
}

//MARK:- Need to create New Methods //step2
extension API : Router{
    
    var route : String {
        
        switch self {
        
        case .getCategories:
            return APIPaths.getCategories
        case .getQuestion(amount: let amount, catId: let category, difficultyType: let difficultyType, choiceType: let choiceType):
            return APIPaths.getQuestions(amount: amount,catId: category, difficultyType: difficultyType, choiceType: choiceType)
        }
    }
    
    var baseURL : String {  return APIConstants.BasePath }
    
    var parameters : OptionalDictionary {
        let pm = formatParameters()
        
        return pm
    }
    
    func url() -> String {
        return (baseURL + route).RemoveSpace()
    }
    
//MARK:- Need to Set New Methods //step3
    
    var method: Alamofire.HTTPMethod {
        switch self {
      
        default:
            return .get
        }
    }
    var encoder:Alamofire.ParameterEncoder {
            switch self {
//            case .login:
//                return URLEncodedFormParameterEncoder.default
//            case .sendComment , .createAlert:
//                return JSONParameterEncoder.default
    //            return URLEncodedFormParameterEncoder.default
            default:
                return JSONParameterEncoder.default
            }
        }
        
        var encoding:Alamofire.ParameterEncoding {
            switch self {
            
            default:
                return URLEncoding.default
            }
        }
}

//MARK:- Need to Set All Pramaters Here //step4
extension API {
    func formatParameters() -> OptionalDictionary {
        
        switch self {
       
        default:
            return [:]
        }
    }
}

extension String {
    func RemoveSpace() -> String{
        return self.replacingOccurrences(of: " ", with: "%20")
    }
}
