//
//  ContentView.swift
//  plant-explorer
//
//  Created by Mohamed Elkady on 23/08/2020.
//

import SwiftUI
import MLKit

struct ContentView: View {
    @State var isShowPicker: Bool = false
    @State var image: Image? = Image(systemName: "photo")
    @State var inputImage: UIImage?
    @State var label: String = "Pick an image..."

    var body: some View {
        NavigationView {
            Form {
                image?
                    .resizable()
                    .scaledToFit()
                    .frame(height: 320)
                Text(self.label)
            }
            .navigationBarTitle(Text("Plant Explorer"), displayMode: .inline)
            .navigationBarItems(trailing: Button("Pick") {
                withAnimation {
                    self.isShowPicker.toggle()
                }
            })
            .sheet(isPresented: $isShowPicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        self.image = Image(uiImage: inputImage)
        self.label = "Processing..."
        predictNames(forImage: inputImage)
    }
    
    func predictNames(forImage: UIImage) {
        let modelPath = Bundle.main.path(forResource: "lite-model_aiy_vision_classifier_plants_V1_3", ofType: "tflite")
        let visionImage = VisionImage(image: forImage)
        let localModel = LocalModel(path: modelPath!)
        let options = CustomImageLabelerOptions(localModel: localModel)
        options.maxResultCount = 3
        let imageLabeler = ImageLabeler.imageLabeler(options: options)
        imageLabeler.process(visionImage) { labels, error in
            guard error == nil else {
                self.label = "An error happened: \(error.debugDescription)"
                return
            }
            guard let labels = labels, !labels.isEmpty else {
                self.label = "No labels found"
                return
            }
            self.label = labels.map { (imageLabel: ImageLabel) -> String in
                return "\(imageLabel.text) (\(Int(imageLabel.confidence * 100))%)"
            }.joined(separator: "\n")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
