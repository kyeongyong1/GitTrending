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

class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var trendingList = [Array<String>]()
    let reuseIdentifier = "TrendingListCell"
    
    override func viewDidLoad() {
//        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        htmlParsing()
    }
    
    func htmlParsing() {
        
        guard let apiURL = NSURL(string: "https://github.com/trending") else {
            return
        }
        
        if let doc = HTML(url: apiURL as URL, encoding: .utf8) {
            
            for link in doc.css("li") {
                
                let parsingData: Array = translatedArray(string: link.text!)
                print(parsingData)
                
                if parsingData.count == 1 {
                    break
                }
                trendingList.append(parsingData)
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
    
}

class ListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!

    func configure(data: Array<String>) {
        titleLabel?.text = data[0]
        descriptionLabel?.text = data[2]
        languageLabel?.text = data[3]
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
