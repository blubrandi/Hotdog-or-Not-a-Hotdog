//
//  ViewController.swift
//  SeeFood
//
//  Created by Brandi Taylor on 9/18/20.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    
    // Create an image and send it to the model
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else { fatalError("Could not convert image to CIImage.") }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else { fatalError("Loading CoreML model failed.") }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            // process the results of the request
            
            guard let results = request.results as? [VNClassificationObservation] else { fatalError("Model failed to process image.") }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hot Dog!!"
                } else {
                    self.navigationItem.title = "Not a hot dog! :("
                }
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }

    }
    

    @IBAction func cameraButtonTapped(_ sender: Any) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    

    
}

