//
//  ChatController.swift
//  trace
//
//  Created by ITP312 on 19/6/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import ApiAI
import AVFoundation


class ChatController: UIViewController {

    @IBOutlet weak var tracetext: UILabel!
    @IBOutlet weak var inputtext: UITextField!
    
    @IBAction func entermessage(_ sender: Any) {
        let request = ApiAI.shared().textRequest()
        
        if let text = self.inputtext.text, text != "" {
            request?.query = text
        } else {
            return
        }
        
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse
            if let textResponse = response.result.fulfillment.speech {
                self.speechAndText(text: textResponse)
            }
        }, failure: { (request, error) in
            print(error!)
        })
        
        ApiAI.shared().enqueue(request)
        inputtext.text = ""
    }
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    func speechAndText(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechSynthesizer.speak(speechUtterance)
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.tracetext.text = text
        }, completion: nil)
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
