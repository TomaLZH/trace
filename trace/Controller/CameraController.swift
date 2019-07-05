//
//  CameraController.swift
//  trace
//
//  Created by ITP312 on 5/7/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit

class CameraController: UIViewController {

    @IBAction func cameraButtonPressed(_ sender: Any) {
    }
    @IBAction func selectPhotosButtonPressed(_ sender: Any) {
        
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var predictionLabel: UILabel!
    @IBOutlet weak var translatedText: UILabel!
    
   // @IBOutlet weak var detectedText: UILabel!
    
    @IBAction func selectLanguageBtnPressed(_ sender: Any) {
    }
    @IBOutlet weak var selectLanguage: UIButton!
    
    @IBOutlet weak var pickerView: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
