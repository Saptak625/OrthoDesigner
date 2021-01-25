class Line extends DrawingShape { //<>//
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
      if (dimensionEntered && zHit) {
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

  boolean equals(Line l) {
    return (l.startX == startX && l.startY == startY && l.endX == endX && l.endY == endY) || (l.startX == endX && l.startY == endY && l.endX == startX && l.endY == startY);
  }

  void finalizeLine(Point point) {
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
    if (midpoint) {
      points.add(new MidPoint(startingPoint, point));
    }
    startingPoint.selected = false;
    selectedPoint = null;
    for (Point p : findIntersections()) {
      p.addToPoints();
    }
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

  void makeConstructionLines(Point p) {
  }

  Float[] getEquation() {
    Float m = (endY-startY)/(endX-startX);
    Float[] mAndB={m, float(-1), -(startY-(m*startX))};
    if (endX-startX == 0) {
      mAndB[0] = 1.0;
      mAndB[1] = 0.0;
      mAndB[2] = startX;
    }
    return mAndB;
  }

  Float[] getEquation(float centerX, float centerY) {
    Float[] mAndB = this.getEquation();
    mAndB[2] = mAndB[2]+centerY-(mAndB[0]*centerX);
    return mAndB;
  }

  boolean checkPointInSegment(Point p) {
    return ((this.startX <= p.x && p.x <= this.endX) || (this.endX <= p.x && p.x <= this.startX)) && ((this.startY <= p.y && p.y <= this.endY) || (this.endY <= p.y && p.y <= this.startY));
  }

  void undo() {
    lines.remove(lines.size()-1);
    startingPoint.removeFromPoints();
    Point otherPoint = new Point(endX, endY);
    otherPoint.removeFromPoints();
    Point midPoint = new MidPoint(startingPoint, otherPoint);
    midPoint.removeFromPoints();
    for (Point p : this.findIntersections()) {
      p.removeFromPoints();
    }
  }

  ArrayList<Point> findIntersections() {
    //Line-Line
    CopyOnWriteArrayList<Point> intersections = new CopyOnWriteArrayList<Point>();
    Float[] equation1 = this.getEquation();
    for (Line l2 : lines) {
      if (this.equals(l2)) {
        continue;
      }
      Float[] equation2 = l2.getEquation();
      if ((equation1[0]*equation2[1])-(equation2[0]*equation1[1]) != 0) {
        float intersectionX = ((equation1[2]*equation2[1])-(equation2[2]*equation1[1]))/((equation1[0]*equation2[1])-(equation2[0]*equation1[1]));
        float intersectionY = ((equation1[2]*equation2[0])-(equation2[2]*equation1[0]))/((equation2[0]*equation1[1])-(equation1[0]*equation2[1]));
        Point intersection = new IntersectionPoint(round(intersectionX), round(intersectionY));
        if (this.checkPointInSegment(intersection) && l2.checkPointInSegment(intersection)) {
          intersections.add(intersection);
        }
      }
    }
    
    //Line-Arc
    for (Arc arc : arcs) {
      Float[] equation2 = arc.getEquation();
      equation1=this.getEquation(equation2[0], equation2[1]);
      if((equation1[0]*equation1[0])+(equation1[1]*equation1[1]) != 0) {
        float a = (equation1[0]*equation1[0])+(equation1[1]*equation1[1]);
        float b = -2*(equation1[0]*equation1[2]);
        float c = (equation1[2]*equation1[2])-((equation1[1]*equation1[1])*(equation2[2]*equation2[2]));
        if(a != 0 && sqrt((b*b)-(4*a*c))>=0){
          float intersectionX1 = (-b+sqrt((b*b)-(4*a*c)))/(2*a);
          float intersectionX2 = (-b-sqrt((b*b)-(4*a*c)))/(2*a);
          float intersectionY1 = (equation1[2]-(equation1[0]*intersectionX1))/(equation1[1]);
          float intersectionY2 = (equation1[2]-(equation1[0]*intersectionX2))/(equation1[1]);
          Point intersection1 = new IntersectionPoint(round(intersectionX1)+equation2[0], round(intersectionY1)+equation2[1]);
          if(arc.checkPointInArc(intersection1) && this.checkPointInSegment(intersection1)){
            intersections.add(intersection1);
          }
          Point intersection2 = new IntersectionPoint(round(intersectionX2)+equation2[0], round(intersectionY2)+equation2[1]);
          if(arc.checkPointInArc(intersection2) && this.checkPointInSegment(intersection2)){
            intersections.add(intersection2);
          }
        }
      }
    }

    //Add points to final list
    ArrayList<Point> actualIntersections = new ArrayList<Point>();
    for (Point p1 : intersections) {
      boolean contains = false;
      for (Point p2 : points) {
        if (p1.equals(p2)) {
          contains = true;
        }
      }
      if (!contains) {
        actualIntersections.add(p1);
      }
    }
    return actualIntersections;
  }
}

class ConstructionLine extends Line {
  ConstructionLine(Point p) {
    super(p);
  }

  void display() {
    if (!hideConstructionLines) {
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

  void makeConstructionLines(Point p) {
    p.makeConstructionLines();
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
    if (midpoint) {
      points.add(new MidPoint(startingPoint, point));
    }
    selectedPoint = null;
    startingPoint.makeConstructionLines();
    point.makeConstructionLines();
    for (Point p : findIntersections()) {
      p.addToPoints();
    }
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
    if (midpoint) {
      points.add(new MidPoint(startingPoint, point));
    }
    selectedPoint = null;
    startingPoint.makeConstructionLines();
    point.makeConstructionLines();
    for (Point p : findIntersections()) {
      p.addToPoints();
    }
  }

  void makeConstructionLines(Point p) {
    p.makeConstructionLines();
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