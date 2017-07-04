//
//  ListViewController.swift
//  KIGitTrending
//
//  Created by Lee on 2017. 6. 21..
//  Copyright © 2017년 KI. All rights reserved.
//

import Foundation
import UIKit
import Kanna
import WebKit

class ListViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var languageTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    weak var datePickerView = UIPickerView()
    weak var languagePickerView = UIPickerView()
    
    var basicUrl = "https://github.com/trending"
    var currentUrl: String = ""
    var dateList = [String]()
    var languageList = [String]()
    var trendingList = Array<GitData>()
    let reuseIdentifier = "TrendingListCell"
    var isDate: Bool?
    
    override func viewDidLoad() {
        
        currentUrl = basicUrl
        htmlParsing(url: basicUrl)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        dateList = ["today", "this week", "this month"]

        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
        let keyBoardToolBar = KeyBoardToolBar(frame: frame)
        keyBoardToolBar.keyBoardDelegate = self
        let datePickerView = UIPickerView()
        datePickerView.dataSource = self
        datePickerView.delegate = self
        datePickerView.tag = 1
        self.datePickerView = datePickerView
        dateTextField.inputView = datePickerView
        dateTextField.inputAccessoryView = keyBoardToolBar
        
        let keyBoardToolBar2 = KeyBoardToolBar(frame: frame)
        keyBoardToolBar2.keyBoardDelegate = self
        let languagePickerView = UIPickerView()
        languagePickerView.dataSource = self
        languagePickerView.delegate = self
        languagePickerView.tag = 2
        self.languagePickerView = languagePickerView
        languageTextField.inputView = languagePickerView
        languageTextField.inputAccessoryView = keyBoardToolBar2
        
    }
    
    func htmlParsing(url: String) {
       
        resetTrendingList()
        
        guard let apiURL = NSURL(string: url) else {
            return
        }
        
        if let doc = HTML(url: apiURL as URL, encoding: .utf8) {
            
            for link in doc.css("li") {

                let gitData = GitData()
                
                for atom in link.css("a") {
                    if atom.className != nil {
                        if (atom.className?.contains("filter-item"))! {
                            languageList.append(link.text!.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                    }
                }
                
                for leaf in link.css("div") {
                    if leaf.className! == "d-inline-block col-9 mb-1" {
                        let titleComponents = leaf.text!.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " / ")
                        gitData.firstTitle = titleComponents[0]
                        gitData.secondTitle = titleComponents[1]
                        gitData.gitUrl = URL(string: "https://github.com/\(titleComponents[0])/\(titleComponents[1])")
                        
                    } else if leaf.className! == "py-1" {
                        gitData.desc = leaf.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                    } else if leaf.className! == "f6 text-gray mt-2" {
                        for atom in leaf.css("span") {
                            if atom.className == nil {
                                continue
                            }
                            if atom.className! == "d-inline-block mr-3" {
                                gitData.language = atom.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                            } else if atom.className! == "float-right" {
                                gitData.todayStar = atom.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                        }
                        for atom in leaf.css("a") {
                            let href = atom["href"]
                            if (href?.contains("stargazers"))! {
                                gitData.totalStar = atom.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                            } else if (href?.contains("network"))! {
                                gitData.numberOfNetwork = atom.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                            
                            
                        }
                    }
                }
                if gitData.firstTitle == nil, gitData.secondTitle == nil {
                    continue
                }
                trendingList.append(gitData)
            }
        }
        languageList.append("Swift")
        languageList.append("Objective-c")
    }
    
    func translatedArray(string: String) -> Array<String> {
        var translatedArray = [String]()
        let components = string.components(separatedBy: "\n")
        
        for component in components {
            let trimmingData = component.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmingData != "" {
                translatedArray.append(trimmingData)
            }
        }
        return translatedArray
    }
    
    @IBAction func languageTouch(_ sender: UITextField) {
        isDate = false
    }
    @IBAction func dateTouched(_ sender: UITextField) {
        isDate = true
    }

    @IBAction func textFieldDidEndEditing(_ sender: UITextField) {
        if (dateTextField?.isFirstResponder)! {
            dateTextField.resignFirstResponder()
            datePickerView?.resignFirstResponder()
        } else if (languageTextField?.isFirstResponder)! {
            languageTextField.resignFirstResponder()
            languagePickerView?.resignFirstResponder()
        }
    }
  
    func doneButtonTouched() {

        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.view)
        })
        activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            activityIndicator.stopAnimating()
        }
        
        textFieldDidEndEditing(UITextField())
        
        if isDate == true {
            guard let selectedRow = datePickerView?.selectedRow(inComponent: 0) else { return }
            let date = dateList[selectedRow]
            dateTextField.text = "Trending:\(date)"
            
            if (currentUrl.contains("?")) {
                let component = currentUrl.components(separatedBy: "?")
                currentUrl = component[0]
            }
    
            var postFix = ""
            if selectedRow == 0 {
                postFix = "?since=daily"
            } else if selectedRow == 1 {
                postFix = "?since=weekly"
            } else {
                postFix = "?since=monthly"
            }

            currentUrl = "\(currentUrl)\(postFix)"
            
            
            htmlParsing(url: currentUrl)
            
            tableView.reloadData()
    
        } else {
            guard let selectedRow = languagePickerView?.selectedRow(inComponent: 0) else { return }
            if selectedRow == 0 || selectedRow == 1 {
                activityIndicator.stopAnimating()
                return
            }
            let language = languageList[selectedRow]
            languageTextField.text = "Language:\(language)"
           
            if currentUrl.contains("?") {
                let component = currentUrl.components(separatedBy: "?")
                let postFix = component[1]
                currentUrl = "\(basicUrl)/\(language)"
                currentUrl.append("?\(postFix)")
            } else {
                currentUrl = "\(basicUrl)/\(language)"
            }
            
            htmlParsing(url: currentUrl)
            
            tableView.reloadData()
        }
        
       
    }
    
    func cancelButtonTouched() {
        if isDate == true {
            dateTextField.resignFirstResponder()
        } else {
            languageTextField.resignFirstResponder()
        }
    }
    
    func resetTrendingList() {
        trendingList.removeAll()
        languageList.removeAll()
    }
    
}

class ListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var starLabel: UILabel!
    
    func configure(data: GitData) {
        
        let titleAttributedString = NSMutableAttributedString(string: "\(data.firstTitle!) / ")
        titleAttributedString.append(NSAttributedString(string: data.secondTitle!, attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17)]))
        titleLabel?.attributedText = titleAttributedString
       
        descriptionLabel?.text = data.desc
        languageLabel?.text = data.language
        networkLabel.text = data.numberOfNetwork
        guard let today = data.todayStar, let total = data.totalStar else {
            return
        }
        starLabel.text = "\(total) \\ \(today)"
    }
    
}

extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .newlines).joined()
    }
}


extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! ListTableViewCell
        cell.configure(data: trendingList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if dateTextField.isFirstResponder {
            dateTextField.resignFirstResponder()
        } else if languageTextField.isFirstResponder {
            languageTextField.resignFirstResponder()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if dateTextField.isFirstResponder {
            dateTextField.resignFirstResponder()
        } else if languageTextField.isFirstResponder {
            languageTextField.resignFirstResponder()
        }
    }
}


extension ListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "detail_git" {
        
            let thisCell = sender as! ListTableViewCell
            let indexPath = tableView.indexPath(for: thisCell)!
            
            let destViewController = segue.destination as! DetailWebViewController
            destViewController.request = URLRequest(url: trendingList[indexPath.row].gitUrl!)
        }
    }
}

extension ListViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return dateList.count
        } else if pickerView.tag == 2 {
            return languageList.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return dateList[row]
        } else if pickerView.tag == 2 {
            return languageList[row]
        }
        return String()
    }
    
}

