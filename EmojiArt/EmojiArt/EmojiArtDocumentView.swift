//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by 仝华帅 on 2021/4/3.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat =  1.0
    @State private var chosenPalette: String = ""
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(document: self.document, chosenPalette: self.$chosenPalette)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(self.chosenPalette.map {String($0)}, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: defaultEmojiSize))
                                .onDrag { return NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
                .onAppear {
                    self.chosenPalette = self.document.defaultPalette
                }            }
            
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                    )
                    .gesture(self.doubleTapToZoom(in: geometry.size))
                    
                    
                    if self.isLoading {
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    } else {
                        ForEach(self.document.emojis) { emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * zoomScale)
                                .position(self.position(for: emoji, in: geometry.size))
                        }
                    }
                }
                .clipped()
                .gesture(self.zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onReceive(self.document.$backgroundImage) { image in
                    self.zoomToFit(image, in: geometry.size)
                }
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width / 2, y: location.y - geometry.size.height / 2)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    return self.drop(providers: providers, at: location)
                }
                .navigationBarItems(trailing: Button(action: {
                    if let url = UIPasteboard.general.url {
                        self.document.backgroundURL = url
                    }
                }, label: {
                    Image(systemName: "doc.on.clipboard").imageScale(.large)
                }))
            }
            .zIndex(-1)
        }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(self.document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                self.steadyStateZoomScale *= finalGestureScale
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            
            self.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width / 2, y: location.y + size.height / 2)
        return location
    }
    
    private let defaultEmojiSize: CGFloat = 40
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.backgroundURL = url
        }
        
        if !found {
            found = providers.loadObjects(ofType: String.self) {string in
                self.document.addEmoji(string, at: location, size: defaultEmojiSize)
            }
        }
        return found
    }
    
    var isLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
}


//
//extension String: Identifiable {
//    public var id: String { return self }
//}


//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
