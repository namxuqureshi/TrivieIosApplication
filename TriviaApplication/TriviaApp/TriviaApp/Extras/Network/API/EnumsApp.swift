//
//  EnumsApp.swift
//  BingLine
//
//  Created by Shahid Saleem on 2/17/21.
//

import Foundation

enum UserType:String,Codable {
    case Personal = "personal"
    case Vendor = "vendor"
}

enum SocialTypes:String,CaseIterable {
    case Facebook = "facebook"
    case Google = "google"
    case Apple = "apple"
    case None = ""
}

enum Gender:String,CaseIterable {
    case Male = "male"
    case Female = "female"
    case Other = "other"
}


enum TypeForgot :String,CaseIterable {
    case Phone = "phone"
    case Email = "email"
}

enum MediaType :String,CaseIterable {
    case Image = "image"
    case Video = "video"
    case Audio = "audio"
    case Document = "document"
    case Location = "location"
}
