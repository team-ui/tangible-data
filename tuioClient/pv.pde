
//*****************************************************************************
// TITLE:         GEOMETRY UTILITIES IN 2D  
// DESCRIPTION:   Classes and functions for manipulating points, vectors, edges, triangles, quads, frames, and circular arcs  
// AUTHOR:        Prof Jarek Rossignac
// DATE CREATED:  September 2009
// EDITS:         Revised July 2011
//*****************************************************************************
//************************************************************************
//**** POINT CLASS
//************************************************************************
class pt { 
  float x=0,y=0; 
  // CREATE
  pt () {}
  pt (float px, float py) {x = px; y = py;};

  // MODIFY
  pt setTo(float px, float py) {x = px; y = py; return this;};  
  pt setTo(pt P) {x = P.x; y = P.y; return this;}; 
  pt setToMouse() { x = mouseX; y = mouseY;  return this;}; 
  pt add(float u, float v) {x += u; y += v; return this;}                       // P.add(u,v): P+=<u,v>
  pt add(pt P) {x += P.x; y += P.y; return this;};                              // incorrect notation, but useful for computing weighted averages
  pt add(float s, pt P)   {x += s*P.x; y += s*P.y; return this;};               // adds s*P
  pt add(vec V) {x += V.x; y += V.y; return this;}                              // P.add(V): P+=V
  pt add(float s, vec V) {x += s*V.x; y += s*V.y; return this;}                 // P.add(s,V): P+=sV
  pt translateTowards(float s, pt P) {x+=s*(P.x-x);  y+=s*(P.y-y);  return this;};  // transalte by ratio s towards P
  pt scale(float u, float v) {x*=u; y*=v; return this;};
  pt scale(float s) {x*=s; y*=s; return this;}                                  // P.scale(s): P*=s
  pt scale(float s, pt C) {x*=C.x+s*(x-C.x); y*=C.y+s*(y-C.y); return this;}    // P.scale(s,C): scales wrt C: P=L(C,P,s);
  pt rotate(float a) {float dx=x, dy=y, c=cos(a), s=sin(a); x=c*dx+s*dy; y=-s*dx+c*dy; return this;};     // P.rotate(a): rotate P around origin by angle a in radians
  pt rotate(float a, pt G) {float dx=x-G.x, dy=y-G.y, c=cos(a), s=sin(a); x=G.x+c*dx+s*dy; y=G.y-s*dx+c*dy; return this;};   // P.rotate(a,G): rotate P around G by angle a in radians
  pt rotate(float s, float t, pt G) {float dx=x-G.x, dy=y-G.y; dx-=dy*t; dy+=dx*s; dx-=dy*t; x=G.x+dx; y=G.y+dy;  return this;};   // fast rotate s=sin(a); t=tan(a/2); 
  pt moveWithMouse() { x += mouseX-pmouseX; y += mouseY-pmouseY;  return this;}; 
     
  // DRAW , WRITE
  pt write() {print("("+x+","+y+")"); return this;};  // writes point coordinates in text window
  pt v() {vertex(x,y); return this;};  // used for drawing polygons between beginShape(); and endShape();
  pt show(float r) {ellipse(x, y, 2*r, 2*r); return this;}; // shows point as disk of radius r
  pt show() {show(3); return this;}; // shows point as small dot
  pt label(String s, float u, float v) {fill(black); text(s, x+u, y+v); noFill(); return this; };
  pt label(String s, vec V) {fill(black); text(s, x+V.x, y+V.y); noFill(); return this; };
  pt label(String s) {label(s,5,4); return this; };
  pt tag(String s) {fill(white); show(13); fill(black); text(s, x-5, y+4); return this;} 
    
  } // end of pt class

//************************************************************************
//**** VECTORS
//************************************************************************
class vec { float x=0,y=0; 
 // CREATE
  vec () {};
  vec (float px, float py) {x = px; y = py;};
 
 // MODIFY
  vec setTo(float px, float py) {x = px; y = py; return this;}; 
  vec setTo(vec V) {x = V.x; y = V.y; return this;}; 
  vec zero() {x=0; y=0; return this;}
  vec scaleBy(float u, float v) {x*=u; y*=v; return this;};
  vec scaleBy(float f) {x*=f; y*=f; return this;};
  vec reverse() {x=-x; y=-y; return this;};
  vec divideBy(float f) {x/=f; y/=f; return this;};
  vec normalize() {float n=sqrt(sq(x)+sq(y)); if (n>0.000001) {x/=n; y/=n;}; return this;};
  vec add(float u, float v) {x += u; y += v; return this;};
  vec add(vec V) {x += V.x; y += V.y; return this;};   
  vec add(float s, vec V) {x += s*V.x; y += s*V.y; return this;};   
  vec rotateBy(float a) {float xx=x, yy=y; x=xx*cos(a)-yy*sin(a); y=xx*sin(a)+yy*cos(a); return this;};
  vec left() {float m=x; x=-y; y=m; return this;};
 
  // OUTPUT VEC
  vec clone() {return(new vec(x,y));}; 

  // OUTPUT TEST MEASURE
  float norm() {return(sqrt(sq(x)+sq(y)));}
  boolean isNull() {return((abs(x)+abs(y)<0.000001));}
  float angle() {return(atan2(y,x)); }

  // DRAW, PRINT
  void write() {println("<"+x+","+y+">");};
  void showAt (pt P) {line(P.x,P.y,P.x+x,P.y+y); }; 
  void showArrowAt (pt P) {line(P.x,P.y,P.x+x,P.y+y); 
      float n=min(this.norm()/10.,height/50.); 
      pt Q=P(P,this); 
      vec U = S(-n,U(this));
      vec W = S(.3,R(U)); 
      beginShape(); Q.add(U).add(W).v(); Q.v(); Q.add(U).add(M(W)).v(); endShape(CLOSE); }; 
  void label(String s, pt P) {P(P).add(0.5,this).add(3,R(U(this))).label(s); };
  } // end vec class

//************************************************************************
//**** POINTS
//************************************************************************
// create 
pt P() {return P(0,0); };                                                                            // make point (0,0)
pt P(float x, float y) {return new pt(x,y); };                                                       // make point (x,y)
pt P(pt P) {return P(P.x,P.y); };                                                                    // make copy of point A
pt Mouse() {return P(mouseX,mouseY);};                                                                 // returns point at current mouse location
pt Pmouse() {return P(pmouseX,pmouseY);};                                                              // returns point at previous mouse location
pt ScreenCenter() {return P(width/2,height/2);}                                                        //  point in center of  canvas

// display 
void show(pt P, float r) {ellipse(P.x, P.y, 2*r, 2*r);};                                             // draws circle of center r around P
void show(pt P) {ellipse(P.x, P.y, 6,6);};                                                           // draws small circle around point
void edge(pt P, pt Q) {line(P.x,P.y,Q.x,Q.y); };                                                      // draws edge (P,Q)
void arrow(pt P, pt Q) {arrow(P,V(P,Q)); }                                                            // draws arrow from P to Q
void label(pt P, String S) {text(S, P.x-4,P.y+6.5); }                                                 // writes string S next to P on the screen ( for example label(P[i],str(i));)
void label(pt P, vec V, String S) {text(S, P.x-3.5+V.x,P.y+7+V.y); }                                  // writes string S at P+V
void v(pt P) {vertex(P.x,P.y);};                                                                      // vertex for drawing polygons between beginShape() and endShape()
void v(pt P, float u, float v) {vertex(P.x,P.y,u,v);};// vertex for drawing polygons between beginShape() and endShape()
void v(pt P, pt Q) {vertex(P.x,P.y,Q.x,Q.y);};
void show(pt P, pt Q, pt R) {beginShape(); v(P); v(Q); v(R); endShape(CLOSE); };                      // draws triangle 

// transform 
pt R(pt Q, float a) {float dx=Q.x, dy=Q.y, c=cos(a), s=sin(a); return new pt(c*dx+s*dy,-s*dx+c*dy); };  // Q rotated by angle a around the origin
pt R(pt Q, float a, pt C) {float dx=Q.x-C.x, dy=Q.y-C.y, c=cos(a), s=sin(a); return P(C.x+c*dx-s*dy, C.y+s*dx+c*dy); };  // Q rotated by angle a around point P
pt P(pt P, vec V) {return P(P.x + V.x, P.y + V.y); }                                                 //  P+V (P transalted by vector V)
pt MoveByDistanceTowards(pt P, float d, pt Q) { return P(P,d,U(V(P,Q))); };                          //  P+dU(PQ) (transLAted P by *distance* s towards Q)!!!

// average 
pt P(pt A, pt B) {return P((A.x+B.x)/2.0,(A.y+B.y)/2.0); };                                          // (A+B)/2 (average)
pt P(pt A, pt B, pt C) {return P((A.x+B.x+C.x)/3.0,(A.y+B.y+C.y)/3.0); };                            // (A+B+C)/3 (average)
pt P(pt A, pt B, pt C, pt D) {return P(P(A,B),P(C,D)); };                                            // (A+B+C+D)/4 (average)

// weighted average 
pt P(float a, pt A) {return P(a*A.x,a*A.y);}                                                      // aA  
pt P(float a, pt A, float b, pt B) {return P(a*A.x+b*B.x,a*A.y+b*B.y);}                              // aA+bB, (a+b=1) 
pt P(float a, pt A, float b, pt B, float c, pt C) {return P(a*A.x+b*B.x+c*C.x,a*A.y+b*B.y+c*C.y);}   // aA+bB+cC 
pt P(float a, pt A, float b, pt B, float c, pt C, float d, pt D){return P(a*A.x+b*B.x+c*C.x+d*D.x,a*A.y+b*B.y+c*C.y+d*D.y);} // aA+bB+cC+dD 

// frame maps
pt P(pt O, float x, vec I) {return P(O.x+x*I.x,O.y+x*I.y);}                              // O+xI
pt P(pt O, float x, vec I, float y, vec J) {return P(O.x+x*I.x+y*J.x,O.y+x*I.y+y*J.y);}   // O+xI+yJ
float x(pt P, pt O, vec I, vec J) {return det(V(O,P),J)/det(I,J);}
float y(pt P, pt O, vec I, vec J) {return det(V(O,P),I)/det(J,I);}

// barycentric coordinates and transformations
float m(pt A, pt B, pt C) {return (B.x-A.x)*(C.y-A.y) - (B.y-A.y)*(C.x-A.x); }
float a(pt P, pt A, pt B, pt C) {return m(P,B,C)/m(A,B,C); }
float b(pt P, pt A, pt B, pt C) {return m(A,P,C)/m(A,B,C); }
float c(pt P, pt A, pt B, pt C) {return m(A,B,P)/m(A,B,C); }

float x(vec V, vec I, vec J) {return det(V,J)/det(I,J);}
float y(vec V, vec I, vec J) {return det(V,I)/det(J,I);}

float x(pt P, pt A, pt B) {return dot(V(A,B),V(A,P))/d2(A,B);}
float y(pt P, pt A, pt B) {return det(V(A,B),V(A,P))/d2(A,B);}
     
// measure 
boolean isSame(pt A, pt B) {return (A.x==B.x)&&(A.y==B.y) ;}                                         // A==B
boolean isSame(pt A, pt B, float e) {return ((abs(A.x-B.x)<e)&&(abs(A.y-B.y)<e));}                   // ||A-B||<e
float d(pt P, pt Q) {return sqrt(d2(P,Q));  };                                                       // ||AB|| ()
float d2(pt P, pt Q) {return sq(Q.x-P.x)+sq(Q.y-P.y); };                                             // AB*AB (Distance squared)

boolean projectsBetween(pt P, pt A, pt B) {return dot(V(A,P),V(A,B))>0 && dot(V(B,P),V(B,A))>0 ; };
float disToLine(pt P, pt A, pt B) {return abs(det(U(A,B),V(A,P))); };
pt projectionOnLine(pt P, pt A, pt B) {return P(A,dot(V(A,B),V(A,P))/dot(V(A,B),V(A,B)),V(A,B));}


//************************************************************************
//**** VECTORS
//************************************************************************
// create 
vec V(vec V) {return new vec(V.x,V.y); };                                                             // make copy of vector V
vec V(pt P) {return new vec(P.x,P.y); };                                                              // make vector from origin to P
vec V(float x, float y) {return new vec(x,y); };                                                      // make vector (x,y)
vec V(pt P, pt Q) {return new vec(Q.x-P.x,Q.y-P.y);};                                                 // PQ (make vector Q-P from P to Q
vec U(vec V) {float n = n(V); if (n==0) return new vec(0,0); else return new vec(V.x/n,V.y/n);};      // V/||V|| (Unit vector : normalized version of V)
vec U(pt P, pt Q) {return U(V(P,Q));};                                                                // PQ/||PQ| (Unit vector : from P towards Q)
vec MouseDrag() {return new vec(mouseX-pmouseX,mouseY-pmouseY);};                                      // vector representing recent mouse displacement

// display 
void show(pt P, vec V) {line(P.x,P.y,P.x+V.x,P.y+V.y); }                                              // show V as line-segment from P 
void show(pt P, float s, vec V) {show(P,S(s,V));}                                                     // show sV as line-segment from P 
void arrow(pt P, float s, vec V) {arrow(P,S(s,V));}                                                   // show sV as arrow from P 
void arrow(pt P, vec V, String S) {arrow(P,V); P(P(P,0.70,V),15,R(U(V))).label(S,V(-5,4));}       // show V as arrow from P and print string S on its side
void arrow(pt P, vec V) {show(P,V);  float n=n(V); if(n<0.01) return; float s=max(min(0.2,20./n),6./n);       // show V as arrow from P 
     pt Q=P(P,V); vec U = S(-s,V); vec W = R(S(.3,U)); beginShape(); v(P(P(Q,U),W)); v(Q); v(P(P(Q,U),-1,W)); endShape(CLOSE);}; 

// weighted sum 
vec W(float s,vec V) {return V(s*V.x,s*V.y);}                                                      // sV
vec W(vec U, vec V) {return V(U.x+V.x,U.y+V.y);}                                                   // U+V 
vec W(vec U,float s,vec V) {return W(U,S(s,V));}                                                   // U+sV
vec W(float u, vec U, float v, vec V) {return W(S(u,U),S(v,V));}                                   // uU+vV ( Linear combination)

// transformed 
vec R(vec V) {return new vec(-V.y,V.x);};                                                             // V turned right 90 degrees (as seen on screen)
vec R(vec V, float a) {float c=cos(a), s=sin(a); return(new vec(V.x*c-V.y*s,V.x*s+V.y*c)); };                                     // V rotated by a radians
vec S(float s,vec V) {return new vec(s*V.x,s*V.y);};                                                  // sV
vec Reflection(vec V, vec N) { return W(V,-2.*dot(V,N),N);};                                          // reflection
vec M(vec V) { return V(-V.x,-V.y); }                                                                  // -V


// measure 
float dot(vec U, vec V) {return U.x*V.x+U.y*V.y; }                                                     // dot(U,V): U*V (dot product U*V)
float det(vec U, vec V) {return dot(R(U),V); }                                                         // det | U V | = scalar cross UxV 
float n(vec V) {return sqrt(dot(V,V));};                                                               // n(V): ||V|| (norm: length of V)
float n2(vec V) {return sq(V.x)+sq(V.y);};                                                             // n2(V): V*V (norm squared)
boolean parallel (vec U, vec V) {return dot(U,R(V))==0; }; 

float angle (vec U, vec V) {return atan2(det(U,V),dot(U,V)); };                                   // angle <U,V> (between -PI and PI)
float angle(vec V) {return(atan2(V.y,V.x)); };                                                       // angle between <1,0> and V (between -PI and PI)
float angle(pt A, pt B, pt C) {return  angle(V(B,A),V(B,C)); }                                       // angle <BA,BC>
float turnAngle(pt A, pt B, pt C) {return  angle(V(A,B),V(B,C)); }                                   // angle <AB,BC> (positive when right turn as seen on screen)
int toDeg(float a) {return int(a*180/PI);}                                                           // convert radians to degrees
float toRad(float a) {return(a*PI/180);}                                                             // convert degrees to radians 
float positive(float a) { if(a<0) return a+TWO_PI; else return a;}                                   // adds 2PI to make angle positive

vec mul(vec V,float f) {vec result = V(V); result.x*=f; result.y*=f; return result;};

//************************************************************************
//**** INTERPOLATION
//************************************************************************


// Interpolation of points LERP
pt L(pt A, pt B, float t) {return P(A.x+t*(B.x-A.x),A.y+t*(B.y-A.y));}

// Interpolation of vectors 
vec L(vec U, vec V, float s) {return new vec(U.x+s*(V.x-U.x),U.y+s*(V.y-U.y));};                      // (1-s)U+sV (Linear interpolation between vectors)
vec S(vec U, vec V, float s) {float a = angle(U,V); vec W = R(U,s*a); float u = n(U); float v=n(V); W(pow(v/u,s),W); return W; } // steady interpolation from U to V
vec slerp(vec U, float t, vec V) {float a = angle(U,V); float b=sin((1.-t)*a),c=sin(t*a),d=sin(a); return W(b/d,U,c/d,V); }


