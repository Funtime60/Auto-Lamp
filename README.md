# Auto-Lamp
A Factorio Mod that adds a tool that will place lamp ghosts in an area where there is electricity and space for lamps.

It's a simple 2-Day mod that I wrote because I wasn't happy with how [Lamp Placer](https://mods.factorio.com/mod/lamp-placer) handled the work on large areas.

This mod works by grabbing all the "electric-pole" entities in the selection area and queuing them into a table using the fact that lua's next() function is FIFO in Factorio's implemntation. From there every tick it will take 1 pole and find all tiles posistions within the coverage area of the pole and queue them in a second queue. If there are any positions in the second queue it will process 1 of those instead of a pole. If a lamp can be placed in the spot, the pole still exists, and there aren't any lamps or ghost lamps closer than the minimum distance it will make a ghost lamp. If it couldn't place a lamp it will recursively call the function until it either places a lamp or it runs out of spaces to place a lamp.

Contributions, suggestions, locales, and even requests are welcome. Just fork and make a PR with your change or an issue with bugs and anything else.
