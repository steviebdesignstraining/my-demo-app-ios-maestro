//
//  PaymentMethodViewController.swift
//  My Demo App
//
//  Created by Mubashir on 16/09/21.
//

import UIKit
import FormTextField
import EasyTipView

class PaymentMethodViewController: UIViewController, UITextFieldDelegate,EasyTipViewDelegate {
    @IBOutlet weak var billingAddresBtn: UIButton!
    @IBOutlet weak var securityCodeTipBtn: UIButton!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var billingAddressView: UIView!
    @IBOutlet weak var cartCountContView: UIView!
    
    @IBOutlet weak var cartCountLbl: UILabel!
    
    @IBOutlet weak var fullNameCardTF: TextFieldBorderColor!
    @IBOutlet weak var cardNumberTF: FormTextField!
    @IBOutlet weak var expirationDateTF: FormTextField!
    @IBOutlet weak var securityCodeTF: FormTextField!
    
    @IBOutlet weak var fullNameTF: TextFieldBorderColor!
    @IBOutlet weak var address1TF: TextFieldBorderColor!
    @IBOutlet weak var address2TF: TextFieldBorderColor!
    @IBOutlet weak var cityTF: TextFieldBorderColor!
    @IBOutlet weak var stateRegionTF: TextFieldBorderColor!
    @IBOutlet weak var zipCodeTF: TextFieldBorderColor!
    @IBOutlet weak var countryTF: TextFieldBorderColor!
    
    
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var billingAddressViewHeight: NSLayoutConstraint!
    
    var isBillingSame = false
    var preferences = EasyTipView.Preferences()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cartCountLbl.text = String(Engine.sharedInstance.cartCount)
        
        if Engine.sharedInstance.cartCount < 1 {
            cartCountContView.isHidden = true
        }
        
        billingAddresBtn.isSelected = true
        isBillingSame = true
        
        if billingAddresBtn.isSelected == true {
            mainViewHeight.constant = 615
            billingAddressView.isHidden = true
        }else{
            mainViewHeight.constant = 1100
            billingAddressView.isHidden = false
        }
        toolTipPreferences()
        formTextFieldValidation()
        
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
    
    @IBAction func securityCodeTipButton(_ sender: Any) {
        securityCodeTipBtn.isUserInteractionEnabled = false
        showToolTip()
    }
    
    @IBAction func billingAddressButton(_ sender: UIButton) {
        if billingAddresBtn.isSelected {
            billingAddresBtn.isSelected = false
            mainViewHeight.constant = 1100
            billingAddressView.isHidden = false
            isBillingSame = false
        }else{
            billingAddresBtn.isSelected = true
            mainViewHeight.constant = 615
            billingAddressView.isHidden = true
            isBillingSame = true
        }
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
    
    @IBAction func reviewOrderButton(_ sender: Any) {

        // Validate card details
        guard let fullNameCard = fullNameCardTF.text, !fullNameCard.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide the full name on the card.")
            return
        }

        guard let cardNumber = cardNumberTF.text, !cardNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide the card number.")
            return
        }

        // Validate card number length (should be 19 characters including spaces: "1234 5678 1234 5678")
        let cardNumberDigits = cardNumber.replacingOccurrences(of: " ", with: "")
        guard cardNumberDigits.count == 16 else {
            Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide a valid 16-digit card number.")
            return
        }

        guard let expirationDate = expirationDateTF.text, !expirationDate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide the expiration date.")
            return
        }

        // Validate expiration date format (MM/YY)
        let expirationRegex = "^(0[1-9]|1[0-2])/[0-9]{2}$"
        let expirationTest = NSPredicate(format:"SELF MATCHES %@", expirationRegex)
        guard expirationTest.evaluate(with: expirationDate) else {
            Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide a valid expiration date in MM/YY format.")
            return
        }

        // Validate security code
        guard let securityCode = securityCodeTF.text, !securityCode.isEmpty else {
            Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide the security code (CVV/CVC).")
            return
        }

        guard securityCode.count == 3, securityCode.allSatisfy({ $0.isNumber }) else {
            Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide a valid 3-digit security code.")
            return
        }

        // Validate billing address if not same as shipping
        if billingAddresBtn.isSelected == false {
            guard let fullName = fullNameTF.text, !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide your full name.")
                return
            }

            guard let address1 = address1TF.text, !address1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide your address.")
                return
            }

            guard let city = cityTF.text, !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide your city.")
                return
            }

            guard let zipCode = zipCodeTF.text, !zipCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide your zip/postal code.")
                return
            }

            guard let country = countryTF.text, !country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                Methods.showAlertMessage(vc: self, title: "Validation Error!", message: "Please provide your country.")
                return
            }

            // Save billing address
            Engine.sharedInstance.fullNameBilling = fullName
            Engine.sharedInstance.addressLine1Billing = address1
            Engine.sharedInstance.addressLine2Billing = address2TF.text ?? ""
            Engine.sharedInstance.cityBilling = city
            Engine.sharedInstance.stateRegionBilling = stateRegionTF.text ?? ""
            Engine.sharedInstance.zipCodeBilling = zipCode
            Engine.sharedInstance.countryBilling = country
        }

        // Save card details
        Engine.sharedInstance.fullNameCard = fullNameCard
        Engine.sharedInstance.cardNumber = cardNumber
        Engine.sharedInstance.expirationDate = expirationDate

        let storyboard = UIStoryboard.init(name: "TabBar", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ReviewYourOrderViewController") as! ReviewYourOrderViewController
        vc.isBillingSame = isBillingSame
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension PaymentMethodViewController {
    func toolTipPreferences() {
        preferences.drawing.font = UIFont(name: "ProximaNova-Medium", size: 15)!
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.backgroundColor = UIColor.black
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.bottom
    }
    
    func formTextFieldValidation() {
        let cardNumberPlaceholderText = NSAttributedString(string: "3258 1265 7568 7896",
                                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(cgColor: #colorLiteral(red: 0.4274509804, green: 0.4588235294, blue: 0.5176470588, alpha: 1))])
        let expirationDatePlaceholderText = NSAttributedString(string: "03/25",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(cgColor: #colorLiteral(red: 0.4274509804, green: 0.4588235294, blue: 0.5176470588, alpha: 1))])
        let securityCodePlaceholderText = NSAttributedString(string: "123",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(cgColor: #colorLiteral(red: 0.4274509804, green: 0.4588235294, blue: 0.5176470588, alpha: 1))])
        
        cardNumberTF.borderWidth = 0.7
        cardNumberTF.layer.cornerRadius = 5
        cardNumberTF.layer.borderColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6980392157, alpha: 1)
        cardNumberTF.attributedPlaceholder = cardNumberPlaceholderText
        
        expirationDateTF.borderWidth = 0.7
        expirationDateTF.layer.cornerRadius = 5
        expirationDateTF.layer.borderColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6980392157, alpha: 1)
        expirationDateTF.attributedPlaceholder = expirationDatePlaceholderText
        
        securityCodeTF.borderWidth = 0.7
        securityCodeTF.layer.cornerRadius = 5
        securityCodeTF.layer.borderColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6980392157, alpha: 1)
        securityCodeTF.attributedPlaceholder = securityCodePlaceholderText
        
        cardNumberTF.inputType = .integer
        cardNumberTF.formatter = CardNumberFormatter()
        var validation = Validation()
        validation.minimumLength = "1234 5678 1234 5678".count
        validation.maximumLength = "1234 5678 1234 5678".count
        let characterSet = NSMutableCharacterSet.decimalDigit()
        characterSet.addCharacters(in: " ")
        validation.characterSet = characterSet as CharacterSet
        var inputValidator = InputValidator(validation: validation)
        cardNumberTF.inputValidator = inputValidator
        
        expirationDateTF.inputType = .integer
        expirationDateTF.formatter = CardExpirationDateFormatter()
        validation = Validation()
        validation.minimumLength = 5
        validation.maximumLength = 5
        let inputValidatorExpiry = CardExpirationDateInputValidator(validation: validation)
        expirationDateTF.inputValidator = inputValidatorExpiry
        
        securityCodeTF.inputType = .integer
        validation = Validation()
        validation.maximumLength = "CVC".count
        validation.minimumLength = "CVC".count
        validation.characterSet = CharacterSet.decimalDigits
        inputValidator = InputValidator(validation: validation)
        securityCodeTF.inputValidator = inputValidator
    }
    
    func easyTipViewDidTap(_ tipView: EasyTipView) {
        print("\(tipView) did tap!")
        securityCodeTipBtn.isUserInteractionEnabled = true
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        print("\(tipView) did dismiss!")
        securityCodeTipBtn.isUserInteractionEnabled = true
    }
    
    func showToolTip() {
        EasyTipView.show(forView: self.securityCodeTipBtn, withinSuperview : self.mainView , text: "CVV is the last three digits on the back of your credit card.",preferences:self.preferences,delegate: self)
    }
}
