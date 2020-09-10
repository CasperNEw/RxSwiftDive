import Foundation
import UIKit
import Photos
import RxSwift

class PhotoWriter {

    enum Errors: Error {
        case couldNotSavePhoto
    }

    static func save(_ image: UIImage) -> Single<String> {

        return Single.create { single -> Disposable in

            var savedAssetId: String?
            PHPhotoLibrary
                .shared()
                .performChanges({
                    let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    savedAssetId = request.placeholderForCreatedAsset?.localIdentifier
                }, completionHandler: { success, error in
                    DispatchQueue.main.async {
                        if success, let identifier = savedAssetId {
                            single(.success(identifier))
                        } else {
                            single(.error(error ?? Errors.couldNotSavePhoto))
                        }
                    }
                })
            return Disposables.create()
        }
    }
}
