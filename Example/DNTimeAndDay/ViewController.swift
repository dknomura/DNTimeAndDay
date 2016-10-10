//
//  ViewController.swift
//  DNTimeAndDay
//
//  Created by dnomnom on 09/07/2016.
//  Copyright (c) 2016 dnomnom. All rights reserved.
//

import UIKit
import DNTimeAndDay

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var dayTextField: UITextField!    
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var intervalTextField: UITextField!
    @IBOutlet weak var timeFormatLabel: UILabel!
    @IBOutlet weak var dayFormatLabel: UILabel!
    
    
    enum OutletTags: Int {
        case day = 0, time, interval
    }
    
    var timeAndDayDisplay: DNTimeAndDay = DNTimeAndDay.init(dayString: "m", timeString: "12")!
<<<<<<< HEAD
    var timeFormat: DNTimeAndDayFormat = .format12Hour
    var dayFormat: DNTimeAndDayFormat = .full
=======
    var timeAndDayFormat: DNTimeAndDayFormat = DNTimeAndDayFormat(time:.format12Hour, day:.full)
>>>>>>> 5fd66633f5187d9eb923592e8dd5022c460c09c1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFields()
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func switchTimeFormat(sender: UISwitch) {
        timeAndDayFormat.time = sender.on ? .format12Hour : .format24Hour
        timeTextField.text = timeAndDayDisplay.time.stringValue(forFormat: timeAndDayFormat)
        timeFormatLabel.text = timeAndDayFormat.time.rawValue
    }
    @IBAction func switchDayFormat(sender: UISwitch) {
        timeAndDayFormat.day = sender.on ? .full : .abbr
        dayTextField.text = timeAndDayDisplay.day.stringValue(forFormat:timeAndDayFormat)
        dayFormatLabel.text = timeAndDayFormat.day == .full ? "Full Day" : "Abbr Day"
    }
    
    @IBAction func setCurrentTimeAndDay(sender: UIButton) {
        timeAndDayDisplay = DNTimeAndDay.currentTimeAndDay()
        timeAndDayDisplay.minuteInterval = Int(intervalTextField.text!)!
        setTextFields()
    }
    
    @IBAction func increaseTaggedTextField(sender: UIButton) {
        changeTextField(forButton: sender, increase: true)
    }
    
    @IBAction func decreaseTaggedTextField(sender: UIButton) {
        changeTextField(forButton: sender, increase: false)
    }
    
    private func changeTextField(forButton button: UIButton, increase: Bool) {
        if let outletTag = OutletTags(rawValue: button.tag) {
            switch outletTag {
            case .day:
                increase ? timeAndDayDisplay.increaseDay() : timeAndDayDisplay.decreaseDay()
            case .time:
                increase ? timeAndDayDisplay.increaseTime() : timeAndDayDisplay.decreaseTime()
            case .interval:
                timeAndDayDisplay.minuteInterval += increase ? 5 : -5
            }
            setTextFields()
        } else {
            print("No outlet tag for #\(button.tag)")
        }
    }
    
    private func setTextFields() {
        dayTextField.text = timeAndDayDisplay.day.stringValue(forFormat: timeAndDayFormat)
        timeTextField.text = timeAndDayDisplay.time.stringValue(forFormat:timeAndDayFormat)
        intervalTextField.text = String(timeAndDayDisplay.minuteInterval)
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if textField === dayTextField {
            if let day = DNDay.init(stringValue: textField.text!) {
                timeAndDayDisplay.day = day
            } else {
                displayError(withMessage: "Invalid day input", handler: nil)
            }
        } else if textField === timeTextField {
            if let time = DNTime.init(stringValue: textField.text!) {
                timeAndDayDisplay.time = time
            } else {
                displayError(withMessage: "Invalid time input", handler: nil)
            }
        } else if textField === intervalTextField {
            if let interval = Int(textField.text!) {
                timeAndDayDisplay.minuteInterval = interval
            } else {
                displayError(withMessage: "Invalid interval input", handler: nil)
            }
        }
    }
    
    private func displayError(withMessage message: String, handler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController.init(title: "Error", message: message, preferredStyle: .Alert)
        let confirmation = UIAlertAction.init(title: "Ok", style: .Default, handler: handler)
        alertController.addAction(confirmation)
        presentViewController(alertController, animated: true, completion: nil)
    }
}

