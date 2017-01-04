Chain[] A = new Chain[5];
float dt = 0.1;
boolean unClicked = true;
PVector clicked = new PVector(-1,-1);

boolean showSkelly = true;

void setup() {
    size(500,400);

    A[0] = new Chain(color(0,255,255), new PVector(150,100));
    A[1] = new Chain(color(255,0,0), new PVector(200,100));
    A[2] = new Chain(color(0,255,0), new PVector(250,100)); 
    A[3] = new Chain(color(255,0,255), new PVector(300,100));
    A[4] = new Chain(color(190,74,0), new PVector(350,100));
}


void draw() {
    background(255);
    
    stroke(0);strokeWeight(8);noFill();
    line(75,325,100,100);  line(400,100,425,325);
    
    if(mousePressed && unClicked) {
        clicked = findClicked(A, mouseX, mouseY);  //clicked.x is chain index, clicked.y is link index
    }    
    
    if(mousePressed) {
        A[int(clicked.x)].L[int(clicked.y)].Pull(mouseX, mouseY);
    }    
    
    collideBalls(A); 
     
    for(int n=0; n<A.length; n++) {        
      A[n].Update();
      A[n].Move();
      A[n].Draw();
    }
    
    mouseWheel();
    
    
    if(showSkelly) {
      for(int m=0; m<A.length; m++) {
        for(int n=0; n<A[m].L.length; n++) {
          A[m].L[n].DrawOld();
        }
      }
    }
    
    stroke(0);strokeWeight(8);noFill();
    line(50,350,100,100);  line(100,100,400,100); line(400,100,450,350);
    line(50,350,100,100);  line(400,100,450,350);
    text(dt,25,25);
}








class Chain {
  Link[] L = new Link[3];
  color c = color(255, 0, 0);
  float len = 50;
  Ball B;
  
  Chain(color cc, PVector p) {
    c = cc;
    
    L[0] = new Link(p.x, p.y, len);
    for(int n=1; n<L.length; n++) {
      L[n] = new Link(L[n-1]);
    }
    
    B = new Ball(L[2]);
    L[2].addBall(B);
  }
  
  void Update() {
    for(int n=0; n<L.length; n++) {
      L[n].CalcForces();
    }
  }
  
  void Move() {
    for(int n=0; n<L.length; n++) {
      L[n].Move();
    }
    
    if(L[2].B != null) {
      L[2].B.Update();
    }
  }
  
  void Draw() {
    stroke(c); strokeWeight(5); noFill();
    beginShape();
      vertex(L[0].anchorX, L[0].anchorY);
      bezierVertex(L[0].px,L[0].py,L[1].px,L[1].py,L[2].px,L[2].py);
    endShape();
    
    if(L[2].B != null) {
      L[2].B.Draw();
    }
  }
  
  
}



class Ball {
  float px, py, ax, ay, vx, vy;
  float R = 20;
  Link L;
  
  Ball(Link ll) {
    L = ll;
    px = L.px; py = L.py;
    R = 25; //random(15)+10;
  }
  
  void Update() {
    px = L.px; py = L.py; 
  }
  
  void Draw() {
    stroke(0); strokeWeight(2); fill(190,120,145);
    ellipse(px,py,2*R,2*R);
  }
  
}



class Link {
  float anchorX, anchorY;
  float px, py;
  float vx, vy, ax, ay;
  float L, D, rx, ry, rpx, rpy;
  float cs = 5;
  float cv = 0.5;
  float tx, ty;
  Ball B;
  
  Link next, prev;
  
  Link(float x, float y, float ll) {
    anchorX = x;
    anchorY = y;
    
    L = ll;
    
    px = anchorX; py = anchorY + ll;
  }
  
  Link(Link L0) {
    prev = L0;
    prev.connectToNext(this);
    
    L = prev.L;
    px = prev.px;
    py = prev.py + L;
  }
  
  
  Link(Link L0, float x, float y) {
    prev = L0;
    prev.connectToNext(this);
    
    px = x; py = y;
    
    float rx = px-prev.px;
    float ry = py-prev.py;
    
    L = sqrt(rx*rx + ry*ry);
  }
  
  void Pull(float X, float Y) {

       float rx = px-X;
       float ry = py-Y;
       float r = sqrt(rx*rx + ry*ry);
       float urx = rx/r; float ury = ry/r;
       
       ax = ax - 3*r*urx - 0.5*vx;
       ay = ay - 3*r*ury - 0.5*vy;
       
  }
  
  void CalcForces() {
    ax = ax + 0.0*randomGaussian() - 0.001*vx; 
    ay = ay + 0.0*randomGaussian() - 0.001*vy + 0.2*L;
    
    if(prev != null) {
       float rx = px-prev.px;
       float ry = py-prev.py;
       float r = sqrt(rx*rx + ry*ry);
       float urx = rx/r; float ury = ry/r;
       
       float vpar = vx*urx + vy*ury;
       
       ax = ax + cs*(L-r)*urx;
       ay = ay + cs*(L-r)*ury;
       
       ax = ax - cv*vpar*urx;
       ay = ay - cv*vpar*ury;
       
    } else {
       float rx = px-anchorX;
       float ry = py-anchorY;
       float r = sqrt(rx*rx + ry*ry);
       float urx = rx/r; float ury = ry/r;
       
       float vpar = vx*urx + vy*ury;
       
       ax = ax + cs*(L-r)*urx;
       ay = ay + cs*(L-r)*ury;
       
       ax = ax - cv*vpar*urx;
       ay = ay - cv*vpar*ury;
    }
    
    
    if(next != null) {
       float rx = px-next.px;
       float ry = py-next.py;
       float r = sqrt(rx*rx + ry*ry);
       float urx = rx/r; float ury = ry/r;
       
       float vpar = vx*urx + vy*ury;
       
       ax = ax + cs*(L-r)*urx;
       ay = ay + cs*(L-r)*ury;
       
       ax = ax - cv*vpar*urx;
       ay = ay - cv*vpar*ury;
       
    } else {
       //ay = ay + 35;
    }
    
    if(B != null) {
      ay = ay + 5;
    }
    
  }
  
  void Move() {
    vx = vx + dt*ax; vy = vy + dt*ay;
    px = px + dt*vx; py = py + dt*vy; 
    
    if(prev != null && next != null) {
       tx = next.px - prev.px; ty = next.py - prev.py;
       float tt = sqrt(tx*tx + ty*ty);
       tx = tx/tt; ty = ty/tt;
    } else if(prev==null) {
       tx = next.px - anchorX; ty = next.py - anchorY;
       float tt = sqrt(tx*tx + ty*ty);
       tx = tx/tt; ty = ty/tt;
    } else if(next==null) {
       tx = px - prev.px; ty = py - prev.py;
       float tt = sqrt(tx*tx + ty*ty);
       tx = tx/tt; ty = ty/tt;
    }
    
    ax = 0; ay = 0;
  }
  
  
  void Draw() {
    if(prev == null && next !=null) {
      float[] ppx = {anchorX,px,px,next.px};
      float[] ppy = {anchorY,py,py,next.py};
      
      bezier(ppx[0],ppy[0],ppx[1],ppy[1],ppx[2],ppy[2],ppx[3],ppy[3]);
    } else if(prev != null && next !=null) {
      float[] ppx = {prev.px,px,px,next.px};
      float[] ppy = {prev.py,py,py,next.py};
      
      bezier(ppx[0],ppy[0],ppx[1],ppy[1],ppx[2],ppy[2],ppx[3],ppy[3]);
    }
  }
  
  
  void DrawOld() {
    if(prev == null) {
      stroke(128); strokeWeight(1);
      line(anchorX, anchorY, px, py);
      
      strokeWeight(3);
      point(anchorX, anchorY);
      point(px, py);
    } else {
      stroke(128); strokeWeight(1);
      line(prev.px, prev.py, px, py);
      
      strokeWeight(3);
      point(px, py);
    }
  }
  
  void connectToNext(Link L2) {
     next = L2;
  }
  
  void addBall(Ball bb) {
    B = bb;
  }
  
  
}


void mouseReleased() {
  unClicked = true;
}



void collideBalls(Chain[] C) {
   for(int m=0; m<C.length; m++) {
     for(int n=0; n<C.length; n++) {
       if(m>n) {
         float dist2 = pow(C[m].L[2].px - C[n].L[2].px,2) + pow(C[m].L[2].py - C[n].L[2].py,2); 
         
         float rx = C[m].L[2].px - C[n].L[2].px;
         float ry = C[m].L[2].py - C[n].L[2].py;
         float rr = sqrt(rx*rx + ry*ry);
         rx = rx/rr; ry = ry/rr;
         
         float dvx = C[m].L[2].vx - C[n].L[2].vx;
         float dvy = C[m].L[2].vy - C[n].L[2].vy;
         
         float vdot = dvx*rx + dvy*ry;
        
         
         
         if(dist2 < pow(C[m].L[2].B.R + C[n].L[2].B.R,2) && vdot<0) {   //Collision--handle it:
         
         //Thanks, http://www.real-world-physics-problems.com/elastic-collision.html !
           float vmix = C[m].L[2].vx, vmiy = C[m].L[2].vy;
           float vnix = C[n].L[2].vx, vniy = C[n].L[2].vy;
           
           float mm = pow(C[m].L[2].B.R,3), mn = pow(C[n].L[2].B.R,3);
           
           float vmfx = (mm-mn)/(mm+mn)*vmix + 2*mn/(mm+mn)*vnix;
           float vmfy = (mm-mn)/(mm+mn)*vmiy + 2*mn/(mm+mn)*vniy;
           
           float vnfx = 2*mm/(mm+mn)*vmix + (mn-mm)/(mm+mn)*vnix;
           float vnfy = 2*mm/(mm+mn)*vmiy + (mn-mm)/(mm+mn)*vniy;
           
           C[m].L[2].vx = vmfx; C[m].L[2].vy = vmfy;
           C[n].L[2].vx = vnfx; C[n].L[2].vy = vnfy;
           
         } else if(dist2 < pow(C[m].L[2].B.R + C[n].L[2].B.R,2)) {
           C[m].L[2].ax = C[m].L[2].ax + 100*50/(50+rr)*rx;
           C[m].L[2].ay = C[m].L[2].ay + 100*50/(50+rr)*ry;
           
           C[n].L[2].ax = C[n].L[2].ax - 100*50/(50+rr)*rx;
           C[n].L[2].ay = C[n].L[2].ay - 100*50/(50+rr)*ry;
         }
         
       }
     } 
   }
}



PVector findClicked(Chain[] C, float X, float Y) {
  unClicked = false;
  
  float min_dist2 = 1e10;
  PVector winner = new PVector(-1,-1);
  
  for(int m=0; m<C.length; m++) {
    for(int n=0; n<C[m].L.length; n++) {
      float dist2 = pow(C[m].L[n].px-X,2) + pow(C[m].L[n].py-Y,2);
    
      if( dist2<min_dist2) {
        min_dist2 = dist2;
        winner.set(m,n);
      }
    }
  }
  
  return winner;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  
  if(e>0 && dt>0.019) {
    dt = dt - 0.01;
  } else if(e<0 && dt<0.249) {
    dt = dt + 0.01;
  }
  
}