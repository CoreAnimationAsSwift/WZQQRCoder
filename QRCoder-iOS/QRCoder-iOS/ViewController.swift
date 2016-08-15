//
//  ViewController.swift
//  QRCoder-iOS
//
//  Created by mac on 16/8/15.
//  Copyright © 2016年 mac. All rights reserved.
//

import UIKit
import AVFoundation
import QRCoder
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scanner = QRCoder()
        scanner.scan()
        
    }

   

}

