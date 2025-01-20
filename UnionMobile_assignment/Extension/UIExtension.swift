//
//  UIExtension.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/19/25.
//

import SwiftUI
import UIKit

// MARK: - 커스텀 폰트
extension Font {
    enum Family: String {
        case bold,boldItalic,extraLight,italic,light,lightItalic,medium,mediumItalic,regular,semiBold,semiBoldItalic,thin,thinItalic
    }
    
    static func kantumruyPro(size: CGFloat, family: Family) -> Font {
        return Font.custom("KantumruyPro-\(family)", size: size)
    }
}

// MARK: - 이미지 다운샘플링
extension UIImage {
    func downsampled(to pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let data = self.pngData(),
              let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return self
        }
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return self
        }
        
        return UIImage(cgImage: downsampledImage)
    }
}

// MARK: - 이미지 캐싱
actor ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {

        // 디바이스 메모리에 따라 동적으로 설정
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let maxMemory = totalMemory / 4
        
        cache.countLimit = 200
        cache.totalCostLimit = min(
            1024 * 1024 * 50,
            Int(maxMemory)
        )
    }
    
    func image(for url: URL, targetSize: CGSize) -> UIImage? {
        let key = cacheKey(for: url, size: targetSize)
        return cache.object(forKey: key as NSString)
    }
    
    func insertImage(_ image: UIImage, for url: URL, targetSize: CGSize) {
        let key = cacheKey(for: url, size: targetSize)
        let downsampledImage = image.downsampled(to: targetSize)
        cache.setObject(downsampledImage, forKey: key as NSString)
    }
    
    private func cacheKey(for url: URL, size: CGSize) -> String {
        "\(url.absoluteString)_\(Int(size.width))x\(Int(size.height))"
    }
}

@MainActor
extension Image {
    func toUIImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        return renderer.uiImage
    }
}

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL
    private let targetSize: CGSize
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    init(
        url: URL,
        targetSize: CGSize,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.targetSize = targetSize
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                placeholder()
            case .success(let image):
                content(image)
                    .task {
                        if let uiImage = image.toUIImage() {
                            await ImageCache.shared.insertImage(
                                uiImage,
                                for: url,
                                targetSize: targetSize
                            )
                        }
                    }
            case .failure:
                placeholder()
            @unknown default:
                placeholder()
            }
        }
    }
}
