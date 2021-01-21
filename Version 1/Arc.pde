class Arc extends DrawingShape {
  boolean fixedRadius;
  boolean fixedArc;
  float radius;
  float centerX;
  float centerY;
  float angleStart;
  float angleEnd;
  boolean clockwise;
  ArrayList<Point> points = new ArrayList<Point>();

  Arc(Point center) {
    fixedRadius = false;
    fixedArc = false;
    centerX = center.x;
    centerY = center.y;
    clockwise = true;
    this.points.add(center);
  }

  void display() {
    if (!fixedRadius && !fixedArc) {
      float newMouseX=(1/scaleFactor)*(mouseX-400)-xTranslation+400;
      float newMouseY=(1/scaleFactor)*(mouseY-400)-yTranslation+400;
      radius = sqrt((newMouseX-centerX)*(newMouseX-centerX)+(newMouseY-centerY)*(newMouseY-centerY));
      arc(centerX, centerY, radius*2, radius*2, radians(0), radians(360));
    } else if (!fixedArc) {
      float newMouseX=(1/scaleFactor)*(mouseX-400)-xTranslation+400;
      float newMouseY=(1/scaleFactor)*(mouseY-400)-yTranslation+400;
      translate(centerX, centerY);
      angleStart = atan2(points.get(1).y-centerY, points.get(1).x-centerX);
      if (angleStart < 0) {
        angleStart+=radians(360);
      }
      float mouseAngle = atan2(newMouseY-centerY, newMouseX-centerX);
      if (mouseAngle < 0) {
        mouseAngle+=radians(360);
      }
      mouseAngle+=radians(360);
      if (mouseAngle > angleStart+radians(360)) {
        mouseAngle -= radians(360);
      }
      translate(-centerX, -centerY);
      if (!clockwise) {
        if (mouseAngle>=radians(360)) {
          mouseAngle-=radians(360);
        } else {
          angleStart+=radians(360);
        }
        float temporary = angleStart;
        angleStart = mouseAngle;
        mouseAngle = temporary;
      }
      arc(centerX, centerY, radius*2, radius*2, angleStart, mouseAngle);
    } else {
      if(zHit){
        for(Point p: this.points){
          p.addToPoints();
        }
      }
      arc(centerX, centerY, radius*2, radius*2, angleStart, angleEnd);
    }
  }

  void finalizeRadius(Point point) {
    radius = sqrt((point.x-centerX)*(point.x-centerX)+(point.y-centerY)*(point.y-centerY));
    this.points.add(point);
    fixedRadius = true;
  }

  void finalizeArc(Point point) {
    fixedArc = true;
    float newMouseX=point.x;
    float newMouseY=point.y;
    translate(centerX, centerY);
    angleStart = atan2(points.get(1).y-centerY, points.get(1).x-centerX);
    if (angleStart < 0) {
      angleStart+=radians(360);
    }
    angleEnd = atan2(newMouseY-centerY, newMouseX-centerX);
    if (angleEnd < 0) {
      angleEnd+=radians(360);
    }
    angleEnd+=radians(360);
    if (angleEnd > angleStart+radians(360)) {
      angleEnd -= radians(360);
    }
    translate(-centerX, -centerY);
    if (!clockwise) {
      if (angleEnd>=radians(360)) {
        angleEnd-=radians(360);
      } else {
        angleStart+=radians(360);
      }
      float temporary = angleStart;
      angleStart = angleEnd;
      angleEnd = temporary;
    }
    this.points.add(point);
    arcs.add(this);
    undoList.add(this);
    for (Point p : this.points) {
      p.selected = false;
    }
    selectedPoint = null;
    selectedPoint = null;
    currentArc = null;
  }

  void flipDirection() {
    clockwise = !clockwise;
  }
  
  void undo() {
    arcs.remove(arcs.size()-1);
    for(Point p: this.points){
      p.removeFromPoints();
    }
  }
}

class ConstructionArc extends Arc {
  ConstructionArc(Point center) {
    super(center);
  }

  void display() {
    if(!hideConstructionLines){
      noFill();
      stroke(100, 100, 100);
      strokeWeight(0.5);
      super.display();
    }
  }
}

class VisibleArc extends Arc {
  VisibleArc(Point center) {
    super(center);
  }

  void display() {
    noFill();
    stroke(0);
    strokeWeight(3);
    super.display();
  }

  void finalizeArc(Point point) {
    super.finalizeArc(point);
    //Get all points for making construction lines.
    ArrayList<Point> terminalPoints = new ArrayList<Point>();
    terminalPoints.add(new Point(centerX+radius, centerY));
    terminalPoints.add(new Point(centerX, centerY+radius));
    terminalPoints.add(new Point(centerX-radius, centerY));
    terminalPoints.add(new Point(centerX, centerY-radius));
    for (int i=0; i<4; i++) {
      float angle = radians(90)*i;
      if ((angleStart <= angle && angle <= angleEnd) || (angleStart <= angle+radians(360) && angle+radians(360) <= angleEnd)) {
        //angle-=radians(360);
        angle=degrees(angle);
        Point checkPoint = terminalPoints.get(int(angle/90));
        if(checkPoint.x == centerX || checkPoint.y == centerY){
          boolean contains = false;
          for(Point p: this.points){
            if(p.equals(checkPoint)){
              contains = true;
            }
          }
          if(!contains){
            this.points.add(checkPoint);
          }
        }
      }
    }
    for (Point otherPoints : this.points) {
      otherPoints.makeConstructionLines();
    }
  }
}

class HiddenArc extends Arc {
  HiddenArc(Point center) {
    super(center);
  }

  void display() {
    noFill();
    stroke(0, 255, 0);
    strokeWeight(2);
    super.display();
  }
  
  void finalizeArc(Point point) {
    super.finalizeArc(point);
    //Get all points for making construction lines.
    ArrayList<Point> terminalPoints = new ArrayList<Point>();
    terminalPoints.add(new Point(centerX+radius, centerY));
    terminalPoints.add(new Point(centerX, centerY+radius));
    terminalPoints.add(new Point(centerX-radius, centerY));
    terminalPoints.add(new Point(centerX, centerY-radius));
    for (int i=0; i<4; i++) {
      float angle = radians(90)*i;
      if ((angleStart <= angle && angle <= angleEnd) || (angleStart <= angle+radians(360) && angle+radians(360) <= angleEnd)) {
        //angle-=radians(360);
        angle=degrees(angle);
        Point checkPoint = terminalPoints.get(int(angle/90));
        if(checkPoint.x == centerX || checkPoint.y == centerY){
          boolean contains = false;
          for(Point p: this.points){
            if(p.equals(checkPoint)){
              contains = true;
            }
          }
          if(!contains){
            this.points.add(checkPoint);
          }
        }
      }
    }
    for (Point otherPoints : this.points) {
      otherPoints.makeConstructionLines();
    }
  }
}

class CenterArc extends Arc {
  CenterArc(Point center) {
    super(center);
  }

  void display() {
    noFill();
    stroke(255, 0, 0);
    strokeWeight(2);
    super.display();
  }
  
  void finalizeArc(Point point) {
    super.finalizeArc(point);
    //Get all points for making construction lines.
    ArrayList<Point> terminalPoints = new ArrayList<Point>();
    terminalPoints.add(new Point(centerX+radius, centerY));
    terminalPoints.add(new Point(centerX, centerY+radius));
    terminalPoints.add(new Point(centerX-radius, centerY));
    terminalPoints.add(new Point(centerX, centerY-radius));
    for (int i=0; i<4; i++) {
      float angle = radians(90)*i;
      if ((angleStart <= angle && angle <= angleEnd) || (angleStart <= angle+radians(360) && angle+radians(360) <= angleEnd)) {
        //angle-=radians(360);
        angle=degrees(angle);
        Point checkPoint = terminalPoints.get(int(angle/90));
        if(checkPoint.x == centerX || checkPoint.y == centerY){
          boolean contains = false;
          for(Point p: this.points){
            if(p.equals(checkPoint)){
              contains = true;
            }
          }
          if(!contains){
            this.points.add(checkPoint);
          }
        }
      }
    }
    for (Point otherPoints : this.points) {
      otherPoints.makeConstructionLines();
    }
  }
}