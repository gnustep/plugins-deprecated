#include <AppKit/AppKit.h>
#include "GGnomeTheme.h"
#include "GGPainter.h"

@interface GSTableCornerView : NSView
{}
@end


@implementation NSTableHeaderCell (Gnome)
- (NSRect) drawingRectForBounds: (NSRect)theRect
{
  return theRect;
}

- (void) _drawBorderAndBackgroundWithFrame: (NSRect)cellFrame
                                    inView: (NSView*)controlView
{
  GGPainter *painter = [GGPainter instance];

  GtkWidget *widget = [GGPainter getWidget: @"GtkTreeView.GtkButton"];

  GtkStateType state = GTK_STATE_NORMAL;

  if (![self isEnabled]) {
    state = GTK_STATE_INSENSITIVE;
  }

  NSImage *img = [painter paintBox: widget
                          withPart: "button"
                           andSize: cellFrame
                          withClip: NSZeroRect
                        usingState: _cell.is_highlighted ? GTK_STATE_ACTIVE : GTK_STATE_NORMAL
                            shadow: GTK_SHADOW_OUT
                             style: widget->style];

  [painter drawAndReleaseImage: img inFrame: cellFrame flipped: YES];
}
@end


@implementation GSTableCornerView (Gnome)
- (void) drawRect: (NSRect)aRect
{
  /*
  NSRect cellFrame = aRect;

  GGPainter *painter = [GGPainter instance];

  GtkWidget *widget = [GGPainter getWidget: @"GtkTreeView.GtkButton"];

  GtkStateType state = GTK_STATE_NORMAL;

  NSImage *img = [painter paintBox: widget
                          withPart: "button"
                           andSize: cellFrame
                          withClip: NSZeroRect
                        usingState: GTK_STATE_NORMAL
                            shadow: GTK_SHADOW_OUT
                             style: widget->style];

  [painter drawAndReleaseImage: img inFrame: cellFrame flipped: YES];
  */
}
@end
