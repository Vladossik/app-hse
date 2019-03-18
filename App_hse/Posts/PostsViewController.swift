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

class PostsViewController: UITableViewController {

    @IBOutlet weak var titleNavBar: UINavigationItem!
    
    
    var posts: [Item] = []
    var profiles: [Profile] = []
    var groups: [Group] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.register(UINib(nibName: "PostsCell", bundle: Bundle.main), forCellReuseIdentifier: "PostsCell")
        getPosts()
        
    }
    
    private func getPosts() {
        let session = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        
        dataTask = session.dataTask(with: URL(string: "https://api.vk.com/method/wall.get?owner_id=-177771483&fields=first_name,last_name,photo_50&extended=1&v=5.92&access_token=" + VKDelegate.token)!) { data, r, error in
            if error == nil, let data = data {
                print(data)
                let response = try? JSONDecoder().decode(Welcome.self, from: data)
                self.posts = response!.response.items
                self.profiles = response!.response.profiles
                self.groups = response!.response.groups
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        dataTask?.resume()
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
                cell.lastNameUser?.text = profile.lastName
            } else if let group = groups.first(where: { -$0.id == post.ownerID }) {
                let url = URL(string: group.photo50)!
                cell.avatarUser?.kf.setImage(with: url)
                cell.setup(item: post, group: group)
                cell.nameUser?.text = group.name
                cell.lastNameUser?.text = " "
            }
            
            cell.textPost.text = post.text
    
            return cell
        } else {
            return PostsCell()
        }
    }
}
