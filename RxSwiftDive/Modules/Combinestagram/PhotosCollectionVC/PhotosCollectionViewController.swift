//
//  PhotosCollectionViewController.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 10.09.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import UIKit
import Photos
import RxSwift

class PhotosCollectionViewController: UICollectionViewController {

    // MARK: public properties
    var selectedPhotos: Observable<UIImage> { return selectedPhotosSubject.asObservable() }

    // MARK: private properties
    private lazy var photos = PhotosCollectionViewController.loadPhotos()
    private lazy var imageManager = PHCachingImageManager()
    private let selectedPhotosSubject = PublishSubject<UIImage>()
    private let disposeBag = DisposeBag()

    private lazy var thumbnailSize: CGSize = {
        guard let cellSize = (self.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize else {
            return CGSize.zero
        }
        return CGSize(width: cellSize.width * UIScreen.main.scale,
                      height: cellSize.height * UIScreen.main.scale)
    }()

    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(with: allPhotosOptions)
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()

        let authorized = PHPhotoLibrary.authorized.share()
        authorized
            .skipWhile { !$0 }
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.photos = PhotosCollectionViewController.loadPhotos()
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData() }
            })
            .disposed(by: disposeBag)

        authorized
            .skip(1)
            .takeLast(1)
            .filter { !$0 }
            .subscribe(onNext: { [weak self] _ in
                guard let errorMessage = self?.errorMessage else { return }
                DispatchQueue.main.async(execute: errorMessage) })
            .disposed(by: disposeBag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        selectedPhotosSubject.onCompleted()
    }

    // MARK: - Module function
    private func setupCollectionView() {

        collectionView.backgroundColor = .systemBackground
        collectionView.register(UINib(nibName: PhotoCollectionViewCell.identifier, bundle: nil),
                                forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
    }

    private func errorMessage() {
        showAlert(title: "No access to Camera Roll",
                  description: "You can grant access to Combinestagram from the Settings app")
            .asObservable()
            .take(.seconds(5), scheduler: MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
                _ = self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    // MARK: UICollectionView
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let asset = photos.object(at: indexPath.item)
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier,
                                 for: indexPath) as? PhotoCollectionViewCell

        cell?.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset,
                                  targetSize: thumbnailSize,
                                  contentMode: .aspectFill,
                                  options: nil,
                                  resultHandler: { image, _ in
            if cell?.representedAssetIdentifier == asset.localIdentifier {
                cell?.imageView.image = image
            }
        })

        return cell ?? UICollectionViewCell()
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {

        let asset = photos.object(at: indexPath.item)

        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
            cell.flash()
        }

        imageManager.requestImage(for: asset,
                                  targetSize: view.frame.size,
                                  contentMode: .aspectFill,
                                  options: nil,
                                  resultHandler: { [weak self] image, info in

            guard let image = image, let info = info else { return }

            if let isThumbnail = info[PHImageResultIsDegradedKey as NSString] as? Bool, !isThumbnail {
                self?.selectedPhotosSubject.onNext(image) }
        })
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotosCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: (view.frame.width / 3) - 7,
                      height: (view.frame.width / 3) - 7)
    }
}
