import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    
    private let cache = NSCache<NSURL, UIImage>()
    private let session = URLSession.shared
    private var loadingTasks: [NSURL: Task<UIImage?, Never>] = [:]
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func load(_ url: URL, into imageView: UIImageView, placeholder: UIImage? = nil) {

        imageView.image = placeholder ?? createPlaceholderImage()
        
        let nsurl = url as NSURL
        

        if let cachedImage = cache.object(forKey: nsurl) {
            imageView.image = cachedImage
            return
        }
        

        loadingTasks[nsurl]?.cancel()
        
        // Create new loading task
        let task = Task { [weak self] () -> UIImage? in
            guard let self = self else { return nil }
            
            do {
                let (data, response) = try await self.session.data(from: url)
                
 
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode != 200 {
                    print("❌ Failed to load image from \(url): HTTP \(httpResponse.statusCode)")
                    return nil
                }
                
                guard let originalImage = UIImage(data: data) else { 
                    print("❌ Failed to create image from data for URL: \(url)")
                    return nil 
                }
                
                
                let processedImage = self.processImageForMoviePoster(originalImage, isYouTubeThumbnail: url.absoluteString.contains("youtube.com"))
                

                self.cache.setObject(processedImage, forKey: nsurl)
                print("✅ Successfully loaded and cached image from: \(url)")
                
                return processedImage
            } catch {
                print("❌ Image loading error for \(url): \(error.localizedDescription)")
                return nil
            }
        }
        
        loadingTasks[nsurl] = task
        

        Task { @MainActor in
            if let image = await task.value {
                imageView.image = image
            }
            self.loadingTasks.removeValue(forKey: nsurl)
        }
    }
    
    func cancelLoad(for url: URL) {
        let nsurl = url as NSURL
        loadingTasks[nsurl]?.cancel()
        loadingTasks.removeValue(forKey: nsurl)
    }
    

    func loadMoviePoster(for movie: Movie, into imageView: UIImageView) {

        imageView.image = createPlaceholderImage(for: movie)
        
        // Try to get YouTube thumbnail in background
        Task { @MainActor in
            if let thumbnailURL = await getYouTubeThumbnailURL(for: movie.id) {
                // Load YouTube thumbnail
                self.load(thumbnailURL, into: imageView, placeholder: nil)
            }
            // If no YouTube thumbnail, the custom placeholder remains
        }
    }
    
    /// Get YouTube thumbnail URL for a movie ID
    private func getYouTubeThumbnailURL(for movieId: String) async -> URL? {
        // Simple implementation without external service dependency
        // This would ideally cache results, but for now we'll make the API call
        
        let headers = [
            "x-rapidapi-key": "ba3f178ff9mshec8ec491381d8f8p1f20f2jsn9f7815f8691f",
            "x-rapidapi-host": "movies-tv-shows-database.p.rapidapi.com",
            "Type": "get-movie-details"
        ]
        
        guard let url = URL(string: "https://movies-tv-shows-database.p.rapidapi.com/?movieid=\(movieId)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let (data, _) = try await session.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            if let youtubeKey = json?["youtube_trailer_key"] as? String, !youtubeKey.isEmpty {
                // Use high quality thumbnail that works better for movie posters
                return URL(string: "https://img.youtube.com/vi/\(youtubeKey)/hqdefault.jpg")
            }
        } catch {
            #if DEBUG
            print("Failed to get YouTube key for \(movieId): \(error)")
            #endif
        }
        
        return nil
    }
    
    func createPlaceholderImage(for movie: Movie? = nil) -> UIImage? {
        let size = CGSize(width: 300, height: 450)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Generate colors based on movie title if available
        let colors = generateColorsForMovie(movie)
        
        // Create gradient background
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                colors: [colors.0, colors.1] as CFArray,
                                locations: [0.0, 1.0])
        
        if let gradient = gradient {
            context.drawLinearGradient(gradient,
                                     start: CGPoint(x: 0, y: 0),
                                     end: CGPoint(x: 0, y: size.height),
                                     options: [])
        }
        
        // Add movie icon in center instead of text (text will be shown in labels)
        if movie != nil {
            // Add a subtle film icon in the center
            let iconSize: CGFloat = 60
            let iconRect = CGRect(
                x: (size.width - iconSize) / 2,
                y: (size.height - iconSize) / 2 - 20,
                width: iconSize,
                height: iconSize
            )
            
            // Draw simple play icon
            context.setFillColor(UIColor.white.withAlphaComponent(0.6).cgColor)
            let path = UIBezierPath()
            
            // Triangle (play button)
            let triangleSize: CGFloat = 24
            let centerX = iconRect.midX
            let centerY = iconRect.midY
            
            path.move(to: CGPoint(x: centerX - triangleSize/2, y: centerY - triangleSize/2))
            path.addLine(to: CGPoint(x: centerX + triangleSize/2, y: centerY))
            path.addLine(to: CGPoint(x: centerX - triangleSize/2, y: centerY + triangleSize/2))
            path.close()
            
            context.addPath(path.cgPath)
            context.fillPath()
        }
        
        // Add subtle film strip decoration along the edges
        context.setFillColor(UIColor.white.withAlphaComponent(0.08).cgColor)
        let stripWidth: CGFloat = 6
        let holeSize: CGFloat = 4
        let holeSpacing: CGFloat = size.height / 10
        
        // Left strip
        context.fill(CGRect(x: 0, y: 0, width: stripWidth, height: size.height))
        // Right strip  
        context.fill(CGRect(x: size.width - stripWidth, y: 0, width: stripWidth, height: size.height))
        
        // Add holes in the strips
        context.setFillColor(UIColor.black.withAlphaComponent(0.3).cgColor)
        for i in 0..<10 {
            let y = CGFloat(i) * holeSpacing + holeSpacing/2 - holeSize/2
            // Left holes
            context.fill(CGRect(x: (stripWidth - holeSize)/2, y: y, width: holeSize, height: holeSize))
            // Right holes
            context.fill(CGRect(x: size.width - stripWidth + (stripWidth - holeSize)/2, y: y, width: holeSize, height: holeSize))
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private func generateColorsForMovie(_ movie: Movie?) -> (CGColor, CGColor) {
        guard let movie = movie else {
            // Default colors if no movie info
            return (UIColor.cardBackground.cgColor, UIColor.primaryPurple.withAlphaComponent(0.7).cgColor)
        }
        
        // Generate consistent colors based on movie title hash
        let hash = movie.title.hashValue
        let hue1 = CGFloat(abs(hash) % 360) / 360.0
        let hue2 = CGFloat(abs(hash.multipliedReportingOverflow(by: 2).partialValue) % 360) / 360.0
        
        let color1 = UIColor(hue: hue1, saturation: 0.6, brightness: 0.7, alpha: 1.0)
        let color2 = UIColor(hue: hue2, saturation: 0.8, brightness: 0.5, alpha: 1.0)
        
        return (color1.cgColor, color2.cgColor)
    }
    
    /// Process image to better fit movie poster format
    private func processImageForMoviePoster(_ originalImage: UIImage, isYouTubeThumbnail: Bool) -> UIImage {
        let targetSize = CGSize(width: 300, height: 450) // 2:3 aspect ratio for movie posters
        
        if isYouTubeThumbnail {
            // YouTube thumbnails are 16:9, we need to crop them to 2:3
            return cropYouTubeThumbnailToPosterFormat(originalImage, targetSize: targetSize)
        } else {
            // For other images, just resize while maintaining aspect ratio
            return resizeImage(originalImage, targetSize: targetSize)
        }
    }
    
    /// Crop YouTube thumbnail (16:9) to movie poster format (2:3)
    private func cropYouTubeThumbnailToPosterFormat(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let originalSize = image.size
        let originalAspectRatio = originalSize.width / originalSize.height
        let targetAspectRatio = targetSize.width / targetSize.height
        
        // Calculate crop dimensions
        var cropRect: CGRect
        
        if originalAspectRatio > targetAspectRatio {
            // Original is wider, crop from sides
            let newWidth = originalSize.height * targetAspectRatio
            let xOffset = (originalSize.width - newWidth) / 2
            cropRect = CGRect(x: xOffset, y: 0, width: newWidth, height: originalSize.height)
        } else {
            // Original is taller, crop from top/bottom
            let newHeight = originalSize.width / targetAspectRatio
            let yOffset = (originalSize.height - newHeight) / 2
            cropRect = CGRect(x: 0, y: yOffset, width: originalSize.width, height: newHeight)
        }
        
        // Perform the crop
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return resizeImage(image, targetSize: targetSize)
        }
        
        let croppedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        return resizeImage(croppedImage, targetSize: targetSize)
    }
    
    /// Resize image to target size while maintaining quality
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
