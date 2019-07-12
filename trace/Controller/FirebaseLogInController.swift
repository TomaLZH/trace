//
//  FirebaseLogInController.swift
//  trace
//
//  Created by ITP312 on 12/7/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import FirebaseAuth

class FirebaseLogInController: UIViewController {
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
   @IBAction func segmentTapped(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 {
            loginButton.setTitle("Login", for: UIControl.State.normal)
        } else {
            loginButton.setTitle("Signup", for: UIControl.State.normal)
        }
    }
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        if segment.selectedSegmentIndex == 0 {
            login()
        } else if segment.selectedSegmentIndex == 1 {
            signup()
        }
        
    }
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        let forgotPasswordAlert = UIAlertController(title: "Forgot password?", message: "Enter email address", preferredStyle: .alert)
        forgotPasswordAlert.addTextField { (textField) in
            textField.placeholder = "Enter email address"
        }
        forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        forgotPasswordAlert.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (action) in
            let resetEmail = forgotPasswordAlert.textFields?.first?.text
            Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in
                if error != nil{
                    let resetFailedAlert = UIAlertController(title: "Reset Failed", message: "Error: \(String(describing: error?.localizedDescription))", preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetFailedAlert, animated: true, completion: nil)
                }else {
                    let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Check your email", preferredStyle: .alert)
                    resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetEmailSentAlert, animated: true, completion: nil)
                }
            })
        }))
        //PRESENT ALERT
        self.present(forgotPasswordAlert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    
    func login(){
        
        if self.email.text == "" || self.password.text == ""
        {
            let alert = UIAlertController(title: "Dotard", message: "Fill up also don't fill up", preferredStyle: .alert)
            
            
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)        } else {
            Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!){
                (user, error) in
                
                if error == nil {
                    
                    
                    
                   print("You did justin yayyy")  //do stuff here
                   
                    
                    
                    
                } else {
                    print("Error")
                    
                }
            }
        }
        
    }
    
    func signup(){
        
        if email.text == "" {
            let alert = UIAlertController(title: "Dotard", message: "Fill up also don't fill up", preferredStyle: .alert)
            
            
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        } else {
            Auth.auth().createUser(withEmail: email.text!, password: password.text!){
                (user, error) in
                if error == nil {
                    print("Omigoto Justin you are sicc")
                    let alert = UIAlertController(title: "Iwae Waga Maou", message: "You successfully signed up.. dotard", preferredStyle: .alert)
                    
                    
                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
                    
                    
                } else {
                    print("Ji Pa Boom")
                }
            }
        }
        
    }
    
    
  

}
