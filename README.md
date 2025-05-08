# MediationGame
The repository for the game project (currently titled meditation game) being made for The University of Wisconsin Stout

Providing an escape for students and whomever needs it. A retreat into a simple, quaint little farmhouse to tend to your garden, and write about your feelings.

NOTICE -> USE THE MEDITATION GAME FOLDER -> ZEN GARDEN IS DEPRACATED

# A Notice of Privacy
Given the nature of sharing private information we are committed to the protection of your save files and game instances from data collection of any kind from the development team, UW-Stout, or whomever may manage this game in the future.

# Godot Engine
To ensure stability across all collaboraters, we will be using Godot Version V4.3.stable.official[77dcf97d8] in order to work on this project.

# Project Setup

## 1 
Find an appropriate location on your device to store the GitHub repository for the game. Make sure that when cloning it you checkout the main branch (artists). 

## 2
When opening Godot, you have the ability to import a prohect into the project manager, simply import the .project file in the repo and the project should be imported and editable right away.

# Project Standards

## Altering Project Settings / Installing Plugins
Along the way, programmers may discover plugins and/or settings in the project that can be added/altered in order to make development of the game smoother. If this is the case, everyone must make sure they have no unsaved changes that are not in the newest version of the project. That is, everyone should have the same version upon pulling the plugin/setting down.

## Coding Standards
Godot uses a language for it's programming called GDScript, it is very similar to python, and easily readable.

## Documentation Standards
Because of the similarity to Godot, and emphasis on industry standard technique, we will be using a standard commenting practice on our code. 

This means that code should be commented with short, yet descriptive bits of text that describe why the function you have created exists.

For Class creations, we will be using NuPy docstrings to document our class structure. An Examble is below.

```python
"""Gets and prints the spreadsheet's header columns

Parameters
----------
file_loc : str
    The file location of the spreadsheet
print_cols : bool, optional
    A flag used to print the columns to the console (default is False)

Return
-------
list
    a list of strings representing the header columns
"""
```

