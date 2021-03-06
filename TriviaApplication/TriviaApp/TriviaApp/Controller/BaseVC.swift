//
//  BaseVC.swift
//  TriviaApp
//
//  Created by Namxu Ihseruq on 06/03/2021.
//

import Foundation
import UIKit
import RSLoadingView

class BaseVC:UIViewController{
    
    let loadingView = RSLoadingView.init(effectType: RSLoadingView.Effect.spinAlone)
    let imageBlur = DefaultImageClass.init(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingView.shouldDimBackground = true
        self.loadingView.colorVariation = CGFloat.init(3)
        self.imageBlur.tag = 1221
    }
    
    func showLoading(_ isNeedBlue:Bool = false) {
        DispatchQueue.main.async {
            let rect = CGRect.init(x: (Int(self.view.frame.size.width)/2) - (52/2),
                                   y: (Int(self.view.frame.size.height)/2) - (52/2),
                                   width: 52,
                                   height: 52)
            self.imageBlur.frame = rect
            self.imageBlur.image = UIImage.init(named: "TriviaAppIcon")
            self.imageBlur.contentMode = .scaleAspectFit
            self.loadingView.show(on: self.view)
            self.imageBlur.isHidden = false
            self.imageBlur.cornerRadius = rect.height/2
            self.imageBlur.clipsToBounds = true
            self.view.addSubview(self.imageBlur)
            self.view.bringSubviewToFront(self.imageBlur)
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
//            RSLoadingView.hide(from: self.view)
            self.loadingView.hide()
            self.imageBlur.removeFromSuperview()
            self.imageBlur.isHidden = true
//            for (_,items) in self.view.subviews.enumerated(){
//                if(items.tag == 1221){
//                    items.removeFromSuperview()
//                    break
//                }
//            }
        }
    }
    
    func getAllGategories(completaion:(([CategoryModel]) -> Void)? = nil){
        if DataManager.sharedInstance.categories.isEmpty{
            APIManager.sharedInstance.opertationWithRequest(withApi: .getCategories) { (APIResponse) in
                switch APIResponse {
                
                case .Success(_):
                    completaion?(DataManager.sharedInstance.categories)
                case .Failure(_):
                    completaion?(DataManager.sharedInstance.categories)
                case .Progress(_):
                    break
                }
            }
        }else{
            completaion?(DataManager.sharedInstance.categories)
        }
    }
    
    
    @IBAction public func goBack(_ sender : UIButton){
        if self.navigationController != nil{
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    open func delay(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}
