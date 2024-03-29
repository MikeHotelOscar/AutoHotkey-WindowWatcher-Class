# AutoHotkey-WindowWatcher-Class
The WindowWatcherClass.ahk file contains two classes, *Rule* and *WindowWatcher*. These classes allow you to designate functions to run automatically when a window matching a typical WinTitle, but excluding those matching an exclusion WinTitle (ExcTitle), opens or closes.

## Rule Class
The Rule class can be invoked by either the WindowWatcher class (described below) or by something similar to the following example:
```
global newRule := new Rule(WinTitle, ExcTitle, OpenFunc, CloseFunc)
```
In this, WinTitle is a typical WinTitle, as is ExcTitle. OpenFunc is the name of a function to be called when a matching window opens, CloseFunc when a matching window closes. All parameters are strings. When OpenFunc is called, the Rule class passes an HWND to the function, allowing any command that accepts a WinTitle to target that window using *ahk_id HWND*.

## Interoperability with Virtual Desktop Class
By default, these classes ALSO trigger not just when a window is open or closed, but also trigger the opening function whenever you switch virtual desktops on Windows 10 or 11. By passing an already existing Virtual Desktop object as a variable to the WindowWatcher class below, this behavior is eliminated, like so:
```
global newWinWatch := new WindowWatcher(vd)
```

## WindowWatcher Class
The WindowWatcher class is a management wrapper for the Rule class, invoked by something similar to the following example:
```
global newWinWatch := new WindowWatcher()
```
Following this, we can create new rules by using the AddRule Method, as shown:
```
WinWatch.AddRule(WinTitle, ExcTitle, OpenFunc, CloseFunc)
```
These parameters are the same as the Rule class, with the following adendum: in the place of WinTitle, you can use "All", to match EVERY window.

In addition, you can do the following, with the previously mentioned "All" being a valid WinTitle:

Delete Rules already added:
```
WinWatch.DeleteRule(WinTitle)
```
Suspend Rules from being followed:
```
WinWatch.SuspendRule(WinTitle)
```
Resume Suspended Rules:
```
WinWatch.ResumeRule(WinTitle)
```
Suspend all Rules:
```
WinWatch.SuspendAll()
```
Resume all Rules:
```
WinWatch.ResumeAll()
```
and Delete all Rules: 
```
WinWatch.DeleteAll()
```
