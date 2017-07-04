//
//  KeyBoardToolBar.swift
//  KIGitTrending
//
//  Created by Lee on 2017. 6. 27..
//  Copyright © 2017년 KI. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol keyBoardToolBarDelegate {
    func doneButtonTouched()
    func cancelButtonTouched()
}

class KeyBoardToolBar: UIToolbar {
    
    weak var doneButton: UIButton!
    weak var cancleButton: UIButton!
    var keyBoardDelegate: ListViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(doneButtonTouched), for: .touchUpInside)
        addSubview(button)
        button.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-10)
            make.top.bottom.equalTo(self)
            make.width.equalTo(50)
        }
        self.doneButton = button
       
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTouched), for: .touchUpInside)
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.top.bottom.equalTo(self)
            make.width.equalTo(80)
        }
    }
    
    func doneButtonTouched() {
        keyBoardDelegate?.doneButtonTouched()
    }
    
    func cancelButtonTouched() {
        keyBoardDelegate?.cancelButtonTouched()
    }
}
