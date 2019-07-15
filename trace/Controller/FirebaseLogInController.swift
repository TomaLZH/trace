//
//  FirebaseLogInController.swift
//  trace
//
//  Created by ITP312 on 12/7/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class FirebaseLogInController: UIViewController {
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
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
       resetPassword()
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
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    //do stuff here
                  //  let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                  //  self.present(vc!, animated: true, completion: nil)
                   
                } else {
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
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
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(defaultAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    
    func resetPassword() {
        if self.email.text == "" {
            let alert = UIAlertController(title: "Oops!", message: "Please enter an email.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(defaultAction)
            
            present(alert, animated: true, completion: nil)
            
        } else {
          
            Auth.auth().sendPasswordReset(withEmail: self.email.text!, completion: { (error) in
                
                var title = ""
                var message = ""
                
                if error != nil {
                    title = "Error!"
                    message = (error?.localizedDescription)!
                } else {
                    title = "Success!"
                    message = "Password reset email sent."
                    self.email.text = ""
                }
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(defaultAction)
                
                self.present(alert, animated: true, completion: nil)
            })
        }
    
  
    }
}
