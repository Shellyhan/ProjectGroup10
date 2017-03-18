//
//  QuestionController.swift
//  Developed by Ryan Brown, Nathan Cheung
//
//  Using the coding standard provided by eure: github.com/eure/swift-style-guide
//
//  When registering a new user, the app will ask a series of questions to the user about his activity habits and
//  schedule.
//  using this, the app will be able to run matching algorithms and tailor the app to the user's preferences.
//
//  Bugs:
//  users are able to choose more than one choice on questions that are supposed to be only one selection
//  Sometimes the survey will open then immediately close
//
//  Changes:
//  Changed header color
//  Allowed multiple selections
//  Register survey 'data' into firebase
//
//
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//  Credits to: https://github.com/purelyswift/personality_type_tutorial_completed

import UIKit

import Firebase


//MARK: QuestionController



class QuestionController: UITableViewController {
    
    var surveyScore = 0
    
    let cellID = "cmpt276"
    let headerId = "headerId"
    
    func userClickedContinue() {
        
        if let questionIndex = navigationController?.viewControllers.index(of: self) {
            
            questionsList[questionIndex].selectedAnswerIndex = surveyScore
            
            // This is what allows the user to proceed to the next question
            if questionIndex < questionsList.count - 1 {
                
                print("Survey score is \(surveyScore)")
                let questionController = QuestionController()
                questionController.surveyScore = surveyScore
                navigationController?.pushViewController(questionController, animated: true)
            }
            else {
                
                let resultsController = ResultsController()
                resultsController.surveyScore = surveyScore
                resultsController.currentSurveyQuestion = questionsList[questionIndex]
                navigationController?.pushViewController(resultsController, animated: true)
            }
        }
    }
    
    
    //MARK: UITableViewController
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsMultipleSelection = true
        
        navigationItem.title = "Question"
        
        // The back button color/text
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Return", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continue", style: .plain, target: self, action: #selector(userClickedContinue))
        
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
        if let questionIndex = navigationController?.viewControllers.index(of: self) {
            
            let surveyQuestion = questionsList[questionIndex]
            if let count = surveyQuestion.answers?.count {
                
                return count
            }
        }
        return 0
    }
    
    //Recognize the cellID and create table objects accordingly
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
            as! AnswerCell
        
        tableCell.accessoryType = tableCell.isSelected ? .checkmark: .none
        tableCell.selectionStyle = .none
        
        if let questionIndex = navigationController?.viewControllers.index(of: self) {
            
            let surveyQuestion = questionsList[questionIndex]
            tableCell.nameLabel.text = surveyQuestion.answers?[indexPath.row]
        }
        return tableCell
    }
    
    // Recognize and create header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let questionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerId)
            as! QuestionHeader
        
        if let index = navigationController?.viewControllers.index(of: self) {
            
            let question = questionsList[index]
            questionHeader.nameLabel.text = question.questionString
        }
        return questionHeader
    }
    
    // Recognzie and create results page
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        surveyScore = surveyScore + indexPath.item
        print(surveyScore)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        surveyScore = surveyScore - indexPath.item
        print(surveyScore)
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}


//MARK: ResultsController


// This is what they see after they've answered the questions
class ResultsController: UIViewController {
    
    var surveyScore = 0
    var currentSurveyQuestion: Question? {
        
        didSet {
            
            print(currentSurveyQuestion?.selectedAnswerIndex as Any) // ??
        }
    }
    
    let resultsLabel: UILabel = {
        
        let finishLabel = UILabel()
        finishLabel.text = "Thank you for answering."
        finishLabel.translatesAutoresizingMaskIntoConstraints = false
        finishLabel.textAlignment = .center
        finishLabel.font = UIFont.boldSystemFont(ofSize: 14)
        
        return finishLabel
        
    }()
    
    func continueToApp() {
        
        let currentUID = FIRAuth.auth()?.currentUser?.uid
        let firebaseReference = FIRDatabase.database().reference()
        let userReferenceInDatabase = firebaseReference.child("Users").child(currentUID!)
        
        userReferenceInDatabase.updateChildValues(["survey": surveyScore])
        
        self.presentingViewController!.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: UIViewController
    
    
    // The text at the top of the page in the coloured section
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continue", style: .plain, target: self, action: #selector(continueToApp))
        
        navigationItem.title = "Finished"
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(resultsLabel)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":resultsLabel]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":resultsLabel]))
    }
}


//MARK: QuestionHeader


// Class for the header above the answers
class QuestionHeader: UITableViewHeaderFooterView {
    
    //Create and set label properties
    let nameLabel: UILabel = {
        
        let questionLabel = UILabel()
        questionLabel.text = "Question"
        questionLabel.font = UIFont.boldSystemFont(ofSize: 14)
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        return questionLabel
    }()
    
    //setup the constrains of the labels
    func setupViews() {
        
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":nameLabel]))
    }
    
    // Added by xcode automatically
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(reuseIdentifier: String?) {
        
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
}


//MARK: AnswerCell


// Class for our answer cells
class AnswerCell: UITableViewCell {
    
    // Initialize table cell
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    // This was added by xcode automatically after creating the class
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    // Create and set label properties
    let nameLabel: UILabel = {
        
        let answerLabel = UILabel()
        answerLabel.font = UIFont.systemFont(ofSize: 14)
        answerLabel.text = "Answers"
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        return answerLabel
    }()
    
    // Setup the constraints of the labels
    func setupViews() {
        
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":nameLabel]))
    }
}


//MARK: Private


// Future feature would be to add the ability to select multiple answers
// It is unfortunately very messy and cluttered, haven't figured out how to remedy that just yet
var questionsList: [Question] = [Question(questionString: "What is your fitness experience level?", answers: ["Expert (5+ years)", "Advanced (2-5 years)", "Intermediate (1-2 years)", "Novice (< 1 year)", "Total beginner (0 experience)"], selectedAnswerIndex: nil), Question(questionString: "What best describes your fitness activity interests?", answers: ["Free weight training", "Cardiovascular training", "Yoga", "Sports", "All of the above"], selectedAnswerIndex: nil), Question(questionString: "In what time slot are you available?", answers:["8:30-10:30AM", "10:30-12:30PM", "12:30-2:30PM", "2:30-4:30PM", "4:30-6:30PM"], selectedAnswerIndex: nil), Question(questionString: "What day(s) of the week are you available?", answers: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Mon/Wed/Fri", "Tues/Thurs", "Everyday"], selectedAnswerIndex: nil), Question(questionString: "Do you have a gender matching preference?", answers:["I'd prefer to match with people of my gender", "I don't care"], selectedAnswerIndex: nil)]

struct Question {
    
    var questionString: String?
    var answers: [String]?
    var selectedAnswerIndex: Int?
}
