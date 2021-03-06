//
//  ButtonCell.swift
//  TriviaApp
//
//  Created by Namxu Ihseruq on 06/03/2021.
//

import UIKit

class ButtonCell: BaseTBCell {

    @IBOutlet weak var btnCell:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var onClickedButton:(() -> Void)?
    @IBAction func onClickButton(_ sd:UIButton){
        self.onClickedButton?()
    }
    
}
