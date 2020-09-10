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
    private lazy var buttonAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionAdd))

    public let selfTitle = "Combinestagram"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItem()
        setupSubscribers()
    }

    // MARK: - Module functions
    private func setupNavigationItem() {

        navigationItem.rightBarButtonItem = buttonAdd
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupSubscribers() {

        images
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
        buttonAdd.isEnabled = photos.count < 6

        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }

    private func pushPhotosCollectionVC() {
        let photosCollectionVC = PhotosCollectionViewController(nibName: PhotosCollectionViewController.identifier,
                                                                bundle: nil)

        photosCollectionVC.selectedPhotos
            .subscribe(
                onNext: { [weak self] newImage in
                    guard let images = self?.images, images.value.count < 6 else { return }
                    images.accept(images.value + [newImage])
                },
                onDisposed: { print("Completed photo selection") })
            .disposed(by: disposeBag)

        navigationController?.pushViewController(photosCollectionVC, animated: true)
    }

    // MARK: - Actions
    @IBAction func actionClear() {
        images.accept([])
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
