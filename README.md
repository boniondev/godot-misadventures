<sup>In memory of Pizzavu</sup>
# godot-(mis)adventures
What follows is my past works and projects that I have done with Godot engine. Most if not all of these are unfinished, but perhaps you may find usefulness within them. A special thanks to the Godot community and Github for making all of this possible, and cooliecat for all the helpful feedback throughout my coding endeavours.
## Licenses
### MIT
ALL files with the following extensions are released with the [MIT](https://github.com/boniondev/godot-misadventures/blob/main/LICENSE-MIT) license:
* .gd (Godot scripts)
* .tscn (Godot scenes)
* .godot (Godot project configuration files)
* .cfg (Godot export presets)
* .import (Godot asset import parameters)
### CC0
ALL* files with the following extensions are released with the [CC0](https://github.com/boniondev/godot-misadventures/blob/main/LICENSE-CC0) license:
* .png
* .svg
> [!WARNING]
> *There is one exception to this rule. Godot's logo, referred to as icon.svg in all projects, is released under [CC-BY 4.0 International](https://creativecommons.org/licenses/by/4.0/).

## Projects
### 2playershumptest
This was my attempt at making a multiplayer shoot em up game, but I ultimately dropped it due to the headache of multiplayer connectivity. If two people wanted to play together not locally, the host would have to open a port on their router, something not everyone knows how to do or wants to be bothered doing, or use a program like Hamachi. Another thing I considered using was UPnP (Universal Plug & Play), but most routers nowadays are configured to have it disabled by default as, unsurprisingly, letting any program open any port for any reason is not exactly the safest thing to do. The last option I considered was having a dedicated routing server for NAT Punching that both players would connect to. Not only would that have been expensive in the long run, but it also would have opened another can of worms regarding European Union's GDPR(General Data Protection Regulation), as the IPs of the connecting players would have to be briefly stored inside of the server and thus, I would have to take efforts into making the server secure, not to mention the possible legal ramifications of when and if the server gets compromised.

I didn't exactly learn that much regarding making games by working on this, but I did come up with a somewhat overcomplicated logging system out of necessity, as I found Godot logging was very vague. It lies inside FCabinet.gd.

> [!TIP]
> By downloading the 2playershumptest folder, you should be able to import it as a Godot project and run it out of the box without issues.