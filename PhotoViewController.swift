//
//  PhotoViewController.swift
//  
//
//  Created by Jason Jin on 3/25/17.
//
//

import UIKit
import TesseractOCR
import GPUImage

class PhotoViewController: UIViewController, G8TesseractDelegate {
    var loading: UIActivityIndicatorView! = nil
    var addedString = " "
    @IBOutlet weak var textView: UITextView!
    lazy var tesseract: G8Tesseract = {
        let tesseract = G8Tesseract(language: "eng")
        //tesseract?.engineMode = .tesseractCubeCombined
        tesseract?.delegate = self
        tesseract?.charWhitelist = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890:.@/-";
        tesseract?.maximumRecognitionTime = 2.0
        return tesseract!
    }()
    
    var analyzeButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 667-66, width: 375, height: 66))
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.white
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Start", for: .normal)
        button.setTitle("Analyzing!", for: UIControlState.disabled)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.white, for: .disabled)
        button.setImage(UIImage(named:"ic_arrow_forward"), for: .normal)
        button.setImage(UIImage(named:"ic_arrow_forward_white"), for: .disabled)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(PhotoViewController.recognizeImage), for: UIControlEvents.touchUpInside)
        //button.frame(CGRect(x: 250, y: 5, width: 100, height: 30))
        //        button.titleEdgeInsets = UIEdgeInsets
        return button
    }()


        
        
    
    private var fourColorCircularProgress: KYCircularProgress!
    var progressTimer: Timer!
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var backgroundImage: UIImage
    
    var isRecognizing = false
    
    init(image: UIImage) {
        self.backgroundImage = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var backgroundImageView: UIImageView!
    
    override func loadView() {
        print("view did load")
        super.loadView()
        
        
        self.view.backgroundColor = UIColor.gray
        backgroundImageView = UIImageView(frame: view.frame)
        backgroundImageView.contentMode = UIViewContentMode.scaleAspectFit
        backgroundImageView.image = backgroundImage
        view.addSubview(backgroundImageView)
        let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
        cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)
        view.addSubview(analyzeButton)
        
        configureFourColorCircularProgress()
        loading = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        loading.center = self.view.center
        loading.hidesWhenStopped = true
        loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.view.addSubview(loading)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    private func configureFourColorCircularProgress() {
        fourColorCircularProgress = KYCircularProgress(frame: CGRect(x: view.frame.width/3, y: view.frame.height/3+10, width: view.frame.width/3, height: view.frame.height/3))
        fourColorCircularProgress.colors = [UIColor(rgba: 0xA6E39D11), UIColor(rgba: 0xAEC1E355), UIColor(rgba: 0xAEC1E3AA), UIColor(rgba: 0xF3C0ABFF)]
                view.addSubview(fourColorCircularProgress)
    }
    
    func updateProgress() {
        if (fourColorCircularProgress.progress >= 1) {
            isRecognizing = false
            fourColorCircularProgress.isHidden = true
            progressTimer.invalidate()
        }
        if (tesseract.progress == 0) {
            fourColorCircularProgress.progress += 0.01
        }
        else {
            
        }
    }
    
    
    func recognizeImage(_ sender: AnyObject) {
        let button: UIButton = sender as! UIButton
        button.isEnabled = false
        button.tintColor = UIColor.black
        button.backgroundColor = UIColor.black
        cleanImage()
        let recognizedBlocks = tesseract.recognizedBlocks(by: .textline)
        for item in recognizedBlocks! {
            if ((item as AnyObject).confidence > 50) {
                //print((item as AnyObject).text)
                addedString += ((item as AnyObject).text)
            }
        }
        print(addedString)
        fourColorCircularProgress.isHidden = true
        displayAlert()
        //self.backgroundImageView.image = tesseract.image(withBlocks: recognizedBlocks, drawText: true, thresholded: false)
        
        //endTime()
        //self.progressTimer.invalidate()
        
    }
    func endTime() {
        print("started timer")
        //progressTimer.invalidate()
    }
    func progressImageRecognition(for tesseract: G8Tesseract!) {
        let progress = Double(tesseract.progress)/100
        fourColorCircularProgress.progress = progress
    }
    func preprocessedImage(for tesseract: G8Tesseract!, sourceImage: UIImage!) -> UIImage! {
        let filter = AdaptiveThreshold()
        filter.blurRadiusInPixels = 50.0
        let filtered = sourceImage.filterWithOperation(filter)
        self.backgroundImageView.image = filtered
        return filtered
    }
    func cleanImage() {
        self.tesseract.image = self.backgroundImage//.g8_blackAndWhite()
        //self.backgroundImageView.image = self.tesseract.image
        let image = self.backgroundImageView.image
        tesseract.recognize()
        
    }
    func displayAlert() {
        self.analyzeButton.isEnabled = true
        self.analyzeButton.backgroundColor = UIColor.white
        let alert = SCLAlertView()
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "Futura-Medium", size: 20)!,
            kTextFont: UIFont(name: "Futura-Medium", size: 14)!,
            kButtonFont: UIFont(name: "Futura-Bold", size: 14)!,
            showCloseButton: true,
            shouldAutoDismiss: false
        )
        alert.appearance = appearance
        alert.addButton("Next", backgroundColor: UIColorFromRGB(0x99CCFF), textColor: UIColor.white, showDurationStatus: false) {
            
            self.analyzeButton.setTitle("Start", for: .normal)
            alert.hideView()
            let newVC = TextViewController(text: self.tesseract.recognizedText)
            self.present(newVC, animated: true, completion: nil)
        }
        alert.showCustom("Recognized!", subTitle: "Click next to view the text!", color: UIColorFromRGB(0x2DC79B), icon: SCLAlertViewStyleKit.imageOfCheckmark)
        self.loading.stopAnimating()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
    }
    
    func linksToCheck(text: String) {
        /*switch text {
        case "https":
            <#code#>
        case "http":
        default:
            <#code#>
        }*/
    }
    
    func recog() {
        
        
        print("finished recognizing")
        
    }
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
}
