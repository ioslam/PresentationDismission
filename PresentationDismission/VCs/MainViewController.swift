//
//  MainViewController.swift
//  PresentationDismission
//
//  Created by Eslam on 4/18/20.
//  Copyright © 2020 Eslam. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func watchButton(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "videoVC") as? VideoVC
        presentAsSheet(vc!, height: 600)
    }
    

}
