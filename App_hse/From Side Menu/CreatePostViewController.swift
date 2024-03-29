//
//  CreatePostViewController.swift
//  App_hse
//
//  Created by Vladislava on 07/04/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import UIKit
import Just
import SwiftyVK

class CreatePostViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, SWRevealViewControllerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var buttonPost: UIButton!
    
    @IBAction func buttonPost(_ sender: Any) {
        
        let firstfield = category.text
        let secondfield = messageText.text
        
        if firstfield!.isEmpty || secondfield!.isEmpty || (secondfield! == "..." || secondfield! == ".." || secondfield! == "."){
            let myAlert = UIAlertController(title: "Alert", message: "All fields must be filled", preferredStyle: UIAlertController.Style.alert)
            let okey = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
            
            myAlert.addAction(okey)
            self.present(myAlert, animated: true, completion: nil)
            
            return
        }
        else {
        
        let parameters: [Parameter: String] = [
            .ownerId: "-177771483",
            .message : "#" + category.text! + "\n" + messageText.text!,
            .signed : "1",
        ]
        
        VK.API.Wall.post(parameters)
            .configure(with: Config(httpMethod: .POST))
            .onSuccess {response in
                DispatchQueue.main.async {
                    let showAlert = UIAlertController(title: "Done!", message: "Your post on the wall", preferredStyle: UIAlertController.Style.alert)
                    let imageView = UIImageView(frame: CGRect(x: 110, y: 80, width: 50, height: 50))
                    imageView.image = #imageLiteral(resourceName: "success")
                    showAlert.view.addSubview(imageView)
                    let height = NSLayoutConstraint(item: showAlert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 180)
                    let width = NSLayoutConstraint(item: showAlert.view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 260)
                    showAlert.view.addConstraint(height)
                    showAlert.view.addConstraint(width)
                    showAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(showAlert, animated: true, completion: nil)}
                }
            .onError ({ error in print(error)})
            .send()
        
        }
    }
    
    var hashtags = ["Lost", "FreeOfCharge","PromoCodes","Taxi","BoardGames"]
    var picker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Create Post"
        
        messageText.layer.borderColor = UIColor.lightGray.cgColor
        messageText.layer.cornerRadius = 5.0
        messageText.layer.borderWidth = 0.5
        
        buttonPost.layer.borderColor = UIColor.lightGray.cgColor
        buttonPost.layer.cornerRadius = 5.0
        buttonPost.layer.borderWidth = 0.5
        
        picker.delegate = self
        picker.dataSource = self
        
        category.inputView = picker
        
        self.hideKeyboardWhenTappedAround()
        
        sideMenu()
    }
    
    // left side menu
    func sideMenu() {
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController()?.rearViewRevealWidth = 275
            
            view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hashtags.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return hashtags[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        category.text = hashtags[row]
        self.view.endEditing(true)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
