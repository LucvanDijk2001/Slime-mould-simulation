# Slime-mould-simulation
simulation of slime mould

This was a fun little hobby project i made in a weekend between school days. 
I followed this amazing paper https://cargocollective.com/sagejenson/physarum made by Sage Jenson.

The way this works is actually quite simple. The world contains 2 layers. One layer with agents and one trail layer.
Agents have 3 sensors that scan for trails. The agent will steer towards the sensor that picks up the highest trail pheromone amount.
Pheremones get placed every frame by agents on that agents position, placed trail value is adjustable and the area covered is adjustable too.
agents have a bunch of parameters that can be edited. These parameters include:
- decay factor (this is a global one and stands for how fast pheromones dissapear)
- cell size (visibility of agent)
- sensor distance (how far away sensors are from the agent)
- sensor size (the area a sensor scans at given distance)
- sensor angle (the angle at which agents place the sensors at given distance)
- rotation angle (rotation speed of the agent)
- random angle add (little randomization to rotation speed for more interesting simulations)
- cell move speed (speed of agent)
- pheremone amount (value amount in float of how much pheremone gets emplaced on the trailmap)
- deposit size (size covered in pheremone mount around the agent)

program also include a few buttons:
- randomize (randomizes all agent settings except for decay factor, cell size and deposit size)
- reste (reset agents back to default values)
- visualize agent (puts a visualization of agent properties in the middle of the screen, this is a toggle button)
- trails (shows pheremones while button is held)

currently the program has 10k agents running, these simulations would be way cooler with a lot more agents,
so i might look into compute shaders in the future to simulate a ton of agents.

here is an example gif of the program (a very bad quality gif to keep it under 10 mb):

![slimemould](https://user-images.githubusercontent.com/59364952/192152330-b9f614a0-13c2-4dcc-95b1-6db013237f3e.gif)
