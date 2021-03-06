//
//  User.swift
//  BingLine
//
//  Created by Shahid Saleem on 2/17/21.
//

import Foundation
import SwiftyJSON
typealias Boolean = Bool
typealias Serializable = Codable


class Constants {
    
    static let QUESTIONS = "Questions"
    static let ANSWERS = "Answers"
    static let USERS = "Users"
    static let DESCRIPTION = "description"
    static let FINAL_DETAILS = "final_details"
    static let MAIN_TITLE = "main_title"
    static let QUESTIONS_LIST = "questions_list"
    
}

class UserModel : Codable {
    
    var id: String? =  ""
    var auth: String? =  ""
    var authid: String? =  ""
    var username:String? =  ""
    var description:String? =  ""
    var password : String? =  ""
    var default_extension : String? =  ""
    var fname : String? =  ""
    var lname: String? =  ""
    var displayname : String? =  ""
    var image :String? =  ""
}

class CountryModel : Codable {
    
    var countrycode : String? = ""
    var countryname : String? = ""
    var flag : String? = ""
    var phonecode:String? = ""
}

class ContactModel: Codable {
    
    var phone_number:String? =  ""
    var  `extension` :String? =  ""
}
class CallHistoryModel: Codable {
    
    var calldate :String? =  ""
    var clid :String? =  ""
    var src:String? =  ""
    var dst:String? =  ""
    var dcontext:String? =  ""
    var channel:String? =  ""
    var dstchannel:String? =  ""
    var lastapp:String? =  ""
    var lastdata:String? =  ""
    var duration:String? =  ""
    var billsec:String? =  ""
    var disposition:String? =  ""
    var amaflags:String? =  ""
    var accountcode:String? =  ""
    var uniqueid:String? =  ""
    var userfield:String? =  ""
    var did:String? =  ""
    var recordingfile:String? =  ""
    var cnum:String? =  ""
    var cnam:String? =  ""
    var outbound_cnum:String? =  ""
    var outbound_cnam:String? =  ""
    var dst_cnam:String? =  ""
    var linkedid:String? =  ""
    var peeraccount:String? =  ""
    var sequence:String? =  ""
    
}

class chatListModel: Codable {
    
    var sent_to:String? = ""
    var message:String? = ""
    var date_sent:String? = ""
    var isreply:String? = ""
}
enum QuestionCellType:Int,Serializable {
    case QUESTION_TOP = 1
    case QUESTION = 2
}
