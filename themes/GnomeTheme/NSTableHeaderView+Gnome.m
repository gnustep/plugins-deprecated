#include <AppKit/AppKit.h>
#include "GGnomeTheme.h"
#include "GGPainter.h"

@implementation NSTableHeaderView (Gnome)
/*
 * Overidden Methods
 */
- (void)drawRect: (NSRect)aRect
{
  NSArray *columns;
  int firstColumnToDraw;
  int lastColumnToDraw;
  NSRect drawingRect;
  NSTableColumn *column;
  NSTableColumn *highlightedTableColumn;
  float width;
  int i;
  NSCell *cell;

  if (_tableView == nil)
    return;

  firstColumnToDraw = [self columnAtPoint: NSMakePoint (aRect.origin.x,
                                                        aRect.origin.y)];
  if (firstColumnToDraw == -1)
    firstColumnToDraw = 0;

  lastColumnToDraw = [self columnAtPoint: NSMakePoint (NSMaxX (aRect),
                                                       aRect.origin.y)];
  if (lastColumnToDraw == -1)
    lastColumnToDraw = [_tableView numberOfColumns] - 1;

  drawingRect = [self headerRectOfColumn: firstColumnToDraw];
  if (![self isFlipped])
    {
      drawingRect.origin.y++;
    }
  //avoid gap: drawingRect.size.height--;

  columns = [_tableView tableColumns];
  highlightedTableColumn = [_tableView highlightedTableColumn];
  
  for (i = firstColumnToDraw; i < lastColumnToDraw; i++)
    {
      column = [columns objectAtIndex: i];
      width = [column width];
      drawingRect.size.width = width;
      cell = [column headerCell];
      if ((column == highlightedTableColumn)
          || [_tableView isColumnSelected: i])
        {
          [cell setHighlighted: YES];
        }
      else
        {
          [cell setHighlighted: NO];
        }
      [cell drawWithFrame: drawingRect
                           inView: self];
      drawingRect.origin.x += width;
    }
  if (lastColumnToDraw == [_tableView numberOfColumns] - 1)
    {
      column = [columns objectAtIndex: lastColumnToDraw];
      width = [column width] - 1;
      drawingRect.size.width = width;
      cell = [column headerCell];
      if ((column == highlightedTableColumn)
          || [_tableView isColumnSelected: lastColumnToDraw])
        {
          [cell setHighlighted: YES];
        }
      else
        {
          [cell setHighlighted: NO];
        }
      [cell drawWithFrame: drawingRect
                           inView: self];
      drawingRect.origin.x += width;
    }
  else
    {
      column = [columns objectAtIndex: lastColumnToDraw];
      width = [column width];
      drawingRect.size.width = width;
      cell = [column headerCell];
      if ((column == highlightedTableColumn)
          || [_tableView isColumnSelected: lastColumnToDraw])
        {
          [cell setHighlighted: YES];
        }
      else
        {
          [cell setHighlighted: NO];
        }
      [cell drawWithFrame: drawingRect
                           inView: self];
      drawingRect.origin.x += width;
    }

  GtkWidget *widget = [GGPainter getWidget: @"GtkTreeView"];
  [[GGPainter fromGdkColor: widget->style->dark[GTK_STATE_NORMAL]] set];
  NSFrameRect(aRect);
}
@end
