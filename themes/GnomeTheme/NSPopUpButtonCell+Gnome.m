#include <AppKit/AppKit.h>
#include <AppKit/NSProgressIndicator.h>
#include "GGnomeTheme.h"
#include "GGPainter.h"


@implementation NSPopUpButtonCell (Gnome)


static NSImage *_pbc_image[5];

- (NSImage *) _currentArrowImage
{
  if (_pbcFlags.pullsDown)
    {
      if (_pbcFlags.arrowPosition == NSPopUpNoArrow)
        {
          return nil;
        }

      if (_pbcFlags.preferredEdge == NSMinYEdge)
        {
          return _pbc_image[1];
        }
      else if (_pbcFlags.preferredEdge == NSMaxXEdge)
        {
          return _pbc_image[2];
        }
      else if (_pbcFlags.preferredEdge == NSMaxYEdge)
        {
          return _pbc_image[3];
        }
      else if (_pbcFlags.preferredEdge == NSMinXEdge)
        {
          return _pbc_image[4];
        }
      else
        {
          return _pbc_image[1];
        }
    }
  else
    {
      return _pbc_image[0];
    }
}

- (id) init
{
  ASSIGN(_pbc_image[0], [NSImage imageNamed: @"common_Nibble"]);
  ASSIGN(_pbc_image[1], [NSImage imageNamed: @"common_3DArrowDown"]);
  return [self initTextCell: @"" pullsDown: NO];
}

/*
 * This drawing uses the same code that is used to draw cells in the menu.
 */
- (void) drawInteriorWithFrame: (NSRect)cellFrame
                        inView: (NSView*)controlView
{
  BOOL new = NO;

  if ([self menuItem] == nil)
    {
      NSMenuItem *anItem;

      /*
       * Create a temporary NSMenuItemCell to at least draw our control,
       * if items array is empty.
       */
      anItem = [NSMenuItem new];
      [anItem setTitle: [self title]];
      /* We need this menu item because NSMenuItemCell gets its contents
       * from the menuItem not from what is set in the cell */
      [self setMenuItem: anItem];
      RELEASE(anItem);
      new = YES;
    }

  /* We need to calc our size to get images placed correctly */
  [self calcSize];

  GGPainter *painter = [GGPainter instance];

  GtkWidget *button = [GGPainter getWidget: @"GtkComboBox.GtkToggleButton"];

  NSImage *img = [painter paintBox: button
                          withPart: "button"
                           andSize: cellFrame
                          withClip: NSZeroRect
                        usingState: GTK_STATE_NORMAL
                            shadow: GTK_SHADOW_OUT
                             style: button->style];

  [painter drawAndReleaseImage: img inFrame: cellFrame flipped: YES];

  GtkWidget *widget = [GGPainter getWidget: @"GtkComboBox.GtkToggleButton.GtkHBox.GtkVSeparator"];

  img = [painter paintVLine: widget
                   withPart: "vseparator"
                    andSize: cellFrame
                 usingState: GTK_STATE_NORMAL
                      style: widget->style];

  NSSize arrowSize = [[self _currentArrowImage] size];

  [img drawInRect: NSMakeRect(cellFrame.size.width - 2*arrowSize.width - 2*widget->style->xthickness, cellFrame.size.height - widget->style->ythickness, 3, cellFrame.size.height - 2*widget->style->ythickness)
         fromRect: NSMakeRect(0, 0, 3, cellFrame.size.height)
        operation: NSCompositeSourceOver
         fraction: 1.0];

  RELEASE(img);

  [super drawInteriorWithFrame: cellFrame inView: controlView];

  /* Unset the item to restore balance if a new was created */
  if (new)
    {
      [self setMenuItem: nil];
    }
}
@end
