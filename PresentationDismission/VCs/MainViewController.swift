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
    
    @IBAction func DreamWaver(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "secondVC") as? SecondVC
        vc?.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func watchButton(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VideoController") as? VideoController
        self.presentAsSheet(vc!, height: view.frame.size.height)
        
    }
    

}
class SecondVC: UIViewController {
    var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)

    override func viewDidLoad() {
           super.viewDidLoad()

       }
    
    @IBAction func onPanGestureView(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        if(sender.state == UIGestureRecognizer.State.began){
            initialTouchPoint = touchPoint
        } else if(sender.state == UIGestureRecognizer.State.changed) {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.view.frame = CGRect(x: 0, y: touchPoint.y, width: self.view.frame.width, height: self.view.frame.height)
            }
        }else if sender.state == UIGestureRecognizer.State.ended || sender.state==UIGestureRecognizer.State.cancelled{
            
            if touchPoint.y - initialTouchPoint.y > 300 {
                self.dismiss(animated: true, completion: nil)
            }else{
                UIView.animate(withDuration: 0.5, animations: {self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)})
            }
        }
    }
    
}
    
