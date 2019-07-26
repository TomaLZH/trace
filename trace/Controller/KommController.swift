//
//  KommController.swift
//  trace
//
//  Created by ITP312 on 26/7/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import Kommunicate


class KommController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Kommunicate.setup(applicationId:"25dc110eba251b5b57905d14bb3dab85e")
        let kmUser = KMUser()
        kmUser.userId = Kommunicate.randomId() // Pass userId here NOTE : +,*,? are not allowed chars in userId.
        kmUser.email = "lzhaqw1232@gmail.com"// Optional
        kmUser.applicationId = "25dc110eba251b5b57905d14bb3dab85e"
        // Use this same API for login
        Kommunicate.registerUser(kmUser, completion: {
            response, error in
            guard error == nil else {return}
            print("login Success ") // You can launch the chat screen on success of login
            let agentId = ["tourism-ltlhpw"] // Pass your agent id here
            let botId = ["trace-rf5cm"] //enter your integrated bot Id
            
            Kommunicate.createConversation(
                userId: "",
                agentIds: agentId,
                botIds: botId,
                useLastConversation: false,
                completion: { response in
                    guard !response.isEmpty else {return}
                    Kommunicate.showConversationWith(groupId: response, from: self, completionHandler: { success in
                    })
            })
        })
        


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
