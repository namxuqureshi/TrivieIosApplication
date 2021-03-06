//
//  DataManegar.swift
//  BingLine
//
//  Created by Shahid Saleem on 2/17/21.
//

import UIKit
import Alamofire

class DataManager: NSObject {
    
    
    var token:String? {
        set(value) {
            if(value != nil){
                UserDefaults.standard.set(value, forKey: "Token")
            }
        }
        get {
            let stToken = UserDefaults.standard.string(forKey: "Token")
            if(stToken == nil){
                return nil
            }else if (stToken?.isEmpty ?? false) {
                return nil
            }else{
                return stToken
            }
        }
    }
    var categories:[CategoryModel]{
        set {
            let defaults = UserDefaults.standard
            defaults.set(try? PropertyListEncoder().encode(newValue), forKey: "kcategories")
        }
        get {
            let defaults = UserDefaults.standard
            guard let playerData = defaults.object(forKey: "kcategories") as? Data else {
                return []
            }
            guard let player = try? PropertyListDecoder().decode([CategoryModel].self, from: playerData) else {
                return []
            }
            return player
        }
    }
    var isLogin:Bool? {
        set(value) {
            if(value != nil){
                UserDefaults.standard.set(value == true ? "true" : "false", forKey: "isLogin")
            }
        }
        get {
            let isLogedIn = UserDefaults.standard.string(forKey: "isLogin") == "true"
            return isLogedIn
        }
    }
    
    func saveUserPermanentally(_ item:UserModel?) {
        if item != nil {
            let encodedData = try? JSONEncoder().encode(item)
            UserDefaults.standard.set(encodedData, forKey: "UserModel")
        }
    }
    
    func getPermanentlySavedUser() -> UserModel? {
        if let data = UserDefaults.standard.data(forKey: "UserModel"),
            let userData = try? JSONDecoder().decode(UserModel.self, from: data) {
            return userData
        } else {
            return nil
        }
    }
    
    func getScreenWidth() -> CGFloat {
        return CGFloat.init(UserDefaults.standard.double(forKey: "ScreenWidth"))
    }
    
    func setScreenWidth(value:CGFloat) {
        UserDefaults.standard.set(Double.init(value), forKey: "ScreenWidth")
    }
    
    func getScreenHeight() -> CGFloat {
        return CGFloat.init(UserDefaults.standard.double(forKey: "ScreenHeight"))
    }
    func setScreenHeight(value:CGFloat) {
        UserDefaults.standard.set(Double.init(value), forKey: "ScreenHeight")
    }
    
    
    
    
    
    
    var deviceToken:String = UIDevice.current.identifierForVendor!.uuidString
    
    static let sharedInstance = DataManager()
    
    func logoutUser() {
        self.resetDefaults()
        UserDefaults.standard.removeObject(forKey: "user")
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}

