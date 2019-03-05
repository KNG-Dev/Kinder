//
//  SwipingPhotosController.swift
//  Kinder
//
//  Created by Kenny Ho on 2/24/19.
//  Copyright © 2019 Kenny Ho. All rights reserved.
//

import UIKit

class SwipingPhotosController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var cardViewModel: CardViewModel! {
        didSet {
            print(cardViewModel.attributedString)
            controllers = cardViewModel.imageUrls.map({ (imageUrl) -> UIViewController in
                let photoController = PhotoController(imageUrl: imageUrl)
                return photoController
            })
            
            setViewControllers([controllers.first!], direction: .forward, animated: false, completion: nil)
            
            setupBarViews()
        }
    }
    
    var controllers = [UIViewController]()
    
    fileprivate let isCardViewMode: Bool
    
    init(isCardViewMode: Bool = false) {
        self.isCardViewMode = isCardViewMode
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        view.backgroundColor = .white
        
        if isCardViewMode {
            disableSwipeAbility()
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    fileprivate let barsStackView = UIStackView(arrangedSubviews: [])
    fileprivate let deselectedBarColor = UIColor(white: 0, alpha: 0.1)
    
    fileprivate func setupBarViews() {
        cardViewModel.imageUrls.forEach { (_) in
            let barView = UIView()
            barView.backgroundColor = deselectedBarColor
            barView.layer.cornerRadius = 2
            barsStackView.addArrangedSubview(barView)
        }
        barsStackView.arrangedSubviews.first?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
        
        view.addSubview(barsStackView)
        var paddingTop: CGFloat = 8
        if !isCardViewMode {
            paddingTop += UIApplication.shared.statusBarFrame.height + 8
        }
        
        barsStackView.anchors(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: paddingTop, left: 8, bottom: 0, right: 8), size: .init(width: 9, height: 4))
    }
    
    fileprivate func disableSwipeAbility() {
        view.subviews.forEach { (v) in
            if let v = v as? UIScrollView {
                v.isScrollEnabled = false
            }
        }
    }
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
       print("Cycle through photos")
        let currentController = viewControllers!.first!
        if let index = controllers.firstIndex(of: currentController) {
            
            barsStackView.arrangedSubviews.forEach({$0.backgroundColor = deselectedBarColor})
            
            if gesture.location(in: self.view).x > view.frame.width / 2 {
                let nextIndex = min(index + 1, controllers.count - 1)
                let nextController = controllers[nextIndex]
                setViewControllers([nextController], direction: .forward, animated: false, completion: nil)
                barsStackView.arrangedSubviews[nextIndex].backgroundColor = .white
            } else {
                //Previous
                let previousIndex = max(0, index - 1)
                let previousController = controllers[previousIndex]
                setViewControllers([previousController], direction: .forward, animated: false, completion: nil)
                barsStackView.arrangedSubviews[previousIndex].backgroundColor = .white
                
            }
        }
    }
    //MARK: - PageViewController Delegate
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let currentPhotoController = viewControllers?.first
        if let index = controllers.firstIndex(where: {$0 == currentPhotoController}) {
            //set all bars background to gray
            barsStackView.arrangedSubviews.forEach({$0.backgroundColor = deselectedBarColor})
            //set current image's bar background to white
            barsStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
    
    //MARK: - PageViewController Datasource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = controllers.firstIndex(where: { $0 == viewController }) ?? 0
        if index == controllers.count - 1 { return nil }
        return controllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = controllers.firstIndex(where: { $0 == viewController }) ?? 0
        if index == 0 { return nil }
        return controllers[index - 1]
    }
}

class PhotoController: UIViewController {
    
    let imageView = UIImageView(image: #imageLiteral(resourceName: "jane2"))
    
    //provide an initializer that takes in a URL instead
    
    init(imageUrl: String) {
        if let url = URL(string: imageUrl) {
            imageView.sd_setImage(with: url, completed: nil)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        imageView.fillSuperview()
        imageView.contentMode = .scaleAspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
