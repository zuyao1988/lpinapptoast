//
//  EmptyVC.swift
//  SampleApp
//
//  Created by tyaolee on 8/12/21.
//  Copyright © 2021 LivePerson. All rights reserved.
//

import UIKit

class EmptyVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.view.backgroundColor = UIColor.red
        
        let button = UIButton()
        button.frame = CGRect(x: self.view.frame.size.width - 60, y: 60, width: 50, height: 50)
        button.backgroundColor = UIColor.red
        button.setTitle("Name your Button ", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(button)
        // Do any additional setup after loading the view.
    }
    

    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
        
        _ = self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
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
