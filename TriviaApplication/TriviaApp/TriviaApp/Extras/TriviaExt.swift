//
//  BingLineExt.swift
//  BingLine
//
//  Created by Shahid Saleem on 1/30/21.
//

import Foundation
import UIKit
import SkeletonView
import Toast_Swift

extension UIView {
    func newRoundCornersView(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11, *) {
            var cornerMask = CACornerMask()
            if(corners.contains(.topLeft)){
                cornerMask.insert(.layerMinXMinYCorner)
            }
            if(corners.contains(.topRight)){
                cornerMask.insert(.layerMaxXMinYCorner)
            }
            if(corners.contains(.bottomLeft)){
                cornerMask.insert(.layerMinXMaxYCorner)
            }
            if(corners.contains(.bottomRight)){
                cornerMask.insert(.layerMaxXMaxYCorner)
            }
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = cornerMask

        } else {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
}


extension UIViewController{
    var window : UIWindow {
        return UIApplication.shared.windows.first!
    }
    func showToast(text:String,type:Loaf.State,location:Loaf.Location,_ duration:Loaf.Duration = .average,_ completation: (() -> ())? = nil){
        if (text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || text.lowercased() == "success" || text.lowercased() == "success."){
            return
        }
        switch type {
            
        case .success:
            self.showToastWithImage(text: text, isError: type,location:location)
            completation?()
            break
        case .error:
            self.showToastWithImage(text: text, image: nil, isError: type,location:location)
            completation?()
            break
        case .warning:
            self.showToastWithImage(text: text, image: nil, isError: type,location:location)
            completation?()
            break
        case .info:
            self.showToastWithImage(text: text, image: nil, isError: type,location:location)
            completation?()
            break
        case .custom(_):
            completation?()
            break
            
        }
        
    }
    
    func showToastWithImage(text:String,image:UIImage? = nil,isError:Loaf.State = .success,location:Loaf.Location = .top) {
        var style = ToastStyle()
//        style.messageFont = ColeaquesFont.kOSRegular(CGFloat(12)).font()
//        style.titleFont = ColeaquesFont.kOSBold(CGFloat(13)).font()
        switch isError {
        case .success:
            style.backgroundColor = UIColor.blue.withAlphaComponent(0.8)
            style.displayShadow = true
            style.imageSize = CGSize.init(width: 20, height: 20)
            self.window.makeToast(text, duration: 2.0, position: location == .top ? .top : .bottom, title: nil, image: image,style:style)
        case .error:
            style.backgroundColor = UIColor.red.withAlphaComponent(0.8)
            style.displayShadow = true
            style.imageSize = CGSize.init(width: 20, height: 20)
            self.window.makeToast(text, duration: 2.0, position: location == .top ? .top : .bottom, title: nil, image: nil,style:style)
        case .warning,.info,.custom(_):
            style.backgroundColor = UIColor.init(named: "DarkYellowColor") ?? .yellow//ColeaquesColor.redColor.withAlphaComponent(0.8)
            style.displayShadow = true
            style.imageSize = CGSize.init(width: 20, height: 20)
            self.window.makeToast(text, duration: 2.0, position: location == .top ? .top : .bottom, title: nil, image: nil,style:style)
        }
    }
    
    //MARK: Get VC From Storyborad
    func getVC(storyboard : Storyboards, vcIdentifier : ControllersVC) -> UIViewController {
        //String = kStoryBoardMain
        return UIStoryboard(name: storyboard.board(), bundle: nil).instantiateViewController(withIdentifier: vcIdentifier.rawValue)
    }
    func pushView(_ vc:UIViewController?,_ isAnimated:Bool = true,isFromTabControllerPush:Bool = false){
        if let vc = vc {
            if(isFromTabControllerPush){
                if let tabVc = self.tabBarController{
                    tabVc.navigationController?.pushViewController(vc, animated: isAnimated)
                }else{
                    self.navigationController?.pushViewController(vc, animated: isAnimated)
                }
            }else{
                self.navigationController?.pushViewController(vc, animated: isAnimated)
            }
        }
    }
    
    func presentVC(_ vc:UIViewController?,_ isAnimated:Bool = true,isFromTabControllerPush:Bool = false){
        if let vc = vc {
            if(isFromTabControllerPush){
                if let nav = self.tabBarController?.navigationController{
                    nav.present(vc, animated: isAnimated, completion: nil)
                }else{
                    self.present(vc, animated: isAnimated, completion: nil)
                }
            }else{
                if let nav = self.navigationController{
                    nav.present(vc, animated: isAnimated, completion: nil)
                }else{
                    self.present(vc, animated: isAnimated, completion: nil)
                }
            }
        }
    }
}


enum ControllersVC:String {
    case SplashVC = "SplashVC"
    case QuestionsOptionVC = "QuestionsOptionVC"
    
    
    func getIdentifier() -> String {
        return self.rawValue
    }
}
//MARK:- CollectionViewCell
enum CVCells:String ,CaseIterable {
    case IntroCells = "IntroCells"
    
    
    var nib:UINib? {
        return UINib.init(nibName: self.rawValue, bundle: nil)
    }
    var identifier:String {
        return self.rawValue
    }
    
    static func addNibs(_ collectionView:UICollectionView){
        
        for item in CVCells.allCases {
            collectionView.register(item.nib, forCellWithReuseIdentifier: item.identifier)
        }
    }
}

//MARK:- TabelViewCell

enum TVCells:String,CaseIterable {
    
    case ButtonCell = "ButtonCell"
    case QuestionOptionCell = "QuestionOptionCell"
    case QuestionCell = "QuestionCell"
    
    var nib:UINib? {
        return UINib.init(nibName: self.rawValue, bundle: nil)
    }
    var identifier:String {
        return self.rawValue
    }
    
    static func addNibs(_ tableView:UITableView){
        
        for item in TVCells.allCases {
            tableView.register(item.nib, forCellReuseIdentifier: item.identifier)
        }
    }
}

open class BaseTBCell:UITableViewCell {
    var viewArray = [UIView?]()
    var baseVc:BaseVC? = nil
    
    func showSkullAnim(){
        viewArray.forEach({ $0?.showAnimatedGradientSkeleton() })
    }
    
    func hideSkullAnim(){
        viewArray.forEach({ $0?.hideSkeleton(transition: .crossDissolve(0.25))  })
    }
}

open class BaseCVCell:UICollectionViewCell {
    
    var viewArray = [UIView?]()
    var baseVc:BaseVC? = nil
    
    func showSkullAnim(){
        viewArray.forEach({ $0?.showAnimatedGradientSkeleton() })
    }
    
    func hideSkullAnim(){
        viewArray.forEach({ $0?.hideSkeleton(transition: .crossDissolve(0.25))  })
    }
    func enableSkeleton(){
        viewArray.forEach({ $0?.isSkeletonable = true })
    }
}

enum Storyboards :String{
    case MAIN = "MainBoard"
    
    func board()->String{
        return self.rawValue
    }
}

class FloatableTextField:UIView,UITextFieldDelegate,UITextViewDelegate {
    var tfField:UITextField? = nil
    var uiOutline:UIView? = nil
    var tvFloatLabel:UILabel? = nil
    func setupIds(){
        if(self.tfField == nil){
            self.tfField = self.viewWithTag(1010) as? UITextField
        }
        if(self.uiOutline == nil){
            self.uiOutline = self.viewWithTag(2020)
        }
        if(self.tvFloatLabel == nil){
            self.tvFloatLabel = self.viewWithTag(3030) as? UILabel
        }
        if(self.tfField?.delegate == nil){
            self.tfField?.delegate = self
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupIds()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupIds()
        
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let color = UIColor.init(named: "BorderColor") ?? self.borderColor
        self.uiOutline?.borderColor = color
        self.tvFloatLabel?.textColor = color
        self.tvFloatLabel?.setAttributedTextForLabelAll(mainString: self.tvFloatLabel?.attributedText?.string, attributedStringsArray: ["*"], color: [color], attFont: [self.tvFloatLabel?.font])
        self.layoutIfNeeded()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let color = UIColor.white// ?? self.borderColor
        let colorGreen = UIColor.init(named: "RequiredColor") ?? color
        self.uiOutline?.borderColor = color
        self.tvFloatLabel?.textColor = color
        self.tvFloatLabel?.setAttributedTextForLabelAll(mainString: self.tvFloatLabel?.attributedText?.string, attributedStringsArray: ["*"], color: [colorGreen], attFont: [self.tvFloatLabel?.font])
        self.layoutIfNeeded()
    }
}

extension UIView{
    @IBInspectable var borderColor: UIColor? {
        get{
            
            return UIColor.init(cgColor: layer.borderColor ?? UIColor.clear.cgColor)//vBorderColour
        }
        set {
            
            layer.borderColor = newValue?.cgColor
//            vBorderColour = newValue
            self.setNeedsLayout()
            
        }
    }

    func  setAttributedTextForLabelAll(mainString : String? , attributedStringsArray : [String?]  , color : [UIColor?], attFont:[UIFont?]) {
        let attributedString1    = NSMutableAttributedString(string: mainString ?? "")
        for (index,objStr) in attributedStringsArray.enumerated() {
            let range1 = (mainString as NSString?)?.range(of: objStr ?? "") ?? .init()
            let attribute_font = [NSAttributedString.Key.font: attFont[index] ?? UIFont.systemFont(ofSize: CGFloat(12))]
            attributedString1.addAttributes(attribute_font, range:  range1)
            attributedString1.addAttribute(NSAttributedString.Key.foregroundColor, value: color[index] ?? UIColor.clear, range: range1)
        }
        if(self.isKind(of: UILabel.self)) {
            (self as! UILabel).attributedText = attributedString1
        }
        if(self.isKind(of: UITextView.self)) {
            (self as! UITextView).attributedText = attributedString1
        }
        if(self.isKind(of: UITextField.self)) {
            (self as! UITextField).attributedText = attributedString1
        }
        if(self.isKind(of: UIButton.self)) {
            (self as! UIButton).setAttributedTitle(attributedString1, for: .normal)
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
                self.setNeedsLayout()
            }
        }
    }
    var screenWidth:CGFloat {
        get {
            DataManager.sharedInstance.getScreenWidth()//return UIScreen.main.bounds.height
        }
        set(newValue) {
            DataManager.sharedInstance.setScreenWidth(value: newValue)
        }
    }
    
    var screenHeight:CGFloat {
        get {
            DataManager.sharedInstance.getScreenHeight()//return UIScreen.main.bounds.height
        }
        set(newValue) {
            DataManager.sharedInstance.setScreenHeight(value: newValue)
        }
    }
    
    func hideView(){
        self.isHidden = true
    }
    
    func showView(){
        self.isHidden = false
    }
}
