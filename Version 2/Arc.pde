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
    for (Point p : findIntersections()) {
      p.addToPoints();
    }
    selectedPoint = null;
    selectedPoint = null;
    currentArc = null;
  }

  void flipDirection() {
    clockwise = !clockwise;
  }
  
  Float[] getEquation() {
    Float[] circleEquation={centerX, centerY, radius};
    return circleEquation;
  }
  
  Float[] getEquation(float centerOfX, float centerOfY) {
    Float[] circleEquation={centerX-centerOfX, centerY-centerOfY, radius};
    return circleEquation;
  }
  
  ArrayList<Point> findIntersections(){
    CopyOnWriteArrayList<Point> intersections = new CopyOnWriteArrayList<Point>();
    //Arc-Line
    for (Line line : lines) {
      Float[] equation2 = this.getEquation();
      Float[] equation1=line.getEquation(equation2[0], equation2[1]);
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
          if(this.checkPointInArc(intersection1) && line.checkPointInSegment(intersection1)){
            intersections.add(intersection1);
          }
          Point intersection2 = new IntersectionPoint(round(intersectionX2)+equation2[0], round(intersectionY2)+equation2[1]);
          if(this.checkPointInArc(intersection2) && line.checkPointInSegment(intersection2)){
            intersections.add(intersection2);
          }
        }
      }
    }
    //Arc-Arc
    Float[] equation1 = this.getEquation();
    for (Arc arc : arcs) {
      if(this == arc) {
        continue;
      }
      Float[] equation2 = arc.getEquation(equation1[0], equation1[1]);
      if((equation1[0]*equation1[0])+(equation1[1]*equation1[1]) != 0) {
        float bigA = (equation2[0]*equation2[0])+(equation1[2]*equation1[2])+(equation2[1]*equation2[1])-(equation2[2]*equation2[2]);
        float a = 4*((equation2[0]*equation2[0])+(equation2[1]*equation2[1]));
        float b = -4*equation2[0]*bigA;
        float c = (bigA*bigA)-(4*equation1[2]*equation1[2]*equation2[1]*equation2[1]);
        if(a != 0 && sqrt((b*b)-(4*a*c))>=0){
          float intersectionX1 = (-b+sqrt((b*b)-(4*a*c)))/(2*a);
          float intersectionX2 = (-b-sqrt((b*b)-(4*a*c)))/(2*a);
          float intersectionY11 = sqrt((equation1[2]*equation1[2])-(intersectionX1*intersectionX1));
          float intersectionY12 = -intersectionY11;
          float intersectionY21 = sqrt((equation1[2]*equation1[2])-(intersectionX2*intersectionX2));
          float intersectionY22 = -intersectionY21;
          Point intersection1 = new IntersectionPoint(round(intersectionX1)+equation1[0], round(intersectionY11)+equation1[1]);
          if(this.checkPointInArc(intersection1) && arc.checkPointInArc(intersection1)){
            intersections.add(intersection1);
          }
          Point intersection2 = new IntersectionPoint(round(intersectionX1)+equation1[0], round(intersectionY12)+equation1[1]);
          if(this.checkPointInArc(intersection2) && arc.checkPointInArc(intersection2)){
            intersections.add(intersection2);
          }
          Point intersection3 = new IntersectionPoint(round(intersectionX2)+equation1[0], round(intersectionY21)+equation1[1]);
          if(this.checkPointInArc(intersection3) && arc.checkPointInArc(intersection3)){
            intersections.add(intersection3);
          }
          Point intersection4 = new IntersectionPoint(round(intersectionX2)+equation1[0], round(intersectionY22)+equation1[1]);
          if(this.checkPointInArc(intersection4) && arc.checkPointInArc(intersection4)){
            intersections.add(intersection4);
          }
        }
      }
    }
    
    //Add points to final list
    ArrayList<Point> actualIntersections = new ArrayList<Point>();
    for(Point p1: intersections){
      boolean contains = false;
      for(Point p2: points){
        if(p1.equals(p2)){
          contains = true;
        }
      }
      for(Point p2: allIntersections){
        if(p1.equals(p2)){
          contains = true;
        }
      }
      if(!contains){
        actualIntersections.add(p1);
      }
    }
    return actualIntersections;
  }
  
  void undo() {
    arcs.remove(arcs.size()-1);
    for(Point p: this.points){
      p.removeFromPoints();
    }
  }
  
  boolean checkPointInArc(Point p){
    if(round(radius) == round(sqrt(((p.x-centerX)*(p.x-centerX))+((p.y-centerY)*(p.y-centerY))))){
      float angleFromPoint = atan2(p.y-centerY, p.x-centerX);
      if(angleFromPoint<0){
        angleFromPoint += radians(360);
      }
      if(angleStart <= angleFromPoint && angleFromPoint <= angleEnd){
        return true;
      }else{
        if(angleStart <= angleFromPoint+radians(360) && angleFromPoint+radians(360) <= angleEnd){
          return true;
        }else{
          return false;
        }
      }
    }else{
      return false;
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
    for (Point p : findIntersections()) {
      p.addToPoints();
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
    for (Point p : findIntersections()) {
      p.addToPoints();
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
    for (Point p : findIntersections()) {
      p.addToPoints();
    }
    for (Point otherPoints : this.points) {
      otherPoints.makeConstructionLines();
    }
  }
}