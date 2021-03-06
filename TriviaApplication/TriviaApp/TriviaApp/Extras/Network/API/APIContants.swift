//
//  APIContants.swift
//  BingLine
//
//  Created by Shahid Saleem on 2/17/21.
//

import Foundation
import Alamofire

func print(_ items: Any...) {
    #if DEBUG
    Swift.print(items)
    #endif
}

internal struct Build{
    static let isProduction = 0
}
//MARK:- All my Base Paths
internal struct APIConstants {
    
   // static let SocketURL = "http://45.56.122.34:1027"
//    https://opentdb.com/api_category.php
    static let BasePath = "https://opentdb.com/"
}

//MARK:- All my apiRoutes/Paths
internal struct APIPaths {
   
    static let getCategories = "api_category.php"
    static let getCategoryQuestion = "api_count.php?category="// ?? Append Cat_id here CATEGORY_ID_HERE
    static func getQuestions(amount:Int = 10,catId:Int,difficultyType:QuestionDifficultyType,choiceType:QuestionChoicetype) -> String{
        return "api.php?amount=\(amount)&category=\(catId)&difficulty=\(difficultyType.rawValue)&type=\(choiceType.rawValue)"
    }
    
}

enum QuestionChoicetype:String,CaseIterable,Codable{
    case MultipleChoice = "multiple"
    case TrueFalse = "boolean"
}


enum QuestionDifficultyType:String,CaseIterable,Codable{
    case Easy = "easy"
    case Medium = "medium"
    case Hard = "hard"
}


//MARK:- All my Parameters Keys
struct PKeys{
    //Paramaters
    static let username = "username"
    static let password = "password"
    static let name = "name"
    static let secret = "secret"
    static let image = "image"
    static let phonenumber = "phone_number"
    static let number = "number"
    static let userid = "user_id="
    static let bingarray = "user_contacts"
    static let message = "message"
    static let sendto = "sendto"
    
}

//MARK:- All my Parameters Key Values

internal struct APIParameterConstants {
    
    struct SignIn {
        static let signin = [PKeys.username,PKeys.password]
    }
    struct Createuser {
        static let createuser = [PKeys.name,PKeys.secret,PKeys.password,PKeys.image,PKeys.username,PKeys.phonenumber]
    }
    struct CheckNumber {
        static let checknumber = [PKeys.number]
    }
    struct UserDetails {
        static let userdetails = [PKeys.userid]
    }
    struct BingContacts {
        static let bingcontact = [PKeys.bingarray]
    }
    struct SendMessage {
        static let sendmessage = [PKeys.message,PKeys.username,PKeys.sendto]
    }
}

enum FileParamName :String{
    case PictureFile = "Attachment.File"
    case Media = "media"
    case Image = "image"
    case IdProofFile = "IdProof.File"
    case ESignatureFile = "ESignature.File"
    case ReferenceAttachmentFile = "ReferenceAttachment.File"
}

enum FileSendType:String {
    case vendor_document = "vendor_document"
}

struct QuestionModel:Codable{
    var category:String? = ""// "": "General Knowledge",
    var type:QuestionChoicetype? = .MultipleChoice//            //"type": "multiple",
    var difficulty:QuestionDifficultyType? = .Medium//            "difficulty": "medium",
    var question:String? = ""//                "question": "In a standard set of playing cards, which is the only king without a moustache?",
    var correct_answer:String? = ""//            "correct_answer": "Hearts",
    var incorrect_answers:ArrayList<String>? = ArrayList()
    var optionsList:ArrayList<String?>{
        var list = [String?]()
        list.append(contentsOf: self.incorrect_answers ?? ArrayList())
        list.append(correct_answer)
        list.shuffle()
        return list
    }
}

struct CategoryModel:Codable{
    var id:Int? = 0
    var name:String? = ""
}

typealias ArrayList<T> = [T]
