//
//  FavoritesViewController.swift
//  App_hse
//
//  Created by Vladislava on 17/03/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import UIKit

class FavoritesViewController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    private var posts: [PostInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.navigationItem.title = "Favorites"
        
         self.refreshControl = UIRefreshControl()
        
         if let refreshControl = self.refreshControl {
            refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
            self.tableView.addSubview(refreshControl)
        }
        
        sideMenu()
        loadData()
    }

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return posts.count
//    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.posts.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = Colors.veryLightPink
        return headerView
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "\(PostsCell.self)",
            for: indexPath) as? PostsCell {
            let post = posts[indexPath.row]
            cell.avatarUser?.kf.setImage(with: post.avatarURL)
            cell.textPost.text = post.text
                .split(separator: "\n")
                .filter {!$0.starts(with: "#") && !$0.isEmpty}
                .joined()

            cell.nameUser?.text = post.name
            cell.lastNameUser?.text = post.surname
            cell.clicked = true
            
            cell.setup(postInfo: post)
            
            cell.backgroundColor = UIColor.white
            cell.layer.borderWidth = 0.1
            cell.layer.cornerRadius = 9
            cell.clipsToBounds = true
            
            return cell
        } else {
            return UITableViewCell(style: .default, reuseIdentifier: "\(PostsCell.self)")
        }
    }
    
    // left side menu
    private func sideMenu() {
        if revealViewController() != nil{
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController()?.rearViewRevealWidth = 275
            
            view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        }
    }
    
      private func loadData(completion: (() -> Void)? = nil) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.storageManager.fetch { [weak self] posts in
            self?.posts = posts
            self?.tableView.reloadData()
        }
        
        DispatchQueue.main.async {
            completion?()
            self.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func refresh() {
        if let refreshControl = refreshControl {
            loadData(completion: refreshControl.endRefreshing)
        }
    }
}
