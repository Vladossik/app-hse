//
//  MenuViewController.swift
//  App_hse
//
//  Created by Vladislava on 14/02/2009.
//  Copyright © 2009 VladislavaVakulenko. All rights reserved.
//

import UIKit
import SwiftyVK

class CategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var categoryCallection: UICollectionView!
    
    let categories: [Category] = [Category(name: "Dormitory fee", hashtag: nil),
                                  Category(name: "Get to university", hashtag: nil),
                                  Category(name: "Lost things", hashtag: "Lost"),
                                  Category(name: "Selling", hashtag: "Selling"),
                                  Category(name: "Free of charge", hashtag: "FreeOfCharge"),
                                  Category(name: "Promo codes", hashtag: "PromoCodes"),
                                  Category(name: "Taxi", hashtag: "Taxi"),
                                  Category(name: "Board games", hashtag: "BoardGames"),
                                  Category(name: "Cleaning", hashtag: nil),
                                  Category(name: "Complaints", hashtag: nil)]
    
    let categoryImages: [UIImage] = [

        UIImage(named:"credit-cards-payment")!,
        UIImage(named:"school-bus")!,
        UIImage(named:"search")!,
        UIImage(named:"low-price")!,
        UIImage(named:"free")!,
        UIImage(named:"discount")!,
        UIImage(named:"taxi")!,
        UIImage(named:"board-gaming")!,
        UIImage(named:"floor-mop")!,
        UIImage(named:"complaint")!,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alert = UIAlertController(title: "Are you subscribed to a group?", message: "if not then we will sign you.", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            self.addGroup()
        }))
        self.present(alert, animated: true, completion: nil)
        
        self.navigationItem.title = "Services"

        categoryCallection.dataSource = self
        categoryCallection.delegate = self
        
        let layout = categoryCallection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 44)/2, height: self.categoryCallection.frame.size.height/3)
        
        sideMenu()
    }
    
    func addGroup(completion: (() -> Void)? = nil) {
        let parameters: [Parameter: String] = [
            .groupId : "177771483"
        ]
        
        VK.API.Groups.join(parameters)
            .onSuccess({data in print(data)})
            .onError ({ error in print(error)})
            .send()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CategoryCollectionViewCell
        
        cell.categoryName.text = categories[indexPath.item].name
        cell.categoryImage.image = categoryImages[indexPath.item]
        
        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = categoryCallection.cellForItem(at: indexPath)
        cell?.layer.cornerRadius = 10
        cell?.layer.borderColor = Colors.peacockBlue.cgColor
        cell?.layer.borderWidth = 3
        
        guard indexPath.row >= 0 else { return }
        let category = categories[indexPath.row]
        
        let bundle = Bundle.main
        let mainStoryboard = UIStoryboard(name: "Main", bundle: bundle)
        
        //дописать!!
        switch category.name {
//        case "Dormitory fee"
        case "Lost things", "Selling", "Free of charge", "Promo codes", "Taxi", "Board games":
            let identifier = "\(PostsViewController.self)"
            let postsViewController = mainStoryboard.instantiateViewController(withIdentifier: identifier) as! PostsViewController
            postsViewController.title = category.name
            postsViewController.hashtag = category.hashtag
            print(postsViewController.posts)
            
            navigationController?.pushViewController(postsViewController, animated: true)
        case "Get to university":
            let identifier = "\(GetFirstTableViewController.self)"
            let postsViewController = mainStoryboard.instantiateViewController(withIdentifier: identifier) as! GetFirstTableViewController
            postsViewController.title = category.name

            navigationController?.pushViewController(postsViewController, animated: true)
        case "Cleaning":
            let identifier = "\(CleaningViewController.self)"
            let cleaningViewController = mainStoryboard.instantiateViewController(withIdentifier: identifier)
            cleaningViewController.title = category.name
            
            navigationController?.pushViewController(cleaningViewController, animated: true)
        case "Complaints":
            let identifier = "\(SendEmailViewController.self)"
            let cleaningViewController = mainStoryboard.instantiateViewController(withIdentifier: identifier)
            cleaningViewController.title = category.name
            
            navigationController?.pushViewController(cleaningViewController, animated: true)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = categoryCallection.cellForItem(at: indexPath)
        cell?.layer.cornerRadius = 10
        cell?.layer.borderColor = Colors.categoryItem.cgColor
        cell?.layer.borderWidth = 0
    }
    
    // left side menu
    func sideMenu() {
        
        if revealViewController() != nil{
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController()?.rearViewRevealWidth = 275
            
            view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        }
    }
    
//    func createAlert(title: String, message: String) {
//
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
//
//        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: <#T##((UIAlertAction) -> Void)?##((UIAlertAction) -> Void)?##(UIAlertAction) -> Void#>))
//    }
    
}
