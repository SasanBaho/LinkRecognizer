//
//  Camera.swift
//  Link Recognizer
//
//  Created by Sasan Baho on 2020-04-21.
//  Copyright © 2020 Sasan Baho. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class Camera{
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var captureSession: AVCaptureSession!
    var capturePhotoOutput: AVCapturePhotoOutput!
    
    func setupCaptureSession(cameraView : UIView){
        
        AVCaptureDevice.authorizeVideo(completion: { (status) in

       
            self.captureSession = AVCaptureSession()
            self.captureSession.sessionPreset = .high
            
            guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
                else {
                    print("Unable to access back camera!")
                    return
                }
            do {
                let input = try AVCaptureDeviceInput(device: backCamera)
                self.capturePhotoOutput = AVCapturePhotoOutput()

                if self.captureSession.canAddInput(input) && self.captureSession.canAddOutput(self.capturePhotoOutput) {
                    self.captureSession.addInput(input)
                    self.captureSession.addOutput(self.capturePhotoOutput)
                    
                    self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
                    self.videoPreviewLayer!.videoGravity = .resizeAspectFill
                   
                     
                    DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
                       self.captureSession!.startRunning()
                       DispatchQueue.main.async {
                        cameraView.layer.addSublayer(self.videoPreviewLayer!)
                          self.videoPreviewLayer!.frame = cameraView.layer.bounds
                       }
                    }
                }
            }
            catch let error  {
                print("Error Unable to initialize back camera:  \(error.localizedDescription)")
            }
            
          
        })
    }
    
    
}



extension AVCaptureDevice {
    enum AuthorizationStatus {
        case justDenied
        case alreadyDenied
        case restricted
        case justAuthorized
        case alreadyAuthorized
        case unknown
    }

    class func authorizeVideo(completion: ((AuthorizationStatus) -> Void)?) {
        AVCaptureDevice.authorize(mediaType: AVMediaType.video, completion: completion)
    }

    private class func authorize(mediaType: AVMediaType, completion: ((AuthorizationStatus) -> Void)?) {
        let status = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch status {
        case .authorized:
            completion?(.alreadyAuthorized)
        case .denied:
            completion?(.alreadyDenied)
        case .restricted:
            completion?(.restricted)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { (granted) in
                DispatchQueue.main.async {
                    if granted {
                        completion?(.justAuthorized)
                    } else {
                        completion?(.justDenied)
                    }
                }
            })
        @unknown default:
            completion?(.unknown)
        }
    }
}

