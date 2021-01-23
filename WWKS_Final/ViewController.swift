//
//  ViewController.swift
//  WWKS_Final
//
//  Created by Stephanie Chiu on 1/3/2021.
//  Copyright © 2021 Stephanie Chiu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - Model
    
    struct Contents: Codable {
        var quote: String
    }
    
    //MARK: - Properties
    
    var quote: Contents?
    let backgroundColor = BackgroundColorProvider()
    let launchImage = UIImageView(image: #imageLiteral(resourceName: "KanyeFace"))
    let launchView = UIView()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var randomizeBtn: UIButton!
    
    //MARK: - Initializer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newQuote()
        launchScreen()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 1 second delay before Kanye face logo is scaled down when Launch Screen launches
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.scaleDownAnimation()
        }
    }
    
    //MARK: - Functions
    
    @IBAction func randomizeBtnAction(_ sender: UIButton) {
        newQuote()
        
        // Randomizes background color
        let randomColor = backgroundColor.randomColor()
        view.backgroundColor = randomColor
        checkColorLuminance(color: randomColor)
        
        //Fade in animation on the quote text when button is tapped
        quoteLabel.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.quoteLabel.alpha = 1.0
        }
        
        sender.shake(duration: 0.5, values: [-12.0, 12.0, -12.0, 12.0, -6.0, 6.0, -3.0, 3.0, 0.0])
    }
    
    // Generates new Kanye quote
    func newQuote() {
        guard let url = URL(string: "https://api.kanye.rest") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: url) {
            (data, response, err) in
            guard let data = data else { return }
            do {
                self.quote = try JSONDecoder().decode(Contents.self, from: data)
                DispatchQueue.main.async {
                    if let kanyeQuote = self.quote {
                        self.quoteLabel.text = kanyeQuote.quote
                        print(kanyeQuote.quote)
                    }
                }
            }
            catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
        }.resume()
    }
    
    // Checks the luminance (ie how dark or light a color the eye perceives it as) and updates the labels to black or white accordingly to improve readability
    func checkColorLuminance(color: UIColor) {
        var r = CGFloat(0)
        var g = CGFloat(0)
        var b = CGFloat(0)
        var a = CGFloat(0)
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let luminance = 1 - ((0.299 * r) + (0.587 * g) + (0.114 * b))
        if luminance < 0.5 {
            titleLabel.textColor = UIColor.black
            quoteLabel.textColor = UIColor.black
            authorLabel.textColor = UIColor.black
        } else {
            titleLabel.textColor = UIColor.white
            quoteLabel.textColor = UIColor.white
            authorLabel.textColor = UIColor.white
        }
    }
    
    // Launch Screen
    func launchScreen() {
        launchView.backgroundColor = UIColor(red: 255/255, green: 244/255, blue: 107/255, alpha: 1.0)
        view.addSubview(launchView)
        launchView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        
        launchImage.contentMode = .scaleAspectFit
        launchView.addSubview(launchImage)
        launchImage.frame = CGRect(x: launchView.frame.maxX - 250, y: launchView.frame.maxY - 630, width: 100, height: 128)
    }
    
    func scaleDownAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.launchImage.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }) { ( success ) in
            self.scaleUpAnimation()
        }
    }
    
    func scaleUpAnimation() {
        UIView.animate(withDuration: 0.35, delay: 0.1, options: .curveEaseIn, animations: {
            self.launchImage.transform = CGAffineTransform(scaleX: 5, y: 5)
        }) { ( success ) in
            self.removeSplashScreen()
        }
    }
    
    func removeSplashScreen() {
        launchView.removeFromSuperview()
    }
}

