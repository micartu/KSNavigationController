//
//  KSNavigationControllerCompatible.swift
//
//  Copyright © 2016 Alex Gordiyenko. All rights reserved.
//  Modified © 2018 Michael Artuerhof. All rights reserved.
//

/*
 The MIT License (MIT)

 Copyright (c) 2016 A. Gordiyenko

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import AppKit

/**
 Protocol your `NSViewController` subclass must conform to.

 Conform to this protocol if you want your `NSViewController` subclass to work with `KSNavigationController`.
 */
public protocol KSNavigationControllerCompatible {
    /**
     Navigation controller object which holds your `NSViewController` subclass.

     Warning: Do not set this properly by yourself.
     */
    var navigationController: KSNavigationController? { get set }
}
