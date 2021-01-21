class Line extends DrawingShape{ //<>//
  Point startingPoint;
  float startX;
  float startY;
  float endX;
  float endY;
  boolean fixed;
  boolean snap;
  boolean dimensionEntered;

  Line(Point point) {
    this.startX=point.x;
    this.startY=point.y;
    this.endX=mouseX;
    this.endY=mouseY;
    this.fixed = false;
    this.snap = false;
    this.startingPoint = point;
    this.dimensionEntered = true;
  }

  void display() {
    if (this.fixed) {
      if(dimensionEntered && zHit){
        startingPoint.addToPoints();
        Point otherPoint = new Point(endX, endY);
        otherPoint.addToPoints();
        Point midPoint = new MidPoint(startingPoint, otherPoint);
        midPoint.addToPoints();
      }
      //Line is already defined. Just show a line.
      line(startX, startY, endX, endY);
    } else {
      //Line needs second point to be defined.
      float newMouseX=(1/scaleFactor)*(mouseX-400)-xTranslation+400;
      float newMouseY=(1/scaleFactor)*(mouseY-400)-yTranslation+400;
      if (this.snap) {
        if (newMouseX-startX != 0) {
          if (-(newMouseY-startY)/( newMouseX-startX ) >= 1 || -(newMouseY-startY)/( newMouseX-startX ) <= -1) {
            line(startX, startY, startX, newMouseY);
          } else {
            line(startX, startY, newMouseX, startY);
          }
        } else {
          line(startX, startY, startX, newMouseY);
        }
      } else {
        line(startX, startY, newMouseX, newMouseY);
      }
    }
  }
  
  boolean equals(Line l){
    return (l.startX == startX && l.startY == startY && l.endX == endX && l.endY == endY) || (l.startX == endX && l.startY == endY && l.endX == startX && l.endY == startY);
  }
  
  void finalizeLine(Point point){
    this.finalizeLine(point, true);
  }

  void finalizeLine(Point point, boolean midpoint) {
    fixed=true;
    endX=point.x;
    endY=point.y;
    selectedPoint=null;
    if (this == currentLine) {
      lines.add(currentLine);
      undoList.add(currentLine);
      currentLine=null;
    } else {
      lines.add(this);
      undoList.add(this);
    }
    startingPoint.selected = false;
    point.selected = false;
    if(midpoint){
      points.add(new MidPoint(startingPoint, point));
    }
    startingPoint.selected = false;
    selectedPoint = null;
    findIntersections();
  }

  void finalizeLine() {
    float newMouseX=(1/scaleFactor)*(mouseX-400)-xTranslation+400;
    float newMouseY=(1/scaleFactor)*(mouseY-400)-yTranslation+400;
    if (this.snap) {
      if (newMouseX-startX != 0) {
        if (-(newMouseY-startY)/( newMouseX-startX ) >= 1 || -(newMouseY-startY)/( newMouseX-startX ) <= -1) {
          endX=startX;
          endY=newMouseY;
        } else {
          endX=newMouseX;
          endY=startY;
        }
      } else {
        endX=startX;
        endY=newMouseY;
      }
    } else {
      endX=newMouseX;
      endY=newMouseY;
    }
    inputBar.show = true;
    inputBar.promptText = "Dimension: ";
    inputBar.input = "";
    inputBar.input += round(sqrt((endX-startX)*(endX-startX)+(endY-startY)*(endY-startY)))/100.0;
    fixed=true;
    dimensionEntered = false;
  }

  Float[] getEquation() {
    Float m = (endY-startY)/(endX-startX);
    Float[] mAndB={m, float(-1), -(startY-(m*startX))};
    if(endX-startX == 0){
      mAndB[0] = 1.0;
      mAndB[1] = 0.0;
      mAndB[2] = startX;
    }
    return mAndB;
  }
  
  boolean checkPointInSegment(Point p){
    return (this.startX <= p.x && p.x <= this.endX) || (this.endX <= p.x && p.x <= this.startX);
  }
  
  void undo() {
    lines.remove(lines.size()-1);
    startingPoint.removeFromPoints();
    Point otherPoint = new Point(endX, endY);
    otherPoint.removeFromPoints();
    Point midPoint = new MidPoint(startingPoint, otherPoint);
    midPoint.removeFromPoints();
  }
}

class ConstructionLine extends Line {
  ConstructionLine(Point p) {
    super(p);
  }

  void display() {
    if(!hideConstructionLines){
      stroke(100, 100, 100);
      strokeWeight(0.5);
      super.display();
    }
  }
}

class VisibleLine extends Line {
  VisibleLine(Point p) {
    super(p);
  }

  void display() {
    stroke(0);
    strokeWeight(3);
    super.display();
  }
  
  void finalizeLine(Point point, boolean midpoint) {
    fixed=true;
    endX=point.x;
    endY=point.y;
    selectedPoint=null;
    if (this == currentLine) {
      lines.add(currentLine);
      undoList.add(currentLine);
      currentLine=null;
    } else {
      lines.add(this);
      undoList.add(this);
    }
    startingPoint.selected = false;
    point.selected = false;
    if(midpoint){
      points.add(new MidPoint(startingPoint, point));
    }
    selectedPoint = null;
    print("Executing");
    startingPoint.makeConstructionLines();
    point.makeConstructionLines();
    findIntersections(); //<>//
  }
}

class HiddenLine extends Line {
  HiddenLine(Point p) {
    super(p);
  }

  void display() {
    stroke(0, 255, 0);
    strokeWeight(2);
    super.display();
  }
  
  void finalizeLine(Point point, boolean midpoint) {
    fixed=true;
    endX=point.x;
    endY=point.y;
    selectedPoint=null;
    if (this == currentLine) {
      lines.add(currentLine);
      undoList.add(currentLine);
      currentLine=null;
    } else {
      lines.add(this);
      undoList.add(this);
    }
    startingPoint.selected = false;
    point.selected = false;
    if(midpoint){
      points.add(new MidPoint(startingPoint, point));
    }
    selectedPoint = null;
    startingPoint.makeConstructionLines();
    point.makeConstructionLines();
    findIntersections(); //<>//
  }
}

class CenterLine extends Line {
  CenterLine(Point p) {
    super(p);
  }

  void display() {
    stroke(255, 0, 0);
    strokeWeight(2);
    super.display();
  }
}