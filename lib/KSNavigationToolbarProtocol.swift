//
//  KSNavigationToolbarProtocol.swift
//  KSNavigationControllerExampleSwift
//
//  Created by Michael Artuerhof on 27.02.19.
//  Copyright © 2019 BearMonti. All rights reserved.
//

import AppKit

public protocol KSNavigationToolbarProtocol: class {
    var leftButton: NSButton? { get }
    var rightButton: NSButton? { get }
    var rightButtons: [NSButton]? { get }
    var toolbarTitle: String? { get }
    var hideToolbar: Bool { get }
}
