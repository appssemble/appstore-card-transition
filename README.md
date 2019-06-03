# appstore-card-transition
Appstore card animation transition. UICollectionView and UITableView card expand animated transition. This library tries to add the appstore transition to your own app. The goal is to be as simple as possible to integrate in an app while keeping the flexibility and customization alive.

<img align="left" src="gif/example2.gif" />
<img align="center" src="gif/example1.gif" />

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

### Manual

Add the library project as a subproject and set the library as a target dependency. Here is a step by step that we recommend:

1. Clone this repo (as a submodule or in a different directory, it's up to you);
2. Drag `AppstoreTransition.xcodeproj` as a subproject;
3. In your main `.xcodeproj` file, select the desired target(s);
4. Go to **Build Phases**, expand Target Dependencies, and add `AppstoreTransition`;
5. In Swift, `import AppstoreTransition` and you are good to go! 

## Example
Checkout the demo project to see some examples of what the library can do and how its done.
