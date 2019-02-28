//
//  KSStack.swift
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

class _KSStackItem<T> : NSObject {
    var value: T
    var next: _KSStackItem<T>?
    init(_ value: T) {
        self.value = value
    }
}

class _KSStack<T>: NSObject {
    fileprivate var _head: _KSStackItem<T>?
    fileprivate var _count: UInt = 0
    var headValue: T? {
        get {
            return self._head?.value
        }
    }
    var count: UInt {
        get {
            return self._count
        }
    }

    func push(_ object: T) -> Void {
        let item = _KSStackItem(object)
        item.next = self._head
        self._head = item
        self._count += 1
    }

    func pop() -> T? {
        guard self._head != nil else {
            NSException(name: NSExceptionName.internalInconsistencyException, reason: "Popped an empty stack", userInfo: nil).raise()
            return nil
        }

        let retVal = self._head?.value
        self._head = self._head?.next
        self._count -= 1
        return retVal
    }

    func iterate(_ block: (T) -> (Void)) -> Void {
        var item = self._head
        while true {
            if let item = item {
                block(item.value)
            } else {
                break
            }

            item = item?.next
        }
    }
}
