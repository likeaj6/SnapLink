//
//  TextViewController.swift
//  SnapLink
//
//  Created by Jason Jin on 3/25/17.
//  Copyright © 2017 Jason Jin. All rights reserved.
//


import UIKit

class TextViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var recognizedText: String
    let textView = UITextView(frame: CGRect(x: 0, y: 88, width: 367, height: 667))
    init(text: String) {
        self.recognizedText = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        textView.dataDetectorTypes = .all;
        textView.isEditable = false
        self.view.addSubview(textView)
        textView.font = .systemFont(ofSize: 30)
        textView.text = recognizedText
        let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
        cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
}
