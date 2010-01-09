#include <AppKit/AppKit.h>
#include <AppKit/NSTabView.h>
#include <GNUstepGUI/GSTheme.h>
#include "GGPainter.h"

@implementation NSTableView (Gnome)
- (void) drawBackgroundInClipRect: (NSRect)clipRect
{
  GGPainter *painter = [GGPainter instance];
  GtkWidget *widget = [GGPainter getWidget: @"GtkTreeView"];
  gtk_tree_view_set_rules_hint(GTK_TREE_VIEW(widget), TRUE);

  NSImage *img = [painter paintFlatBox: widget
                              withPart: "cell_even"
                               andSize: clipRect
                              withClip: NSZeroRect
                            usingState: GTK_STATE_NORMAL
                                shadow: GTK_SHADOW_NONE
                                 style: widget->style];

  [painter drawAndReleaseImage: img inFrame: clipRect flipped: YES];
} 

- (void) drawGridInClipRect: (NSRect)aRect
{
  float minX = NSMinX (aRect);
  float maxX = NSMaxX (aRect);
  float minY = NSMinY (aRect);
  float maxY = NSMaxY (aRect);
  int i;
  float x_pos;
  int startingColumn; 
  int endingColumn;

  NSGraphicsContext *ctxt = GSCurrentContext ();
  float position;

  int startingRow    = [self rowAtPoint: 
			       NSMakePoint (_bounds.origin.x, minY)];
  int endingRow      = [self rowAtPoint: 
			       NSMakePoint (_bounds.origin.x, maxY)];

  /* Using columnAtPoint:, rowAtPoint: here calls them only twice 

     per drawn rect */
  x_pos = minX;
  i = 0;
  while ((i < _numberOfColumns) && (x_pos > _columnOrigins[i]))
    {
      i++;
    }
  startingColumn = (i - 1);

  x_pos = maxX;
  // Nota Bene: we do *not* reset i
  while ((i < _numberOfColumns) && (x_pos > _columnOrigins[i]))
    {
      i++;
    }
  endingColumn = (i - 1);

  if (endingColumn == -1)
    endingColumn = _numberOfColumns - 1;
  /*
  int startingColumn = [self columnAtPoint: 
			       NSMakePoint (minX, _bounds.origin.y)];
  int endingColumn   = [self columnAtPoint: 
			       NSMakePoint (maxX, _bounds.origin.y)];
  */

  DPSgsave (ctxt);
  DPSsetlinewidth (ctxt, 1);
  [_gridColor set];


  GGPainter *painter = [GGPainter instance];
  GtkWidget *widget = [GGPainter getWidget: @"GtkTreeView"];
  gtk_tree_view_set_rules_hint(GTK_TREE_VIEW(widget), TRUE);

  NSRect image_rect = NSMakeRect(0, 0, maxX - minX, _rowHeight);

  NSImage *even_row_image = [painter paintFlatBox: widget
                                         withPart: "cell_even_ruled"
                                          andSize: image_rect
                                         withClip: NSZeroRect
                                       usingState: GTK_STATE_NORMAL
                                           shadow: GTK_SHADOW_NONE
                                             style: widget->style];

  NSImage *odd_row_image = [painter paintFlatBox: widget
                                        withPart: "cell_odd_ruled"
                                         andSize: image_rect
                                        withClip: NSZeroRect
                                      usingState: GTK_STATE_NORMAL
                                          shadow: GTK_SHADOW_NONE
                                            style: widget->style];
  if (_numberOfRows > 0)
    {
      /* Draw rows */
      if (startingRow == -1)
	startingRow = 0;
      if (endingRow == -1)
	endingRow = _numberOfRows - 1;
      
      position = _bounds.origin.y;
      position += startingRow * _rowHeight;
      for (i = startingRow; i <= endingRow + 1; i++)
	{
          NSRect r = NSMakeRect(minX, position, maxX - minX, _rowHeight);

          if (i%2 == 0)
            [even_row_image drawInRect: r fromRect: image_rect operation: NSCompositeSourceOver fraction: 1.0];
          else
            [odd_row_image drawInRect: r fromRect: image_rect operation: NSCompositeSourceOver fraction: 1.0];

	  position += _rowHeight;
	}
    }

  RELEASE(even_row_image);
  RELEASE(odd_row_image);

  gint line_width;
  gint8 *dash_list;
  float dash_list_float[2];
  GdkGCValues lineGCValues;

  gdk_gc_get_values(&widget->style->black_gc[GTK_STATE_NORMAL], &lineGCValues);
  NSColor *lineColor = [GGPainter fromGdkColor: lineGCValues.background];

  gtk_widget_style_get (widget,
                        "grid-line-width", &line_width,
                        "grid-line-pattern", (gchar *)&dash_list,
                        NULL);
  dash_list_float[0] = (float) dash_list[0];
  dash_list_float[1] = (float) dash_list[1];

  [_gridColor set];
  
  DPSsetlinewidth(ctxt, (float) line_width);
  DPSsetdash(ctxt, dash_list_float, 2, 0);
  
  if (_numberOfColumns > 0)
    {
      int lastRowPosition = position - _rowHeight;
      /* Draw vertical lines */
      if (startingColumn == -1)
	startingColumn = 0;
      if (endingColumn == -1)
	endingColumn = _numberOfColumns - 1;

      for (i = startingColumn; i <= endingColumn; i++)
	{
	  DPSmoveto (ctxt, _columnOrigins[i], minY);
	  DPSlineto (ctxt, _columnOrigins[i], lastRowPosition);
	  DPSstroke (ctxt);
	}
      position =  _columnOrigins[endingColumn];
      position += [[_tableColumns objectAtIndex: endingColumn] width];  
      /* Last vertical line must moved a pixel to the left */
      if (endingColumn == (_numberOfColumns - 1))
	position -= 1;
      DPSmoveto (ctxt, position, minY);
      DPSlineto (ctxt, position, lastRowPosition);
      DPSstroke (ctxt);
    }

  DPSgrestore (ctxt);
}


- (void) highlightSelectionInClipRect: (NSRect)clipRect

{
  if (_selectingColumns == NO)
    {
      int selectedRowsCount;
      int row;
      int startingRow, endingRow;
      
      GGPainter *painter = [GGPainter instance];
      GtkWidget *widget  = [GGPainter getWidget: @"GtkTreeView"];

      selectedRowsCount = [_selectedRows count];
      
      if (selectedRowsCount == 0)
	return;
      
      /* highlight selected rows */
      startingRow = [self rowAtPoint: NSMakePoint(0, NSMinY(clipRect))];
      endingRow   = [self rowAtPoint: NSMakePoint(0, NSMaxY(clipRect))];
      
      if (startingRow == -1)
	startingRow = 0;
      if (endingRow == -1)
	endingRow = _numberOfRows - 1;
      
      row = [_selectedRows indexGreaterThanOrEqualToIndex: startingRow];
      while ((row != NSNotFound) && (row <= endingRow))
	{          
          NSRect rowRect = [self rectOfRow: row];

          NSImage *img = [painter paintFocus: widget
                                    withPart: "treeview"
                                     andSize: rowRect
                                  usingState: GTK_STATE_NORMAL
                                       style: widget->style];

          [painter drawAndReleaseImage: img inFrame: rowRect flipped: YES];

	  //NSRectFill(NSIntersectionRect([self rectOfRow: row], clipRect));
	  row = [_selectedRows indexGreaterThanIndex: row];
	}	  
    }
  else // Selecting columns
    {
      unsigned int selectedColumnsCount;
      unsigned int column;
      int startingColumn, endingColumn;
      
      selectedColumnsCount = [_selectedColumns count];
      
      if (selectedColumnsCount == 0)
	return;
      
      /* highlight selected columns */
      startingColumn = [self columnAtPoint: NSMakePoint(NSMinX(clipRect), 0)];
      endingColumn = [self columnAtPoint: NSMakePoint(NSMaxX(clipRect), 0)];

      if (startingColumn == -1)
	startingColumn = 0;
      if (endingColumn == -1)
	endingColumn = _numberOfColumns - 1;

      column = [_selectedColumns indexGreaterThanOrEqualToIndex: startingColumn];
      while ((column != NSNotFound) && (column <= endingColumn))
	{
	  NSHighlightRect(NSIntersectionRect([self rectOfColumn: column],
					     clipRect));
	  column = [_selectedColumns indexGreaterThanIndex: column];
	}	  
    }
}

- (void) drawRect: (NSRect)aRect
{
  int startingRow;
  int endingRow;
  int i;

  /* Draw background */
  [self drawBackgroundInClipRect: aRect];

  if ((_numberOfRows == 0) || (_numberOfColumns == 0))
    {
      return;
    }

  /* Draw grid */
  if (_drawsGrid)
    {
      [self drawGridInClipRect: aRect];
    }

  /* Draw selection */
  [self highlightSelectionInClipRect: aRect];
  
  /* Draw visible cells */
  /* Using rowAtPoint: here calls them only twice per drawn rect */
  startingRow = [self rowAtPoint: NSMakePoint (0, NSMinY (aRect))];
  endingRow   = [self rowAtPoint: NSMakePoint (0, NSMaxY (aRect))];

  if (startingRow == -1)
    {
      startingRow = 0;
    }
  if (endingRow == -1)
    {
      endingRow = _numberOfRows - 1;
    }
  //  NSLog(@"drawRect : %d-%d", startingRow, endingRow);
  {
    SEL sel = @selector(drawRow:clipRect:);
    IMP imp = [self methodForSelector: sel];
    
    for (i = startingRow; i <= endingRow; i++)
      {
        (*imp)(self, sel, i, aRect);
      }
  }
  
  // paint frame around table view like in Gtk+
  GtkWidget *widget  = [GGPainter getWidget: @"GtkTreeView"];
  [[GGPainter fromGdkColor: widget->style->dark[GTK_STATE_NORMAL]] set];
  NSFrameRect(_bounds);
}

- (void) drawRow: (int)rowIndex clipRect: (NSRect)clipRect
{
  int startingColumn; 
  int endingColumn;
  NSTableColumn *tb;
  NSRect drawingRect;
  NSCell *cell;
  int i;
  float x_pos;

  if (_dataSource == nil)
    {
      return;
    }

  /* Using columnAtPoint: here would make it called twice per row per drawn 
     rect - so we avoid it and do it natively */

  /* Determine starting column as fast as possible */
  x_pos = NSMinX (clipRect);
  i = 0;
  while ((i < _numberOfColumns) && (x_pos > _columnOrigins[i]))
    {
      i++;
    }
  startingColumn = (i - 1);

  if (startingColumn == -1)
    startingColumn = 0;

  /* Determine ending column as fast as possible */
  x_pos = NSMaxX (clipRect);
  // Nota Bene: we do *not* reset i
  while ((i < _numberOfColumns) && (x_pos > _columnOrigins[i]))
    {
      i++;
    }
  endingColumn = (i - 1);

  if (endingColumn == -1)
    endingColumn = _numberOfColumns - 1;

  /* Draw the row between startingColumn and endingColumn */
  for (i = startingColumn; i <= endingColumn; i++)
    {
      if (i != _editedColumn || rowIndex != _editedRow)
	{
	  tb = [_tableColumns objectAtIndex: i];
	  cell = [tb dataCellForRow: rowIndex];
	  [self _willDisplayCell: cell
		forTableColumn: tb
		row: rowIndex];
	  [cell setObjectValue: [_dataSource tableView: self
					     objectValueForTableColumn: tb
					     row: rowIndex]]; 
	  drawingRect = [self frameOfCellAtColumn: i
			      row: rowIndex];
	  [cell drawWithFrame: drawingRect inView: self];
	}
    }
}
@end
