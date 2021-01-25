class Point { //<>//
  float x;
  float y;
  boolean selected;

  Point(float x, float y) {
    this.x=x;
    this.y=y;
    this.selected = false;
  }

  boolean display(boolean highlighted) {
    float newMouseX=(1/scaleFactor)*(mouseX-400)-xTranslation+400;
    float newMouseY=(1/scaleFactor)*(mouseY-400)-yTranslation+400;
    if ((sqrt(((newMouseX-x)*(newMouseX-x))+((newMouseY-y)*(newMouseY-y))) < 30/scaleFactor && !highlighted) || this.selected) {
      strokeWeight(8.5);
      stroke(255, 0, 0);
      point(x, y);
      if (this.selected) {
        return false;
      } else {
        return true;
      }
    } else {
      strokeWeight(3);
      stroke(0);
      point(x, y);
      return false;
    }
  }

  boolean checkClick() {
    float newMouseX=(1/scaleFactor)*(mouseX-400)-xTranslation+400;
    float newMouseY=(1/scaleFactor)*(mouseY-400)-yTranslation+400;
    if (sqrt(((newMouseX-x)*(newMouseX-x))+((newMouseY-y)*(newMouseY-y))) < 30/scaleFactor) {
      if (extendConstructionLines) {
        this.makeConstructionLines();
      } else {
        if (!selected || (shapeMode == "arc" && currentArc != null)) {
          boolean temporaryCondition = true;
          if (currentArc != null) {
            if (currentArc.points.get(0) == this) {
              selected=false;
              selectedPoint = null;
              for (Point p : currentArc.points) {
                p.selected = false;
              }
              currentArc = null;
              temporaryCondition = false;
            }
          }
          if (temporaryCondition) {
            selected=true;
            if (selectedPoint == null) {
              selectedPoint = this;
            } else {
              if (shapeMode == "line") {
                if (currentLine != null) {
                  currentLine.startingPoint.selected = false;
                  currentLine.finalizeLine(this);
                }
              } else {
                if (currentArc != null) {
                  if (!currentArc.fixedRadius && !currentArc.fixedArc) {
                    currentArc.finalizeRadius(this);
                  } else if (!currentArc.fixedArc) {
                    currentArc.finalizeArc(this);
                  }
                }
              }
            }
          }
        } else {
          selected=false;
          selectedPoint = null;
        }
      }
      return true;
    }
    return false;
  }

  String findView() {
    if (origin.x <= this.x && this.x <= origin.x+dimensions.get(0)) {
      //Either top or front
      if (origin.y >= this.y && this.y >= origin.y-dimensions.get(1)) {
        //Front
        return "f";
      } else {
        return "t";
      }
    } else {
      //Right view
      return "r";
    }
  }

  void makeConstructionLines() {
    String view = this.findView();
    ArrayList<Line> constructionLines = new ArrayList<Line>();
    ArrayList<Line> copyConstructionLines = new ArrayList<Line>();
    if (view == "f") {
      //Make lines go to top and right
      ConstructionLine topLine = new ConstructionLine(new Point(x, y));
      ConstructionLine rightLine = new ConstructionLine(new Point(x, y));
      topLine.finalizeLine(new Point(x, origin.y-dimensions.get(1)-spacing-dimensions.get(2)), false);
      rightLine.finalizeLine(new Point(origin.x+dimensions.get(0)+spacing+dimensions.get(2), y), false);
      constructionLines.add(topLine);
      constructionLines.add(rightLine);
    } else {
      if (view == "r") {
        ConstructionLine frontLine = new ConstructionLine(new Point(x, y));
        ConstructionLine upToDiagonal = new ConstructionLine(new Point(x, y));
        ConstructionLine otherToDiagonal = new ConstructionLine(new Point(x, origin.y-dimensions.get(1)-spacing-(x-origin.x-dimensions.get(0)-spacing)));
        frontLine.finalizeLine(new Point(origin.x, y), false);
        Point diagonalPoint = new Point(x, origin.y-dimensions.get(1)-spacing-(x-origin.x-dimensions.get(0)-spacing));
        upToDiagonal.finalizeLine(diagonalPoint, false);
        otherToDiagonal.finalizeLine(new Point(origin.x, origin.y-dimensions.get(1)-spacing-(x-origin.x-dimensions.get(0)-spacing)), false);
        constructionLines.add(frontLine);
        constructionLines.add(upToDiagonal);
        constructionLines.add(otherToDiagonal);
      } else {
        ConstructionLine frontLine = new ConstructionLine(new Point(x, y));
        ConstructionLine upToDiagonal = new ConstructionLine(new Point(x, y));
        ConstructionLine otherToDiagonal = new ConstructionLine(new Point(origin.x+dimensions.get(0)+spacing+(origin.y-dimensions.get(1)-spacing-y), y));
        frontLine.finalizeLine(new Point(x, origin.y), false);
        Point diagonalPoint = new Point(origin.x+dimensions.get(0)+spacing+(origin.y-dimensions.get(1)-spacing-y), y);
        upToDiagonal.finalizeLine(diagonalPoint, false);
        otherToDiagonal.finalizeLine(new Point(origin.x+dimensions.get(0)+spacing+(origin.y-dimensions.get(1)-spacing-y), origin.y), false);
        constructionLines.add(frontLine);
        constructionLines.add(upToDiagonal);
        constructionLines.add(otherToDiagonal);
      }
    }
    for (Line l1 : constructionLines) {
      for (Line l2 : lines) {
        if (l1.equals(l2)) {
          copyConstructionLines.add(l1);
        }
      }
    }
    for (Line l : constructionLines) {
      if (!copyConstructionLines.contains(l)) {
        points.add(new Point(l.endX, l.endY));
      }
    }
  }

  boolean equals(Point p) {
    return (round(this.x) == round(p.x)) && (round(this.y) == round(p.y));
  }

  void removeFromPoints() {
    for (Point p : points) {
      if (p.equals(this)) {
        int index = points.indexOf(p);
        if (index != -1) {
          points.remove(index);
        }
        break;
      }
    }
  }

  void addToPoints() {
    boolean contains = false;
    for (Point p : points) {
      if (p.equals(this)) {
        contains = true;
      }
    }
    if (!contains) {
      points.add(this);
    }
  }
}

class MidPoint extends Point {
  MidPoint(float x, float y) {
    super(x, y);
  }

  MidPoint(Point p1, Point p2) {
    super((p1.x+p2.x)/2, (p1.y+p2.y)/2);
  }

  boolean display(boolean highlighted) {
    if (showMidpoints) {
      float newMouseX=(1/scaleFactor)*(mouseX-400)-xTranslation+400;
      float newMouseY=(1/scaleFactor)*(mouseY-400)-yTranslation+400;
      if ((sqrt(((newMouseX-x)*(newMouseX-x))+((newMouseY-y)*(newMouseY-y))) < 30/scaleFactor && !highlighted) || this.selected) {
        strokeWeight(7);
        stroke(0, 0, 255);
        point(x, y);
        if (this.selected) {
          return false;
        } else {
          return true;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  boolean checkClick() {
    if (showMidpoints) {
      return super.checkClick();
    } else {
      return false;
    }
  }
}

class IntersectionPoint extends Point {
  IntersectionPoint(float x, float y) {
    super(x, y);
  }

  boolean display(boolean highlighted) {
    if (showIntersections) {
      float newMouseX=(1/scaleFactor)*(mouseX-400)-xTranslation+400;
      float newMouseY=(1/scaleFactor)*(mouseY-400)-yTranslation+400;
      if ((sqrt(((newMouseX-x)*(newMouseX-x))+((newMouseY-y)*(newMouseY-y))) < 30/scaleFactor && !highlighted) || this.selected) {
        strokeWeight(8.5);
        stroke(0, 255, 0);
        point(x, y);
        if (this.selected) {
          return false;
        } else {
          return true;
        }
      } else {
        strokeWeight(3);
        stroke(0);
        point(x, y);
        return false;
      }
    } else {
      return false;
    }
  }

  boolean checkClick() {
    if (showIntersections) {
      return super.checkClick();
    } else {
      return false;
    }
  }
}