//
//  ViewController.swift
//  TriviaApp
//
//  Created by Namxu Ihseruq on 06/03/2021.
//

import UIKit

class SplashVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showLoading()
        self.getAllGategories{categories in
            self.hideLoading()
            let vc = self.getVC(storyboard: .MAIN, vcIdentifier: .QuestionsOptionVC) as! QuestionsOptionVC
            self.pushView(vc)
//            print(categories)
            
        }
    }

}

