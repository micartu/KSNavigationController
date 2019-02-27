//
//  KSNavigationController.m
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

public typealias AnimationBlock = (_ fromView: NSView?, _ toView: NSView?) -> (fromViewAnimations: [CAAnimation], toViewAnimations: [CAAnimation])

// MARK: Stack

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

// MARK: KSNavigationControllerCompatible

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

// MARK: KSNavigationController

/**
 This class mimics UIKit's `UINavigationController` behavior.

 Navigation bar is not implemented. All methods must be called from main thread.
 */
public class KSNavigationController: NSViewController {

    private lazy var __addRootViewOnce: () = {
        self.install(vc: self.rootViewController)
    }()

    // MARK: Properties

    /** The root view controller on the bottom of the stack. */
    fileprivate(set) var rootViewController: NSViewController

    /** The current view controller stack. */
    public var viewControllers: [NSViewController] {
        get {
            var retVal = [NSViewController]()
            self._stack.iterate { (object: NSViewController) -> (Void) in
                retVal.append(object)
            }

            retVal.append(self.rootViewController)
            return retVal
        }
    }

    /** Number of view controllers currently in stack. */
    public var viewControllersCount: UInt {
        get {
            return self._stack.count + 1
        }
    }

    /** The top view controller on the stack. */
    public var topViewController: NSViewController? {
        get {
            if self._stack.count > 0 {
                return self._stack.headValue;
            }

            return self.rootViewController;
        }
    }
    
    public var toolbarHeight: CGFloat = 44
    public var tintColor: NSColor = NSColor.blue

    fileprivate var _toolbar: NSView? = nil
    fileprivate var _toolbarHeightConstraint: NSLayoutConstraint? = nil
    fileprivate var _activeView: NSView?
    fileprivate var _stack: _KSStack<NSViewController> = _KSStack<NSViewController>()

    // MARK: Life Cycle

    /**
     Initializes and returns a newly created navigation controller.
     This method throws exception if `rootViewController` doesn't conform to `KSNavigationControllerCompatible` protocol.
     - parameter rootViewController: The view controller that resides at the bottom of the navigation stack.
     - returns: The initialized navigation controller object or nil if there was a problem initializing the object.
     */
    init?(rootViewController: NSViewController) {
        self.rootViewController = rootViewController
        super.init(nibName: nil, bundle: nil)
        if var rootViewController = rootViewController as? KSNavigationControllerCompatible {
            rootViewController.navigationController = self
        } else {
            NSException(name: NSExceptionName.internalInconsistencyException, reason: "`rootViewController` doesn't conform to `KSNavigationControllerCompatible`", userInfo: nil).raise()
            return nil
        }
    }

    required init?(coder: NSCoder) {
        self.rootViewController = NSViewController()
        super.init(coder: coder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
    }

    override public func viewWillAppear() {
        super.viewWillAppear()
        _ = self.__addRootViewOnce
    }

    override public func loadView() {
        self.view = NSView()
    }

    // MARK: Public Methods

    /**
     Pushes a view controller onto the receiver’s stack and updates the display. Uses a horizontal slide transition.
     - parameter viewController: The view controller to push onto the stack.
     - parameter animated: Set this value to YES to animate the transition, NO otherwise.
     */
    public func pushViewController(_ viewController: NSViewController, animated: Bool) {
        let pushFrom = self._activeView
        self._stack.push(viewController)
        if var viewControllerWithNav = viewController as? KSNavigationControllerCompatible {
            viewControllerWithNav.navigationController = self
        }
        let nextView = viewController.view
        install(vc: viewController) { [weak self] in
            self?.view.addSubview(viewController.view, positioned: .below,
                                  relativeTo: pushFrom!)
        }
        performTransform(animate: animated,
                         fromView: pushFrom,
                         toView: nextView,
                         animation: defaultPushAnimation())
    }

    /**
     Pops the top view controller from the navigation stack and updates the display.
     - parameter animated: Set this value to YES to animate the transition, NO otherwise.
     - returns: The popped view controller.
     */
    public func popViewControllerAnimated(_ animated: Bool) -> NSViewController? {
        if self._stack.count == 0 {
            return nil
        }
        let popFrom = self._activeView
        let retVal = self._stack.pop()
        let nextVC = self._stack.headValue
        var nextView = self._stack.headValue?.view
        if nextView == nil {
            nextView = rootViewController.view
        }
        if let nc = nextVC,
            let pv = popFrom {
            install(vc: nc) { [weak self] in
                self?.view.addSubview(nc.view, positioned: .below,
                                      relativeTo: pv)
            }
        } else {
            install(vc: rootViewController)
        }
        performTransform(animate: animated,
                         fromView: popFrom,
                         toView: nextView!,
                         animation: defaultPopAnimation())
        return retVal
    }

    /**
     Pops until there's only a single view controller left on the stack. Returns the popped view controllers.
     - parameter animated: Set this value to YES to animate the transitions if any, NO otherwise.
     - returns: The popped view controllers.
     */
    public func popToRootViewControllerAnimated(_ animated: Bool) -> [NSViewController]? {
        if self._stack.count == 0 {
            return nil;
        }
        var retVal = [NSViewController]()
        for _ in 1...self._stack.count {
            if let vc = self.popViewControllerAnimated(animated) {
                retVal.append(vc)
            }
        }
        return retVal
    }

    // MARK: Private Methods
    

    private func install(vc: NSViewController, addVC: (() -> Void)? = nil) {
        // add toolbar to the top of the screen
        if _toolbar == nil {
            let toolbar = NSView(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
            toolbar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(toolbar)
            view.addConstraints([toolbar.topAnchor.constraint(equalTo: view.topAnchor),
                                 toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                 toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
            _toolbarHeightConstraint = toolbar.heightAnchor.constraint(equalToConstant: toolbarHeight)
            _toolbarHeightConstraint?.isActive = true
            _toolbar = toolbar
        }
        // then add the view of given view controller:
        if let toolbar = _toolbar {
            let vv = vc.view
            if let addingClosure = addVC {
                addingClosure()
            } else {
                view.addSubview(vv)
            }
            vv.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints([vv.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
                                 vv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                 vv.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                 vv.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
            // adjust toolbar constraints:
            let showToolbar = { [weak self] (height: CGFloat) in
                self?._toolbarHeightConstraint?.constant = height
                if height > 0 {
                    toolbar.isHidden = false
                } else {
                    toolbar.isHidden = true
                }
            }
            toolbar.subviews.removeAll()
            if let bvc = vc as? KSNavigationToolbarProtocol {
                if bvc.hideToolbar {
                    showToolbar(0)
                } else {
                    showToolbar(toolbarHeight)
                }
                // install title of toolbar:
                if let title = bvc.toolbarTitle {
                    let l = NSTextField()
                    l.stringValue = title
                    l.alignment = .center
                    l.isBezeled = false
                    l.drawsBackground = false
                    l.isEditable = false
                    l.isSelectable = false
                    l.translatesAutoresizingMaskIntoConstraints = false
                    toolbar.addSubview(l)
                    toolbar.addConstraints([l.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
                                            l.centerXAnchor.constraint(equalTo: toolbar.centerXAnchor)])
                }
                let addLeftButton = { (lb: NSView) in
                    lb.translatesAutoresizingMaskIntoConstraints = false
                    toolbar.addSubview(lb)
                    toolbar.addConstraints([lb.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
                                            lb.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 5)])
                }
                if let lb = bvc.leftButton {
                    addLeftButton(lb)
                } else {
                    let lb = NSButton(frame: NSRect(x: 0, y: 0, width: 100, height: 22))
                    let title = "< " + NSLocalizedString("Back", comment: "Back button")
                    lb.isBordered = false
                    lb.target = self
                    lb.action = #selector(backButtonAction(_:))
                    let style = NSMutableParagraphStyle()
                    style.alignment = .center
                    
                    let attributes = [
                        NSAttributedString.Key.foregroundColor: tintColor,
                            //NSAttributedStringKey.font: font,
                            //NSAttributedStringKey.paragraphStyle: style
                        ] as [NSAttributedString.Key : Any]
                    let attBig = [
                        NSAttributedString.Key.foregroundColor: tintColor,
                        NSAttributedString.Key.font: NSFont.systemFont(ofSize: 18),
                        //NSAttributedStringKey.paragraphStyle: style
                        ] as [NSAttributedString.Key : Any]
                    let atitle = NSMutableAttributedString(string: title, attributes: attributes)
                    atitle.addAttributes(attBig, range: NSRange(location: 0, length: 1))
                    lb.attributedTitle = atitle
                    addLeftButton(lb)
                }
                let addRightButton = { (rb: NSView) in
                    rb.translatesAutoresizingMaskIntoConstraints = false
                    toolbar.addSubview(rb)
                    toolbar.addConstraints([rb.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
                                            rb.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -5)])
                }
                if let rb = bvc.rightButton, bvc.rightButtons == nil {
                    addRightButton(rb)
                }
                if let rbs = bvc.rightButtons {
                    let stack = NSStackView(views: rbs)
                    stack.orientation = .vertical
                    stack.spacing = 8
                    stack.distribution = .fill
                    stack.alignment = .centerY
                    addRightButton(stack)
                }
            } else {
                showToolbar(toolbarHeight)
            }
            _activeView = vv
        }
    }
    
    private func performTransform(animate: Bool,
                                  fromView: NSView?,
                                  toView: NSView,
                                  animation: @escaping AnimationBlock) {
        let afterAnimation = {
            fromView?.removeFromSuperview()
            toView.layer?.removeAllAnimations()
        }
        if animate {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                afterAnimation()
            }
            animateTransition(fromView: fromView, toView: toView, animation: animation)
            CATransaction.commit()
        } else {
            afterAnimation()
        }
    }

    private func animateTransition(fromView: NSView?,
                                   toView: NSView?,
                                   animation: AnimationBlock) {
        let anis = animation(fromView, toView)
        fromView?.wantsLayer = true
        toView?.wantsLayer = true
        for animation in anis.fromViewAnimations {
            fromView?.layer?.add(animation, forKey: nil)
        }
        for animation in anis.toViewAnimations {
            toView?.layer?.add(animation, forKey: nil)
        }
    }

    // MARK: - Animations
    
    open func defaultPushAnimation() -> AnimationBlock {
        return { [weak self] (_, _) in
            let containerViewBounds = self?._activeView?.bounds ?? .zero

            let slideToLeftTransform = CATransform3DMakeTranslation(-containerViewBounds.width, 0, 0)
            let slideToLeftAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
            slideToLeftAnimation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
            slideToLeftAnimation.toValue = NSValue(caTransform3D: slideToLeftTransform)
            slideToLeftAnimation.duration = 0.25
            slideToLeftAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            slideToLeftAnimation.fillMode = CAMediaTimingFillMode.forwards
            slideToLeftAnimation.isRemovedOnCompletion = false

            let slideFromRightTransform = CATransform3DMakeTranslation(containerViewBounds.width, 0, 0)
            let slideFromRightAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
            slideFromRightAnimation.fromValue = NSValue(caTransform3D: slideFromRightTransform)
            slideFromRightAnimation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
            slideFromRightAnimation.duration = 0.25
            slideFromRightAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            slideFromRightAnimation.fillMode = CAMediaTimingFillMode.forwards
            slideFromRightAnimation.isRemovedOnCompletion = false

            return ([slideToLeftAnimation], [slideFromRightAnimation])
        }
    }

    open func defaultPopAnimation() -> AnimationBlock {
        return { [weak self] (_, _) in
            let containerViewBounds = self?._activeView?.bounds ?? .zero

            let slideToRightTransform = CATransform3DMakeTranslation(-containerViewBounds.width / 2, 0, 0)
            let slideToRightAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
            slideToRightAnimation.fromValue = NSValue(caTransform3D: slideToRightTransform)
            slideToRightAnimation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
            slideToRightAnimation.duration = 0.25
            slideToRightAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            slideToRightAnimation.fillMode = CAMediaTimingFillMode.forwards
            slideToRightAnimation.isRemovedOnCompletion = false

            let slideToRightFromCenterTransform = CATransform3DMakeTranslation(containerViewBounds.width, 0, 0)
            let slideToRightFromCenterAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
            slideToRightFromCenterAnimation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
            slideToRightFromCenterAnimation.toValue = NSValue(caTransform3D: slideToRightFromCenterTransform)
            slideToRightFromCenterAnimation.duration = 0.25
            slideToRightFromCenterAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            slideToRightFromCenterAnimation.fillMode = CAMediaTimingFillMode.forwards
            slideToRightFromCenterAnimation.isRemovedOnCompletion = false

            return ([slideToRightFromCenterAnimation], [slideToRightAnimation])
        }
    }
    
    // MARK: - Actions
    @objc
    private func backButtonAction(_ sender: Any) {
        popViewControllerAnimated(true)
    }
}
