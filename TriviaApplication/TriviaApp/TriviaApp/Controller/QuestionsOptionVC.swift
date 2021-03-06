//
//  QuestionsOptionVC.swift
//  TriviaApp
//
//  Created by Namxu Ihseruq on 06/03/2021.
//

import UIKit

class QuestionsOptionVC: BaseVC {

    @IBOutlet weak var tableView:UITableView!
    var mData = OptionDataModel.getData()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTbl()
        // Do any additional setup after loading the view.
    }
    

}

extension QuestionsOptionVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = BaseTBCell()
        let item = mData[indexPath.row]
        
        switch item.type {

        case .Category:
            cell = tableView.dequeueReusableCell(withIdentifier: TVCells.QuestionOptionCell.identifier, for: indexPath) as! QuestionOptionCell
            if let cell = cell as? QuestionOptionCell {
                cell.baseVc = self
                cell.setupCell(item)
                cell.onValueChange = { value in
                    self.mData[indexPath.row].value = value
                    self.mData[indexPath.row].category = DataManager.sharedInstance.categories.first(where: { (itemCat) -> Bool in
                        return itemCat.name == value
                    })
                }
            }
        case .Difficulty:
            cell = tableView.dequeueReusableCell(withIdentifier: TVCells.QuestionOptionCell.identifier, for: indexPath) as! QuestionOptionCell
            if let cell = cell as? QuestionOptionCell {
                cell.baseVc = self
                cell.setupCell(item)
                cell.onValueChange = { value in
                    self.mData[indexPath.row].value = value
                    self.mData[indexPath.row].difficulty = QuestionDifficultyType.init(rawValue: value.lowercased())
                }
            }
        case .OptionType:
            cell = tableView.dequeueReusableCell(withIdentifier: TVCells.QuestionOptionCell.identifier, for: indexPath) as! QuestionOptionCell
            if let cell = cell as? QuestionOptionCell {
                cell.baseVc = self
                cell.setupCell(item)
                cell.onValueChange = { value in
                    self.mData[indexPath.row].value = value
                    self.mData[indexPath.row].typeOption = QuestionChoicetype.init(rawValue: value.lowercased())
                }
            }
        case .StartQuestion:
            //ButtonCell
            cell = tableView.dequeueReusableCell(withIdentifier: TVCells.ButtonCell.identifier, for: indexPath) as! ButtonCell
            if let cell = cell as? ButtonCell {
                cell.baseVc = self
                cell.btnCell.string = item.title
                cell.onClickedButton = {
                    let category = self.mData.first { (items) -> Bool in
                        return items.category != nil
                    }?.category
                    let difficulty = self.mData.first { (items) -> Bool in
                        return items.difficulty != nil
                    }?.difficulty
                    let typeOption = self.mData.first { (items) -> Bool in
                        return items.typeOption != nil
                    }?.typeOption
                    if category == nil {
                        self.showToast(text: "Please select Category", type: .error, location: .top)
                    }else if difficulty == nil {
                        self.showToast(text: "Please select Difficulty", type: .error, location: .top)
                    }else if typeOption == nil {
                        self.showToast(text: "Please select Type", type: .error, location: .top)
                    }else{
                        self.showLoading()
                        APIManager.sharedInstance.opertationWithRequest(withApi: API.getQuestion(catId: category?.id ?? 0, difficultyType: difficulty ?? .Medium, choiceType: typeOption ?? .TrueFalse)) { (APIResponse) in
                            self.hideLoading()
                            switch APIResponse {
                            
                            case .Success(let data):
                                print(data?.data as Any)
                            case .Failure(let error):
                                print(error as Any)
                            case .Progress(_):
                                break
                            }
                        }
                    }
                }
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = mData[indexPath.row]
        
        switch item.type{
        
        case .Difficulty,.OptionType,.Category:
            return self.tableView.frame.size.height*0.2

        case .StartQuestion:
            return UITableView.automaticDimension
        }
    }
    
    func setupTbl(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        TVCells.addNibs(self.tableView)
    }
    
}

enum Options:CaseIterable {
    case Category
    case Difficulty
    case OptionType
    case StartQuestion
}

struct OptionDataModel {
    var type:Options = .Category
    var title:String = ""
    var placeholder:String = ""
    var value:String = ""
    var category:CategoryModel? = nil
    var difficulty:QuestionDifficultyType? = nil
    var typeOption:QuestionChoicetype? = nil
    static func getData() -> [OptionDataModel]{
        var list = [OptionDataModel]()
        for item in Options.allCases{
            var element = OptionDataModel()
            element.type = item
            switch item {
            case .Category:
                element.placeholder = "Select Category"
                element.title = "Category *"
            case .Difficulty:
                element.placeholder = "Select Difficulty"
                element.title = "Question Difficulty *"
            case .OptionType:
                element.placeholder = "Select Option Type"
                element.title = "Question Option *"
            case .StartQuestion:
                element.title = "Start Trivia"
            }
            list.append(element)
        }
        return list
    }
}
