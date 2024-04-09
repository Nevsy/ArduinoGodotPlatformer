A repository containing the Godot project for a game controlled by an Arduino Uno board.

#Features - Arduino
Sending over all data received from:

Potentiometer
Button Encode these all into a single number, then send it over through the serial port for Godot to receive.
#Features - Godot
In the main script (C#) we read off the serial port and send over the individual numbers (back to potentiometer and button separate) to the player script. This script is written in gdscript and handles all the character movement: horizontal movement, jumps, wall-jumps, wall-sliding, ... Additional game features:

Heart system (with enemies)
Coin system
