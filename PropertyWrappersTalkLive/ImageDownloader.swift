import SwiftUI
import Combine

class ImageDownloader: ObservableObject {
    @Published
    var storedImage: Image
    
    init(url: String, defaultImageTitle: String) {
        self.storedImage = Image(defaultImageTitle)
        fetchImage(from: url)
    }
    
    private func fetchImage(from url: String) {
        if let url = URL(string: url) {
            downloadImage(from: url) { [weak self] image in
                self?.storedImage = Image(uiImage: image)
            }
        }
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UIImage) -> Void) {
        NetworkUtils.getData(from: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async() {
                completion(image)
            }
        }
    }
}
