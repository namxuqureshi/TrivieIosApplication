//
//  ExtBing.swift
//  BingLine
//
//  Created by Shahid Saleem on 2/17/21.
//

import Foundation
import UIKit


//MARK:- Image Round Class
@IBDesignable
class DefaultImageClass:UIImageView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.cornerRadius = self.frame.size.height/2
        self.layoutIfNeeded()
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.cornerRadius = self.frame.size.height/2
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = min(self.bounds.width, self.bounds.height) / 2
        self.layer.cornerRadius = radius
    }
}

extension UIView{
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius//vCornerRadius
        }
        set {
            layer.cornerRadius = newValue
            //            vCornerRadius = newValue
            self.setNeedsLayout()
            
        }
    }
}

//End
extension String {
    
    var parseJSONString: AnyObject? {
        
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        if let jsonData = data {
            // Will return an object or nil if JSON decoding fails
            do{
                if let json = try (JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary){
                    return json
                }else{
                    let json = try (JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray)
                    return json
                }
                
            }catch{
                print("Error")
            }
            
        } else {
            // Lossless conversion of the string was not possible
            return nil
        }
        
        return nil
    }
    
    var parseJSONStringArray: AnyObject? {
        
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let json:NSArray
        
        if let jsonData = data {
            // Will return an object or nil if JSON decoding fails
            do{
                json  = try  JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)  as! NSArray
                
                return json
            }catch{
                print("Error")
            }
            
        } else {
            // Lossless conversion of the string was not possible
            return nil
        }
        
        return nil
    }
}

protocol StringType { var get: String { get } }
extension String: StringType { var get: String { return self } }
extension Optional where Wrapped: StringType {
    func unwrap() -> String {
        return self?.get ?? ""
    }
}

extension String{
    func toDate( dateFormat format  : String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        return dateFormatter.date(from: self)!
    }
    
    func UTCToLocal(inputFormate : String , outputFormate : String) -> String {
        if self.count > 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  inputFormate  //Input Format kResponseTimeFormat
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            let UTCDate = dateFormatter.date(from: self)
            dateFormatter.dateFormat =  outputFormate // Output Format "MM.dd.yyyy hh:mm a"
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            let UTCToCurrentFormat = dateFormatter.string(from: UTCDate!)
            print(UTCToCurrentFormat)
            return UTCToCurrentFormat
        }else{
            return "Empty Date!"
        }
    }
    func getRanges(of string: String) -> [NSRange] {
        var ranges:[NSRange] = []
        if contains(string) {
            let words = self.components(separatedBy: " ")
            var position:Int = 0
            for word in words {
                if word.lowercased() == string.lowercased() {
                    let startIndex = position
                    let endIndex = word.count
                    let range = NSMakeRange(startIndex, endIndex)
                    ranges.append(range)
                }
                position += (word.count + 1)
            }
        }
        return ranges
    }
    
    func getRemidersRemainingDays(outputFormat:String = "yyyy-MM-dd") -> String{
        let dateRangeStart = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = outputFormat
        let dt = dateFormatter.date(from: self)
        //        dt = dt?.toLocalTime()
        let calendar = Calendar.current
        if calendar.isDateInTomorrow(dt!) {
            return "Tomorrow"
        }else if  calendar.isDateInToday(dt!){
            return "Today"
        }else{
            var diffInDays = calendar.dateComponents([.day], from: dateRangeStart, to: dt!).day
            if diffInDays! > 0 {
                diffInDays = (diffInDays!) + 1
            }
            if diffInDays! <= 0{
                return "Today"
            }else{
                return "\(String(describing: diffInDays!)) Days"
            }
        }
    }
}
