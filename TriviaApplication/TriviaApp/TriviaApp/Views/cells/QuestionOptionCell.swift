//
//  QuestionOptionCell.swift
//  TriviaApp
//
//  Created by Namxu Ihseruq on 06/03/2021.
//

import UIKit
import DropDown

class QuestionOptionCell: BaseTBCell {

    @IBOutlet weak var tfField:FloatableTextField!
    
    var onValueChange:((String) -> Void)?
    let dropDownCategory = DropDown()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCategory()
    }
    
    @objc func onTfChange(_ tf:UITextField){
        onValueChange?(tf.string ?? "")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickDropDown(_ sd:UIButton){
        self.dropDownCategory.anchorView = sd // UIView or UIBarButtonItem
        self.dropDownCategory.show()
    }
    
    
    func setupCategory(){
        dropDownCategory.direction = .bottom
        dropDownCategory.dismissMode = .automatic
        dropDownCategory.bottomOffset = CGPoint(x: 0, y:40)
        dropDownCategory.selectionAction = { [unowned self] (index: Int, item: String) in
            self.tfField.tfField!.string = item
            self.onValueChange?(item)
//            self.onItemChange?(self.tfOption.string ?? "",self.tfOptionValue.string ?? "")
        }
    }
//    var difficulty:QuestionDifficultyType? = nil
//    var typeOption:QuestionChoicetype? = nil
    var itemCell:OptionDataModel? = nil
    func setupCell(_ item:OptionDataModel){
        self.itemCell = item
        self.tfField.tvFloatLabel!.string = item.title
        self.tfField.tfField!.placeholder = item.placeholder
        self.tfField.textFieldDidEndEditing(self.tfField.tfField!)
        self.tfField.tfField!.string = item.value
        switch item.type {
        
        case .Category:
            dropDownCategory.dataSource = DataManager.sharedInstance.categories.map({ (items) -> String in
                return items.name ?? ""
            })
        case .Difficulty:
            dropDownCategory.dataSource = QuestionDifficultyType.allCases.map({ (items) -> String in
                return items.rawValue.capitalized
            })
        case .OptionType:
            dropDownCategory.dataSource = QuestionChoicetype.allCases.map({ (items) -> String in
                return items.rawValue.capitalized
            })
        case .StartQuestion:
            break
        }
    }
    
    
}
