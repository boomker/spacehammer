# Layouts.spoon
Hammerspoon Spoon for easily saving and restoring Desktop layouts

This spoon is inspired by Macsparky's [Keyboard
Maestro Field Guide | MacSparky Field Guides](https://learn.macsparky.com/p/km)

Evan Traver's blog on Hammerspoon and Headspace [Introducing
Headspace](http://evantravers.com/articles/2020/06/19/hammerspoon-headspace/)

The [ArrangeDesktop Spoon](https://www.hammerspoon.org) and generous help from
Luis Cruz (the author of ArrangeDesktop spoon)

This spoon provides the functionality of saving your desktop layouts. The idea
is that you work in different contexts. Each context has applications in
certain locations on your screen(s). 
Once this spoon is loaded by Hammerspoon, it creates a menubar entry, which has
1 option (Save Current Desktop Layout) when loaded for the first time.
Selecting this, gives you a dialog box where you can enter a name for your
context/layout. The app then figures out the location of the apps on the screen
and saves it to ~/.hammerspoon/layouts.json

You can save as many Layouts/Contexts as you want. You can then instantly
switch to the layout using - 
- The menubar
- Keyboard hotkey
- URL

The image below shows layout switching using the menubar. 

![Layouts](./layouts.gif)

## Installation 

- You need to install [Hammerspoon](https://www.hammerspoon.org/)

- Download and copy the folder Layouts.spoon to ~/.hammerspoon/Spoons folder. 
- In the ~/.hammerspoon/init.lua add the following code 
  ```
hyper = {"cmd","shift","ctrl","alt"}
hs.loadSpoon('Layouts')
spoon.Layouts:bindHotKeys({choose = hyper,'8'}}):start()
  ```
  
  Change hyper to whatever you are using as your Hyper key 
  [A better Hyper key hack for Sierra - BrettTerpstra.com](https://brettterpstra.com/2016/09/29/a-better-hyper-key-hack-for-sierra/)
  
  Hyperkey with Karabiner Elements is now much easier   - 
 [Setting up a hyper key — Johannes Holmberg](https://holmberg.io/hyper-key/) 

## Keyboard Shortcut

Using Hyper+8 (or whatever you chose as your hotkey) will popup a chooser box a
la Alfred and you can choose your layouts from there 

![Chooser](./chooser.jpg)

## URL

The spoon also enables switching your layout using a URL. For example to swith
to the layout "Dev" , you can use 
```
open 'hammerspoon://layouts?layout=Dev'
```

Once you've saved all the contexts/layouts using the menubar option, you can
switch using either the menubar, keyboard shortcut or the URL way. 

For people using [Bunch](https://bunchapp.co/), once you've opened all the apps
you need in a Bunch, you can invoke the URL to place the apps on the saved
locations on your screens. 


## Saving /Deleting Layouts

You can save a layout by selecting the "Save Current Desktop Layout" menubar
option

Control clicking the layout will delete the layout. 
