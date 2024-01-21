//
//  AsyncImage.swift
//  Ratatouille

import SwiftUI

struct AsyncImageView: View {
    /// Variables
    let url: URL?
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                placeholderImage
            case .success(let image):
                loadedImage(image)
            case .failure:
                placeholderImage
            @unknown default:
                EmptyView()
            }
        }
    }
    
    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
    }
    
    private func loadedImage(_ image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

struct AsyncImageView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncImageView(url: URL(string: "https://eksempel.com/image.jpg"))
            .frame(width: 100, height: 100)
            .padding()
    }
}
