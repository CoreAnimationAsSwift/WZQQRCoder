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

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let qr = QRCoder()
        let image = qr.generateImage("二维码生成器", avatarImage: nil)
        imageView.image = image
    }

   

}

