//
//  QRCoder.swift
//  QRCoder
//
//  Created by mac on 16/8/15.
//  Copyright © 2016年 mac. All rights reserved.
//

import UIKit
import AVFoundation
public class QRCoder: NSObject,AVCaptureMetadataOutputObjectsDelegate{
    
    public func scan() {
        //1.判断是否有设备
        if !session.canAddInput(videoInput) {
            print("无法添加输入设备")
            return
        }
        if !session.canAddOutput(dataOutPut) {
            print("无法添加输出数据")
            return
        }
        //2.添加输入设备,输出数据
        session.addInput(videoInput)
        session.addOutput(dataOutPut)
        //3.设置输出识别的格式和代理
        dataOutPut.metadataObjectTypes = dataOutPut.availableMetadataObjectTypes
        dataOutPut.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        //4.启动会话
        session.startRunning()
        //5.添加图层
        
        
        
    }
    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
    }
    
    
    //MARK - 扫描属性
    //1.拍摄会话,扫描的桥梁
    lazy var session: AVCaptureSession = {
        return AVCaptureSession()
    }()
    //2.输入设备,摄像头
    lazy var videoInput:AVCaptureDeviceInput? = {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if device == nil{
            return nil
        }
        return try! AVCaptureDeviceInput(device: device)
    }()
    //3输出数据
    lazy var dataOutPut:AVCaptureMetadataOutput = {
        return AVCaptureMetadataOutput()
    }()
    //4.预览视图
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        
        return previewLayer
    }()
    //5.绘图视图图层
    lazy var drawLayer:CALayer = {
       let drawLayer = CALayer()
        
        return drawLayer
    }()


}
