#include <AppKit/AppKit.h>
#include <AppKit/NSScrollView.h>
#include <GNUstepGUI/GSTheme.h>
#include "GGnomeTheme.h"

@implementation GGnomeTheme (NSScrollView)
- (void) drawScrollViewRect: (NSRect)rect
		     inView: (NSView *)view 
{
  NSScrollView  *scrollView = (NSScrollView *)view;
  NSGraphicsContext *ctxt = GSCurrentContext();
  GSTheme	*theme = [GSTheme theme];
  NSColor	*color;
  NSString	*name;
  NSBorderType   borderType = [scrollView borderType];
  NSRect         bounds = [view bounds];

  name = [theme nameForElement: scrollView];
  if (name == nil)
    {
      name = @"NSScrollView";
    }
  color = [theme colorNamed: name state: GSThemeNormalState];
  if (color == nil)
    {
      color = [NSColor controlDarkShadowColor];
    }
  
  switch (borderType)
    {
      case NSNoBorder:
        break;

      case NSLineBorder:
        [color set];
        NSFrameRect(bounds);
        break;

      case NSBezelBorder:
        [theme drawGrayBezel: bounds withClip: rect];
        break;

      case NSGrooveBorder:
        [theme drawGroove: bounds withClip: rect];
        break;
    }

  [color set];
  DPSsetlinewidth(ctxt, 1);
}
@end
