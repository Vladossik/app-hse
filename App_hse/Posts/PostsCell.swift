//
//  PostsCell.swift
//  App_hse
//
//  Created by Vladislava on 08/03/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import UIKit

class PostsCell: UITableViewCell {
    
    var clicked: Bool = false {
        didSet {
            if clicked {
                btnStar.setImage(UIImage(named: "clickStar"), for: .normal)
                saveAsFavorite()
            } else {
                btnStar.setImage(UIImage(named: "star"), for: .normal)
                removeFromFavorites()
            }
        }
    }
    
    @IBOutlet weak var nameUser: UILabel!
    @IBOutlet weak var lastNameUser: UILabel!
    @IBOutlet weak var textPost: UILabel!
    @IBOutlet weak var avatarUser: UIImageView!
    @IBOutlet weak var btnStar: UIButton!
    @IBAction func btnStarClick(_ sender: Any) {
        clicked = !clicked
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set(newFrame) {
            super.frame = newFrame
            super.frame.origin.x += 8
            super.frame.size.width -= 2 * 8
        }
    }
    
    var profile: Profile?
    var group: Group?
    var item: Item?
    var postInfo: PostInfo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarUser.layer.cornerRadius = avatarUser.frame.size.width / 2
        avatarUser.clipsToBounds = true
        textPost.layer.borderColor = Colors.peacockBlue.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setup(item: Item, profile: Profile) {
        self.profile = profile
        self.item = item
    }
    
    func setup(item: Item, group: Group) {
        self.group = group
        self.item = item
    }
    
    func setup(postInfo: PostInfo) {
        self.postInfo = postInfo
    }
    
    private func saveAsFavorite() {
        guard let item = item else { return }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        if let profile = profile {
            appDelegate.storageManager.saveFavoritePost(item, profile: profile) { result in
                print("saved (profile)")
            }
        } else if let group = group {
            appDelegate.storageManager.saveFavoritePost(item, group: group) { result in
                print("saved (group)")
            }
        }
    }
    
    private func removeFromFavorites() {
        guard let postInfo = postInfo else { return }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.storageManager.delete(by: postInfo.id)
    }
}
