#include <AppKit/AppKit.h>
#include <AppKit/NSBrowser.h>
#include <GNUstepGUI/GSTheme.h>

@implementation NSBrowser (Gnome)

- (void) drawRect: (NSRect)rect
{
  float scrollerWidth = [NSScroller scrollerWidth];

  // Load the first column if not already done
  if (!_isLoaded)
    {
      [self loadColumnZero];
    }

  // Draws titles
  if (_isTitled)
    {
      int i;

      for (i = _firstVisibleColumn; i <= _lastVisibleColumn; ++i)
        {
          NSRect titleRect = [self titleFrameOfColumn: i];
          if (NSIntersectsRect (titleRect, rect) == YES)
            {
              [self drawTitleOfColumn: i
                    inRect: titleRect];
            }
        }
    }

  // Draws scroller border
  // deleted

  if (!_separatesColumns)
    {
      NSPoint p1,p2;
      int     i, visibleColumns;
      float   hScrollerWidth = _hasHorizontalScroller ? scrollerWidth : 0;
      
      // Columns borders
      [[GSTheme theme] drawGrayBezel: _bounds withClip: rect];
      
      [[NSColor blackColor] set];
      visibleColumns = [self numberOfVisibleColumns]; 
      for (i = 1; i < visibleColumns; i++)
        {
          p1 = NSMakePoint((_columnSize.width * i) + 2 + (i-1), 
                           _columnSize.height + hScrollerWidth + 2);
          p2 = NSMakePoint((_columnSize.width * i) + 2 + (i-1),
                           hScrollerWidth + 2);
          [NSBezierPath strokeLineFromPoint: p1 toPoint: p2];
        }

      // Horizontal scroller border
      if (_hasHorizontalScroller)
        {
          p1 = NSMakePoint(2, hScrollerWidth + 2);
          p2 = NSMakePoint(rect.size.width - 2, hScrollerWidth + 2);
          [NSBezierPath strokeLineFromPoint: p1 toPoint: p2];
        }
    }
}

@end
