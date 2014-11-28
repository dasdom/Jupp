//
//  PostCell.swift
//  GlobalADN
//
//  Created by dasdom on 21.06.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    private var imageLoadingQueue = NSOperationQueue()
    
    private let hostView: UIView
    let hostViewCenterXConstraint: NSLayoutConstraint?
    let panGestureRecogniser: UIPanGestureRecognizer
    let usernameLabel: UILabel
    let postTextView: UITextView
    private let avatarImageView: UIImageView
    let actionLabel: UILabel
    let actionImageView: UIImageView
    
    var avatarURL: NSURL? {
    didSet {
        avatarImageView.image = nil
        if avatarURL != nil {
            imageLoadingQueue.cancelAllOperations()
            avatarImageView.image = nil
            weak var weakSelf = self
            var imageLoadinOperation = NSBlockOperation(block: {
                var strongSelf = weakSelf
                let imageData = NSData(contentsOfURL: strongSelf!.avatarURL!)
                let image = UIImage(data: imageData!)
                dispatch_async(dispatch_get_main_queue(), {
                    strongSelf!.avatarImageView.image = image
                    })
                })
            
            imageLoadingQueue.addOperation(imageLoadinOperation)
        }
    }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        hostView = {
           let view = UIView()
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            view.backgroundColor = UIColor.whiteColor()
            return view
        }()
        
        panGestureRecogniser = {
            let gestureRecogniser = UIPanGestureRecognizer()
            
            return gestureRecogniser
        }()
        
        usernameLabel = {
            let label = UILabel()
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
            label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
            return label
            }()
        
        postTextView = {
            let textView = UITextView()
            textView.setTranslatesAutoresizingMaskIntoConstraints(false)
            textView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            textView.textContainerInset = UIEdgeInsetsMake(5, -5, 0, 0)
            //        textView.backgroundColor = UIColor.yellowColor()
//            let exclusioinPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 60, height: 60))
//            textView.textContainer.exclusionPaths = [exclusioinPath]
//            textView.backgroundColor = UIColor.yellowColor()
            textView.userInteractionEnabled = false
            return textView
            }()
        
        avatarImageView = {
            let imageView = UIImageView()
            imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
            imageView.layer.cornerRadius = 10.0
            imageView.clipsToBounds = true
            return imageView
            }()
        
        actionLabel = {
            let label = UILabel()
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
//            label.text = "action"
            return label
        }()
        
        actionImageView = {
            let imageView = UIImageView()
            imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
            return imageView
        }()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        backgroundColor = UIColor.yellowColor()
        contentView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        selectionStyle = .None
        
        contentView.addSubview(actionLabel)
        contentView.addSubview(actionImageView)
        contentView.addSubview(hostView)
        hostView.addSubview(usernameLabel)
        hostView.addSubview(postTextView)
        hostView.addSubview(avatarImageView)
        
        hostView.addGestureRecognizer(panGestureRecogniser)
        
        var views = ["actionImageView" : actionImageView, "actionLabel" : actionLabel, "hostView" : hostView, "usernameLabel" : usernameLabel, "avatarImageView" : avatarImageView, "postTextView" : postTextView]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[actionLabel]-10-|", options: nil, metrics: nil, views: views))
        contentView.addConstraint(NSLayoutConstraint(item: actionLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[actionImageView(30)]-10-|", options: nil, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[actionImageView(30)]", options: nil, metrics: nil, views: views))
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[hostView]|", options: nil, metrics: nil, views: views))
        contentView.addConstraint(NSLayoutConstraint(item: hostView, attribute: .Width, relatedBy: .Equal, toItem: contentView, attribute: .Width, multiplier: 1.0, constant: 0.0))
        hostViewCenterXConstraint = NSLayoutConstraint(item: hostView, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        contentView.addConstraint(hostViewCenterXConstraint!)
        
        hostView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-5-[avatarImageView(50)]-5-[postTextView]-5-|", options: nil, metrics: nil, views: views))
        hostView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[avatarImageView(50)]-(>=5)-|", options: nil, metrics: nil, views: views))
        hostView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[usernameLabel][postTextView]-(>=5)-|", options: .AlignAllLeft, metrics: nil, views: views))
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init(style: .Default, reuseIdentifier: "PostCell")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        avatarImageView.image = nil
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

