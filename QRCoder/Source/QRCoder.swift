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
    //MARK: - 参数
    ///最大选择数
    var maxDetectedCount:Int
    ///当前选择数
    var currentDetectedCount:Int = 0
    ///线宽
    var lineWidth:CGFloat
    ///划线颜色
    var strokeColor:UIColor
    //    Block回调
    var completedCallBack:((stringValue:String) -> ())?
    //MARK: - 可调用方法
    ///构造器
    public init(lineWidth:CGFloat = 4,strokeColor:UIColor = UIColor.greenColor(),maxDetectedCount:Int = 20) {
        self.maxDetectedCount = maxDetectedCount
        self.lineWidth = lineWidth
        self.strokeColor = strokeColor
    }
    ///扫描方法
    public func scanCode(view:UIView,completion:(stringValue:String) -> ()) {
        completedCallBack = completion
        setupSession()
        setupLayers(view)
    }
    ///生成二维码,返回UIImage,stringValue为要生成的字符串,
    public func generateImage(stringValue:String,avatarImage:UIImage?,avatarScale:CGFloat = 0.25,color:CIColor = CIColor(color: UIColor.whiteColor()),backColor:CIColor = CIColor(color: UIColor.blackColor())) -> UIImage?{
        //设置一个滤镜CIFilter
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        //重置滤镜的初始值
        qrFilter?.setDefaults()
        //通过KVC设置滤镜的内容
        qrFilter?.setValue(stringValue.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), forKey: "inputMessage")
        //输出图像
        let ciImage = qrFilter?.outputImage
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setDefaults()
        colorFilter?.setValue(ciImage, forKey: "inputImage")
        colorFilter?.setValue(color, forKey: "inputColor0")
        colorFilter?.setValue(backColor, forKey: "inputColor1")
        //输出
        let outImage = colorFilter?.outputImage
        //形变
        let transform = CGAffineTransformMakeScale(5, 5)
        //        输出的图像进行形变
        let transformColor = outImage?.imageByApplyingTransform(transform)
        let image = UIImage(CIImage: transformColor!)
        if avatarImage != nil  {
            return insertAvatarImage(image, avatarImage: avatarImage!, avatarScale:avatarScale)
        }
        return image
    }
    //MARK: - 私有方法
    func setupSession() {
        //1.判断是否有设备
        if !session.canAddInput(videoInput) {
            print("无法添加输入设备")
            return
        }
        if !session.canAddOutput(dataOutPut) {
            print("无法添加输出数据")
            return
        }
        if session.running {
            print("会话正在运行")
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
    }
    func setupLayers(view:UIView) {
        drawLayer.frame = view.bounds
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(drawLayer, atIndex: 0)
        view.layer.insertSublayer(previewLayer, atIndex: 0)
        
    }
    func clearDrawLayer() {
        if drawLayer.sublayers == nil {
            return
        }
        for layer in drawLayer.sublayers! {
            layer.removeFromSuperlayer()
        }
    }
    //画框框,图层
    func drawCodeCorners(codeObject:AVMetadataMachineReadableCodeObject) {
        if codeObject.corners.count == 0 {
            return
        }
        //CoreAnimal
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeColor = strokeColor.CGColor
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.path = createPath(codeObject.corners).CGPath
        drawLayer.addSublayer(shapeLayer)
    }
    //路线
    func createPath(points:NSArray) -> UIBezierPath {
        let path = UIBezierPath()
        var point = CGPoint()
        var index = 0
        CGPointMakeWithDictionaryRepresentation((points[index++] as! CFDictionaryRef), &point)
        path.moveToPoint(point)
        while index < points.count {
            CGPointMakeWithDictionaryRepresentation((points[index++] as! CFDictionaryRef), &point)
            path.addLineToPoint(point)
        }
        path.closePath()
        return path
    }
    func insertAvatarImage(codeImage:UIImage,avatarImage:UIImage,avatarScale:CGFloat) -> UIImage {
        let size = codeImage.size
        UIGraphicsBeginImageContext(size)
        codeImage.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let avatarSize = CGSizeMake(size.width * avatarScale, size.height * avatarScale)
        let x = (size.width - avatarSize.width) * 0.5
        let y = (size.height - avatarSize.height) * 0.5
        avatarImage.drawInRect(CGRectMake(x, y, avatarSize.width, avatarSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    //MARK: - 代理AVCaptureMetadataOutputObjectsDelegate
    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        clearDrawLayer()
        for dataObject in metadataObjects {
            //确保对象类型
            if let codeObject = dataObject as? AVMetadataMachineReadableCodeObject {
                if currentDetectedCount++ > maxDetectedCount {
                    session.stopRunning()
                    completedCallBack!(stringValue: codeObject.stringValue)
                }
                //                转换成预览视图的坐标
                let object = previewLayer.transformedMetadataObjectForMetadataObject(codeObject) as! AVMetadataMachineReadableCodeObject
                drawCodeCorners(object)
            }
        }
    }
    
    
    //MARK: - 扫描属性
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
