//
//  CombineViewController.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 10.09.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class CombineViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonSave: UIButton!

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let images = BehaviorRelay<[UIImage]>(value: [])
    private lazy var addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionAdd))
    private var imageCache = [Int]()

    public let selfTitle = "Combinestagram"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItem()
        setupSubscribers()
    }

    // MARK: - Module functions
    private func setupNavigationItem() {

        navigationItem.rightBarButtonItem = addButton
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupSubscribers() {

        images
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak imagePreview] photos in
                guard let preview = imagePreview else { return }
                preview.image = photos.collage(size: preview.frame.size) })
            .disposed(by: disposeBag)

        images
            .subscribe(onNext: { [weak self] photos in
                self?.updateUI(photos: photos) })
            .disposed(by: disposeBag)
    }

    private func updateUI(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        addButton.isEnabled = photos.count < 6

        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }

    private func updateNavigationIcon() {

        if imageCache.isEmpty { return }

        let icon = imagePreview.image?
            .scaled(CGSize(width: 22, height: 22))
            .withRenderingMode(.alwaysOriginal)

        let iconButton = UIBarButtonItem(image: icon, style: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItems = [addButton, iconButton]
    }

    private func pushPhotosCollectionVC() {
        let photosCollectionVC = PhotosCollectionViewController(nibName: PhotosCollectionViewController.identifier,
                                                                bundle: nil)

        let newPhotos = photosCollectionVC.selectedPhotos.share(replay: 1)

        newPhotos
            .takeWhile { [weak self] _ in
                let count = self?.images.value.count ?? 0
                return count < 6 }
            .filter { newImage in
                return newImage.size.width > newImage.size.height }
            .filter { [weak self] newImage in
                let len = newImage.pngData()?.count ?? 0
                guard self?.imageCache.contains(len) == false else {
                    return false
                }
                self?.imageCache.append(len)
                return true }
            .subscribe(
                onNext: { [weak self] newImage in
                    guard let images = self?.images else { return }
                    images.accept(images.value + [newImage]) },
                onDisposed: { print("Completed photo selection") })
            .disposed(by: disposeBag)

        navigationController?.pushViewController(photosCollectionVC, animated: true)

        newPhotos
            .ignoreElements()
            .subscribe(onCompleted: { [weak self] in
                self?.updateNavigationIcon() })
            .disposed(by: disposeBag)
    }

    // MARK: - Actions
    @IBAction func actionClear() {
        images.accept([])
        imageCache = []
        navigationItem.rightBarButtonItems?.filter { $0.image != nil }.first?.image = nil
    }

    @IBAction func actionSave() {

        guard let image = imagePreview.image else { return }

        PhotoWriter.save(image)
            .subscribe(
                onSuccess: { [weak self] identifier in
                    self?.showMessage("Saved with id: \(identifier)")
                    self?.actionClear()
                },
                onError: { [weak self] error in
                    self?.showMessage("Error", description: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }

    @objc func actionAdd() {
        pushPhotosCollectionVC()
    }

    func showMessage(_ title: String,
                     description: String? = nil) {

        showAlert(title: title, description: description)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
