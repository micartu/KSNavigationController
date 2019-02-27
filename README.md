# KSNavigationController v0.4
UINavigationController for macOS (Swift, Objective-C)

![ksnavigationcontrollerdemo](https://cloud.githubusercontent.com/assets/3193877/17337372/04002c08-58eb-11e6-9c1f-2cabdea4dd66.gif)

Looking for macOS (Mac OS X) analog of UIKit's `UINavigationController` from iOS? This class mimics its behavior.

**Attention**: Navigation bar is not implemented. All methods must be called from main thread.

Swift version (4.2): [KSNavigationController/Swift](https://github.com/micartu/KSNavigationController)
version 0.4 supports navigation toolbar: in order to use it your view must comform to KSNavigationToolbarProtocol.

Swift version (3.0): [KSNavigationController/Swift](https://github.com/coffellas-cto/KSNavigationController/tree/master/KSNavigationController/Swift)

ObjC version: [KSNavigationController/ObjectiveC](https://github.com/coffellas-cto/KSNavigationController/tree/master/KSNavigationController/ObjectiveC)

For Swift 2.2 support see [version 0.1](https://github.com/coffellas-cto/KSNavigationController/releases/tag/v0.1).

## Usage
### Creating a navigation controller
```swift
// Swift
let vc1 = TestViewController()
let navVC = KSNavigationController(rootViewController: vc1)
navVC?.view.frame = NSMakeRect(0.0, 0.0, 480.0, 272.0) // Or use constraints if appropriate
self.window.contentViewController = navVC
self.window.orderFrontRegardless()
```

```objc
// ObjC
TestViewController *vc1 = [[TestViewController alloc] init];
KSNavigationController *navVC = [[KSNavigationController alloc] initWithRootViewController:vc1];
navVC.view.frame = NSMakeRect(0.0, 0.0, 480.0, 272.0); // Or use constraints if appropriate
self.window.contentViewController = navVC;
[self.window orderFrontRegardless];
```
Here your `TestViewController` class is a subclass of `NSViewController`. It also has to conform to `KSNavigationControllerCompatible` protocol in order to have access to `navigationController` property.
### Pushing and popping view controllers onto / from stack
Now, inside your `NSViewController` you can access `navigationController` property (just like in iOS) and push any new view controller on top of navigation stack:
```swift
// Swift
@IBAction func pushAction(sender: AnyObject) {
    self.navigationController?.pushViewController(TestViewController(), animated: true)
}
```

```objc
// ObjC
- (IBAction)pushAction:(id)sender {
    [self.navigationController pushViewController:[[TestViewController alloc] init] animated:YES];
}
```

Do the following to pop the top view controller from stack:
```swift
// Swift
self.navigationController?.popViewControllerAnimated(true)
```

```objc
// ObjC
[self.navigationController popViewControllerAnimated:YES];
```

## KSNavigationControllerCompatible protocol
Conform to this protocol if you want your `NSViewController` subclass to work with `KSNavigationController`.

This protocol has only one property:
```swift
/*Swift*/ weak var navigationController: KSNavigationController? {get set}
```

```objc
/*ObjC*/ @property (weak, nonatomic) KSNavigationController *navigationController;
```

**Warning:** Do not set this properly by yourself.

**Objective-C only:**
You must synthesize `navigationController` property explicitly in your subclass implementation:
```objc
@synthesize navigationController = _navigationController;
```

See example projects for more understanding.

## License
Published under MIT license.

Copyright (c) 2016 A. Gordiyenko.
