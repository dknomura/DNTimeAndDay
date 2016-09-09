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
    var oldDayStepValue = 0.0
    var oldTimeStepValue = 0.0
    var oldIntervalStepValue = 0.0
    @IBOutlet weak var formatLabel: UILabel!
    
    var displayTimeAndDay: DNTimeAndDay = DNTimeAndDay.init(dayString: "m", timeString: "12")!
    var timeFormat: DNTimeFormat = .format12Hour
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayTimeAndDay.minuteInterval = 30
        setDisplay()
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func stepDay(sender: UIStepper) {
        if sender.value > oldDayStepValue {
            displayTimeAndDay.day.increaseDay()
        } else {
            displayTimeAndDay.day.decreaseDay()
        }
        oldDayStepValue = sender.value
        dayTextField.text = displayTimeAndDay.day.stringValue
    }
    @IBAction func stepTime(sender: UIStepper) {
        do {
            if sender.value > oldTimeStepValue {
                try displayTimeAndDay.increaseTimeInterval()
            } else {
                try displayTimeAndDay.decreaseTimeInterval()
            }
            oldTimeStepValue = sender.value
            setDisplay()
        } catch {
            displayError(withMessage: "Invalid time interval value", handler: { (UIAlertAction) in
                self.displayTimeAndDay.minuteInterval = 30
                self.displayMinuteInterval()
            })
        }
    }
    @IBAction func stepTimeInterval(sender: UIStepper) {
        let possibleIntervals = [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60]
        if let index = possibleIntervals.indexOf(displayTimeAndDay.minuteInterval!){
            var distance = 0.distanceTo(index)
            if sender.value > oldIntervalStepValue {
                if distance == possibleIntervals.count - 1 {
                    distance = 0
                } else {
                    distance += 1
                }
            } else {
                if distance == 0 {
                    distance = possibleIntervals.count - 1
                } else {
                    distance -= 1
                }
            }
            displayTimeAndDay.minuteInterval = possibleIntervals[distance]
            displayMinuteInterval()
        }
        oldIntervalStepValue = sender.value
    }
    @IBAction func switchTimeFormat(sender: UISwitch) {
        let timeFormatText: String
        if sender.on {
            timeFormat = .format12Hour
            timeFormatText = "12-Hour"
        } else {
            timeFormat = .format24Hour
            timeFormatText = "24-Hour"
        }
        timeTextField.text = displayTimeAndDay.time.stringValue(forFormat: timeFormat)
        formatLabel.text = timeFormatText
    }
    @IBAction func setCurrentTimeAndDay(sender: UIButton) {
        displayTimeAndDay = DNTimeAndDay.currentTimeAndDay()
        if let minIndex = intervalTextField.text?.rangeOfString(" min")?.startIndex {
            displayTimeAndDay.minuteInterval = Int(intervalTextField.text!.substringToIndex(minIndex))
        }
        setDisplay()
    }
    private func setDisplay() {
        dayTextField.text = displayTimeAndDay.day.stringValue
        timeTextField.text = displayTimeAndDay.time.stringValue(forFormat:timeFormat)
        displayMinuteInterval()
    }
    private func displayMinuteInterval() {
        if displayTimeAndDay.minuteInterval != nil {
            intervalTextField.text = String(displayTimeAndDay.minuteInterval!) + " min"
        }
    }
    func textFieldDidEndEditing(textField: UITextField) {
        if textField === dayTextField {
            if let day = DNTimeAndDay.DNDay.init(stringValue: textField.text!) {
                displayTimeAndDay.day = day
            } else {
                displayError(withMessage: "Invalid day input", handler: nil)
            }
        } else if textField === timeTextField {
            if let time = DNTimeAndDay.DNTime.init(userInputValue: textField.text!) {
                displayTimeAndDay.time = time
            } else {
                displayError(withMessage: "Invalid time input", handler: nil)
            }
        } else if textField === intervalTextField {
            if let interval = Int(textField.text!) {
                displayTimeAndDay.minuteInterval = interval
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

