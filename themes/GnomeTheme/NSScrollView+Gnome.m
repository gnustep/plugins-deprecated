#include <AppKit/AppKit.h>
#include <AppKit/NSScrollView.h>
#include <GNUstepGUI/GSTheme.h>

@implementation NSScrollView (Gnome)

- (void) drawRect: (NSRect)rect
{
  NSGraphicsContext *ctxt = GSCurrentContext();
  GSTheme	*theme = [GSTheme theme];
  NSColor	*color;
  NSString	*name;

  name = [theme nameForElement: self];
  if (name == nil)
    {
      name = @"NSScrollView";
    }
  color = [theme colorNamed: name state: GSThemeNormalState];
  if (color == nil)
    {
      color = [NSColor controlDarkShadowColor];
    }
  
  switch (_borderType)
    {
      case NSNoBorder:
        break;

      case NSLineBorder:
        [color set];
        NSFrameRect(_bounds);
        break;

      case NSBezelBorder:
        [theme drawGrayBezel: _bounds withClip: rect];
        break;

      case NSGrooveBorder:
        [theme drawGroove: _bounds withClip: rect];
        break;
    }

  [color set];
  DPSsetlinewidth(ctxt, 1);

}
@end
