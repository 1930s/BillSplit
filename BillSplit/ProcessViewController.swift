//
//  ProcessViewController.swift
//  BillSplit
//
//  Created by Vinh Vu on 6/5/17.
//  Copyright © 2017 Vinh Vu. All rights reserved.
//

import UIKit
import TesseractOCR

class ProcessViewController: UIViewController {

    @IBOutlet weak var processImageView: UIImageView!
    @IBOutlet weak var processedTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var nextButton: UIButton!
    
    var passedImage: UIImage?
    // Declare allLines array to store each line
    var allLines: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        processImageView.image = passedImage
        performImageRecognition(image: processImageView.image!)
    }
    
    override func viewDidLayoutSubviews() {
        
        nextButton.layer.cornerRadius = 5
        nextButton.layer.borderWidth = 1
        nextButton.layer.borderColor = UIColor(red: 0.0, green: 139.0/255.0, blue: 139.0/255.0, alpha: 1.0).cgColor
        nextButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func performImageRecognition(image: UIImage) {
        
        if let tesseract = G8Tesseract(language: "eng") {
            
            tesseract.pageSegmentationMode = .auto
            //tesseract.charWhitelist = "abcdefghijklmnopqrstuvwxyz0123456789()-%/:."
            tesseract.maximumRecognitionTime = 60.0
            tesseract.image = image.g8_blackAndWhite()
            tesseract.recognize()
            //processedTextView.text = tesseract.recognizedText
            processedTextView.text = processText(recognizedText: tesseract.recognizedText)
            
            processedTextView.sizeToFit()
            processedTextView.layoutIfNeeded()
            
            // Remake content height constraint because the intrinsic content size of
            // UITextView varies
            let textOrigin_y = processedTextView.frame.origin.y
            let textHeight = processedTextView.frame.size.height
            let nextButtonHeight = nextButton.frame.size.height
            
            let newContentHeight = textOrigin_y + textHeight + nextButtonHeight + 35
            containerViewHeight.constant = newContentHeight
        }
    }
    
    // Split the processed text into lines and store
    // them into an array
    // Afterward, remove all the ones that requires
    private func processText(recognizedText: String) -> String {
        
        // Remove all element first before filling it up
        allLines.removeAll()
        
        // Place processed text into new String
        //var text:String! = processedTextView.text
        var text:String! = recognizedText
        
        // Declare range to find \n
        var range:Range<String.Index>?
        
        // range attempts to find \n
        range = text.range(of: "\n")
        
        // Run loop while range is still able to find \n
        while range != nil {
            
            // Get index from beginning of text to \n
            let index = text.startIndex ..< (range?.lowerBound)!
            
            // Create the line of string with index
            let line = text[index]
            
            // Append the line
            allLines.append(line)
            
            // Get index for after the the \n to the end
            let index2 = text.index(after: (range?.lowerBound)!) ..< text.endIndex
            
            // Update the text with the index
            text = text[index2]
            
            // Attempts to find \n
            range = text.range(of: "\n")
        }
        
        // Remove all whitespace form allLines array
        allLines = allLines.filter{ !$0.trimmingCharacters(in: .whitespaces).isEmpty}
        
        var s = ""
        
        for line in allLines {
            s.append(line)
            s.append("\n")
        }
        
        return s
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {

        performSegue(withIdentifier: "priceSegue", sender: nil)
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var items: [Item] = []
        
        for line in allLines {
            let item = Item(name: line, price: 0)
            items.append(item)
        }
        
        if segue.identifier == "priceSegue" {
            
            if let priceVC = segue.destination as? PriceTableViewController {
                
                priceVC.items = items
            }
        }
    }
}
