//
//  ViewController.swift
//  ImageLoaderApp
//
//  Created by Mradul Kumar on 19/04/2024.
//

import UIKit
import SafariServices

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let reuseIdentifier = "ImageCell"
    private let offset: CGFloat = 12.0
    private var itemsPerRow: CGFloat = 3
    private var imageData: [ImageData] = []
    private var prevOffsetY: Double = 0.0
    
    var output: ViewModelInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setUpUI()
        
        let viewModel = ViewModel()
        self.output = viewModel
        viewModel.output = self
        self.output?.loadData()
    }
}

extension ViewController {
    
    func setUpUI() {
        //title
        self.title = "Media Coverage"
        
        //setting up collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        let nibName = UINib(nibName: "ImageCell", bundle:nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: reuseIdentifier)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = offset * (itemsPerRow + 1)
        let collectionViewW = self.collectionView.frame.width
        let availableWidth = collectionViewW - paddingSpace
        let widthPerItem = floor(availableWidth / itemsPerRow)
        
        return CGSize.init(width: Double(widthPerItem), height: Double(widthPerItem))
    }
    
    // 2
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: offset, left: offset, bottom: offset, right: offset)
    }
    
    // 3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return offset
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return offset
    }
}

extension ViewController: UICollectionViewDataSource {
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.imageData.count
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //1
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! ImageCell
        
        cell.imgData = self.imageData[indexPath.row]
        cell.tag = indexPath.row
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didTapCellAt(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cellTemp = cell as? ImageCell
        cellTemp!.loadImage()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cellTemp = cell as? ImageCell
        cellTemp!.stopLoadingImage()
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentYoffset = scrollView.contentOffset.y
        if prevOffsetY > contentYoffset { return }
        prevOffsetY = contentYoffset
        let height = scrollView.frame.size.height
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom <= height + 100 {
            output?.fetchMoreData()
        }
    }
}

extension ViewController: ViewModelOutput {
    
    func reloadData(_ imageData: [ImageData]) {
        self.imageData = imageData
        self.collectionView.reloadData()
    }
    
    func updateData(_ newImageData: [ImageData]) {
        self.imageData = newImageData
        self.collectionView.reloadData()
    }
    
    func error(_ error: ApiError) {
        let alert = UIAlertController(title: "Images Loader", message: error.displayMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
            self.navigationController?.dismiss(animated: true)
        }))
        self.navigationController?.present(alert, animated: true)
    }
    
    func showSafariControllerFor(urlToOpen: String) {
        guard let url = URL(string: urlToOpen) else { return }
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = true
        let viewController = SFSafariViewController(url: url, configuration: config)
        let navController = UINavigationController(rootViewController: viewController)
        navController.setNavigationBarHidden(true, animated: false)
        navController.modalTransitionStyle = .coverVertical
        navController.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
}

extension ViewController {
    
    @objc func didTapCellAt(index: Int) {
        self.output?.showDetailsForArticle(at: index)
    }
}
