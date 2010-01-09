#include <AppKit/AppKit.h>
#include <AppKit/NSScroller.h>
#include <GNUstepGUI/GSTheme.h>
#include "GGPainter.h"

@implementation NSScroller (Gnome)

/*
 *	draw the scroller
 */
- (void) drawRect: (NSRect)rect
{
  NSRect rectForPartIncrementLine;
  NSRect rectForPartDecrementLine;
  NSRect rectForPartKnobSlot;

  rectForPartIncrementLine = [self rectForPart: NSScrollerIncrementLine];
  rectForPartDecrementLine = [self rectForPart: NSScrollerDecrementLine];
  rectForPartKnobSlot = [self rectForPart: NSScrollerKnobSlot];

  [[_window backgroundColor] set];
  NSRectFill (rect);

  ///////////////// BEGIN ADDITION
  GGPainter *painter = [GGPainter instance];

  GtkWidget *widget = [GGPainter getWidget: _scFlags.isHorizontal ? @"GtkHScrollbar" : @"GtkVScrollbar"];

  NSImage *img;
    img = [painter paintBox: widget
                   withPart: "trough"
                    andSize: _bounds
                   withClip: NSZeroRect
                 usingState: GTK_STATE_NORMAL
                     shadow: GTK_SHADOW_OUT
                      style: widget->style];

   [painter drawAndReleaseImage: img inFrame: _bounds flipped: YES];
  ///////////////// END ADDITION

  if (NSIntersectsRect (rect, rectForPartKnobSlot) == YES)
    {
      [self drawKnobSlot];
      [self drawKnob];
    }

  if (NSIntersectsRect (rect, rectForPartDecrementLine) == YES)
    {
      [self drawArrow: NSScrollerDecrementArrow 
            highlight: _hitPart == NSScrollerDecrementLine];
    }
  if (NSIntersectsRect (rect, rectForPartIncrementLine) == YES)
    {
      [self drawArrow: NSScrollerIncrementArrow 
            highlight: _hitPart == NSScrollerIncrementLine];
    }
}

@end
