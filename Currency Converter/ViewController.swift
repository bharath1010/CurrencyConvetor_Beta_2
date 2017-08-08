//
//  ViewController.swift
//  Currency Converter
//
//  Created by macbook on 08/08/17.
//  Copyright © 2017 Falconnect Technologies Private Limited Falconnect Technologies Private Limited Falconnect Technologies Private Limited. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,UIPickerViewDelegate ,UITextFieldDelegate {
    //Declaration
    
    //UIPickerview
    var picker:UIPickerView!
    // Array
    var currencyBalance: [Double] = [1000.00,0.00,0.00]
    var flag = ["euro.png","us.png","jpy.png"];
    var currencyName=["Euro (€)","Dollar ($)","JPY (¥)"]
    var currencySymbol = ["EUR","USD","JPY"]
   
    //UIButton
    @IBOutlet weak var convert: UIButton!
    
    //UIView
    @IBOutlet weak var toView: UIView!
    @IBOutlet weak var fromView: UIView!
    var viewbackground : UIView = UIView();
   
    //UITextField
    @IBOutlet weak var commission: UITextField!
    @IBOutlet weak var fromCurrency: UITextField!
    @IBOutlet weak var toImg: UITextField!
    @IBOutlet weak var fromImg: UITextField!
    @IBOutlet weak var fromLabel: UITextField!
    @IBOutlet weak var toLabel: UITextField!
    @IBOutlet weak var toCurrency: UITextField!
    var activeTF : UITextField!
   
    //UILabel
    @IBOutlet weak var jpyBalance: UILabel!
    @IBOutlet weak var dollarBalance: UILabel!
    @IBOutlet weak var euroBalance: UILabel!
    @IBOutlet weak var success: UILabel!
   
    //UIAcitityIndicator
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
   
    //Int values
    var activeTextField = 0
    var indexValue = 0
    var i = 0
    
    //Url parameters
    //String
    var fromCur = ""
    var  toCur = ""
    var amount = ""
    var activeValue = ""
    
    //Double
    var commissionAmount = 0.00
    var baseAmount = 0.00
    var checkAmount = 0.00
    
    //image
    
    var image:UIImage = UIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //Border for Amount textfield
        fromCurrency.layer.borderWidth=1.0
        fromCurrency.layer.borderColor=UIColor.white.cgColor;
        
        
        toCurrency.layer.borderWidth=1.0
        toCurrency.layer.borderColor=UIColor.white.cgColor;
        
        convert.layer.borderWidth=1.0
        convert.layer.borderColor=UIColor.white.cgColor;
        
        //TextField delegate
        fromImg.delegate = self
        toImg.delegate = self
        
        //Intalizeing
        fromCur = "EUR"
        
        toCur = "USD"
        
        //activity allcation to view
        actInd.frame = CGRect(x: 0,y: 5,width: 40,height: 40);
        actInd.center = view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(actInd)
        actInd.isHidden = true

        //activity
        viewbackground.frame = view.frame
        viewbackground.isHidden = true
        viewbackground.backgroundColor = UIColor.clear
        view.addSubview(viewbackground)
        
        
        
    }
    
    func initBalance()   {
        euroBalance.text! =  NSString(format: "€ %.2f", currencyBalance[0]) as String
        dollarBalance.text! = NSString(format: "$ %.2f", currencyBalance[1]) as String
        jpyBalance.text! = NSString(format: "¥ %.2f", currencyBalance[2]) as String

    }
    

    @IBAction func convertPressed(_ sender: Any) {
        
        //activity show

        actInd.startAnimating()
        viewbackground.isHidden = false

        //getting the input
        amount = fromCurrency.text!
        
        self.indexValue = self.currencySymbol.index(of: self.fromCur)!
        
        baseAmount = currencyBalance[indexValue]
        
        checkAmount = Double(baseAmount) - Double(amount)!

        
        
        if amount == "" || amount == "0"
        {
            //activity hide

            self.actInd.stopAnimating()
            viewbackground.isHidden = true


            let alert = UIAlertController(title: "Invaild", message: "Please enter the vaild amount", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if fromCur.isEqual(toCur)
        {
            //activity hide

            self.actInd.stopAnimating()
            viewbackground.isHidden = true

            
            let alert = UIAlertController(title: "Same currency", message: "You are not allowed to transfer to the same account", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        }
            else if (checkAmount < 0)
        {
            //activity hide

            self.actInd.stopAnimating()
            viewbackground.isHidden = true

            //Error alert
            let alert = UIAlertController(title: "Insufficent Balance", message: "Your balance is insufficent to make this transaction", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        }
            else {
        
        //API Function call GET Method
            
        let url = URL(string: "http://api.evp.lt/currency/commercial/exchange/\(amount)-\(fromCur)/\(toCur)/latest")
            
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    
                    //getting postition of the transfing amount
                     self.indexValue = self.currencySymbol.index(of: self.toCur)!
                    
                    self.amount = json["amount"] as! String
                    
                    
                    self.baseAmount = Double(self.currencyBalance[self.indexValue]) + Double(self.amount)!
                    
                    self.currencyBalance[self.indexValue] = Double(self.baseAmount)
                    
                    OperationQueue.main.addOperation({
                        
                        //Commission calculation
                        
                        if self.i >= 5
                        {
                            self.amount = self.fromCurrency.text!
                            self.commissionAmount = (Double(self.amount)! * 0.7) / 100;
                            self.commission.text! = NSString(format: "%.2f", self.commissionAmount) as String
                        }
                        
                        self.indexValue = self.currencySymbol.index(of: self.fromCur)!
                        
                         self.amount = self.fromCurrency.text!
                        
                        self.baseAmount = self.currencyBalance[self.indexValue]
                        
                        //Getting base amount value with commmision
                        self.baseAmount = Double(self.currencyBalance[self.indexValue]) - Double(self.amount)! - self.commissionAmount
                        
                        
                        self.currencyBalance[self.indexValue] = self.baseAmount;
                        
                        //Reinitalize the balance
                        self.initBalance()

                        //Coverted currency
                        self.toCurrency.text! = (json["amount"] as? String)!

                        
                        //i iteration for commission calculation
                        self.i += 1
                        
                        //activity hide
                        self.actInd.stopAnimating()
                        self.viewbackground.isHidden = true
                        
                        //success transcation
                        
                        self.success.text = String(format: "You have converted \(self.amount) \(self.fromCur) to \((json["amount"] as? String)!) \(self.toCur). Commission Fee - %.2f \(self.fromCur).", self.commissionAmount)
                        
                    })
                    
                }catch let error as NSError{
                    print(error)
                }
            }
        }).resume()

        }
    }
    
    //Picker delegate methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return currencyName.count
    }
    
    
   
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        //Uiview with imageview and label
        let myView = UIView(frame: CGRect(x: 0,y: 0,width: pickerView.bounds.width - 30,height: 40))
        
        let myImageView = UIImageView(frame:  CGRect(x: 50,y: 5,width: 30,height: 30))
        
        
        var rowString = String()
        
        rowString = currencyName[row]
        myImageView.image = UIImage(named:flag[row])
        
        let myLabel = UILabel(frame:  CGRect(x: 120,y: 5,width: pickerView.bounds.width - 90,height: 30) )
        myLabel.font = UIFont(name:myLabel.font.familyName, size: 18)
        myLabel.text = rowString
        
        myView.addSubview(myLabel)
        myView.addSubview(myImageView)
        
        return myView
    }
    
    // get currect value for picker view
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // set currect active value based on picker view
        switch activeTextField {
        case 1:
            
            image = UIImage(named: flag[row])!;
            fromImg.background=image;
            fromLabel.text=currencyName[row];
            fromCur = currencySymbol[row];
        
        case 2:
            
            image = UIImage(named: flag[row])!;
            toImg.background=image;
            toLabel.text=currencyName[row];
            toCur = currencySymbol[row];


        default:
            activeValue = ""
        }
    }
    
    //Done
    func doneClick() {

        if activeTF == fromImg || activeTF == toImg {
            activeTF.text = activeValue

        }
        activeTF.resignFirstResponder()
        
    }
    // cancel
    func cancelClick() {
        activeTF.resignFirstResponder()
    }

    //TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // set up correct active textField (no)
        switch textField {
        case fromImg:
            activeTextField = 1
        case toImg:
            activeTextField = 2
        case fromLabel:
            activeTextField = 1
        case toLabel:
            activeTextField = 2
        default:
            activeTextField = 0
        }
        
        // set active Text Field
        activeTF = textField
        
        self.pickUpValue(textField: textField)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    //Dyamnic Picker creation
    func pickUpValue(textField: UITextField) {
        
        // create frame and size of picker view
        picker = UIPickerView(frame:CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.size.width, height: 216)))
        
        // deletates
        picker.delegate = self
    
        picker.backgroundColor = UIColor.clear
        
        //intialize picker to textfield
        toImg.inputView = self.picker
        fromImg.inputView = self.picker
        fromLabel.inputView = self.picker
        toLabel.inputView = self.picker

        
        // toolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.barTintColor = UIColor.lightGray
        toolBar.sizeToFit()
        
        // buttons for toolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}

