<img align="center" src="gif/logo.png" />

# appstore-card-transition

[![Version](https://img.shields.io/cocoapods/v/appstore-card-transition.svg)](http://cocoapods.org/pods/appstore-card-transition)
[![License](https://img.shields.io/cocoapods/l/appstore-card-transition.svg)](https://github.com/appssemble/appstore-card-transition/blob/master/LICENSE?raw=true)
![Xcode 10.0+](https://img.shields.io/badge/Xcode-10.0%2B-blue.svg)
![iOS 11.0+](https://img.shields.io/badge/iOS-11.0%2B-blue.svg)
![Swift 5.0+](https://img.shields.io/badge/Swift-5.0%2B-orange.svg)

Appstore card animation transition. UICollectionView and UITableView card expand animated transition. This library tries to add the appstore transition to your own app. The goal is to be as simple as possible to integrate in an app while keeping the flexibility and customization alive.

### Top dismissal
<img align="left" src="gif/example2.gif" />
<img align="center" src="gif/example1.gif" />

### Bottom dismissal
<img align="left" src="gif/example3.gif" />
<img align="center" src="gif/example4.gif" />

## How it works

appstore-card-transition uses the `UIViewControllerTransitioningDelegate` to implement the a custom transition animation. The initial frame of the selected cell is taken and the details view controller is animated from that position to the final expanded mode. Making sure that the expansion of the details view controller looks good falls in your responsability.

For closing the details view controller, gesture recognizers are used and the details view controller is animated back to the size of the cell, note that you can change the position of the cell while the details is shown to provide a more dynamic behaviour.

Most of the parameteres are customizable and callbacks for each meaningful action is provided.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate appstore-card-transition into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
use_frameworks!

target '<Your Target Name>' do
    pod 'appstore-card-transition'
end
```

Then, run the following command:

```bash
$ pod repo update
$ pod install
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but appstore-card-transition does support its use on supported platforms.

Once you have your Swift package set up, adding appstore-card-transition as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/appssemble/appstore-card-transition.git", from: "1.0.3")
]
```

### Manual

Add the library project as a subproject and set the library as a target dependency. Here is a step by step that we recommend:

1. Clone this repo (as a submodule or in a different directory, it's up to you);
2. Drag `AppstoreTransition.xcodeproj` as a subproject;
3. In your main `.xcodeproj` file, select the desired target(s);
4. Go to **Build Phases**, expand Target Dependencies, and add `AppstoreTransition`;
5. In Swift, `import AppstoreTransition` and you are good to go! 

## Basic usage guide

First make sure your cells implement the `CardCollectionViewCell` protocol.

```swift
extension YourCollectionViewCell: CardCollectionViewCell {    
    var cardContentView: UIView {
        get {
            return containerView
        }
    }
}
```

If you want your cells to also be responsive to touches, override the following methods:

```swift
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animate(isHighlighted: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animate(isHighlighted: false)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animate(isHighlighted: false)
    }
```

Your cell is now all setup, now go to your details view controller and make it conform to the `CardDetailViewController` protocol.

```swift
extension YourDetailsViewController: CardDetailViewController {
    
    var scrollView: UIScrollView {
        return contentScrollView // the scrollview (or tableview) you use in your details view controller
    }
    
    
    var cardContentView: UIView {
        return headerView // can be just a view at the top of the scrollview or the tableHeaderView
    }

}
```

One more thing you need to hook in your details view controller. Make sure you call the `dismissHandler` in your `scrollViewDidScroll`:

```swift
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissHandler.scrollViewDidScroll(scrollView)
    }
```

Now you are ready to add the actual transition. In your `cellForItemAt` method, after you configured your cell as desired, make sure you set the following:

```swift
        cell.settings.cardContainerInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0) //set this only if your cardContentView has some margins relative to the actual cell content view.
        
        transition = CardTransition(cell: cell, settings: cell.settings) //create the transition
        viewController.settings = cell.settings //make sure same settings are used by both the details view controller and the cell
        //set the transition
        viewController.transitioningDelegate = transition
        viewController.modalPresentationStyle = .custom
        
        //actually present the details view controller
        presentExpansion(viewController, cell: cell, animated: true)
```

If you got here you should now have a basic appstore transition. It might not be perfect yet but its definitely a strong start. If something doesn't look well check if the constraints from your details view controller play well with resizing.

## Tweaking and troubleshooting

Playing with the parameters: check the `TransitionSettings` class.
Most common issues are animation glitches. To prevent those, make sure your constraints are properly set (especailly the top ones) and safe areas work as expected.

Next, make sure your `cardContainerInsets` are properly set and they reflect the actual ones from your cell.

Lastly, your scrollview might need some scrolling to match the actual cell look (it might need some more top inset than the cell for instance). For this case you can scroll the content as needed in your `viewDidLoad` method and for the dismiss animation you can use the `dismissalScrollViewContentOffset` property from `TransitionSettings`.

## Customization

Most often than not, you'll want to animate some other content alongside the appstore animation. For this purpose action blocks are available. You can implement the following callbacks to receive changes in the transition progress.

```swift
extension YourDetailsViewController: CardDetailViewController {

    func didStartPresentAnimationProgress() { ... }
    func didFinishPresentAnimationProgress() { ... }
    
    func didBeginDismissAnimation() { ... }
    func didChangeDismissAnimationProgress(progress:CGFloat) { ... }
    func didFinishDismissAnimation() { ... }
    func didCancelDismissAnimation(progress:CGFloat) { ... }
    
}
```

## Example

Checkout the demo project to see some examples of what the library can do and how its done.

## Contribute

We're aware that this is far from perfect so any improvement or feature is welcomed. If you made an awesome change don't hesitate to create a pull request.

This project is inspired from [this project](https://github.com/aunnnn/AppStoreiOS11InteractiveTransition)

## Let us help you

Do you need help with your app development? [Drop us a line](https://appssemble.com)



<p align="center">
    </br>
    </br>
    <img src="https://www.appssemble.com/img/appssemble-black.png" height="40" />
</p>
