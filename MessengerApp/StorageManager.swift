//
//  StorageManager.swift
//  MessengerApp
//
//  Created by Eldiiar on 29/3/22.
//

import Foundation
import FirebaseStorage

final class StorageManger {
    static let shared = StorageManger()
    
    let storage = Storage.storage().reference()
    
    func uploadProfilePicture(with data: Data,
                              fileName: String,
                              completion: @escaping (Result<String, Error>) -> ()) {
        storage.child("images/\(fileName)").putData(data, metadata: nil) { metadata, error in
            guard error == nil else {
                print("Failed to upload data into the firebase")
                completion(.failure(error!))
                return
            }
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to download url data")
                    completion(.failure(error!))
                    return
                }
                let urlString = url.absoluteString
                completion(.success(urlString))
            }
        }
    }
    
    func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> ()) {
        let reference = storage.child(path)
        reference.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(error!))
                return
            }
            completion(.success(url))
            
        }
    }
}
