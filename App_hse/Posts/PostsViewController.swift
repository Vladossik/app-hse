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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.register(UINib(nibName: "PostsCell", bundle: Bundle.main), forCellReuseIdentifier: "PostsCell")
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
            guard
                let self = self,
                let response = try? JSONDecoder().decode(Response.self, from: data)
            else { return }
            
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //достать ячейку из кеша
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "PostsCell", for: indexPath) as? PostsCell {
            let post = posts[indexPath.row]
            
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
            
//            if let indexOfFirstWhiteSpace = post.text.index(of: " ") {
//                let substring = post.text[indexOfFirstWhiteSpace...]
//                cell.textPost.text = substring.trimmingCharacters(in: .whitespacesAndNewlines)
//            } else {
                cell.textPost.text = post.text
//            }
            
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
