//
//  ViewController.swift
//  Link Recognizer
//
//  Created by Sasan Baho on 2020-04-21.
//  Copyright © 2020 Sasan Baho. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation
import FirebaseMLVision
import Firebase

protocol FrameExtractorDelegate: class {
    func captured(image: UIImage)
}

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate, WKNavigationDelegate, WKUIDelegate, UISearchBarDelegate, AVCaptureVideoDataOutputSampleBufferDelegate  {
    
    let vision = Vision.vision()
    var textRecognizer: VisionTextRecognizer!
    let urlRecognizer = UrlRecognizer()


    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cameraViewHight: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var hintTextLabel: UILabel!
    @IBOutlet weak var cameraBtn: UIButton!
    
    let camera = Camera()
    let cropImage = CropImage()
    let spinner = Spinner()
    let k = Constants()
    var isBookmarkOpen = false
    var isCameraViewOpen = true
    var cameraAuthorized = false
    weak var delegate: FrameExtractorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoad()
       
        NotificationCenter.default.addObserver(self, selector: #selector(openBookmarkUrl), name: Notification.Name(k.tappedBookmarkUrl), object: nil )
    }
    
    func setupLoad() {
        runCamera()
        bottomView.layer.zPosition = 50
        cameraView.layer.zPosition = 39
        webView.layer.zPosition = 40
        topView.layer.zPosition = 40
        self.cameraViewHight.constant = 80
        webView.uiDelegate = self
        searchBar.delegate = self
        hideHint()
        searchBar.searchTextField.textAlignment = .center
        searchBar.placeholder = k.firstLoadText
        searchBar.searchTextField.font = UIFont(name: "Arial", size: 13)
    }
    
    func hideHint(){
        hintTextLabel.layer.zPosition = 100
        hintTextLabel.textColor = .white
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
            UIView.animate(withDuration: 1.0, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.hintTextLabel.alpha = 0
            })
        }
    }
    
    func runCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .restricted || status == .denied {
            alertCameraAccessNeeded()
        }else {
            camera.setupCaptureSession(cameraView: cameraView)
            cameraAuthorized = true
        }
    }

    func cameraViewAnimation() {
        if isCameraViewOpen {
            closeCameraView()
        }else{
            openCameraView()
        }
    }
    func closeCameraView(){
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
               self.cameraViewHight.constant = 0
               self.view.layoutIfNeeded()
           }, completion: nil)
        isCameraViewOpen = false

    }
    
    func openCameraView() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
             self.cameraViewHight.constant = 80
             self.view.layoutIfNeeded()
           }, completion: nil)
        isCameraViewOpen = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(true)
           webView?.navigationDelegate = self
           webView.load(URLRequest(url: URL(string: k.defaultUrl)!))
           
       }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
        if cameraAuthorized {
            camera.captureSession!.stopRunning()
        }
            
       }
    
    @objc func openBookmarkUrl(_ nc: Notification){
        if let data = nc.userInfo as? [String: String]
        {
            let bookmarkedUrl = data["urlKey"]!
            webView.load(URLRequest(url: URL(string: bookmarkedUrl)!))
        }
    }
    
    //put image to MLKit
    func runTextRecognition(with image: UIImage){
        textRecognizer = vision.onDeviceTextRecognizer()

        let imageMetadata = VisionImageMetadata()
        imageMetadata.orientation = UIUtilities.visionImageOrientation(from: image.imageOrientation)
        
        let visionImage = VisionImage(image: image)
        visionImage.metadata = imageMetadata
        
        textRecognizer.process(visionImage) { (features, error)  in self.processResult(from: features, error: error)
        }
    }
    
    //Start to translate image to text
    func processResult(from text: VisionText?, error: Error?) {
        var newUrl = ""
        if let features = text {
            for block in features.blocks {
                for line in block.lines {
                    for element in line.elements {
                        if urlRecognizer.findUrl(from: element.text.lowercased()) != "" {
                            newUrl = urlRecognizer.findUrl(from: element.text.lowercased())
                        }
                    }
                }
            }
           if newUrl.isValidURL || newUrl != "" {
               openUrl(urlString : newUrl)
           }else {
               searchBar.text = k.cantFindText
               removeSpinner()
           }
        }else {
            searchBar.text = k.cantFindText
            removeSpinner()
        }
        
    }
    
    func openUrl(urlString : String){
        if urlString.isValidURL {
            openCameraView()
            if isCameraViewOpen {
                if urlString.lowercased().range(of: "http") == nil {
                    searchBar.text = urlString
                    if let url = URL(string: "http://\(urlString)") {
                        webView.load(URLRequest(url: url))
                    }
                }else{
                    searchBar.text = urlString
                    if let url = URL(string: urlString){
                        webView.load(URLRequest(url: url))
                    }
                }
                closeCameraView()
            }else {
                openCameraView()
            }
        }else{
            searchBar.text = k.cantFindText
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let imageData = photo.fileDataRepresentation()
                   else { return }
           if let image = UIImage(data: imageData){
               let newImage = cropImage.scaleAndCropImage(image, toSize: cameraView.frame.size)
               runTextRecognition(with: newImage)
           }
    }
    
    func alertCameraAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
     
         let alert = UIAlertController(
             title: "Need Camera Access",
             message: "Camera access is required to make full use of this app.",
             preferredStyle: UIAlertController.Style.alert
         )
     
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
         
        present(alert, animated: true, completion: nil)
        
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        camera.capturePhotoOutput!.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func capturePhoto(_ sender: UIButton) {
        if cameraAuthorized {
            if isCameraViewOpen {
                capturePhoto()
            }else{
                openCameraView()
            }
        }else {
            alertCameraAccessNeeded()
        }
    }
    
    
    @IBAction func backwardBtn(_ sender: UIButton) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    @IBAction func forwardBtn(_ sender: UIButton) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @IBAction func shareBtn(_ sender: UIButton) {
        let urlToShare = webView.url?.absoluteString
        if urlToShare!.isValidURL {
            let objectsToShare = [urlToShare!] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            //Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }else {
            searchBar.text = "Can't find any link to share!"
        }
    }
    
    @IBAction func bookmarkBtn(_ sender: UIButton) {
        closeCameraView()
    }
    @IBAction func openCameraViewButton(_ sender: UIButton) {
        cameraViewAnimation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "bookmarks" {
            let nav = segue.destination as! UINavigationController
            let svc = nav.topViewController as! BookmarkViewController
            svc.url = webView.url!.absoluteString
        }
    }

    func removeSpinner() {
        spinner.removeSpinner()
        cameraBtn.setBackgroundImage(UIImage(systemName: "camera"), for: .normal)
    }
    
    // this handles target=_blank links by opening them in the same view
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        spinner.showSpinner(onView: cameraBtn)

    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.title") { (result, error) in
            if error == nil && result != nil{
                self.searchBar.text = result as? String
            }else {
                self.searchBar.text = webView.url?.absoluteString
            }
        }
        //removeSpinner()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        removeSpinner()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        closeCameraView()
        view.endEditing(true)
        if let searchText = searchBar.text {
            if searchText.isValidURL {
                 openUrl(urlString: searchText)
            }
            else {
                let correctUrlString = searchText.replacingOccurrences(of: " ", with: "+")
                webView.load(URLRequest(url: URL(string: ("\(k.defaultUrl)/search?q=\(correctUrlString)"))!))
            }
        }else {
            return
        }
        
        
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = webView.url?.absoluteString
        self.searchBar.searchTextField.selectAll(self)
        removeSpinner()
    }
    
}

