


[![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![License](https://img.shields.io/badge/license-MIT-71787A.svg)](https://tldrlegal.com/license/mit-license)

![](https://github.com/Pyroh/Fluor/blob/master/ressources/banner.png?raw=true)

# What is Fluor ?
**Fluor** is a tool that allows you to automatically change the behaviour of the keyboard's fn keys depending on the active application. That's this simple.

# How does it works ?
<img src="https://github.com/Pyroh/Fluor/blob/master/ressources/statusbar.png?raw=true" width=327pt>

**Fluor** lies in your status bar and makes you see instantaneously which mode your keyboard is on:

- <img src="https://github.com/Pyroh/Fluor/blob/master/Fluor/Assets.xcassets/iconAppleModeTemplate.imageset/iconAppleModeTemplate@2x.png?raw=true" width=16pt> means that the keyboard's fn keys act like Apple function keys.
- <img src="https://github.com/Pyroh/Fluor/blob/master/Fluor/Assets.xcassets/iconOtherModeTemplate.imageset/iconOtherModeTemplate@2x.png?raw=true" width=16pt> means that the keyboard's fn keys act like these good old functions keys (F1, F2, F3, you got it...).

## Fluor's menu
This is what you get when you click on **Fluor** in the status bar:

<img src="https://github.com/Pyroh/Fluor/blob/master/ressources/mainmenu.png?raw=true" width=279pt>

You can choose the default mode, whenever **Fluor** runs it will activate the default mode for your keyboard's fn keys.

**Fluor** also displays the active application and its associated rule that you can change on the go.  
<img src="https://github.com/Pyroh/Fluor/blob/master/Fluor/Assets.xcassets/defaultModeTemplate.imageset/defaultModeTemplate@2x.png?raw=true" width=16pt> is the default rule and means that the application will adopt default Fluor's keyboard behaviour.

## Rules Editor
<img src="https://github.com/Pyroh/Fluor/blob/master/ressources/ruleseditor.png?raw=true" width=412pt>

This panel allows you to see all the rules you set at once. You can modify or delete any rule. Adding a rule will prompt a file selector in which you'll be able to select the application you want to set a rule for.

## Running Applications
<img src="https://github.com/Pyroh/Fluor/blob/master/ressources/runningapps.png?raw=true" width=412pt>

Sometimes it is not possible to select an application in the *Rules Editor* especially games run from Steam. This panel lets you set a rule for any running application. Of course the rules you set in this panel will be available directly in the *Rules Editor*. You can also remove a rule by setting the application behaviour to <img src="https://github.com/Pyroh/Fluor/blob/master/Fluor/Assets.xcassets/defaultModeTemplate.imageset/defaultModeTemplate@2x.png?raw=true" width=16pt>, it will also disappear from the *Rules Editor* panel.

# Why is it open source ?
I made **Fluor** because I needed such an application. I wanted it simple, nicely designed and free and I didn't find such a thing on the internet. Once it was done I used it for a little while, cleaned up the code and decided to give it to others for free (what was a requirement for me can also be a requirement for others).  
You'll argue that such a non-sandboxed app had no chance to hit the AppStore and you'll be right. But if it had the chance it would have remained free and open-source. I don't think there's much people needing such an app and I prefer seeing it used by a wider range of people.  

This app is also built using open-source code that's why I think it belongs to this world. And if someone learns something looking at the code I'll be happy 😃.

# License
**Fluor** is released under the MIT license. See LICENSE for details.

Some of [**fntoggle**](https://github.com/nelsonjchen/fntoggle)'s code was used. As its author [wrote](https://github.com/nelsonjchen/fntoggle#license) it could be released under the GPL2 license.

The code also uses [**LaunchAtLoginController**](https://github.com/Mozketo/LaunchAtLoginController) which is Copyright (c) 2010 Ben Clark-Robinson, ben.clarkrobinson@gmail.com and is released under the MIT LICENSE.