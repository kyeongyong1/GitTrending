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

class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var dateList = [String]()
    var languageList = [String]()
    var trendingList = Array<GitData>()
    let reuseIdentifier = "TrendingListCell"
    
    
    override func viewDidLoad() {
        htmlParsing()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        dateList = ["today ","this week", "this month"]
    }
    
    func htmlParsing() {
        
        guard let apiURL = NSURL(string: "https://github.com/trending") else {
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
                            if atom.className! == "mr-3" {
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
    
    @IBAction func languageButtonTouched(_ sender: UIButton) {
        
        
        
    }
    
    @IBAction func dateButtonTouched(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) { 
            self.pickerView.alpha = 1
        }
        
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


extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! ListTableViewCell
        cell.configure(data: trendingList[indexPath.row])
        return cell
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
        return self.dateList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.dateList[row]
    }
}

