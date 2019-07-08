//
//  CameraController.swift
//  trace
//
//  Created by ITP312 on 5/7/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import Firebase

class CameraController: UIViewController {
    
    
    lazy var vision = vision.vision()
    var textDetector: VisionTextDetector?
    
    let languages = ["Select Language", "Hindi", "French", "Italian", "German", "Japanese"]
    let languageCodes = ["hi", "hi", "fr", "it", "de", "ja"]
    var targetCode = "hi"

    @IBAction func cameraButtonTapped(_ sender: Any) {
    }
    @IBAction func photosButtonTapped(_ sender: Any) {
        
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var predictionLabel: UILabel!
    
    
    
    @IBOutlet weak var translatedText: UILabel!
    
   // @IBOutlet weak var detectedText: UILabel!
    
    @IBAction func languageSelectorTapped(_ sender: Any) {
        
        if pickerVisible {
            languagePickerHeightConstraint.constant = 0
            pickerVisible = false
            translateText(detectedText:self.detectedText.text ?? "" )
            
        } else {
            languagePickerHeightConstraint.constant = 150
            pickerVisible = true
        }
        
    }
    @IBOutlet weak var languageSelectorButton: UIButton!
    
    @IBOutlet weak var languagePicker: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLanguagePicker()

        // Do any additional setup after loading the view.
    }
    
    func configureLanguagePicker() {
        languagePicker.dataSource = self
        languagePicker.delegate = self
    }
    
    
    
    func detectText (image: UIImage){
        textDetector = vision.textDetector()
        
        let visionImage = VisionImage(image: image)
        textDetector?.detect(in: visionImage){(features,error) in
            guard error == nil, let features = features, !features.isEmpty else{
                return
            }
            debugPrint("Feature blocks in the image: \(features.count)")
            var detectedText = ""
            for feature in features {
                let value = feature.text
                detectedText.append("\(value) ")
            }
            self.detectedText.text = detectedText
            self.translateText(detectedText: detectedText)
            
            
        }
    }
    
    
    
    extension CameraController: UIPickerViewDataSource, UIPickerViewDelegate {
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return languages.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return languages[row]
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            languageSelectorButton.setTitle(languages[row], for: .normal)
            targetCode = languageCodes[row]
        }
        
        
        
        
    }
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
