#include <AppKit/AppKit.h>
#include <AppKit/NSProgressIndicator.h>
#include "GGnomeTheme.h"
#include "GGPainter.h"


 @implementation NSSliderCell (Gnome)
 - (void) drawBarInside: (NSRect)rect flipped: (BOOL)flipped
 {

  [[NSColor windowBackgroundColor] drawSwatchInRect: rect];

   BOOL horizontal = (rect.size.width > rect.size.height);

   GGPainter *painter = [GGPainter instance];
   GtkWidget *widget = [GGPainter getWidget: horizontal ? @"GtkHScale" : @"GtkVScale"];

   NSImage *img = [painter paintBox: widget
                           withPart: "trough"
                            andSize: rect
                           withClip: NSZeroRect
                         usingState: [self isEnabled] ? GTK_STATE_NORMAL : GTK_STATE_INSENSITIVE
                             shadow: GTK_SHADOW_IN
                              style: widget->style];

   [painter drawAndReleaseImage: img inFrame: rect flipped: YES];
}

 - (void) drawKnob
{
   [self setBordered: NO];
   [self setBezeled: NO];

   NSRect knobRect = [self knobRectFlipped: [_control_view isFlipped]];

   BOOL horizontal = (knobRect.size.width > knobRect.size.height);

   if (horizontal)
     knobRect.origin.y += 1;
   else
     knobRect.origin.x += 1;

   [self drawKnob: knobRect];
}
@end
