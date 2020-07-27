//
//  MovementViewController.swift
//  ProyectoDAM2
//
//  Created by Luis Javier Bustamante Rodriguez on 7/27/20.
//  Copyright © 2020 Luis Javier Bustamante Rodriguez. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MovementViewController: UIViewController {
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var addMovementButton: UIButton!

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
    }
    
    @IBAction func addMovementButtonAction(_ sender: Any) {
        let amount = Float(quantityTextField.text ?? "0")
        // Agregamos un dato a Firestore
        var ref: DocumentReference? = nil
        ref = db.collection("movements").addDocument(data: [
            "email": email,
            "ammount": amount,
            "timestamp": Timestamp()
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                self.navigationController?.pushViewController(HomeViewController(email: self.email, provider: ProviderType.init(rawValue: self.provider.rawValue)!), animated: false)
            }
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
