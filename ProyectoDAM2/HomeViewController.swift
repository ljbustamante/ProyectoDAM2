//
//  HomeViewController.swift
//  ProyectoDAM2
//
//  Created by Luis Javier Bustamante Rodriguez on 7/27/20.
//  Copyright © 2020 Luis Javier Bustamante Rodriguez. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FacebookLogin
import FirebaseFirestore

enum ProviderType: String{
    case basic
    case google
    case facebook
}

class HomeViewController: UIViewController {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var closeSessionButton: UIButton!
    
    private let email: String
    private let provider: ProviderType
    
    var db: Firestore!
    
    init(email: String, provider: ProviderType){
        self.email = email
        self.provider = provider
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Inicio"
        navigationItem.setHidesBackButton( true, animated: false )
        
        emailLabel.text = email
        providerLabel.text = provider.rawValue
        // Guardamos los datos del usuario
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "email")
        defaults.set(provider.rawValue, forKey: "provider")
        defaults.synchronize()
    }
    
    @IBAction func closeSessionButtonAction(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "provider")
        defaults.synchronize() 
        
        switch provider {
        
        case .basic:
            firebaseLogOut()
        case .google:
            GIDSignIn.sharedInstance()?.signOut()
            firebaseLogOut()
        case .facebook:
            LoginManager().logOut()
            firebaseLogOut()
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addMovementAction(_ sender: Any) {
        self.navigationController?.pushViewController(MovementViewController(email: self.email, provider: self.provider), animated: true)
    }
    @IBAction func viewMovementsAction(_ sender: Any) {
    }
    
    private func firebaseLogOut(){
        do{
            try Auth.auth().signOut()
        } catch {
            //Se ha producido un error
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
