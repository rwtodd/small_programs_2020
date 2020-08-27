#include<X11/Xlib.h>
#include<X11/Xutil.h>
#include<X11/Xos.h>
#include<stdio.h>
#include<stdlib.h>
#include<stdbool.h>

Display *dis;
int screen;
Window win;
GC gc;

void init_x(void) {
  /* get the colors black and white (see section for details) */
  unsigned long black,white;

  /* use the information from the environment variable DISPLAY 
     to create the X connection:
  */	
  dis=XOpenDisplay((char *)0);
  screen=DefaultScreen(dis);
  black=BlackPixel(dis,screen),	/* get color black */
    white=WhitePixel(dis, screen);  /* get color white */

  /* once the display is initialized, create the window.
     This window will be have be 200 pixels across and 300 down.
     It will have the foreground white and background black
  */
  win=XCreateSimpleWindow(dis,DefaultRootWindow(dis),0,0,	
			  200, 300, 5, white, black);

  /* here is where some properties of the window can be set.
     The third and fourth items indicate the name which appears
     at the top of the window and the name of the minimized window
     respectively.
  */
  XSetStandardProperties(dis,win,"My Window","HI!",None,NULL,0,NULL);

  /* this routine determines which types of input are allowed in
     the input.  see the appropriate section for details...
  */
  XSelectInput(dis, win, ExposureMask|ButtonPressMask|KeyPressMask);

  /* create the Graphics Context */
  gc=XCreateGC(dis, win, 0,0);        

  /* here is another routine to set the foreground and background
     colors _currently_ in use in the window.
  */
  XSetBackground(dis,gc,black);
  XSetForeground(dis,gc,white);

  /* clear the window and bring it on top of the other windows */
  XClearWindow(dis, win);
  XMapRaised(dis, win);
}

void close_x(void) {
  XFreeGC(dis,gc);
  XDestroyWindow(dis,win);
  XCloseDisplay(dis);
  exit(1);
}

void redraw(void) {
  XClearWindow(dis, win);
}

int main(int argc, char **argv) {
  XEvent event;		/* the XEvent declaration !!! */
  KeySym key;		/* a dealie-bob to handle KeyPress Events */	
  char text[255];		/* a char buffer for KeyPress Events */

  init_x();

  /* look for events forever... */
  while(true) {		
    /* get the next event and stuff it into our event variable.
       Note:  only events we set the mask for are detected!
    */
    XNextEvent(dis, &event);
	
    if (event.type==Expose && event.xexpose.count==0) {
      /* the window was exposed redraw it! */
      redraw();
    }
    if (event.type==KeyPress&&
	XLookupString(&event.xkey,text,255,&key,0)==1) {
      /* use the XLookupString routine to convert the invent
	 KeyPress data into regular text.  Weird but necessary...
      */
      if (text[0]=='q') {
	close_x();
      }
      printf("You pressed the %c key!\n",text[0]);
    }
    if (event.type==ButtonPress) {
      /* tell where the mouse Button was Pressed */
      int x=event.xbutton.x, y=event.xbutton.y;

      strcpy(text,"X is FUN!");
      XSetForeground(dis,gc,0xeeee00 | (rand()%event.xbutton.x%255));
      XDrawImageString(dis,win,gc,x,y, text, strlen(text));
    }
  }
}

