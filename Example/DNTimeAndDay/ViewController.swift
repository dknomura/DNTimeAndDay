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
    var timeFormat: DNTimeFormat = .format12Hour
    var dayFormat: DNDayFormat = .full
    
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
        if sender.on {
            timeFormat = .format12Hour
        } else {
            timeFormat = .format24Hour
        }
        timeTextField.text = timeAndDayDisplay.time.stringValue(forFormat: timeFormat)
        timeFormatLabel.text = timeFormat.rawValue
    }
    
    @IBAction func switchDayFormat(sender: UISwitch) {
        if sender.on {
            dayFormat = .full
        } else {
            dayFormat = .abbr
        }
        dayTextField.text = timeAndDayDisplay.day.stringValue(forFormat: dayFormat)
        dayFormatLabel.text = dayFormat == .full ? "Full Day" : "Abbr Day"
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
        dayTextField.text = timeAndDayDisplay.day.stringValue(forFormat: dayFormat)
        timeTextField.text = timeAndDayDisplay.time.stringValue(forFormat:timeFormat)
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
            if let time = DNTime.init(userInputValue: textField.text!) {
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

