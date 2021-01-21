import java.util.concurrent.CopyOnWriteArrayList;

CopyOnWriteArrayList<Point> points = new CopyOnWriteArrayList<Point>();
CopyOnWriteArrayList<Point> allIntersections = new CopyOnWriteArrayList<Point>();
Point origin = new Point(50, 750);
CopyOnWriteArrayList<Line> lines = new CopyOnWriteArrayList<Line>();
CopyOnWriteArrayList<Arc> arcs = new CopyOnWriteArrayList<Arc>();
Point selectedPoint = null;
Line currentLine = null;
Arc currentArc = null;
String shapeMode = "line";
InputBar inputBar = new InputBar();
CopyOnWriteArrayList<Float> dimensions = new CopyOnWriteArrayList<Float>();
ArrayList<DrawingShape> undoList = new ArrayList<DrawingShape>();
boolean hideConstructionLines= false;
boolean showMidpoints = true;
boolean showIntersections = true;
boolean zHit = false;
float spacing;
String lineType = "construction";
float xTranslation = 0;
float yTranslation = 0;
float scaleFactor = 1;
float scrollSpeed = 5;

void setup() {
  size(800, 800);
  background(255);
  points.add(new Point(50, 750));
}

void draw(){
  background(255);
  //BaseLines
  strokeWeight(3);
  stroke(0);
  translate(400, 400);
  scale(scaleFactor);
  translate(-400, -400);
  translate(xTranslation, yTranslation);
  line(50, 750, 50, 725);
  line(50, 750, 75, 750);
  //Dynamic Editor //<>//
  for(Line l: lines){
    l.display();
  }
  for(Arc a: arcs){
    a.display();
  }
  if(selectedPoint != null){
    if(shapeMode == "line"){
      if(currentLine == null){
        if(lineType == "visible"){
          currentLine = new VisibleLine(selectedPoint);
        }else if(lineType == "construction"){
          currentLine = new ConstructionLine(selectedPoint);
        }else if(lineType == "hidden"){
          currentLine = new HiddenLine(selectedPoint);
        }else{
          currentLine = new CenterLine(selectedPoint);
        }
      }
      currentLine.display();
    }else{
      if(currentArc == null){
        if(lineType == "visible"){
          currentArc = new VisibleArc(selectedPoint);
        }else if(lineType == "construction"){
          currentArc = new ConstructionArc(selectedPoint);
        }else if(lineType == "hidden"){
          currentArc = new HiddenArc(selectedPoint);
        }else{
          currentArc = new CenterArc(selectedPoint);
        }
      }
      currentArc.display();
    }
  }else{
    currentLine = null;
  }
  boolean highlighted = false;
  if(!hideConstructionLines){
    for(Point p: points){
      if(p.display(highlighted)){
        highlighted = true;
      }
    }
    if(showIntersections){
      for(Point p: allIntersections){
        if(p.display(highlighted)){
          highlighted = true;
        }
      }
    }
  }
  translate(-xTranslation, -yTranslation);
  translate(400, 400);
  scale(1/scaleFactor);
  translate(-400, -400);
  inputBar.display();
  String mode;
  if(lineType == "visible"){
    mode = "V";
  }else if(lineType == "construction"){
    mode = "Q";
  }else if(lineType == "hidden"){
    mode = "H";
  }else{
    mode = "C";
  }
  text(mode, 710, 790);
  text(shapeMode, 740, 790);
  translate(400, 400);
  scale(scaleFactor);
  translate(-400, -400);
  translate(xTranslation, yTranslation);
  if(zHit){
    zHit = false;
  }
  if(selectedPoint != null && (currentLine == null && currentArc == null)){
    selectedPoint.selected = false;
    selectedPoint = null;
  }
}

void mouseClicked(){
  Point previousPoint = null;
  if(selectedPoint != null){
    previousPoint = new Point(selectedPoint.x, selectedPoint.y);
  }
  if(!hideConstructionLines){
    for(Point p: points){
      boolean clicked = p.checkClick();
      if(clicked){
        break;
      }
    }
    if(showIntersections){
      for(Point p: allIntersections){
        boolean clicked = p.checkClick();
        if(clicked){
          break;
        }
      }
    }
  }
  if(selectedPoint != null && previousPoint != null){
    if(previousPoint.equals(selectedPoint)){
      //Nothing changed. Line has to be made by dimensioning.
      if(shapeMode == "line"){
        currentLine.finalizeLine();
      }
    }
  }
}

void keyReleased(){
  if(keyCode == SHIFT){
    //Snap current line
    if(currentLine != null){
      currentLine.snap = false;
    }
  }
}

void keyPressed(){
  if(keyCode == SHIFT){
    //Snap current line
    if(currentLine != null){
      currentLine.snap = true;
    }
  }else if(keyCode == UP || keyCode == DOWN || keyCode == RIGHT || keyCode == LEFT){
    if(keyCode == UP){
      yTranslation+=scrollSpeed/scaleFactor;
    }else if(keyCode == DOWN){
      yTranslation-=scrollSpeed/scaleFactor;
    }else if(keyCode == RIGHT){
      xTranslation-=scrollSpeed/scaleFactor;
    }else{
      xTranslation+=scrollSpeed/scaleFactor;
    }
  }else if(key == '=' || key == '-'){
    if(key == '='){
      scaleFactor+=0.02;
    }else{
      if(scaleFactor>0.02){
        scaleFactor-=0.02;
      }
    }
  }else{
    if(inputBar.show){
      if(keyCode == BACKSPACE){
        if(inputBar.input.length() > 0){
          inputBar.input=inputBar.input.substring(0, inputBar.input.length()-1);
        }
      }else if(keyCode == ENTER || keyCode == RETURN){
        //Submit Value.
        if(inputBar.promptText == "X: " || inputBar.promptText == "Y: " || inputBar.promptText == "Z: "){
          //If input is for dimensions
          dimensions.add(float(inputBar.input)*100);
          inputBar.input = "";
          if(inputBar.promptText == "X: "){
            //Add First Dimension.
            ConstructionLine xAxis = new ConstructionLine(origin);
            xAxis.finalizeLine(new Point(origin.x+dimensions.get(0), origin.y));
            points.add(new Point(origin.x+dimensions.get(0), origin.y));
            inputBar.promptText = "Y: ";
          }else if(inputBar.promptText == "Y: "){
            //Create two parralel y-lines
            ConstructionLine yAxis1 = new ConstructionLine(origin);
            ConstructionLine yAxis2 = new ConstructionLine(new Point(origin.x+dimensions.get(0), origin.y));
            ConstructionLine xAxis2 = new ConstructionLine(new Point(origin.x, origin.y-dimensions.get(1)));
            yAxis1.finalizeLine(new Point(origin.x, origin.y-dimensions.get(1)));
            yAxis2.finalizeLine(new Point(origin.x+dimensions.get(0), origin.y-dimensions.get(1)));
            xAxis2.finalizeLine(new Point(origin.x+dimensions.get(0), origin.y-dimensions.get(1)));
            points.add(new Point(origin.x, origin.y-dimensions.get(1)));
            points.add(new Point(origin.x+dimensions.get(0), origin.y-dimensions.get(1)));
            inputBar.promptText = "Z: ";
          }else{
            //Create two other views.
            spacing = ((dimensions.get(0)+dimensions.get(0))/2)*0.4;
            
            //Right Side View
            ConstructionLine spacer1 = new ConstructionLine(new Point(origin.x+dimensions.get(0), origin.y));
            spacer1.finalizeLine(new Point(origin.x+dimensions.get(0)+spacing, origin.y), false);
            ConstructionLine spacer2 = new ConstructionLine(new Point(origin.x+dimensions.get(0), origin.y-dimensions.get(1)));
            spacer2.finalizeLine(new Point(origin.x+dimensions.get(0)+spacing, origin.y-dimensions.get(1)), false);
            ConstructionLine zAxis1 = new ConstructionLine(new Point(origin.x+dimensions.get(0)+spacing, origin.y));
            ConstructionLine zAxis2 = new ConstructionLine(new Point(origin.x+dimensions.get(0)+spacing, origin.y-dimensions.get(1)));
            ConstructionLine yAxis1 = new ConstructionLine(new Point(origin.x+dimensions.get(0)+spacing, origin.y));
            ConstructionLine yAxis2 = new ConstructionLine(new Point(origin.x+dimensions.get(0)+spacing+dimensions.get(2), origin.y));
            zAxis1.finalizeLine(new Point(origin.x+dimensions.get(0)+spacing+dimensions.get(2), origin.y));
            zAxis2.finalizeLine(new Point(origin.x+dimensions.get(0)+spacing+dimensions.get(2), origin.y-dimensions.get(1)));
            yAxis1.finalizeLine(new Point(origin.x+dimensions.get(0)+spacing, origin.y-dimensions.get(1)));
            yAxis2.finalizeLine(new Point(origin.x+dimensions.get(0)+spacing+dimensions.get(2), origin.y-dimensions.get(1)));
            points.add(new Point(origin.x+dimensions.get(0)+spacing+dimensions.get(2), origin.y));
            points.add(new Point(origin.x+dimensions.get(0)+spacing+dimensions.get(2), origin.y-dimensions.get(1)));
            points.add(new Point(origin.x+dimensions.get(0)+spacing, origin.y-dimensions.get(1)));
            points.add(new Point(origin.x+dimensions.get(0)+spacing, origin.y));
            
            //45 degree line
            ConstructionLine diagonal = new ConstructionLine(new Point(origin.x+dimensions.get(0), origin.y-dimensions.get(1)));
            diagonal.finalizeLine(new Point(origin.x+dimensions.get(0)+spacing+dimensions.get(2), origin.y-dimensions.get(1)-spacing-dimensions.get(2)), false);
            points.add(new Point(origin.x+dimensions.get(0)+spacing+dimensions.get(2), origin.y-dimensions.get(1)-spacing-dimensions.get(2)));
            
            //Bending over Diagonal
            ConstructionLine vertical1 = new ConstructionLine(new Point(origin.x+dimensions.get(0)+spacing, origin.y-dimensions.get(1)));
            ConstructionLine vertical2 = new ConstructionLine(new Point(origin.x+dimensions.get(0)+spacing+dimensions.get(2), origin.y-dimensions.get(1)));
            vertical1.finalizeLine(new Point(origin.x+dimensions.get(0)+spacing, origin.y-dimensions.get(1)-spacing), false);
            vertical2.finalizeLine(new Point(origin.x+dimensions.get(0)+spacing+dimensions.get(2), origin.y-dimensions.get(1)-spacing-dimensions.get(2)), false);
            ConstructionLine horizontal1 = new ConstructionLine(new Point(origin.x+dimensions.get(0)+spacing, origin.y-dimensions.get(1)-spacing));
            ConstructionLine horizontal2 = new ConstructionLine(new Point(origin.x+dimensions.get(0)+spacing+dimensions.get(2), origin.y-dimensions.get(1)-spacing-dimensions.get(2)));
            horizontal1.finalizeLine(new Point(origin.x+dimensions.get(0), origin.y-dimensions.get(1)-spacing), false);
            horizontal2.finalizeLine(new Point(origin.x+dimensions.get(0), origin.y-dimensions.get(1)-spacing-dimensions.get(2)), false);
            points.add(new Point(origin.x+dimensions.get(0)+spacing, origin.y-dimensions.get(1)-spacing));
            points.add(new Point(origin.x+dimensions.get(0)+spacing+dimensions.get(2), origin.y-dimensions.get(1)-spacing-dimensions.get(2)));
            points.add(new Point(origin.x, origin.y-dimensions.get(1)-spacing));
            points.add(new Point(origin.x, origin.y-dimensions.get(1)-spacing-dimensions.get(2)));
            
            //Make Rest of Top View
            ConstructionLine spacing1 = new ConstructionLine(new Point(origin.x, origin.y-dimensions.get(1)));
            ConstructionLine spacing2 = new ConstructionLine(new Point(origin.x+dimensions.get(0), origin.y-dimensions.get(1)));
            spacing1.finalizeLine(new Point(origin.x, origin.y-dimensions.get(1)-spacing), false);
            spacing2.finalizeLine(new Point(origin.x+dimensions.get(0), origin.y-dimensions.get(1)-spacing), false);
            ConstructionLine zAxis3 = new ConstructionLine(new Point(origin.x, origin.y-dimensions.get(1)-spacing));
            ConstructionLine zAxis4 = new ConstructionLine(new Point(origin.x+dimensions.get(0), origin.y-dimensions.get(1)-spacing));
            zAxis3.finalizeLine(new Point(origin.x, origin.y-dimensions.get(1)-spacing-dimensions.get(2)));
            zAxis4.finalizeLine(new Point(origin.x+dimensions.get(0), origin.y-dimensions.get(1)-spacing-dimensions.get(2)));
            ConstructionLine xAxis3 = new ConstructionLine(new Point(origin.x+dimensions.get(0), origin.y-dimensions.get(1)-spacing-dimensions.get(2)));
            ConstructionLine xAxis4 = new ConstructionLine(new Point(origin.x+dimensions.get(0), origin.y-dimensions.get(1)-spacing));
            xAxis3.finalizeLine(new Point(origin.x, origin.y-dimensions.get(1)-spacing-dimensions.get(2)));
            xAxis4.finalizeLine(new Point(origin.x, origin.y-dimensions.get(1)-spacing));
            points.add(new Point(origin.x+dimensions.get(0), origin.y-dimensions.get(1)-spacing));
            points.add(new Point(origin.x+dimensions.get(0), origin.y-dimensions.get(1)-spacing-dimensions.get(2)));
            inputBar.show = false;
          }
        }else if(inputBar.promptText == "Dimension: "){
          //Finalization with Dimension
          float oldValue=sqrt((currentLine.endX-currentLine.startX)*(currentLine.endX-currentLine.startX)+(currentLine.endY-currentLine.startY)*(currentLine.endY-currentLine.startY))/100.0;
          float newValue=float(inputBar.input);
          currentLine.endX=((currentLine.endX-currentLine.startX)*(newValue/oldValue))+currentLine.startX;
          currentLine.endY=((currentLine.endY-currentLine.startY)*(newValue/oldValue))+currentLine.startY;
          Point newPoint = new Point(currentLine.endX, currentLine.endY);
          if(lineType == "visible"){
            currentLine.startingPoint.makeConstructionLines();
            newPoint.makeConstructionLines();
          }
          points.add(newPoint);
          points.add(new MidPoint(currentLine.startingPoint, newPoint));
          selectedPoint=null;
          lines.add(currentLine);
          currentLine.dimensionEntered = true;
          currentLine.startingPoint.selected = false;
          currentLine=null;
          inputBar.promptText = "";
          inputBar.input = "";
          inputBar.show = false;
          findIntersections();
        }
      }else{
        inputBar.input+=key;
      }
    }else{
      String previousLineType = lineType;
      if(key == 'v'){
        lineType = "visible";
      }else if(key == 'q'){
        lineType = "construction";
      }else if(key == 'h'){
        lineType = "hidden";
      }else if(key == 'c'){
        lineType = "center";
      }else if(key == 'm'){
        showMidpoints = !showMidpoints;
      }else if(key == 'f' && currentArc != null){
        if(currentArc.fixedRadius && !currentArc.fixedArc){
          currentArc.flipDirection();
        }
      }else if(key == 'l'){
        shapeMode = "line";
        currentArc = null;
        if(selectedPoint != null){
          selectedPoint.selected = false;
        }
        selectedPoint = null;
      }else if(key == 'a'){
        shapeMode = "arc";
        currentLine = null;
        if(selectedPoint != null){
          selectedPoint.selected = false;
        }
        selectedPoint = null;
      }else if(key == 'o'){
        hideConstructionLines = !hideConstructionLines;
      }else if(key == 'z'){
        if(undoList.size() != 0){
          undoList.get(undoList.size()-1).undo();
          undoList.remove(undoList.size()-1);
          zHit = true;
        }
      }else if(key == 'i'){
        showIntersections= !showIntersections;
      }
      if(shapeMode == "line"){
        if(currentLine != null && lineType != previousLineType){
          if(key == 'v'){
            currentLine=new VisibleLine(currentLine.startingPoint);
          }else if(key == 'q'){
            currentLine=new ConstructionLine(currentLine.startingPoint);
          }else if(key == 'h'){
            currentLine=new HiddenLine(currentLine.startingPoint);
          }else if(key == 'c'){
            currentLine=new CenterLine(currentLine.startingPoint);
          }
        }
      }else{
        if(currentArc != null && lineType != previousLineType){
          if(key == 'v'){
            Arc temporaryArc=new VisibleArc(currentArc.points.get(0));
            temporaryArc.fixedRadius = currentArc.fixedRadius;
            temporaryArc.fixedArc = currentArc.fixedArc;
            temporaryArc.radius = currentArc.radius;
            temporaryArc.centerX = currentArc.centerX;
            temporaryArc.centerY = currentArc.centerY;
            temporaryArc.angleStart = currentArc.angleStart;
            temporaryArc.angleEnd = currentArc.angleEnd;
            temporaryArc.clockwise = currentArc.clockwise;
            temporaryArc.points = currentArc.points;
            currentArc = temporaryArc;
          }else if(key == 'q'){
            Arc temporaryArc=new ConstructionArc(currentArc.points.get(0));
            temporaryArc.fixedRadius = currentArc.fixedRadius;
            temporaryArc.fixedArc = currentArc.fixedArc;
            temporaryArc.radius = currentArc.radius;
            temporaryArc.centerX = currentArc.centerX;
            temporaryArc.centerY = currentArc.centerY;
            temporaryArc.angleStart = currentArc.angleStart;
            temporaryArc.angleEnd = currentArc.angleEnd;
            temporaryArc.clockwise = currentArc.clockwise;
            temporaryArc.points = currentArc.points;
            currentArc = temporaryArc;
          }else if(key == 'h'){
            Arc temporaryArc=new HiddenArc(currentArc.points.get(0));
            temporaryArc.fixedRadius = currentArc.fixedRadius;
            temporaryArc.fixedArc = currentArc.fixedArc;
            temporaryArc.radius = currentArc.radius;
            temporaryArc.centerX = currentArc.centerX;
            temporaryArc.centerY = currentArc.centerY;
            temporaryArc.angleStart = currentArc.angleStart;
            temporaryArc.angleEnd = currentArc.angleEnd;
            temporaryArc.clockwise = currentArc.clockwise;
            temporaryArc.points = currentArc.points;
            currentArc = temporaryArc;
          }else if(key == 'c'){
            Arc temporaryArc=new CenterArc(currentArc.points.get(0));
            temporaryArc.fixedRadius = currentArc.fixedRadius;
            temporaryArc.fixedArc = currentArc.fixedArc;
            temporaryArc.radius = currentArc.radius;
            temporaryArc.centerX = currentArc.centerX;
            temporaryArc.centerY = currentArc.centerY;
            temporaryArc.angleStart = currentArc.angleStart;
            temporaryArc.angleEnd = currentArc.angleEnd;
            temporaryArc.clockwise = currentArc.clockwise;
            temporaryArc.points = currentArc.points;
            currentArc = temporaryArc;
          }
        }
      }
    }
  }
}

void findIntersections(){
  /*
  //Line-Line
  CopyOnWriteArrayList<Point> intersections = new CopyOnWriteArrayList<Point>();
  for(Line l1: lines){
    Float[] equation1 = l1.getEquation();
    for(Line l2: lines){
      if(l1.equals(l2)){
        continue;
      }
      Float[] equation2 = l2.getEquation();
      if((equation1[0]*equation2[1])-(equation2[0]*equation1[1]) != 0){
        float intersectionX = ((equation1[2]*equation2[1])-(equation2[2]*equation1[1]))/((equation1[0]*equation2[1])-(equation2[0]*equation1[1]));
        float intersectionY = ((equation1[2]*equation2[0])-(equation2[2]*equation1[0]))/((equation2[0]*equation1[1])-(equation1[0]*equation2[1]));
        Point intersection = new IntersectionPoint(round(intersectionX), round(intersectionY));
        if(l1.checkPointInSegment(intersection) && l2.checkPointInSegment(intersection)){
          intersections.add(intersection);
        }
      }
    }
  }
  
  //Add points to final list
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
      allIntersections.add(p1);
    }
  }*/
}