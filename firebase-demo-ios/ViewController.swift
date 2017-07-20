//
//  ViewController.swift
//  firebase-demo-ios
//
//  Created by Patrick Conrey on 7/18/17.
//  Copyright © 2017 Conrey Designs. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MaterialComponents

class ViewController: UIViewController {
    
    //MARK: - Properties
    
    var colorRef: DatabaseReference?
    var countRef: DatabaseReference?
    var clicksRef: DatabaseReference?

    //MARK: - Outlets

    @IBOutlet weak var button: MDCRaisedButton!
    
    //MARK: - Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // boilerplate button
        button.setElevation(4, for: .normal)
        button.setTitle("INCREMENT", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Lifecycle Function. Attach observers here.
    */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // reference to color node on database
        colorRef = Database.database().reference().child("hex_color")
        
        // reference to count node
        countRef = Database.database().reference().child("count")
        
        // reference to auto generated child node of clicks
        clicksRef = Database.database().reference().child("clicks").childByAutoId()
        
        observeColorNode()
    }
    
    /**
     Lifecycle Function. Detach all observers here. Though unnecessary
     here, detaching observers is considered good practice when their call-
     backs are no longer consequential
    */
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        colorRef?.removeAllObservers()
        countRef?.removeAllObservers()
        clicksRef?.removeAllObservers()
    }
    
    //MARK: - Actions
    
    /**
     User tapped button. Will increment count on database.
    */
    @IBAction func didTapButton(_ sender: MDCButton) {
        
        // attach listener to count node
        // will be called once to get the current count at the node
        countRef?.observeSingleEvent(of: .value, with: { (countSnap) in
            
            // cast the count as an integer
            if var count = countSnap.value as? Int {
                
                // increment count
                // and post to database
                count += 1
                self.countRef?.setValue(count)
                
                // log the time that the click happened
                self.clicksRef?.setValue(String(describing: NSDate()))
            }
        })
    }
    
    //MARK: - Helper Functions
    
    /**
     Will attach listener to color node. Upon change, will update the background color of the button
    */
    func observeColorNode() {
        
        // attach listener to node
        // handler will be called when value at node changes
        colorRef?.observe(.value, with: { (snapshot) in
            
            // cast snapshot as string
            if let color = snapshot.value as? String {
                
                // send hex string to helper function
                self.button.backgroundColor = self.hexStringToUIColor(hex: color)
            }
        })
    }
    
    // AUTHOR: Ethan Strider
    // FROM: https://stackoverflow.com/questions/24263007/how-to-use-hex-colour-values-in-swift-ios
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }


}

