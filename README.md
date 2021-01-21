# OrthoDesigner
An application that makes orthographic designs much easier and faster. More features are soon to come. 

## Usage(Version 1)
Program starts by asking the max x, y, and z dimensions and renders the views accordingly. Then, continue to add lines and arcs of different line types to finish model. As you put lines and arcs in one view, construction lines automatically transfer dimensions to other views. This allows user to focus more on drawing a view than worrying if they are missing lines. Once complete, a screenshot can be taken hiding some features and keeping others based on the user's preference. A better export method is on the agenda for upcoming features in the future.

## Commands(Version 1)
### Drawing Tools
* Line -> "l"
* Arc -> "a"
* Snap Mode(Only for lines. Makes lines vertical or horizontal) -> Hold "SHIFT"
* Flip Arc Direction(Only for arcs. Toggles the direction that arc is created in) -> "f"

### Line Types
* Construction(Thin, grey line) -> "q"
* Visible Line(Thick, black line) -> "v"
* Center Line(Thick, red line) -> "c"
* Hidden Line(Thick, green line) -> "h"

### Adjust Viewing Screen
* Zoom in -> "="
* Zoom out -> "-"
* Tranlate Left Or Right -> Left or Right Arrow Keys
* Translate Up or Down -> Up or Down Arrow Keys

### Hide and Show Features
* Hide midpoints -> "m"
* Hide construction lines and points(Tidies up drawing) -> "o"
Note in a later version, a shortcut may be designated to hide/show interections.

### Ways to make a line
1. Select a starting point and then select another point. Line is created with corresponding start and end points.
2. Select a starting point and right-click point. Then, the application prompts user to enter dimension. Using the angle between where the mouse was pressed and the starting point, application scales line along the same angle.

### How to make a arc
1. Select center point. Next, select another point to provide radius of arc. This point also becomes the starting point of the arc. Then, Finally, select one more point as the end point of the arc. 
Note that making arcs by dimensions is on the agenda of upcoming features. Currently, the same result can be acheived by dimensioning around the center point with construction lines.
Also, note all arcs are circular in this version.  

## Screenshots of Application(Version 1)
![Image of Simple Orthographic without Construction Lines](https://github.com/Saptak625/OrthoDesigner/blob/main/Application%20Screenshots/SimpleOrtho1WithoutConstruction.png)
![Image of Harder Orthographic with Construction Lines](https://github.com/Saptak625/OrthoDesigner/blob/main/Application%20Screenshots/HarderOrtho1WithConstruction.png)

## Upcoming Features
1. Intersections between Lines and Arcs
2. Create Arcs using Dimensions
3. Style Lines(Dashed Patterns)
4. Better Undo and Create Redo Feature
5. Suggestions for Proper Line Type
6. Save screenshot from application
7. 3-D Isometric Renderer
8. ???
