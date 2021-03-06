//
//  ViewController.swift
//  matemeup
//
//  Created by Mehdi Meddour on 3/21/18.
//  Copyright © 2018 MateMeUp. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var connexionButton: UIButton!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailInput.delegate = self
        self.passwordInput.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func checkLogin(email: String, password: String) {
        let _self: UIViewController = self

        let _ = APIRequest.getInstance().send(route: "login", method: "POST", body: ["email": email, "password": password], callback: Callback(success: { data in
            let jsonData = data as? Dictionary<String, Any>
            let token = jsonData!["token"] as? String
            let user = jsonData!["user"] as? Dictionary<String, Any>
            
            JWT.putAPI(token!)
            APIRequest.getInstance().addQueryString("token", token!)
            let _ = ConnectedUser.set(user!)
            Navigation.goTo(segue: "loginSuccessSegue", view: _self)
        }, fail: { error in
            DispatchQueue.main.async {
                Alert.ok(controller: self, title: "Erreur lors de la connexion", message: "Email / Mot de passe invalide", callback: nil)
            }
        }))
    }

    // Mark : Actions
    @IBAction func connexion(_ sender: Any) {
        
        let email: String! = emailInput.text
        let password: String! = passwordInput.text

        checkLogin(email: email, password: password)
    }
    
    
}

