//
//  ContactExt.swift
//  BingLine
//
//  Created by Shahid Saleem on 2/19/21.
//

import UIKit

extension UIImageView {
    
    /// Sets the image property of the view based on initial text, a specified background color, custom text attributes, and a circular clipping
    ///
    /// - Parameters:
    ///   - string: The string used to generate the initials. This should be a user's full name if available.
    ///   - color: This optional paramter sets the background of the image. By default, a random color will be generated.
    ///   - circular: This boolean will determine if the image view will be clipped to a circular shape.
    ///   - textAttributes: This dictionary allows you to specify font, text color, shadow properties, etc.
    open func setImage(string: String?,
                       color: UIColor? = nil,
                       circular: Bool = false,
                       textAttributes: [NSAttributedString.Key: Any]? = nil) {
        
        let image = imageSnap(text: string != nil ? string?.initials : "",
                              color: color ?? .random,
                              circular: circular,
                              textAttributes:textAttributes)
        
        if let newImage = image {
            self.image = newImage
        }
    }
    
    private func imageSnap(text: String?,
                           color: UIColor,
                           circular: Bool,
                           textAttributes: [NSAttributedString.Key: Any]?) -> UIImage? {
        
        let scale = Float(UIScreen.main.scale)
        var size = bounds.size
        if contentMode == .scaleToFill || contentMode == .scaleAspectFill || contentMode == .scaleAspectFit || contentMode == .redraw {
            size.width = CGFloat(floorf((Float(size.width) * scale) / scale))
            size.height = CGFloat(floorf((Float(size.height) * scale) / scale))
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(scale))
        let context = UIGraphicsGetCurrentContext()
        if circular {
            let path = CGPath(ellipseIn: bounds, transform: nil)
            context?.addPath(path)
            context?.clip()
        }
        
        // Fill
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // Text
        if let text = text {
            let attributes = textAttributes ?? [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0)]
            
            let textSize = text.size(withAttributes: attributes)
            let bounds = self.bounds
            let rect = CGRect(x: bounds.size.width/2 - textSize.width/2, y: bounds.size.height/2 - textSize.height/2, width: textSize.width, height: textSize.height)
            
            text.draw(in: rect, withAttributes: attributes)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

// MARK:- UIColor Helper
var color = [UIColor.init(cgColor: #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)),UIColor.init(cgColor: #colorLiteral(red: 0.07450980392, green: 0.07450980392, blue: 0.5058823529, alpha: 1)),UIColor.init(cgColor: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1))]

extension UIColor {
    
    /// Returns random generated color.
    public static var random: UIColor {
        //        srandom(arc4random())
        //        var red: Double = 0
        //
        //        while (red < 0.1 || red > 0.84) {
        //            red = drand48()
        //        }
        //
        //        var green: Double = 0
        //        while (green < 0.1 || green > 0.84) {
        //            green = drand48()
        //        }
        //
        //        var blue: Double = 0
        //        while (blue < 0.1 || blue > 0.84) {
        //            blue = drand48()
        //        }
        //.blue//.init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
        return color.randomElement() ?? .blue
        
    }
    
    public static func colorHash(name: String?) -> UIColor {
        guard let name = name else {
            return color.randomElement() ?? .blue
        }
        
        var nameValue = 0
        for character in name {
            let characterString = String(character)
            let scalars = characterString.unicodeScalars
            nameValue += Int(scalars[scalars.startIndex].value)
        }
        
        var r = Float((nameValue * 123) % 51) / 51
        var g = Float((nameValue * 321) % 73) / 73
        var b = Float((nameValue * 213) % 91) / 91
        
        let defaultValue: Float = 0.84
        r = min(max(r, 0.1), defaultValue)
        g = min(max(g, 0.1), defaultValue)
        b = min(max(b, 0.1), defaultValue)
        
        return  color.randomElement() ?? .blue
    }
}

// MARK: String Helper

extension String {
    
    public var initials: String {
        var finalString = String()
        var words = components(separatedBy: .whitespacesAndNewlines)
        
        if let firstCharacter = words.first?.first {
            finalString.append(String(firstCharacter))
            words.removeFirst()
        }
        
        if let lastCharacter = words.last?.first {
            finalString.append(String(lastCharacter))
        }
        
        return finalString.uppercased()
    }
}


extension UIImageView {
    override open func awakeFromNib() {
        super.awakeFromNib()
        tintColorDidChange()
    }
    func rotate(at angle : Int) {
        if angle == 0 || angle == 360 {
            self.transform = CGAffineTransform(rotationAngle: 0)
        }else if angle == 90 {
            self.transform = CGAffineTransform(rotationAngle: .pi / 2)
        }else if angle == 45 {
            self.transform = CGAffineTransform(rotationAngle: .pi / 4)
        }else if angle == 180 {
            self.transform = CGAffineTransform(rotationAngle: .pi)
        }else if angle == 270 {
            self.transform = CGAffineTransform(rotationAngle: .pi * 1.5)
        }else{
            self.transform = CGAffineTransform(rotationAngle: 0)
        }
    }
    
    func addCircleGradiendBorder(_ width: CGFloat,borderColor:[CGColor]) {
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: bounds.size)
        let colors: [CGColor] = borderColor
        gradient.colors = colors
        gradient.startPoint = CGPoint(x: 1, y: 0.5)
        gradient.endPoint = CGPoint(x: 0, y: 0.5)
        
        let cornerRadius = frame.size.width / 2
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        //        if(self.borderWidth == 0.0){
        //            self.borderWidth = 3
        //        }
        let shape = CAShapeLayer()
        let path = UIBezierPath(ovalIn: bounds)
        
        shape.lineWidth = 3//width
        shape.path = path.cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor // clear
        gradient.mask = shape
        
        layer.insertSublayer(gradient, below: layer)
    }
}

public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UIScrollView {
    
    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollToView(view:UIView, animated: Bool) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x:0, y:childStartPoint.y,width: 1,height: self.frame.height), animated: animated)
        }
    }
    
    // Bonus: Scroll to top
    func scrollToTop(animated: Bool) {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: animated)
    }
    
    // Bonus: Scroll to bottom
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: true)
        }
    }
    
}



extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}

extension UITextField {
    var string:String? {
        get {
            return self.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        set {
            self.text = newValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
    }
    var txtColor :UIColor? {
        get {
            return self.textColor
        }
        set {
            self.textColor = newValue
        }
    }
    
}

extension UITextView {
    var string:String? {
        get {
            return self.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        set {
            self.text = newValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
    }
    var txtColor :UIColor? {
        get {
            return self.textColor
        }
        set {
            self.textColor = newValue
        }
    }
}

extension UILabel {
    var string:String? {
        get {
            return self.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        set {
            self.text = newValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
    }
    var txtColor :UIColor? {
        get {
            return self.textColor
        }
        set {
            self.textColor = newValue
        }
    }
    
}

extension UIButton {
    
    var image:UIImage? {
        get {
            return self.currentImage
        }
        set {
            self.setImage(newValue, for: .normal)
            self.setImage(newValue, for: .selected)
            self.setImage(newValue, for: .highlighted)
            self.setImage(newValue, for: .disabled)
        }
    }
    
    var txtColor :UIColor? {
        get {
            return self.titleLabel?.textColor
        }
        set {
            self.setTitleColor(newValue, for: .normal)
        }
    }
    var string :String? {
        get {
            return self.titleLabel?.string ?? ""
        }
        set {
            self.setTitle(newValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", for: .normal)
            self.setTitle(newValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", for: .selected)
            self.setTitle(newValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", for: .highlighted)
        }
    }
}
