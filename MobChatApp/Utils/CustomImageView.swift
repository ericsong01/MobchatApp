import UIKit

var imageCache = [String:UIImage]()

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        
        lastURLUsedToLoadImage = urlString

        self.image = nil // Fixes image flickering whenever an image updates

        self.image = UIImage(named: "purple_gradient")

        // Check cache - if image exists, set the post image using the cache and don't fetch anything
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }

        guard let url = URL(string: urlString) else {return}

        URLSession.shared.dataTask(with: url) { (data, response, error) in

            if let error = error {
                print ("Failed to fetch post image:", error)
            }

            // Ensure the photos are not repeating in the cells
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }

            guard let imageData = data else {return}

            let photoImage = UIImage(data: imageData)

            imageCache[url.absoluteString] = photoImage

            DispatchQueue.main.async {
                self.image = photoImage
            }
            }.resume()//ALWAYS USE THIS AT THE END OF DATATASK

        URLSession.shared.finishTasksAndInvalidate()

    }
    
    func loadHighlightImage(urlString: String, imageView: UIImageView) {
        
        lastURLUsedToLoadImage = urlString
        
        self.image = nil // Fixes image flickering whenever an image updates
        
        self.image = UIImage(named: "purple_gradient")
        
        // Check cache - if image exists, set the post image using the cache and don't fetch anything
        if let cachedImage = imageCache[urlString] {
            if cachedImage.size.height > cachedImage.size.width {
                imageView.contentMode = .scaleAspectFit
                imageView.backgroundColor = .black
            } else {
                imageView.contentMode = .scaleAspectFill
                imageView.backgroundColor = .clear
            }
            
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print ("Failed to fetch post image:", error)
            }
            
            // Ensure the photos are not repeating in the cells
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            
            guard let imageData = data else {return}
            
            let photoImage = UIImage(data: imageData)

            imageCache[url.absoluteString] = photoImage
            
            DispatchQueue.main.async {
                
                if let height = photoImage?.size.height, let width = photoImage?.size.width {
                    if height > width {
                        imageView.contentMode = .scaleAspectFit
                        imageView.backgroundColor = .black
                    } else {
                        imageView.contentMode = .scaleAspectFill
                        imageView.backgroundColor = .clear
                    }
                }
                
                self.image = photoImage
            }
            }.resume()//ALWAYS USE THIS AT THE END OF DATATASK
        
        URLSession.shared.finishTasksAndInvalidate()
        
    }
    
}

class TaskManager {
    static let shared = TaskManager()
    
    let session = URLSession(configuration: .default)
    
    typealias completionHandler = (Data?, URLResponse?, Error?) -> Void
    
    var tasks = [URL: [completionHandler]]()
    
    func dataTask(with url: URL, completion: @escaping completionHandler) {
        if tasks.keys.contains(url) {
            print ("contains keys:", url)
            tasks[url]?.append(completion)
        } else {
            tasks[url] = [completion]
            let _ = session.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
                DispatchQueue.main.async {
                    
                    print("Finished network task")
                    
                    guard let completionHandlers = self?.tasks[url] else { return }
                    for handler in completionHandlers {
                        
                        print("Executing completion block")
                        
                        handler(data, response, error)
                    }
                }
            }).resume()
        }
    }
}
