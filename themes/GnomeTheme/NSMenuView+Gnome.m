#include <AppKit/AppKit.h>
#include <AppKit/NSProgressIndicator.h>
#include "GGnomeTheme.h"
#include "GGPainter.h"

@implementation NSMenuView (Gnome)
- (void) drawRect: (NSRect)rect
{
  int        i;
  int        howMany = [_itemCells count];

  // Draw the menu cells.
  for (i = 0; i < howMany; i++)
    {
      NSRect aRect;
      NSMenuItemCell *aCell;

      aRect = [self rectOfItemAtIndex: i];
      if (NSIntersectsRect(rect, aRect) == YES)
        {
          aCell = [self menuItemCellForItemAtIndex: i];
          [aCell drawWithFrame: aRect inView: self];
        }
    }

  GGPainter *painter = [GGPainter instance];
  GtkWidget *widget = [GGPainter getWidget: @"GtkMenu"];

  NSImage *img = [painter paintBox: widget
                          withPart: "menu"
                           andSize: _bounds
                          withClip: NSZeroRect
                        usingState: GTK_STATE_NORMAL
                            shadow: GTK_SHADOW_OUT
                             style: widget->style];

  [painter drawAndReleaseImage: img inFrame: _bounds flipped: NO];
}

@end

