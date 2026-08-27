//
//  WebViewViewController.swift
//  My Demo App
//
//  Created by Mubashir on 17/09/21.
//

import UIKit

class WebViewViewController: UIViewController {
    
    @IBOutlet weak var cartCountContView: UIView!
    
    @IBOutlet weak var cartCountLbl: UILabel!
    
    @IBOutlet weak var urlTF: TextFieldBorderColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cartCountLbl.text = String(Engine.sharedInstance.cartCount)
        if Engine.sharedInstance.cartCount < 1 {
            cartCountContView.isHidden = true
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goToSiteButton(_ sender: Any) {
        // Validate URL is not empty
        guard let urlText = urlTF.text, !urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please enter a URL to navigate to.")
            return
        }

        var urlString = urlText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Add https:// if no protocol specified
        if !urlString.starts(with: "http://") && !urlString.starts(with: "https://") {
            urlString = "https://\(urlString)"
        }

        // Validate URL format
        guard let url = URL(string: urlString), url.host != nil else {
            Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please enter a valid URL (e.g., www.example.com).")
            return
        }

        let storyboard = UIStoryboard.init(name: "Menu", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebViewHandlerViewController") as! WebViewHandlerViewController
        vc.urlString = urlString
        self.navigationController?.pushViewController(vc, animated: true)
    }
   
    @IBAction func catalogButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "TabBar", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CatalogViewController") as! CatalogViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func cartButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "TabBar", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MyCartViewController") as! MyCartViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func moreButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Menu", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
