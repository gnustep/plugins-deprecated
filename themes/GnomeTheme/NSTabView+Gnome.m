#include <AppKit/AppKit.h>
#include <AppKit/NSTabView.h>
#include <GNUstepGUI/GSTheme.h>
#include "GGPainter.h"

@implementation NSTabView (Gnome)

// Drawing.

- (void) drawRect: (NSRect)rect
{
  NSGraphicsContext *ctxt = GSCurrentContext();
  GSTheme           *theme = [GSTheme theme];
  int               howMany = [_items count];
  int               i;
  int               previousState = 0;
  NSRect            aRect = _bounds;
  NSColor           *lineColour = [NSColor highlightColor];
  NSColor           *backgroundColour = [[self window] backgroundColor];
  BOOL              truncate = [self allowsTruncatedLabels];

  GGPainter *painter = [GGPainter instance];
  GtkWidget *widget = [GGPainter getWidget: @"GtkNotebook"];
  NSImage   *img = nil;

  // Make sure some tab is selected
  if (!_selected && howMany > 0)
    [self selectFirstTabViewItem: nil];

  DPSgsave(ctxt);

  switch (_type)
    {
      default:
      case NSTopTabsBezelBorder: 
        aRect.size.height -= 16;
        img = [painter paintBox: widget
                       withPart: "notebook"
                        andSize: aRect
                       withClip: rect
                     usingState: GTK_STATE_NORMAL
                         shadow: GTK_SHADOW_OUT
                          style: widget->style];

        [painter drawAndReleaseImage: img inFrame: aRect flipped: NO];
        break;

      case NSBottomTabsBezelBorder: 
        aRect.size.height -= 16;
        aRect.origin.y += 16;
        img = [painter paintBox: widget
                       withPart: "notebook"
                        andSize: aRect
                       withClip: rect
                     usingState: GTK_STATE_NORMAL
                         shadow: GTK_SHADOW_OUT
                          style: widget->style];

        [painter drawAndReleaseImage: img inFrame: aRect flipped: NO];
        aRect.origin.y -= 16;
        break;

      case NSLeftTabsBezelBorder: 
        aRect.size.width -= 18;
        aRect.origin.x += 18;
        img = [painter paintBox: widget
                       withPart: "notebook"
                        andSize: aRect
                       withClip: rect
                     usingState: GTK_STATE_NORMAL
                         shadow: GTK_SHADOW_OUT
                          style: widget->style];

        [painter drawAndReleaseImage: img inFrame: aRect flipped: NO];
        break;

      case NSRightTabsBezelBorder: 
        aRect.size.width -= 18;
        img = [painter paintBox: widget
                       withPart: "notebook"
                        andSize: aRect
                       withClip: rect
                     usingState: GTK_STATE_NORMAL
                         shadow: GTK_SHADOW_OUT
                          style: widget->style];

        [painter drawAndReleaseImage: img inFrame: aRect flipped: NO];
        break;

      case NSNoTabsBezelBorder: 
        img = [painter paintBox: widget
                       withPart: "notebook"
                        andSize: aRect
                       withClip: rect
                     usingState: GTK_STATE_NORMAL
                         shadow: GTK_SHADOW_OUT
                          style: widget->style];

        [painter drawAndReleaseImage: img inFrame: aRect flipped: NO];
        break;

      case NSNoTabsLineBorder: 
        [[NSColor controlDarkShadowColor] set];
        NSFrameRect(aRect);
        break;

      case NSNoTabsNoBorder: 
        break;
    }

  NSPoint iP;
  GtkPositionType position;
  float labelYCorrection;
  if (_type == NSBottomTabsBezelBorder)
    {
      iP.x = _bounds.origin.x;
      iP.y = _bounds.origin.y;
      position = GTK_POS_TOP; // sic!
      labelYCorrection = 1.0;
    }   
  else if (_type == NSTopTabsBezelBorder)
    {
      iP.x = _bounds.origin.x;
      iP.y = _bounds.size.height - 16;
      position = GTK_POS_BOTTOM; // sic!
      labelYCorrection = -2.0;
    }

  for (i = 0; i < howMany; i++) 
    {
      NSRect r;
      NSRect fRect;
      NSTabViewItem *anItem = [_items objectAtIndex: i];
      NSTabState itemState = [anItem tabState];
      NSSize s = [anItem sizeOfLabel: truncate];

      r.origin.x = iP.x;
      r.origin.y = iP.y;
      r.size.width = s.width + 16;
      r.size.height = 15;

      fRect = r;

      if (itemState == NSSelectedTab)
        {
          // Undraw the line that separates the tab from its view.
          if (_type == NSBottomTabsBezelBorder)
            fRect.origin.y += 1;
          else if (_type == NSTopTabsBezelBorder)
            fRect.origin.y -= 1;

          fRect.size.height += 1;
        }
      [backgroundColour set];
      NSRectFill(fRect);

      if (itemState == NSSelectedTab) 
        {
          img = [painter paintExtension: widget
                               withPart: "tab"
                                andSize: r
                               withClip: NSZeroRect
                             usingState: GTK_STATE_NORMAL
                                 shadow: GTK_SHADOW_OUT
                               position: position
                                  style: widget->style];
          iP.x += r.size.width;
        }
      else if (itemState == NSBackgroundTab)
        {
          img = [painter paintExtension: widget
                               withPart: "tab"
                                andSize: r
                               withClip: NSZeroRect
                             usingState: GTK_STATE_ACTIVE
                                 shadow: GTK_SHADOW_OUT
                               position: position
                                  style: widget->style];
          iP.x += r.size.width - 4;
        } 
      else
        NSLog(@"Not finished yet. Luff ya.\n");
      
      if (itemState == NSSelectedTab && i == howMany -1)
        r.size.width += 4;

      [painter drawAndReleaseImage: img inFrame: r flipped: NO];
          
      // Label
      [anItem drawLabel: truncate inRect: NSMakeRect(r.origin.x + (r.size.width - s.width)/2, r.origin.y + labelYCorrection, s.width, s.height)];
          
      previousState = itemState;
    }
  // FIXME: Missing drawing code for other cases

  DPSgrestore(ctxt);
}
@end
