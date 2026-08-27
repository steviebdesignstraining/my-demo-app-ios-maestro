//
//  CheckoutViewController.swift
//  My Demo App
//
//  Created by Mubashir on 16/09/21.
//

import UIKit

class ShippingAddressViewController: UIViewController {
    
    @IBOutlet weak var cartCountContView: UIView!
    
    @IBOutlet weak var cartCountLbl: UILabel!
    
    @IBOutlet weak var fullNameTF: TextFieldBorderColor!
    @IBOutlet weak var address1TF: TextFieldBorderColor!
    @IBOutlet weak var address2TF: TextFieldBorderColor!
    @IBOutlet weak var cityTF: TextFieldBorderColor!
    @IBOutlet weak var stateRegionTF: TextFieldBorderColor!
    @IBOutlet weak var zipCodeTF: TextFieldBorderColor!
    @IBOutlet weak var countryTF: TextFieldBorderColor!
    
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
    
    @IBAction func toPaymentButton(_ sender: Any) {

        // Validate full name
        guard let fullName = fullNameTF.text, !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide your full name.")
            return
        }

        // Validate address line 1
        guard let address1 = address1TF.text, !address1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide your address.")
            return
        }

        // Validate city
        guard let city = cityTF.text, !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide your city.")
            return
        }

        // Validate zip/postal code
        guard let zipCode = zipCodeTF.text, !zipCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide your zip/postal code.")
            return
        }

        // Validate country
        guard let country = countryTF.text, !country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide your country.")
            return
        }

        // All validations passed - save shipping address
        Engine.sharedInstance.fullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        Engine.sharedInstance.addressLine1 = address1.trimmingCharacters(in: .whitespacesAndNewlines)
        Engine.sharedInstance.addressLine2 = (address2TF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        Engine.sharedInstance.city = city.trimmingCharacters(in: .whitespacesAndNewlines)
        Engine.sharedInstance.stateRegion = (stateRegionTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        Engine.sharedInstance.zipCode = zipCode.trimmingCharacters(in: .whitespacesAndNewlines)
        Engine.sharedInstance.country = country.trimmingCharacters(in: .whitespacesAndNewlines)

        let storyboard = UIStoryboard.init(name: "TabBar", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PaymentMethodViewController") as! PaymentMethodViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func catalogButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "TabBar", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TabBar") as! CatalogViewController
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
