//
//  TestViewController.swift
//  KSNavigationControllerExampleSwift
//
//  Created by Alex on 8/4/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Cocoa

class TestViewController: NSViewController, KSNavigationControllerCompatible {
    weak var navigationController: KSNavigationController?

    @IBOutlet weak var textField: NSTextField!
    
    @IBAction func pushAction(_ sender: AnyObject) {
        self.navigationController?.pushViewController(TestViewController(), animated: true)
    }

    @IBAction func popAction(_ sender: AnyObject) {
        _ = self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(red: CGFloat(arc4random_uniform(63)) / 63.0 + 0.5, green: CGFloat(arc4random_uniform(63)) / 63.0 + 0.5, blue: CGFloat(arc4random_uniform(63)) / 63.0 + 0.5, alpha: 1).cgColor
        
        if let count = self.navigationController?.viewControllersCount {
            self.textField.stringValue = String(count)
        }
    }
    
    @objc
    func testButtonAction(_ sender: Any) {
        print("button was tapped")
    }
}

extension TestViewController: KSNavigationToolbarProtocol {
    var leftButton: NSButton? {
        get {
            let count = Int(self.textField.stringValue) ?? 0
            if count % 3 == 1 {
                let but = NSButton(frame: NSRect(x: 0, y: 0, width: 150, height: 55))
                but.isBordered = true
                but.bezelStyle = .rounded
                but.title = "Left Push me"
                but.target = self
                but.action = #selector(testButtonAction(_:))
                return but
            }
            return nil
        }
    }
    var rightButton: NSButton? {
        get {
            let count = Int(self.textField.stringValue) ?? 0
            if count % 2 == 1 {
                let but = NSButton(frame: .zero)
                but.isBordered = true
                but.title = "Push me"
                but.target = self
                but.action = #selector(testButtonAction(_:))
                return but
            }
            return nil
        }
    }
    var rightButtons: [NSButton]? {
        get {
            let count = Int(self.textField.stringValue) ?? 0
            if count % 3 == 1 {
                let but = NSButton(frame: .zero)
                but.isBordered = true
                but.title = "First"
                but.target = self
                but.action = #selector(testButtonAction(_:))
                
                let k = NSButton(frame: .zero)
                k.isBordered = true
                k.bezelStyle = .rounded
                k.title = "Second"
                k.target = self
                k.action = #selector(testButtonAction(_:))
                return [but, k]
            }
            return nil
        }
        
    }
    var toolbarTitle: String? {
        get {
            let count = Int(self.textField.stringValue) ?? 0
            if count % 3 == 1 {
                return self.textField.stringValue
            }
            return nil
        }
        
    }
    var hideToolbar: Bool {
        get {
            let count = Int(self.textField.stringValue) ?? 0
            return (count % 2 == 0)
        }
    }
}
