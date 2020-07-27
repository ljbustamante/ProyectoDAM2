//
//  AuthViewController.swift
//  ProyectoDAM2
//
//  Created by Luis Javier Bustamante Rodriguez on 7/25/20.
//  Copyright © 2020 Luis Javier Bustamante Rodriguez. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseAuth
import GoogleSignIn
import FacebookLogin

class AuthViewController: UIViewController {
    @IBOutlet weak var authStackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Autenticación"
        passwordTextField.textContentType = .oneTimeCode
        Analytics.logEvent("InitScreen",  parameters: ["message": "Integración de Firebase completa."])
        // Comprobar la sesión del usuario autenticado
        let defaults = UserDefaults.standard
        if let email = defaults.value(forKey: "email") as? String,
            let provider = defaults.value(forKey: "provider") as? String{
            authStackView.isHidden = true
            
            self.navigationController?.pushViewController(HomeViewController(email: email, provider: ProviderType.init(rawValue: provider)!), animated: false)
        }
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authStackView.isHidden = false
        
    }

    @IBAction func signUpButtonAction(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail:  email, password: password) { (result, error) in
                self.showHome(result: result, error: error, provider: .basic)
            }
        }
    }
    
    @IBAction func logInButtonAction(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail:  email, password: password) { (result, error) in
                self.showHome(result: result, error: error, provider: .basic)
            }
        }
    }
    @IBAction func googleButtonAction(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func facebookButtonAction(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logOut()
        loginManager.logIn(permissions: [.email], viewController: self) { (result) in
            switch result {
                
            case .success(granted: let granted, declined: let declined, token: let token):
                
                let credential = FacebookAuthProvider.credential(withAccessToken: token.tokenString )
                
                Auth.auth().signIn(with: credential) { (result, error) in
                    self.showHome(result: result, error: error, provider: .facebook)
                }
            case .cancelled:
                break
            case .failed(_):
                break
            }
        }
    }
    
    private func showHome(result: AuthDataResult?, error: Error?, provider: ProviderType){
        if let result = result, error == nil {
            self.navigationController?.pushViewController(HomeViewController(email: result.user.email!, provider: provider), animated: true)
        }else{
            let alertController = UIAlertController(title: "Error", message: "Se ha producido un error de autenticación mediante \(provider.rawValue)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension AuthViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil, user.authentication != nil {
            let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { (result, error) in
                self.showHome(result: result, error: error, provider: .google)
            }
        }
    }
}
