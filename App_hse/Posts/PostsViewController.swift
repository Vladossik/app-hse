//
//  PostsViewController.swift
//  App_hse
//
//  Created by Vladislava on 08/03/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import UIKit
import Just
import Kingfisher
import SwiftyVK

class PostsViewController: UITableViewController {
    
    var posts: [Item] = []
    var profiles: [Profile] = []
    var groups: [Group] = []
    
    var hashtag: String?
    
    
    @IBAction func bellGroup(_ sender: Any) {
        
        let alert = UIAlertController(title: "Do you want to subscribe to a group??", message: "so you will see new posts.", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.addGroup()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPosts()
        self.refreshControl = UIRefreshControl()
        
        if let refreshControl = self.refreshControl {
            refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
            self.tableView.addSubview(refreshControl)
        }
    }
    
    private func getPosts(completion: (() -> Void)? = nil) {
        let parameters: [Parameter: String] = [
            .ownerId: "-177771483",
            .fields: "first_name,last_name,photo_50",
            .extended: "1"
        ]
        
        VK.API.Wall.get(parameters).onSuccess { [weak self] data in
            guard let self = self else { return }
            
            let response: Response
            
            do {
                response = try JSONDecoder().decode(Response.self, from: data)
            } catch {
                print(error)
                return
            }
            
            self.posts = response.items.filter {
                if let hashtag = self.hashtag {
                    return $0.text.hasPrefix("#\(hashtag)")
                } else {
                    return true
                }
            }
            
            self.profiles = response.profiles
            self.groups = response.groups
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                completion?()
            }
        }.onError({ error in
            DispatchQueue.main.async {
                completion?()
            }
        }).send()
    }
    
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
        //достать ячейку из кеша
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "PostsCell") as? PostsCell {
            let post = posts[indexPath.section]
            
            if let profile = profiles.first(where: { $0.id == post.signerID }) {
                let url = URL(string: profile.photo50)!
                cell.avatarUser?.kf.setImage(with: url)
                cell.setup(item: post, profile: profile)
                cell.nameUser?.text = profile.firstName
                cell.lastNameUser.isHidden = false
                cell.lastNameUser?.text = profile.lastName
            } else if let group = groups.first(where: { -$0.id == post.ownerID }) {
                let url = URL(string: group.photo50)!
                cell.avatarUser?.kf.setImage(with: url)
                cell.setup(item: post, group: group)
                cell.nameUser?.text = group.name
                cell.lastNameUser.isHidden = true
            }
            
            cell.textPost.text = post.text
                .split(separator: "\n")
                .filter {!$0.starts(with: "#") && !$0.isEmpty}
                .joined()
            
            cell.backgroundColor = UIColor.white
            cell.layer.borderWidth = 0.1
            cell.layer.cornerRadius = 9
            cell.clipsToBounds = true
           
            return cell
        } else {
            return PostsCell()
        }
    }
    
    @objc private func refresh() {
        if let refreshControl = refreshControl {
            getPosts(completion: refreshControl.endRefreshing)
        }
    }
}
