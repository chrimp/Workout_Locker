//
//  SegueViewController.swift
//  workout locker
//
//  Created by 김태우 on 2022/01/15.
//

import UIKit

class SegueViewController: UIViewController {
       
    var tentaAPIAddr_sg: String? = nil
    var viewController: UIViewController?
    var userDidUpdateField: Bool! = false
    
    @IBOutlet weak var tentaAPIAddr_field: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tentaAPIAddr_field.text = UserDefaults.standard.string(forKey: "tentaAPIAddr")
    }

    
    @IBAction func updateTentaAddr() {
        tentaAPIAddr_sg = tentaAPIAddr_field.text
        UserDefaults.standard.set(tentaAPIAddr_sg, forKey: "tentaAPIAddr")
        userDidUpdateField = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if userDidUpdateField {
            let vc = ViewController()
            vc.postworkoutduration()
        }
        userDidUpdateField = false
    }
}
