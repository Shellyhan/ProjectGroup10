//
//  ViewController.swift
//  ActiveSFU-Survey
//
//  Created by CoolMac on 2017-02-28.
//  Copyright © 2017 CoolMac. All rights reserved.
//

import UIKit

struct Question{
    var questionString: String?
    var answers: [String]?
    var selectedAnswerIndex: Int?
}

// Future feature would be to add the ability to select multiple answers
// It is unfortunately very messy and cluttered, haven't figured out how to remedy that just yet
var questionsList: [Question] = [Question(questionString: "What is your fitness experience level?", answers: ["Expert (5+ years)", "Advanced (2-5 years)", "Intermediate (1-2 years)", "Novice (< 1 year)", "Total beginner (0 experience)"], selectedAnswerIndex: nil), Question(questionString: "What best describes your fitness activity interests?", answers: ["Free weight training", "Cardiovascular training", "Yoga", "Sports", "All of the above"], selectedAnswerIndex: nil), Question(questionString: "In what time slot are you available?", answers:["8:30-10:30AM", "10:30-12:30PM", "12:30-2:30PM", "2:30-4:30PM", "4:30-6:30PM"], selectedAnswerIndex: nil), Question(questionString: "What day(s) of the week are you available?", answers: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Mon/Wed/Fri", "Tues/Thurs", "Everyday"], selectedAnswerIndex: nil), Question(questionString: "Do you have a gender matching preference?", answers:["I'd prefer to match with people of my gender", "I don't care"], selectedAnswerIndex: nil)]



class QuestionController: UITableViewController {
    
    // The value/contents of the string are irrelevant
    // They're just to assign a unique id to the tableview object later
    let cellID = "cmpt276"
    let headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Text at top
        navigationItem.title = "Question"
        
        // The back button color/text
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Return", style: .plain, target:nil, action: nil)
        
        // Register the answercell class in creating new table cells. Assign this an id value of 'cellID'
        tableView.register(AnswerCell.self, forCellReuseIdentifier: cellID)
        
        // Registers a header cell above the question cells
        tableView.register(QuestionHeader.self, forHeaderFooterViewReuseIdentifier: headerId)
        
        // Puts the header 50 pixels above the answer cells
        tableView.sectionHeaderHeight = 50
        
        // Gets rid of the lines below the bottom cells
        tableView.tableFooterView = UIView()
        
    }
    
    // Repeat the answer labels 5 times
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        // This is for accessing the desired question
        if let index = navigationController?.viewControllers.index(of: self) {
            let question = questionsList[index]
            if let count = question.answers?.count {
                return count
            }
        }
        
        return 0
    }
    
    //Recognize the cellID and create table objects accordingly
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
            as! AnswerCell
      
        if let index = navigationController?.viewControllers.index(of: self) {
            let question = questionsList[index]
            cell.nameLabel.text = question.answers?[indexPath.row]
        }
        
        return cell
    }
    
    // Recognize and create header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerId)
            as! QuestionHeader
        
        if let index = navigationController?.viewControllers.index(of: self) {
            let question = questionsList[index]
            header.nameLabel.text = question.questionString
        }
        
        return header
    }
    
    // Recognzie and create results page
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let index = navigationController?.viewControllers.index(of: self) {
            questionsList[index].selectedAnswerIndex = indexPath.item
           
            // This is what allows the user to proceed to the next question
            if index < questionsList.count - 1{
                let questionController = QuestionController()
                navigationController?.pushViewController(questionController, animated: true)
            } else{
                let controller = ResultsController()
                controller.question = questionsList[index]
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    }

// This is what they see after they've answered the questions
class ResultsController: UIViewController{
    
    var question: Question?{
        didSet {
            print(question?.selectedAnswerIndex as Any) // ??
        }
        
        
    }
    
    let resultsLabel: UILabel = {
        let label = UILabel()
        label.text = "Thank you for answering."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        return label
    
    }()
    
    // The text at the top of the page in the coloured section
    override func viewDidLoad(){
        super.viewDidLoad()
        
        navigationItem.title = "Finished"
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(resultsLabel)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":resultsLabel]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":resultsLabel]))
        
    }
}


// Class for the header above the answers
class QuestionHeader: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    //Create and set label properties
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Question"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //setup the constrains of the labels
    func setupViews(){
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":nameLabel]))
        
    }
    
    // Added by xcode automatically
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



// Class for our answer cells
class AnswerCell: UITableViewCell{
    
    // Initialize table cell
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    // This was added by xcode automatically after creating the class
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Create and set label properties
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Answers"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Setup the constraints of the labels
    func setupViews(){
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":nameLabel]))
        
    }
}

