#include <hmg.ch>
#include "hbclass.ch"

Class GridPlus

   DATA aData        INIT {}
   DATA cReportHeader1 INIT ''
   DATA cReportHeader2 INIT ''
   DATA cReportHeader3 INIT ''
   DATA cReportFooter  INIT ''
   DATA aColumnHeaders INIT {}
   DATA aColumnWidths INIT {}
   DATA aColumnJustify INIT {}
   DATA nPaperHeight INIT 0
   DATA nPaperWidth INIT 0
   DATA nLeftMargin INIT 0
   DATA nRightMargin INIT 0
   DATA nTopMargin INIT 0
   DATA nBottomMargin INIT 0
   DATA nRowHeight INIT 5
   DATA aColumnSum INIT {}
   DATA aMergeHeaders INIT {}
   DATA aGroupColumns INIT {}
   DATA aReportHeaderFont INIT {}
   DATA aReportFooterFont INIT {}
   DATA aReportFont INIT {}
   DATA aCellFont INIT {}
   DATA lHorizontalLines INIT .t.
   DATA lVerticalLines   INIT .t.
   DATA nPenWidth INIT 0.1
   DATA cPrinter INIT ''
   DATA lWordWrap INIT .f.
   DATA nDPI INIT 96
   DATA lPageCenter INIT .f.
   DATA lSpreadWhiteSpace INIT .f.
   DATA lIncludeDate INIT .f.
   DATA lIncludeTime INIT .f.
   DATA cDatePrefix INIT 'Date :'
   DATA cTimePrefix INIT 'Time :'
   DATA cPageNumberPrefix INIT 'Page No. :'
   DATA nDateTimeAlignment INIT 0 // left
   DATA lPageNumbering INIT .t.
   DATA nPageNumberPosition INIT 1 // TOP 2 bottom 3 both
   DATA nPageNumberAlignment INIT 1 // Right
   DATA nDefaultColumnWidth INIT 30 // default width 30 mm per column
   DATA lTruncateColumns INIT .f. 
   DATA nOrientation INIT 1 // portrait
   DATA lPreview  INIT .t. 
   DATA nGroupIndent INIT 3 
   DATA cDecimalSymbol INIT '.'
   DATA aColumnPicture INIT {}

   
   DATA nTextMaxRow INIT 60 
   
   DATA nColumnCount INIT 0
   DATA nMM2Pixel INIT 3.7795 // @ 96 DPI
   DATA aPaperSizes INIT {}
   DATA nMM2Text INIT 0.38167 //  80 cols / 210 mm

   DATA nPaperSize INIT 9 // A4
   DATA nDateTimeAlignment INIT 0 // left
   DATa cLastExportFileName INIT ''
   DATA nColSpacing INIT 1
   
   DATA nPrintLeftMargin INIT 0
   DATA nPrintMaxRow INIT 0
   DATA nPrintCurRow INIT 0
   DATA nPrintCurCol INIT 0
   DATA aPrintWidths INIT {}
   DATA aPrintJustify INIT {}
   DATA nPrintMaxCol INIT 0
   DATA aPrintColumnHeaders INIT {}
   DATA nPrintPaperWidth INIT 0
   DATA nPrintPaperHeight INIT 0
   DATA nPrintLineHeight INIT 0
   DATA nPrintCurPage INIT 0
   DATA lMergeHeader INIT .f.
   DATA aPrintColumns INIT {}
   DATA nMouseStartCol INIT 0
   DATA nGridCol INIT 0
   DATA cDragArea INIT ''
   DATA lDraggable INIT .f.
   DATA lDragStart INIT .f.
   
   METHOD New
   METHOD AddArrayData
   METHOD addGridData
   METHOD Export2CSV
   METHOD Export2HTML
   METHOD Export2TXT
   METHOD ShowGUI
   METHOD PrintGrid
   && METHOD PrintPDF
   && METHOD ExportImages
   METHOD Printer SETGET
   METHOD PaperHeight SETGET
   METHOD PaperWidth SETGET
   METHOD TopMargin SETGET
   METHOD LeftMargin SETGET
   METHOD RightMargin SETGET
   METHOD BottomMargin SETGET
   METHOD ColumnHeaders SETGET
   METHOD ColumnWidths SETGET
   METHOD ColumnJustify SETGET
   METHOD ReportHeader1 SETGET
   METHOD ReportHeader2 SETGET
   METHOD ReportHeader3 SETGET
   METHOD ReportFooter SETGET
   METHOD RowHeight SETGET
   METHOD GroupColumns SETGET
   METHOD GroupIndent SETGET
   METHOD MergeHeaders SETGET
   METHOD ColumnSum SETGET
   METHOD HorizontalLines SETGET
   METHOD VerticalLines SETGET
   METHOD ReportHeaderFont SETGET
   METHOD ReportFooterFont SETGET
   METHOD ReportFont SETGET
   METHOD CellFont SETGET
   METHOD PenWidth SETGET
   METHOD WordWrap SETGET
   METHOD DPI SETGET
   METHOD PageCenter SETGET
   METHOD SpreadWhiteSpace SETGET
   METHOD PaperSize SETGET
   METHOD IncludeDate SETGET
   METHOD IncludeTime SETGET
   METHOD DatePrefix SETGET
   METHOD TimePrefix SETGET
   METHOD PageNumberPrefix SETGET
   METHOD DateTimeAlignment SETGET
   METHOD PageNumbering SETGET
   METHOD PageNumberPosition SETGET
   METHOD PageNumberAlignment SETGET   
   METHOD DefaultColumnWidth SETGET
   METHOD TruncateColumns SETGET
   METHOD Orientation SETGET
   METHOD Preview SETGET
   METHOD TextMaxRow SETGET
   METHOD LastExportFileName SETGET
   
   METHOD DecimalSymbol SETGET
   METHOD ColumnPicture SETGET
   
   METHOD ParseQuote
   METHOD HTMLAlign
   METHOD LoadPaperSizes
   METHOD TextJustify
   METHOD PrintLen
   METHOD PrintLine
   METHOD PrintMultiLine
   METHOD StartNewPage
   METHOD PrintData
   METHOD StripComma
   METHOD PrintMergeHeaders

   
   METHOD DrawScale
   METHOD PrinterChanged
   METHOD PaperSizeChanged
   METHOD OrientationChanged
   METHOD CustomSizeSelected
   METHOD MarginChanged
   METHOD PaperWidthChanged
   METHOD PaperHeightChanged
   METHOD ColumnSizeCheck
   METHOD ColumnSumChecked
   METHOD AddToGroup
   METHOD DelFromGroup
   METHOD MoveUpGroup
   METHOD MoveDownGroup
   Method SelectReportHeaderFont
   Method SelectReportFooterFont
   Method SelectReportFont
   Method ControlsFontUpdate
   METHOD AddMergeHeader
   METHOD RemoveMergeHeader
   Method MergeHeadersUpdate
   Method GPOnQuery
   METHOD SliderLeftMarginChanged
   METHOD SliderRightMarginChanged
   
end class

METHOD New CLASS GridPlus
   ::nPaperHeight := 297 // default for A4 size
   ::nPaperWidth := 210 // default for A4 Size
   ::nLeftMargin := 15 
   ::nRightMargin := 15
   ::nTopMargin := 15
   ::nBottomMargin := 15
   ::nRowHeight := 5
   ::cPrinter := GetDefaultPrinter()
   ::aReportHeaderFont := { 'Arial', 12, .t., .f., .t., .f. } // { cFontName, nFontSize, lBold, lItalic, lUnderline, lStrikeout }
   ::aReportFooterFont := { 'Arial', 12, .t., .f., .f., .f. }
   ::aReportFont := { 'Arial', 10, .f., .f., .f., .f. }
   ::aCellFont := {}
   ::LoadPaperSizes()
RETURN self

METHOD AddArrayData( aArray, lFormatted ) CLASS GridPlus
   local i := 0
   local j := 0
   local nRowCount := hmg_len( aArray )
   local aLineData := {}
   default lFormatted := .f.
   ::nColumnCount := 0
   asize( ::aData, 0 )
   asize( ::aColumnHeaders, 0 )
   asize( ::aColumnJustify, 0 )
   asize( ::aColumnWidths, 0 )
   if nRowCount > 0
      ::nColumnCount := hmg_len( aArray[ 1 ] )
      if lFormatted // already formatted array. Just clone
         ::aData := aclone( aArray )
      else // now format
         for i := 1 to nRowCount
            asize( aLineData, 0 )
            for j := 1 to ::nColumnCount
               do case
               case valtype( aArray[ i, j ] ) == 'N' // numeric
                  aadd( aLineData, ltrim( str( aArray[ i, j ] ) ) )
               case valtype( aArray[ i, j ] ) == 'D' // date  
                  aadd( aLineData, dtoc( aArray[ i, j ] ) )
               case valtype( aArray[ i, j ] ) == 'L' // Logic
                  aadd( aLineData, if( aArray[ i, j ], 'T', 'F' ) )
               otherwise  // character
                  aadd( aLineData, aArray[ i, j ] )
               endcase
            next j
            aadd( ::aData, aclone( aLineData ) )
         next i            
      endif                         
      for i := 1 to ::nColumnCount
         aadd( ::aColumnHeaders, 'Column ' + alltrim( str( i ) ) )
         aadd( ::aColumnJustify, if( valtype( aArray[ 1, i ] ) == 'N', 1, 0 ) )
         aadd( ::aColumnWidths, ::nDefaultColumnWidth )
      next i   
   endif   
Return SELF

METHOD AddGridData( cForm, cGrid )
   local i := 0
   local j := 0
   local nRowCount := getproperty( cForm, cGrid, 'ITEMCOUNT' )
   local aLineData := {}
   local aFormattedLineData := {}
   local xItem
   local aEditControls := {} 
   local aComboItems := {}

   asize( ::aData, 0 )
   asize( ::aColumnHeaders, 0 ) 
   asize( ::aColumnJustify, 0 )
   asize( ::aColumnWidths, 0 )
   ::nColumnCount := getproperty( cForm, cGrid, 'COLUMNCOUNT' )
   for i := 1 to ::nColumnCount
      aadd( ::aColumnHeaders, getproperty( cForm, cGrid, 'COLUMNHEADER', i ) )
      aadd( ::aColumnJustify, getproperty( cForm, cGrid, 'COLUMNJUSTIFY', i ) )
      aadd( ::aColumnWidths, getproperty( cForm, cGrid, 'COLUMNWIDTH', i ) / ::nMM2Pixel )
      aadd( aEditControls, getproperty( cForm, cGrid, 'COLUMNCONTROL', i ) )
   next i
   if nRowCount > 0
      for i := 1 to nRowCount
         aLineData := getproperty( cForm, cGrid, 'ITEM', i )
         asize( aFormattedLineData, 0 )
         for j := 1 to ::nColumnCount
            if ValType( aEditControls[ j ] ) == 'U' // control undefined
               aadd( aFormattedLineData, aLineData[ j ] )
            else // control defined.    
               do case 
               case ValType( aLineData[ j ] ) == 'N'
                  if aEditControls[ j, 1 ] == 'COMBOBOX'
                     aComboItems := aEditControls[ j, 2 ]
                     aadd( aFormattedLineData, aComboItems[ aLineData[ j ] ] )
                  else  // spinner/numeric textbox. just format
                     aadd( aFormattedLineData, ltrim( str( aLineData[ j ] ) ) )
                  endif   
               case ValType( aLineData[ j ] ) == 'D'
                  aadd( aFormattedLineData, dtoc( aLineData[ j ] ) )
               case ValType( aLineData[ j ] ) == 'L'
                  if aEditControls[ j, 1 ] == 'CHECKBOX'
                     if aLineData[ j ]
                        aadd( aFormattedLineData, aEditControls[ j, 2 ] )
                     else   
                        aadd( aFormattedLineData, aEditControls[ j, 3 ] )
                     endif
                  else
                     aadd( aFormattedLineData, if( aLineData[ j ], 'T', 'F' ) )
                  endif                     
               otherwise
                  aadd( aFormattedLineData, aLineData[ j ] )
               endcase
            endif
         next j
         aadd( ::aData, aclone( aFormattedLineData ) )
      next i   
   endif   
return self

METHOD Export2CSV( cFileName, lHeaderRow ) CLASS GridPlus
   local fHandle := nil
   local i := 0
   local j := 0
   local k := 0
   local nRowCount := hmg_len( ::aData )
   local cLine := ''
   local cLineBreak := chr( 13 )
   local lStarted := .f.
   local cbuffer := ''
   local nBuffer := 0
   local nRecBuffer := 10000
   default lHeaderRow := .t.
   if nRowCount == 0 // no data
      return nil
   endif
   if pcount() == 0
      cFileName :=  PutFile ( { { "Comma Separated Value Files (*.csv)", "*.csv" } }, "Export to text file (CSV)", , .f. ) 
      if hmg_len( alltrim( cFileName ) ) == 0
         return nil
      endif
      if at( ".csv", hmg_lower( cFileName) ) > 0
         if .not. hb_uright( hmg_lower( cFileName), 4 ) == ".csv"
            cFileName := cFileName + ".csv"
         endif
      else
         cFileName := cFileName + ".csv"
      endif
   endif
   fHandle := fcreate( cFileName )
   if fHandle < 0
      msgstop( "File "+ cFileName + " could not be created!" )
      return nil
   endif
   if hmg_len( ::aColumnHeaders ) > 0 .and. lHeaderRow // add header row
      lStarted := .f.
      for i := 1 to ::nColumnCount
         if ::aColumnWidths[ i ] > 0
            if lstarted
               cLine := cLine + ','
            else
               lStarted := .t.
            endif
            cLine := cLine + '"' + ::parsequote( ::aColumnHeaders[ i ] ) + '"'
         endif         
      next i
      cLine := cLine + cLineBreak
      fwrite( fHandle, cLine )
   endif   
   // add data
   for i := 1 to nRowCount
      if nRowCount - i > nRecBuffer
         nBuffer := i + nRecBuffer - 1
      else
         nBuffer := nRowCount
      endif
      cBuffer := ''
      for k := i to nBuffer
         cLine := ''   
         lStarted := .f.
         for j := 1 to ::nColumnCount
            if ::aColumnWidths[ j ] > 0
               if lstarted
                  cLine := cLine + ','
               else
                  lStarted := .t.
               endif
               cLine := cLine + '"' + ::ParseQuote( memotran( ::aData[ i, j ], " ", " ")  ) + '"'
            endif   
         next j
         cLine := cLine + cLineBreak
         cBuffer := cBuffer + cLine
         if i < nBuffer
            i := i + 1
         endif
      next k   
      fwrite( fHandle, cBuffer )
   next i   
   if fclose( fHandle )
      ::cLastExportFileName = cFileName
      msginfo( 'Exported to file ' + cFileName + ' Successfully!' )
   else
      msgstop( 'Error in saving the file - ' + cFileName + '!' )
   endif
return nil 

METHOD Export2HTML( cFileName ) CLASS GridPlus
   local fHandle := nil
   local i := 0
   local j := 0
   local nRowCount := hmg_len( ::aData )
   local cHTML := ''
   local cHeader := ''
   local cFontName := ::aReportFont[ 1 ]
   local nFontSize := ::aReportFont[ 2 ]
   local nMM2Pixel := 3.7795
   local aHTMLColumnJustify := {}
   local aHTMLColumnWidths := {}
   local nTotalWidth := 0
   local aLineData := {}
   local aColTotal := {}
   local lGrouping := .f.
   local n1stGroup := 0
   local n2ndGroup := 0
   local n3rdGroup := 0
   local lColSum := .f.
   local cCur1stGroup := ''
   local cCur2ndGroup := ''
   local cCur3rdGroup := ''
   local nColShowCount := 0
   local cGroupTD := ''
   local a1stGroupTotal := {}
   local a2ndGroupTotal := {}
   local a3rdGroupTotal := {}
   local nValue := 0
   local nPos := 0
   local nRecBuffer := 300
   local nBuffer := 0
   

   if nRowCount == 0 // no data
      return nil
   endif
   if pcount() == 0
      cFileName :=  PutFile ( { { "HTML Files (*.html)", "*.html" } }, "Export to HTML file", , .f. ) 
      if hmg_len( alltrim( cFileName ) ) == 0
         return nil
      endif
      if at( ".html", hmg_lower( cFileName) ) > 0
         if .not. hb_uright( hmg_lower( cFileName), 5 ) == ".html"
            cFileName := cFileName + ".html"
         endif
      else
         cFileName := cFileName + ".html"
      endif
   endif
   fHandle := fcreate( cFileName )
   if fHandle < 0
      msgstop( "File "+ cFileName + " could not be created!" )
      return nil
   endif
   if hmg_len( ::cReportHeader1 ) > 0
      cHeader := ::cReportHeader1
   endif 
   for i := 1 to ::nColumnCount
      aadd( aHTMLColumnWidths, ::aColumnWidths[ i ] * nMM2Pixel )   
      aadd( aHTMLColumnJustify, ::HTMLAlign( ::aColumnJustify[ i ] ) )
      nTotalWidth := nTotalWidth + ( ::aColumnWidths[ i ] * nMM2Pixel ) 
      if ::aColumnWidths[ i ] > 0
         nColShowCount++
      endif
   next i   
   if hmg_len( ::aGroupColumns ) == 0
      lGrouping := .f.
   else
      lGrouping := .t.
      n1stGroup := ::aGroupColumns[ 1 ]
      do case
      case hmg_len( ::aGroupColumns ) == 2 
         n2ndGroup := ::aGroupColumns[ 2 ]
      case hmg_len( ::aGroupColumns ) > 2
         n2ndGroup := ::aGroupColumns[ 2 ]
         n3rdGroup := ::aGroupColumns[ 3 ]
      endcase   
   endif   
   if hmg_len( ::aColumnSum ) > 0
      lColSum := .t.
      for i := 1 to hmg_len( ::aColumnSum )
         aadd( aColTotal, 0 )
         aadd( a1stGroupTotal, 0 )
         aadd( a2ndGroupTotal, 0 )
         aadd( a3rdGroupTotal, 0 )
      next i
   else
      lColSum := .f.
   endif
   
   cHTML := '<HTML>' + CRLF
   if hmg_len( cHeader ) > 0
      cHTML := cHTML + '<HEAD><TITLE>' + cHeader + '</TITLE></HEAD>' + CRLF
   endif
   cHTML := cHTML + '<STYLE>' + CRLF
   cHTML := cHTML + '.td1 { font-family:"' + cFontName + '", "Arial"; font-size:' + alltrim( str( nFontSize ) ) + 'pt; border-style:outset; border-width:0 }' + CRLF
   cHTML := cHTML + 'table { border-collapse: collapse }' + CRLF
   cHTML := cHTML + 'td, th { font-family:"' + cFontName + '", "Arial"; font-size:' + alltrim( str( nFontSize ) ) + 'pt; border-style:outset; border-width:1; padding: 2px }' + CRLF
   cHTML := cHTML + 'tr:hover {background-color: #f5f5f5}' + CRLF
   cHTML := cHTML + 'table-layout: fixed' + CRLF 
   cHTML := cHTML + '</STYLE>'
   cHTML := cHTML + '<BODY TOPMARGIN=' + alltrim( str( ::nTopMargin ) ) + ' LEFTMARGIN=' + alltrim( str( ::nLeftMargin ) ) + ' RIGHTMARGIN=' + alltrim( str( ::nRightMargin ) ) + ' BOTTOMMARGIN=' + alltrim( str( ::nBottomMargin ) ) + '>' + CRLF
   
   // report headers table   
   if hmg_len( alltrim( ::cReportHeader1 ) ) > 0
      cHTML := cHTML + '<TABLE Width="' + alltrim( str( nTotalWidth ) ) + '">' + CRLF
      cHTML := cHTML + '<TR><TD align="CENTER" class="TD1"><font size=5><u>' + ::cReportHeader1 + '</u></font></TD></TR>' + CRLF
      cHTML := cHTML + '</TABLE>' + CRLF
   endif   
   if hmg_len( alltrim( ::cReportHeader2 ) ) > 0
      cHTML := cHTML + '<TABLE Width="' + alltrim( str( nTotalWidth ) ) + '">' + CRLF
      cHTML := cHTML + '<TR><TD align="CENTER" class="TD1"><font size=5><u>' + ::cReportHeader2 + '</u></font></TD></TR>' + CRLF
      cHTML := cHTML + '</TABLE>' + CRLF
   endif   
   if hmg_len( alltrim( ::cReportHeader3 ) ) > 0
      cHTML := cHTML + '<TABLE Width="' + alltrim( str( nTotalWidth ) ) + '">' + CRLF
      cHTML := cHTML + '<TR><TD align="CENTER" class="TD1"><font size=5><u>' + ::cReportHeader3 + '</u></font></TD></TR>' + CRLF
      cHTML := cHTML + '</TABLE>' + CRLF
   endif   
   
   // Main Table
   
   cHTML := cHTML + '<TABLE Width="' + alltrim( str( nTotalWidth ) ) + '">' + CRLF
   // Column Headers
   if hmg_len( ::aMergeHeaders  ) > 0
      cHTML := cHTML + '<TR>' + CRLF
      i := 1
      cHTML := cHTML + '<TR>' + CRLF
      for j := 1 to hmg_len( ::aMergeHeaders )
         nStartCol := ::aMergeHeaders[ j, 1 ]
         nEndCol := ::aMergeHeaders[ j, 2 ]
         cHeader := ::aMergeHeaders[ j, 3 ]
         nSpan := 0
         nTotalWidth := 0
         do while i < nStartCol
            if ::aColumnWidths[ i ] > 0
               nTotalWidth := nTotalWidth + ::aColumnWidths[ i ]
               nSpan := nSpan + 1
            endif   
            i++
         enddo
         if nSpan > 0
            cHTML := cHTML + '<TD WIDTH=' + alltrim( str( nTotalWidth  ) ) + ' ALIGN="' + 'CENTER' + '" colspan="' + alltrim( str( nSpan ) ) + '" border-width=0><B>' + '' + '</B></TD>' + CRLF
         endif
         nSpan := 0
         nTotalWidth := 0
         do while i <= nEndCol
            if ::aColumnWidths[ i ] > 0
               nTotalWidth := nTotalWidth + ::aColumnWidths[ i ]
               nSpan := nSpan + 1
            endif   
            i++
         enddo
         if nSpan > 0
            cHTML := cHTML + '<TD WIDTH=' + alltrim( str( nTotalWidth  ) ) + ' ALIGN="' + 'CENTER' + '" colspan="' + alltrim( str( nSpan ) ) + '" border-width=0><B>' + cHeader + '</B></TD>' + CRLF
         endif
      next j
      nSpan := 0
      nTotalWidth := 0
      do while i <= ::nColumnCount
         if ::aColumnWidths[ i ] > 0
            nTotalWidth := nTotalWidth + ::aColumnWidths[ i ]
            nSpan := nSpan + 1
         endif   
         i++
      enddo
      if nSpan > 0
         cHTML := cHTML + '<TD WIDTH=' + alltrim( str( nTotalWidth  ) ) + ' ALIGN="' + 'CENTER' + '" colspan="' + alltrim( str( nSpan ) ) + '" border-width=0><B>' + '' + '</B></TD>' + CRLF
      endif
      cHTML := cHTML + '</TR>' + CRLF
   endif
   
   cHTML := cHTML + '<TR>' + CRLF
   for i := 1 to ::nColumnCount
      if aHTMLColumnWidths[ i ] > 0
         cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ i ]  ) ) + ' ALIGN="' + aHTMLColumnJustify[ i ] + '" border-width=0><B>' + ::aColumnHeaders[ i ] + '</B></TD>' + CRLF
      endif
   next i
   cHTML := cHTML + '</TR>' + CRLF
   
   // Now it is time for data
   if lGrouping
      cGroupTD := '<TD align="LEFT" Width=' + alltrim( str( nTotalWidth ) ) + ' colspan="' + alltrim( str( nColShowCount ) ) + '">' 
      aLineData := ::aData[ 1 ]
      cCur1stGroup := aLineData[ n1stGroup ]
      cHTML := cHTML + '<TR>' + CRLF
      cHTML := cHTML + cGroupTD + '<b>' + alltrim( ::aColumnHeaders[ n1stGroup ] ) + ' : ' + alltrim( cCur1stGroup ) + '</b></TD>' + CRLF
      cHTML := cHTML + '</TR>' + CRLF
      if n2ndGroup > 0
         cCur2ndGroup := aLineData[ n2ndGroup ]
         cHTML := cHTML + '<TR>' + CRLF
         cHTML := cHTML + cGroupTD + replicate( '&nbsp;', ::nGroupIndent ) + '<b>' + alltrim( ::aColumnHeaders[ n2ndGroup ] ) + ' : ' + alltrim( cCur2ndGroup ) + '</b></TD>' + CRLF
         cHTML := cHTML + '</TR>' + CRLF
      endif
      if n3rdGroup > 0
         cCur3rdGroup := aLineData[ n3rdGroup ]
         cHTML := cHTML + '<TR>' + CRLF
         cHTML := cHTML + cGroupTD + replicate( '&nbsp;', ::nGroupIndent + ::nGroupIndent ) + '<b>' + alltrim( ::aColumnHeaders[ n3rdGroup ] ) + ' : ' + alltrim( cCur3rdGroup ) + '</b></TD>' + CRLF
         cHTML := cHTML + '</TR>' + CRLF
      endif
   endif
   fWrite( fHandle, cHTML )   
   cHTML := ''
   for i := 1 to nRowCount
      if nRowCount - i > nRecBuffer
         nBuffer := i + nRecBuffer - 1
      else
         nBuffer := nRowCount
      endif
      cHTML := ''
      for k := i to nBuffer
         aLineData := ::aData[ i ]
         // do we need a group/subgroup header change?
         if lGrouping
            if .not. aLineData[ n1stGroup ] == cCur1stGroup
               if lColSum
                  // print all levels of total
                  // print 3rd group total if available
                  if n3rdGroup > 0
                     cHTML := cHTML + '<TR>' + CRLF
                     for j := 1 to ::nColumnCount
                        if aHTMLColumnWidths[ j ] > 0
                           nPos := ascan( ::aColumnSum, j )
                           if nPos == 0 // this column is not summed up. empty cell
                              cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '</TD>' + CRLF
                           else // print corresponding total
                              if hmg_len( ::aColumnPicture ) == 0 // no picture mentioned
                                 cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( str( a3rdGroupTotal[ nPos ] ) ) + '</b></TD>' + CRLF
                              else                              
                                 cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( transform( a3rdGroupTotal[ nPos ], ::aColumnPicture[ j ] ) ) + '</b></TD>' + CRLF
                              endif   
                           endif                     
                        endif
                     next i
                     cHTML := cHTML + '</TR>' + CRLF
                  endif
                  if n2ndGroup > 0
                     cHTML := cHTML + '<TR>' + CRLF
                     for j := 1 to ::nColumnCount
                        if aHTMLColumnWidths[ j ] > 0
                           nPos := ascan( ::aColumnSum, j )
                           if nPos == 0 // this column is not summed up. empty cell
                              cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '</TD>' + CRLF
                           else // print corresponding total
                              if hmg_len( ::aColumnPicture ) == 0 
                                 cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( str( a2ndGroupTotal[ nPos ] ) ) + '</b></TD>' + CRLF
                              else
                                 cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( transform( a2ndGroupTotal[ nPos ], ::aColumnPicture[ j ] ) ) + '</b></TD>' + CRLF
                              endif   
                           endif                     
                        endif
                     next i
                     cHTML := cHTML + '</TR>' + CRLF
                  endif
                  cHTML := cHTML + '<TR>' + CRLF
                  for j := 1 to ::nColumnCount
                     if aHTMLColumnWidths[ j ] > 0
                        nPos := ascan( ::aColumnSum, j )
                        if nPos == 0 // this column is not summed up. empty cell
                           cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '</TD>' + CRLF
                        else // print corresponding total
                           if hmg_len( ::aColumnPicture ) == 0
                              cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( str( a1stGroupTotal[ nPos ] ) ) + '</b></TD>' + CRLF
                           else   
                              cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( transform( a1stGroupTotal[ nPos ], ::aColumnPicture[ j ] ) ) + '</b></TD>' + CRLF
                           endif   
                        endif                     
                     endif
                  next i
                  cHTML := cHTML + '</TR>' + CRLF
               endif               
               // group head change
               afill( a1stGroupTotal, 0 )
               afill( a2ndGroupTotal, 0 )
               afill( a3rdGroupTotal, 0 )
               cCur1stGroup := aLineData[ n1stGroup ]
               cHTML := cHTML + '<TR>' + CRLF
               cHTML := cHTML + cGroupTD + '<b>' + alltrim( ::aColumnHeaders[ n1stGroup ] ) + ' : ' + alltrim( cCur1stGroup ) + '</b></TD>' + CRLF
               cHTML := cHTML + '</TR>' + CRLF
               // since 1st group is changed, we have to change subgroup headings also!
               if n2ndGroup > 0
                  cCur2ndGroup := aLineData[ n2ndGroup ]
                  cHTML := cHTML + '<TR>' + CRLF
                  cHTML := cHTML + cGroupTD + replicate( '&nbsp;', ::nGroupIndent ) + '<b>' + alltrim( ::aColumnHeaders[ n2ndGroup ] ) + ' : ' + alltrim( cCur2ndGroup ) + '</b></TD>' + CRLF
                  cHTML := cHTML + '</TR>' + CRLF
               endif
               if n3rdGroup > 0
                  cCur3rdGroup := aLineData[ n3rdGroup ]
                  cHTML := cHTML + '<TR>' + CRLF
                  cHTML := cHTML + cGroupTD + replicate( '&nbsp;', ::nGroupIndent + ::nGroupIndent ) + '<b>' + alltrim( ::aColumnHeaders[ n3rdGroup ] ) + ' : ' + alltrim( cCur3rdGroup ) + '</b></TD>' + CRLF
                  cHTML := cHTML + '</TR>' + CRLF
               endif
            else   
               if n2ndGroup > 0
                  if .not. aLineData[ n2ndGroup ] == cCur2ndGroup
                     if lColSum
                        // summation entries for 3rd group and 2nd group
                        if n3rdGroup > 0
                           cHTML := cHTML + '<TR>' + CRLF
                           for j := 1 to ::nColumnCount
                              if aHTMLColumnWidths[ j ] > 0
                                 nPos := ascan( ::aColumnSum, j )
                                 if nPos == 0 // this column is not summed up. empty cell
                                    cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '</TD>' + CRLF
                                 else // print corresponding total
                                    if hmg_len( ::aColumnPicture ) == 0
                                       cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( str( a3rdGroupTotal[ nPos ] ) ) + '</b></TD>' + CRLF
                                    else   
                                       cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( transform( a3rdGroupTotal[ nPos ], ::aColumnPicture[ j ] ) ) + '</b></TD>' + CRLF
                                    endif   
                                 endif                     
                              endif
                           next i
                           cHTML := cHTML + '</TR>' + CRLF
                        endif
                        if n2ndGroup > 0
                           cHTML := cHTML + '<TR>' + CRLF
                           for j := 1 to ::nColumnCount
                              if aHTMLColumnWidths[ j ] > 0
                                 nPos := ascan( ::aColumnSum, j )
                                 if nPos == 0 // this column is not summed up. empty cell
                                    cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '</TD>' + CRLF
                                 else // print corresponding total
                                    if hmg_len( ::aColumnPicture ) == 0
                                       cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( str( a2ndGroupTotal[ nPos ] ) ) + '</b></TD>' + CRLF
                                    else
                                       cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( transform( a2ndGroupTotal[ nPos ], ::aColumnPicture[ j ] ) ) + '</b></TD>' + CRLF
                                    endif                                 
                                 endif                     
                              endif
                           next i
                           cHTML := cHTML + '</TR>' + CRLF
                        endif
                     endif
                     // second level group changed
                     afill( a2ndGroupTotal, 0 )
                     afill( a3rdGroupTotal, 0 )
                     cCur2ndGroup := aLineData[ n2ndGroup ]
                     cHTML := cHTML + '<TR>' + CRLF
                     cHTML := cHTML + cGroupTD + replicate( '&nbsp;', ::nGroupIndent ) + '<b>' + alltrim( ::aColumnHeaders[ n2ndGroup ] ) + ' : ' + alltrim( cCur2ndGroup ) + '</b></TD>' + CRLF
                     cHTML := cHTML + '</TR>' + CRLF
                     // change for 3rd level grouping if available
                     if n3rdGroup > 0
                        cCur3rdGroup := aLineData[ n3rdGroup ]
                        cHTML := cHTML + '<TR>' + CRLF
                        cHTML := cHTML + cGroupTD + replicate( '&nbsp;', ::nGroupIndent + ::nGroupIndent ) + '<b>' + alltrim( ::aColumnHeaders[ n3rdGroup ] ) + ' : ' + alltrim( cCur3rdGroup ) + '</b></TD>' + CRLF
                        cHTML := cHTML + '</TR>' + CRLF
                     endif
                  else
                  // check for 3rd level grouping
                     if n3rdGroup > 0
                        if .not. aLineData[ n3rdGroup ] == cCur3rdGroup
                           if lColSum 
                           // summation for 3rd grouping
                              cHTML := cHTML + '<TR>' + CRLF
                              for j := 1 to ::nColumnCount
                                 if aHTMLColumnWidths[ j ] > 0
                                    nPos := ascan( ::aColumnSum, j )
                                    if nPos == 0 // this column is not summed up. empty cell
                                       cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '</TD>' + CRLF
                                    else // print corresponding total
                                       cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( str( a3rdGroupTotal[ nPos ] ) ) + '</b></TD>' + CRLF
                                    endif                     
                                 endif
                              next i
                              cHTML := cHTML + '</TR>' + CRLF
                           endif   
                           afill( a3rdGroupTotal, 0 )
                           cCur3rdGroup := aLineData[ n3rdGroup ]
                           cHTML := cHTML + '<TR>' + CRLF
                           cHTML := cHTML + cGroupTD + replicate( '&nbsp;', ::nGroupIndent + ::nGroupIndent ) + '<b>' + alltrim( ::aColumnHeaders[ n3rdGroup ] ) + ' : ' + alltrim( cCur3rdGroup ) + '</b></TD>' + CRLF
                           cHTML := cHTML + '</TR>' + CRLF
                        endif
                     endif
                  endif                  
               endif            
            endif
         endif      
         if lColSum
            for n := 1 to hmg_len( ::aColumnSum )
               nValue := val( alltrim( ::StripComma( aLineData[ ::aColumnSum[ n ] ] ) ) )
               aColTotal[ n ] := aColTotal[ n ] + nValue
               if lGrouping
                  a1stGroupTotal[ n ] := a1stGroupTotal[ n ] + nValue
                  a2ndGroupTotal[ n ] := a2ndGroupTotal[ n ] + nValue
                  a3rdGroupTotal[ n ] := a3rdGroupTotal[ n ] + nValue
               endif   
            next n
         endif
         cHTML := cHTML + '<TR>' + CRLF
         for j := 1 to ::nColumnCount
            if aHTMLColumnWidths[ j ] > 0
               cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + aLineData[ j ] + '</TD>' + CRLF
            endif
         next j
         cHTML := cHTML + '</TR>' + CRLF
         if i < nBuffer
            i := i + 1
         endif
         fWrite( fHandle, cHTML )   
      next k   
   next i         
   cHTML := ''
   if lColSum
      if lGrouping
         // print all levels of total
         // print 3rd group total if available
         if n3rdGroup > 0
            cHTML := cHTML + '<TR>' + CRLF
            for j := 1 to ::nColumnCount
               if aHTMLColumnWidths[ j ] > 0
                  nPos := ascan( ::aColumnSum, j )
                  if nPos == 0 // this column is not summed up. empty cell
                     cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '</TD>' + CRLF
                  else // print corresponding total
                     if hmg_len( ::aColumnPicture ) == 0
                        cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( str( a3rdGroupTotal[ nPos ] ) ) + '</b></TD>' + CRLF
                     else  
                        cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( transform( a3rdGroupTotal[ nPos ], ::aColumnPicture[ j ] ) ) + '</b></TD>' + CRLF
                     endif   
                  endif                     
               endif
            next i
            cHTML := cHTML + '</TR>' + CRLF
         endif
         if n2ndGroup > 0
            cHTML := cHTML + '<TR>' + CRLF
            for j := 1 to ::nColumnCount
               if aHTMLColumnWidths[ j ] > 0
                  nPos := ascan( ::aColumnSum, j )
                  if nPos == 0 // this column is not summed up. empty cell
                     cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '</TD>' + CRLF
                  else // print corresponding total
                     if hmg_len( ::aColumnPicture ) == 0
                        cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( str( a2ndGroupTotal[ nPos ] ) ) + '</b></TD>' + CRLF
                     else
                        cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( transform( a2ndGroupTotal[ nPos ], ::aColumnPicture[ j ] ) ) + '</b></TD>' + CRLF
                     endif                     
                  endif                     
               endif
            next i
            cHTML := cHTML + '</TR>' + CRLF
         endif
         cHTML := cHTML + '</TR>' + CRLF
         for j := 1 to ::nColumnCount
            if aHTMLColumnWidths[ j ] > 0
               nPos := ascan( ::aColumnSum, j )
               if nPos == 0 // this column is not summed up. empty cell
                  cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '</TD>' + CRLF
               else // print corresponding total
                  if hmg_len( ::aColumnPicture ) == 0
                     cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( str( a1stGroupTotal[ nPos ] ) ) + '</b></TD>' + CRLF
                  else    
                     cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' + alltrim( transform( a1stGroupTotal[ nPos ], ::aColumnPicture[ j ] ) ) + '</b></TD>' + CRLF
                  endif   
               endif                     
            endif
         next i
         cHTML := cHTML + '</TR>' + CRLF
      endif               
      // now time for grand total
      cHTML := cHTML + '<TR>' + CRLF
      for j := 1 to ::nColumnCount
         if aHTMLColumnWidths[ j ] > 0
            nPos := ascan( ::aColumnSum, j )
            if nPos == 0 // this column is not summed up. empty cell
               cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '</TD>' + CRLF
            else // print corresponding total
               if hmg_len( ::aColumnPicture ) == 0
                  cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' +  alltrim( str( aColTotal[ nPos ] ) ) + '</b></TD>' + CRLF
               else   
                  cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aHTMLColumnWidths[ j ] ) ) + ' ALIGN="' + aHTMLColumnJustify[ j ] + '">' + '<b>' +  alltrim( transform( aColTotal[ nPos ], ::aColumnPicture[ j ] ) ) + '</b></TD>' + CRLF
               endif   
            endif                     
         endif
      next i
      cHTML := cHTML + '</TR>' + CRLF
   endif      
   cHTML := cHTML + '</TABLE>' + CRLF
   
   // footers
   if hmg_len( alltrim( ::cReportFooter ) ) > 0
      cHTML := cHTML + '<TABLE Width="' + alltrim( str( nTotalWidth ) ) + '">' + CRLF
      cHTML := cHTML + '<TR><TD align="CENTER" class="TD1">' + ::cReportFooter + '</TD></TR>' + CRLF
      cHTML := cHTML + '</TABLE>' + CRLF
   endif
   // date and time
   cDateTime := ''
   if ::lIncludeDate
      cDateTime := ::cDatePrefix + dtoc( date() ) + ' '
   endif
   if ::lIncludeTime
      cDateTime := cDateTime + ::cTimePrefix + time()
   endif
   if hmg_len( cDateTime ) > 0
      cHTML := cHTML + '<TABLE Width="' + alltrim( str( nTotalWidth ) ) + '">' + CRLF
      cHTML := cHTML + '<TR><TD align="' + ::HTMLAlign( ::nDateTimeAlignment ) + '" class="TD1">' + cDateTime + '</TD></TR>' + CRLF
      cHTML := cHTML + '</TABLE>' + CRLF
   endif   
   cHTML := cHTML + '</HTML>' + CRLF
   fWrite( fHandle, cHTML )   
   if fclose( fHandle )
      ::cLastExportFileName = cFileName
      msginfo( 'Exported to file ' + cFileName + ' Successfully!' )
   else   
      msgstop( 'Error in Saving the File - ' + cFileName + '!' )
   endif      
return nil   

METHOD PrintGrid() CLASS GridPlus
   local nRowCount := hmg_len( ::aData )
   local lSuccess := .f.
   local cFontName := ::aReportFont[ 1 ]
   local nFontSize := ::aReportFont[ 2 ]
   local cHeadFontName := ::aReportHeaderFont[ 1 ]
   local nHeadFontSize := ::aReportHeaderFont[ 2 ]
   local ho, vo := 0
   local aColumns := {}
   local aTiles := {}
   
   local aPrintLine := {}
   
   local aColTotal := {}
   local lGrouping := .f.
   local n1stGroup := 0
   local n2ndGroup := 0
   local n3rdGroup := 0
   local lColSum := .f.
   local cCur1stGroup := ''
   local cCur2ndGroup := ''
   local cCur3rdGroup := ''
   local a1stGroupTotal := {}
   local a2ndGroupTotal := {}
   local a3rdGroupTotal := {}
   local i, j, k := 0
   ::nPrintLeftMargin := ::nLeftMargin
   
   if ::nPaperSize == 256 // custom size
      select printer ::cPrinter ;
         to lSuccess ;
         ORIENTATION ::nOrientation ;
         Papersize ::nPaperSize ;
         paperlength ::nPaperHeight ;
         paperwidth ::nPaperWidth ;
         preview
   else
      select printer ::cPrinter ;
         to lSuccess ;
         ORIENTATION ::nOrientation ;
         Papersize ::nPaperSize ;
         preview
   endif
   if .not. lSuccess
      msgstop( 'Printer Error!' )   
      return nil
   endif
   // real paper dimensions
   if ::nPaperSize == 256
      if ::nOrientation == 1 // portrait
         ::nPrintPaperWidth := ::nPaperWidth
         ::nPrintPaperHeight := ::nPaperHeight
      else
         ::nPrintPaperWidth := ::nPaperHeight
         ::nPrintPaperHeight := ::nPaperWidth
      endif
   else
      HO := GETPRINTABLEAREAHORIZONTALOFFSET()
      VO := GETPRINTABLEAREAVERTICALOFFSET()
      ::nPrintPaperWidth :=  GETPRINTABLEAREAWIDTH() + ( HO * 2 ) 
      ::nPrintPaperHeight := GETPRINTABLEAREAHEIGHT() + ( VO * 2 ) 
   endif   
   ::nPrintLineHeight := max( int( nFontSize / 72 * 25.4 )  + 1, ::nRowHeight ) 
   start printdoc
   if ::lPageNumbering .and. ( ::nPageNumberPosition == 2 .or. ::nPageNumberPosition == 3 )
      ::nPrintMaxRow := ::nPrintPaperHeight - ::nBottomMargin - ::nPrintLineHeight - ::nPrintLineHeight
   else   
      ::nPrintMaxRow := ::nPrintPaperHeight - ::nBottomMargin - ::nPrintLineHeight 
   endif   
   ::nPrintMaxCol := ::nPrintPaperWidth - ::nRightMargin
   if hmg_len( ::aGroupColumns ) == 0
      lGrouping := .f.
   else
      lGrouping := .t.
      n1stGroup := ::aGroupColumns[ 1 ]
      do case
      case hmg_len( ::aGroupColumns ) == 2 
         n2ndGroup := ::aGroupColumns[ 2 ]
      case hmg_len( ::aGroupColumns ) > 2
         n2ndGroup := ::aGroupColumns[ 2 ]
         n3rdGroup := ::aGroupColumns[ 3 ]
      endcase   
   endif   
   if hmg_len( ::aColumnSum ) > 0
      lColSum := .t.
      for i := 1 to hmg_len( ::aColumnSum )
         aadd( aColTotal, 0 )
         aadd( a1stGroupTotal, 0 )
         aadd( a2ndGroupTotal, 0 )
         aadd( a3rdGroupTotal, 0 )
      next i
   else
      lColSum := .f.
   endif
   
   // find max column
   nCol := ::nLeftMargin
   asize( aColumns, 0 )
   for i := 1 to hmg_len( ::aColumnWidths )
      if ::aColumnWidths[ i ] > 0
         if nCol + ::aColumnWidths[ i ] > ::nPrintMaxCol
            // page to be vertically split
            if hmg_len( aColumns ) == 0
               // column is not fit in the page. to avoid infinite loop
               return nil
            else
               aadd( aTiles, aclone( aColumns ) )
               asize( aColumns, 0 )
               nCol := ::nLeftMargin
               aadd( acolumns, i )
               nCol := nCol + ::aColumnWidths[ i ] + ::nColSpacing
            endif
         else
            aadd( acolumns, i )
            nCol := nCol + ::aColumnWidths[ i ] + ::nColSpacing
         endif
      endif
   next i
   if hmg_len( aColumns )  > 0
      aadd( aTiles, aclone( aColumns ) )
   endif   
   for i := 1 to if( ::lTruncateColumns, 1, hmg_len( aTiles ) )
      start printpage
      aColumns := aTiles[ i ]    // printable columns in this tile
      ::aPrintColumns := aclone( aTiles[ i ] )
      asize( aPrintLine, 0 )
      asize( ::aPrintJustify, 0 )
      asize( ::aPrintWidths, 0 )
      ::nPrintMaxCol := ::nPrintLeftMargin
      for j := 1 to hmg_len( aColumns )
         nPrintColumn := aColumns[ j ]
         nColWidth := ::aColumnWidths[ nPrintColumn ]
         ::nPrintMaxCol := ::nPrintMaxCol + nColWidth + ::nColSpacing
         cColumnHeader := alltrim( ::aColumnHeaders[ nPrintColumn ] )
         if ::PrintLen( cColumnHeader, nFontSize, cFontName ) <= nColWidth // fit inside the column 
            aadd( aPrintLine, cColumnHeader )
         else // header is bigger than the column width. to be truncated!
            nCount := hmg_len( cColumnHeader )
            do while ::PrintLen( hb_usubstr( cColumnHeader, 1, nCount ), nFontSize, cFontName ) > nColWidth
               nCount := nCount - 1 
            enddo
            aadd( aPrintLine, hb_usubstr( cColumnHeader, 1, nCount ) )            
         endif
         aadd( ::aPrintJustify, ::aColumnJustify[ nPrintColumn ] )
         aadd( ::aPrintWidths, nColWidth )
      next j
      ::aPrintColumnHeaders := aClone( aPrintLine ) // for reuse in the forthcoming pages!
      if ::lPageCenter // all content shall be in the center of the page. change the left margin
         nOffset := ( ::nPrintPaperWidth - ::nRightMargin ) - ::nPrintMaxCol
         if nOffset > 0.0
            ::nPrintLeftMargin := ::nLeftMargin + int( nOffset / 2 )
            ::nPrintMaxCol := ::nPrintMaxCol + int( nOffset / 2 )
         else
            ::nPrintLeftMargin := ::nLeftMargin
         endif
      else
         ::nPrintLeftMargin := ::nLeftMargin
      endif
      if ::lSpreadWhiteSpace // change the widths proportionate to the paper width
         ::nPrintLeftMargin := ::nLeftMargin
         nOffset := ( ::nPrintPaperWidth - ::nRightMargin ) - ::nPrintMaxCol
         if nOffset > 0.0
            nTotalWidth := 0
            for j := 1 to hmg_len( ::aPrintWidths )
               nTotalWidth := nTotalWidth + ::aPrintWidths[ j ]
            next j   
            nTotalOffset := 0
            for j := 1 to hmg_len( ::aPrintWidths )
               nCurOffset := int( ::aPrintWidths[ j ] / nTotalWidth  * nOffset ) 
               ::aPrintWidths[ j ] := ::aPrintWidths[ j ] + nCurOffset
               nTotalOffset := nTotalOFfset + nCurOffset 
            next j
            ::nPrintMaxCol := ::nPrintMaxCol + nTotalOffset
         endif
      endif         
      ::nPrintCurPage := 1
      ::nPrintCurRow := ::nTopMargin
      ::nPrintCurCol := ::nPrintLeftMargin
      if ::lPageNumbering           
         if ::nPageNumberPosition == 1 .or. ::nPageNumberPosition == 3 // top or both
            cPageNumber := ::cPageNumberPrefix + ' ' + alltrim( str( ::nPrintCurPage, 10, 0 ) )
            do case
            case ::nPageNumberAlignment == 0 // left
               @ ::nPrintCurRow, ::nPrintLeftMargin print cPageNumber font cFontName size nFontSize
            case ::nPageNumberAlignment == 2 // center
               @ ::nPrintCurRow, ::nPrintPaperWidth / 2 print cPageNumber font cFontName size nFontSize center
            case ::nPageNumberAlignment == 1 // right
               @ ::nPrintCurRow, ::nPrintMaxCol print cPageNumber font cFontName size nFontSize right
            endcase
            ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
         endif
      endif
      // headers
      if hmg_len( alltrim( ::cReportHeader1 ) ) > 0
         ::PrintData( ::nPrintCurRow, ::nPrintPaperWidth / 2, ::cReportHeader1, ::aReportHeaderFont, 'CENTER' )
         ::nPrintCurRow := ::nPrintCurRow + int( nHeadFontSize / 72 * 25.4 )  + 3
      endif   
      if hmg_len( alltrim( ::cReportHeader2 ) ) > 0
         ::PrintData( ::nPrintCurRow, ::nPrintPaperWidth / 2, ::cReportHeader2, ::aReportHeaderFont, 'CENTER' )
         ::nPrintCurRow := ::nPrintCurRow + int( nHeadFontSize / 72 * 25.4 )  + 3
      endif   
      if hmg_len( alltrim( ::cReportHeader3 ) ) > 0
         ::PrintData( ::nPrintCurRow, ::nPrintPaperWidth / 2, ::cReportHeader3, ::aReportHeaderFont, 'CENTER' )
         ::nPrintCurRow := ::nPrintCurRow + int( nHeadFontSize / 72 * 25.4 )  + 3
      endif   
      ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
      
      // column headers
      
      if hmg_len( aTiles ) == 1 .and. hmg_len( ::aMergeHeaders ) > 0
         ::lMergeHeader := .t.
         ::PrintMergeHeaders()
         ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
      else
         ::lMergeHeader := .f.      
      endif   
      ::PrintLine( ::aPrintColumnHeaders, .t., .t. ) 
      asize( aPrintLine, 0 )
      ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
      
      // now time for data!
      if lGrouping
         aLineData := ::aData[ 1 ]
         cCur1stGroup := aLineData[ n1stGroup ]
         aadd( aPrintLine, alltrim( ::aColumnHeaders[ n1stGroup ] ) + ' : ' + alltrim( cCur1stGroup ) )
         ::PrintLine( aPrintLine, .f., .t. )
         ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
         asize( aPrintLine, 0 )
         if n2ndGroup > 0
            cCur2ndGroup := aLineData[ n2ndGroup ]
            aadd( aPrintLine, replicate( ' ', ::nGroupIndent ) + alltrim( ::aColumnHeaders[ n2ndGroup ] ) + ' : ' + alltrim( cCur2ndGroup ) )
            ::PrintLine( aPrintLine, .f., .t. )
            ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
            asize( aPrintLine, 0 )
         endif
         if n3rdGroup > 0
            cCur3rdGroup := aLineData[ n3rdGroup ]
            aadd( aPrintLine, replicate( ' ', ::nGroupIndent + ::nGroupIndent ) + alltrim( ::aColumnHeaders[ n3rdGroup ] ) + ' : ' + alltrim( cCur3rdGroup ) )
            ::PrintLine( aPrintLine, .f., .t. )
            ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
            asize( aPrintLine, 0 )
         endif
      endif   
      for j := 1 to nRowCount
         aLineData := ::aData[ j ]
         // do we need a group/subgroup header change?
         if lGrouping
            if .not. aLineData[ n1stGroup ] == cCur1stGroup  // 1st level group is changed!
               if lColSum
                  // print all levels of total
                  // print 3rd group total if available
                  if n3rdGroup > 0
                     for k := 1 to hmg_len( aColumns )
                        nPrintColumn := aColumns[ k ]
                        nPos := ascan( ::aColumnSum, nPrintColumn )
                        if nPos == 0 // this column is not summed up. empty cell
                           aadd( aPrintLine, '' )
                        else // print corresponding total
                           if hmg_len( ::aColumnPicture ) == 0
                              aadd( aPrintLine, alltrim( str( a3rdGroupTotal[ nPos ] ) ) )
                           else
                              aadd( aPrintLine, alltrim( transform( a3rdGroupTotal[ nPos ], ::aColumnPicture[ nPrintColumn ] ) ) )
                           endif                           
                        endif                     
                     next k
                     ::PrintLine( aPrintLine, .f., .t. )
                     ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
                     asize( aPrintLine, 0 )
                  endif
                  if n2ndGroup > 0
                     for k := 1 to hmg_len( aColumns )
                        nPrintColumn := aColumns[ k ]
                        nPos := ascan( ::aColumnSum, nPrintColumn )
                        if nPos == 0 // this column is not summed up. empty cell
                           aadd( aPrintLine, '' )
                        else // print corresponding total
                           if hmg_len( ::aColumnPicture ) == 0
                              aadd( aPrintLine, alltrim( str( a2ndGroupTotal[ nPos ] ) ) )
                           else
                              aadd( aPrintLine, alltrim( transform( a2ndGroupTotal[ nPos ], ::aColumnPicture[ nPrintColumn ] ) ) )
                           endif                           
                        endif                     
                     next k
                     ::PrintLine( aPrintLine, .f., .t. )
                     ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
                     asize( aPrintLine, 0 )
                  endif
                  for k := 1 to hmg_len( aColumns )
                     nPrintColumn := aColumns[ k ]
                     nPos := ascan( ::aColumnSum, nPrintColumn )
                     if nPos == 0 // this column is not summed up. empty cell
                        aadd( aPrintLine, '' )
                     else // print corresponding total
                        if hmg_len( ::aColumnPicture ) == 0
                           aadd( aPrintLine, alltrim( str( a1stGroupTotal[ nPos ] ) ) )
                        else
                           aadd( aPrintLine, alltrim( transform( a1stGroupTotal[ nPos ], ::aColumnPicture[ nPrintColumn ] ) ) )
                        endif                        
                     endif                     
                  next k
                  ::PrintLine( aPrintLine, .f., .t. )
                  ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
                  asize( aPrintLine, 0 )
               endif               
               // group head change
               afill( a1stGroupTotal, 0 )
               afill( a2ndGroupTotal, 0 )
               afill( a3rdGroupTotal, 0 )
               cCur1stGroup := aLineData[ n1stGroup ]
               aadd( aPrintLine, alltrim( ::aColumnHeaders[ n1stGroup ] ) + ' : ' + alltrim( cCur1stGroup ) )
               ::PrintLine( aPrintLine, .f., .t. )
               ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
               asize( aPrintLine, 0 )
               // since 1st group is changed, we have to change subgroup headings also!
               if n2ndGroup > 0
                  cCur2ndGroup := aLineData[ n2ndGroup ]
                  aadd( aPrintLine, replicate( ' ', ::nGroupIndent ) + alltrim( ::aColumnHeaders[ n2ndGroup ] ) + ' : ' + alltrim( cCur2ndGroup ) )
                  ::PrintLine( aPrintLine, .f., .t. )
                  ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
                  asize( aPrintLine, 0 )
               endif
               if n3rdGroup > 0
                  cCur3rdGroup := aLineData[ n3rdGroup ]
                  aadd( aPrintLine, replicate( ' ', ::nGroupIndent + ::nGroupIndent ) + alltrim( ::aColumnHeaders[ n3rdGroup ] ) + ' : ' + alltrim( cCur3rdGroup ) )
                  ::PrintLine( aPrintLine, .f., .t. )
                  ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
                  asize( aPrintLine, 0 )
               endif
            else   
               if n2ndGroup > 0
                  if .not. aLineData[ n2ndGroup ] == cCur2ndGroup // 2nd level group is changed!
                     if lColSum
                        // summation entries for 3rd group and 2nd group only
                        if n3rdGroup > 0
                           for k := 1 to hmg_len( aColumns )
                              nPrintColumn := aColumns[ k ]
                              nPos := ascan( ::aColumnSum, nPrintColumn )
                              if nPos == 0 // this column is not summed up. empty cell
                                 aadd( aPrintLine, '' )
                              else // print corresponding total
                                 if hmg_len( ::aColumnPicture ) == 0
                                    aadd( aPrintLine, alltrim( str( a3rdGroupTotal[ nPos ] ) ) )
                                 else   
                                    aadd( aPrintLine, alltrim( transform( a3rdGroupTotal[ nPos ], ::aColumnPicture[ nPrintColumn ] ) ) )
                                 endif   
                              endif                     
                           next k
                           ::PrintLine( aPrintLine, .f., .t. )
                           ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
                           asize( aPrintLine, 0 )
                        endif
                        for k := 1 to hmg_len( aColumns )
                           nPrintColumn := aColumns[ k ]
                           nPos := ascan( ::aColumnSum, nPrintColumn )
                           if nPos == 0 // this column is not summed up. empty cell
                              aadd( aPrintLine, '' )
                           else // print corresponding total
                              if hmg_len( ::aColumnPicture ) == 0
                                 aadd( aPrintLine, alltrim( str( a2ndGroupTotal[ nPos ] ) ) )
                              else
                                 aadd( aPrintLine, alltrim( transform( a2ndGroupTotal[ nPos ], ::aColumnPicture[ nPrintColumn ] ) ) )
                              endif   
                           endif                     
                        next k
                        ::PrintLine( aPrintLine, .f., .t. )
                        ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
                        asize( aPrintLine, 0 )
                     endif
                     // second level group changed
                     afill( a2ndGroupTotal, 0 )
                     afill( a3rdGroupTotal, 0 )
                     cCur2ndGroup := aLineData[ n2ndGroup ]
                     aadd( aPrintLine, replicate( ' ', ::nGroupIndent ) + alltrim( ::aColumnHeaders[ n2ndGroup ] ) + ' : ' + alltrim( cCur2ndGroup ) )
                     ::PrintLine( aPrintLine, .f., .t. )
                     ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
                     asize( aPrintLine, 0 )
                     // change for 3rd level grouping if available
                     if n3rdGroup > 0
                        cCur3rdGroup := aLineData[ n3rdGroup ]
                        aadd( aPrintLine, replicate( ' ', ::nGroupIndent + ::nGroupIndent ) + alltrim( ::aColumnHeaders[ n3rdGroup ] ) + ' : ' + alltrim( cCur3rdGroup ) )
                        ::PrintLine( aPrintLine, .f., .t. )
                        ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
                        asize( aPrintLine, 0 )
                     endif
                  else
                  // check for 3rd level grouping
                     if n3rdGroup > 0
                        if .not. aLineData[ n3rdGroup ] == cCur3rdGroup 
                           if lColSum 
                           // summation for 3rd grouping
                              for k := 1 to hmg_len( aColumns )
                                 nPrintColumn := aColumns[ k ]
                                 nPos := ascan( ::aColumnSum, nPrintColumn )
                                 if nPos == 0 // this column is not summed up. empty cell
                                    aadd( aPrintLine, '' )
                                 else // print corresponding total
                                    if hmg_len( ::aColumnPicture ) == 0
                                       aadd( aPrintLine, alltrim( str( a3rdGroupTotal[ nPos ] ) ) )
                                    else
                                       aadd( aPrintLine, alltrim( transform( a3rdGroupTotal[ nPos ], ::aColumnPicture[ nPrintColumn ] ) ) )
                                    endif                                    
                                 endif                     
                              next k
                              ::PrintLine( aPrintLine, .f., .t. )
                              ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
                              asize( aPrintLine, 0 )
                           endif   
                           afill( a3rdGroupTotal, 0 )
                           cCur3rdGroup := aLineData[ n3rdGroup ]
                           aadd( aPrintLine, replicate( ' ', ::nGroupIndent + ::nGroupIndent ) + alltrim( ::aColumnHeaders[ n3rdGroup ] ) + ' : ' + alltrim( cCur3rdGroup ) )
                           ::PrintLine( aPrintLine, .f., .t. )
                           ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
                           asize( aPrintLine, 0 )
                        endif
                     endif
                  endif                  
               endif            
            endif
         endif      
         if lColSum
            for n := 1 to hmg_len( ::aColumnSum )
               nValue := val( alltrim( ::StripComma( aLineData[ ::aColumnSum[ n ] ] ) ) )
               aColTotal[ n ] := aColTotal[ n ] + nValue
               if lGrouping
                  a1stGroupTotal[ n ] := a1stGroupTotal[ n ] + nValue
                  a2ndGroupTotal[ n ] := a2ndGroupTotal[ n ] + nValue
                  a3rdGroupTotal[ n ] := a3rdGroupTotal[ n ] + nValue
               endif   
            next n
         endif
         // now all gimmicks are over! time for real data :)
         // decide single line or multilines
         if ::lWordWrap
            for k := 1 to hmg_len( aColumns )
               nPrintColumn := aColumns[ k ]
               aadd( aPrintLine, aLineData[ nPrintColumn ] )
            next k
            nMaxLines := 1
            for k := 1 to hmg_len( aLineData )
               if ::aColumnWidths[ k ] > 0
                  cData := aLineData[ k ]
                  nLengthRequired := ::PrintLen( aLineData[ k ], nFontSize, cFontName )
                  if nLengthRequired > ::aColumnWidths[ k ]
                     nLinesRequired := int( nLengthRequired / ::aPrintWidths[ k ] ) + 1
                     nMaxLines := max( nMaxLines, nLinesRequired )
                  endif   
               endif
            next k               
            if nMaxLines > 1 // more than 1 line is required
               if ::nPrintCurRow + ( nMaxLines * ::nPrintLineHeight ) > ::nPrintMaxRow
                  ::nPrintCurPage++
                  ::StartNewPage() 
               endif
               ::PrintMultiLine( aPrintLine, .f., .f., nMaxLines )
               ::nPrintCurRow := ::nPrintCurRow + nMaxLines * ::nPrintLineHeight
               asize( aPrintLine, 0 )
            else // single line is enough
               ::PrintLine( aPrintLine, .f., .f. )
               ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
               asize( aPrintLine, 0 )
            endif   
         else
            for k := 1 to hmg_len( aColumns )
               nPrintColumn := aColumns[ k ]
               if ::PrintLen( aLineData[ nPrintColumn ], nFontSize, cFontName ) > ::aPrintWidths[ k ]
                  cData := aLineData[ nPrintColumn ]
                  nCount := hmg_len( cData )
                  do while ::PrintLen( hb_usubstr( cData, 1, nCount ), nFontSize, cFontName ) > nColWidth
                     nCount := nCount - 1 
                  enddo
                  aadd( aPrintLine, hb_usubstr( cData, 1, nCount ) )
               else
                  aadd( aPrintLine, aLineData[ nPrintColumn ] )
               endif   
            next k
            ::PrintLine( aPrintLine, .f., .f. )
            ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
            asize( aPrintLine, 0 )
         endif         
      next j
      
      if lColSum
         if lGrouping
            // print all levels of total
            // print 3rd group total if available
            if n3rdGroup > 0
               for k := 1 to hmg_len( aColumns )
                  nPrintColumn := aColumns[ k ]
                  nPos := ascan( ::aColumnSum, nPrintColumn )
                  if nPos == 0 // this column is not summed up. empty cell
                     aadd( aPrintLine, '' )
                  else // print corresponding total
                     if hmg_len( ::aColumnPicture ) == 0 
                        aadd( aPrintLine, alltrim( str( a3rdGroupTotal[ nPos ] ) ) )
                     else
                        aadd( aPrintLine, alltrim( transform( a3rdGroupTotal[ nPos ], ::aColumnPicture[ nPrintColumn ] ) ) )
                     endif                     
                  endif                     
               next k
               ::PrintLine( aPrintLine, .f., .t. )
               ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
               asize( aPrintLine, 0 )
            endif
            if n2ndGroup > 0
               for k := 1 to hmg_len( aColumns )
                  nPrintColumn := aColumns[ k ]
                  nPos := ascan( ::aColumnSum, nPrintColumn )
                  if nPos == 0 // this column is not summed up. empty cell
                     aadd( aPrintLine, '' )
                  else // print corresponding total
                     if hmg_len( ::aColumnPicture ) == 0
                        aadd( aPrintLine, alltrim( str( a2ndGroupTotal[ nPos ] ) ) )
                     else
                        aadd( aPrintLine, alltrim( transform( a2ndGroupTotal[ nPos ], ::aColumnPicture[ nPrintColumn ] ) ) )
                     endif   
                  endif                     
               next k
               ::PrintLine( aPrintLine, .f., .t. )
               ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
               asize( aPrintLine, 0 )
            endif
            for k := 1 to hmg_len( aColumns )
               nPrintColumn := aColumns[ k ]
               nPos := ascan( ::aColumnSum, nPrintColumn )
               if nPos == 0 // this column is not summed up. empty cell
                  aadd( aPrintLine, '' )
               else // print corresponding total
                  if hmg_len( ::aColumnPicture ) == 0
                     aadd( aPrintLine, alltrim( str( a1stGroupTotal[ nPos ] ) ) )
                  else
                     aadd( aPrintLine, alltrim( transform( a1stGroupTotal[ nPos ], ::aColumnPicture[ nPrintColumn ] ) ) )
                  endif                  
               endif                     
            next k
            ::PrintLine( aPrintLine, .f., .t. )
            ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
            asize( aPrintLine, 0 )
         endif               
         // now time for grand total
         for k := 1 to hmg_len( aColumns )
            nPrintColumn := aColumns[ k ]
            nPos := ascan( ::aColumnSum, nPrintColumn )
            if nPos == 0 // this column is not summed up. empty cell
               aadd( aPrintLine, '' )
            else // print corresponding total
               if hmg_len( ::aColumnPicture ) == 0
                  aadd( aPrintLine, alltrim( str( aColTotal[ nPos ] ) ) )
               else
                  aadd( aPrintLine, alltrim( transform( aColTotal[ nPos ], ::aColumnPicture[ nPrintColumn ] ) ) )
               endif               
            endif                     
         next k
         ::PrintLine( aPrintLine, .f., .t. )
         ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
         asize( aPrintLine, 0 )
      endif      
      
      // footers
      if hmg_len( alltrim( ::cReportFooter ) ) > 0
         ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
         ::PrintData( ::nPrintCurRow, ::nPrintPaperWidth / 2, ::cReportFooter, ::aReportFooterFont, 'CENTER' )
         ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight + 2
      endif
      // date and time
      cDateTime := ''
      if ::lIncludeDate
         cDateTime := ::cDatePrefix + dtoc( date() ) + ' '
      endif
      if ::lIncludeTime
         cDateTime := cDateTime + ::cTimePrefix + time()
      endif
      if hmg_len( cDateTime ) > 0
         if ::nPrintCurRow > ::nPrintMaxRow
            ::nPrintCurPage++
            ::StartNewPage()
         endif
         do case 
         case ::nDateTimeAlignment == 0 // left
            ::PrintData( ::nPrintCurRow, ::nPrintLeftMargin,  cDateTime, ::aReportFooterFont, 'LEFT' )
         case ::nDateTimeAlignment == 1 // right
            ::PrintData( ::nPrintCurRow, ::nPrintMaxCol,  cDateTime, ::aReportFooterFont, 'RIGHT' )
         case ::nDateTimeAlignment == 2 // center
            ::PrintData( ::nPrintCurRow, ::nPrintPaperWidth / 2, cDateTime, ::aReportFooterFont, 'CENTER' )
         endcase    
      endif   
      if ::lPageNumbering
         if ::nPageNumberPosition == 2 .or. ::nPageNumberPosition == 3 // bottom or both
            cPageNumber := ::cPageNumberPrefix + ' ' + alltrim( str( ::nPrintCurPage, 10, 0 ) )
            do case
            case ::nPageNumberAlignment == 0 // left
               @ ::nPrintMaxRow + ::nPrintLineHeight, ::nPrintLeftMargin print cPageNumber font cFontName size nFontSize
            case ::nPageNumberAlignment == 2 // center
               @ ::nPrintMaxRow + ::nPrintLineHeight, ::nPrintPaperWidth / 2 print cPageNumber font cFontName size nFontSize center
            case ::nPageNumberAlignment == 1 // right
               @ ::nPrintMaxRow + ::nPrintLineHeight, ::nPrintMaxCol print cPageNumber font cFontName size nFontSize right
            endcase
         endif
      endif
      end printpage
   next i
   end printdoc  
return nil


METHOD Export2TXT( cFileName ) CLASS GridPlus
   local cLine := ''
   local i := 0
   local j := 0
   local k := 0
   local nRowCount := hmg_len( ::aData )
   local nRow := 0
   local nMaxRow := ::nTextMaxRow
   local nMaxCol := 0
   local nPage := 0
   local cBold := '' // CHR(27)+'x1'
   local cUnBold := '' // CHR(27)+'x'
   local cLarge := '' // CHR(27)+'w1'
   local cUnLarge := '' // CHR(27)+'w0'
   local nMargin := round( ::nLeftMargin * ::nMM2Text, 0 )
   local aColWidths := {}
   default cFileName := ''

   if nRowCount == 0 // no data
      return nil
   endif
   if pcount() == 0
      cFileName :=  PutFile ( { { "TXT Files (*.txt)", "*.txt" } }, "Export to Text file", , .f. ) 
      if hmg_len( alltrim( cFileName ) ) == 0
         return nil
      endif
      if at( ".txt", hmg_lower( cFileName) ) > 0
         if .not. hb_uright( hmg_lower( cFileName), 4 ) == ".txt"
            cFileName := cFileName + ".txt"
         endif
      else
         cFileName := cFileName + ".txt"
      endif
   endif
   
   for i := 1 to ::nColumnCount
      aadd( aColWidths, round( ::aColumnWidths[ i ] * ::nMM2Text, 0 ) )
   next i
   nPage := 1
   for i := 1 to ::nColumnCount
      nMaxCol := nMaxCol + aColWidths[ i ] + 1
   next i   
   set alter to &cFileName
   set alter on
   nRow := 2
   ?
   ?
   if hmg_len( ::cReportHeader1 ) > 0
      ? space( nMargin ) + cBold + ::TextJustify( ::cReportHeader1, nMaxCol, 2 ) + cUnBold
      nRow := nRow + 1
   endif   

   if hmg_len( ::cReportHeader2 ) > 0
      ? space( nMargin ) + cBold + ::TextJustify( ::cReportHeader2, nMaxCol, 2 ) + cUnBold
      nRow := nRow + 1
   endif   
   if hmg_len( ::cReportHeader3 ) > 0
      ? space( nMargin ) + cBold + ::TextJustify( ::cReportHeader3, nMaxCol, 2 ) + cUnBold
      nRow := nRow + 1
   endif   
   if ::lPageNumbering
      if ::nPageNumberPosition == 1 .or. ::nPageNumberPosition == 3 // top or both
         ? space( nMargin ) + + ::TextJustify( ::cPageNumberPrefix + ' ' + alltrim( str ( nPage ) ), nMaxCol, ::nPageNumberAlignment )
         nRow := nRow + 1
      endif
   endif      
   ? space( nMargin ) + replicate( '-', nMaxCol )
   nRow := nRow + 1
   cLine := space( nMargin ) + cBold
   for i := 1 to ::nColumnCount
      if aColWidths[ i ] > 0
         cLine := cLine + ::TextJustify( ::aColumnHeaders[ i ], aColWidths[ i ], ::aColumnJustify[ i ] ) + ' '
      endif
   next i
   cLine := cLine + cUnBold
   ? cLine
   ? space( nMargin ) + replicate( '-', nMaxCol )
   nRow := nRow + 2
   for i := 1 to nRowCount
      cLine := space( nMargin )
      for j := 1 to hmg_len( ::aData[ i ] )
         if aColWidths[ j ] > 0
            cLine := cLine + ::TextJustify( ::aData[ i, j ], aColWidths[ j ], ::aColumnJustify[ j ] ) + ' '
         endif
      next j   
      ? cLine
      nRow := nRow + 1
      if nRow + 3 > nMaxRow
         if ::lPageNumbering
            if ::nPageNumberPosition == 2 .or. ::nPageNumberPosition == 3 // bottom or both
               ? space( nMargin ) + + ::TextJustify( ::cPageNumberPrefix +  ' ' + alltrim( str ( nPage ) ), nMaxCol, ::nPageNumberAlignment )
               nRow := nRow + 1
            endif
         endif      
         ? chr(12) // page break
         nPage := nPage + 1
         nRow := 2
         ?
         ?
         if hmg_len( ::cReportHeader1 ) > 0
            ? space( nMargin ) + cBold + ::TextJustify( ::cReportHeader1, nMaxCol, 2 ) + cUnBold
            nRow := nRow + 1
         endif   
         if hmg_len( ::cReportHeader2 ) > 0
            ? space( nMargin ) + cBold + ::TextJustify( ::cReportHeader2, nMaxCol, 2 ) + cUnBold
            nRow := nRow + 1
         endif   
         if hmg_len( ::cReportHeader3 ) > 0
            ? space( nMargin ) + cBold + ::TextJustify( ::cReportHeader3, nMaxCol, 2 ) + cUnBold
            nRow := nRow + 1
         endif   
         if ::lPageNumbering
            if ::nPageNumberPosition == 1 .or. ::nPageNumberPosition == 3 // top or both
               ? space( nMargin ) + + ::TextJustify( ::cPageNumberPrefix + ' ' +  alltrim( str ( nPage ) ), nMaxCol, ::nPageNumberAlignment )
               nRow := nRow + 1
            endif
         endif      
         ? space( nMargin ) + replicate( '-', nMaxCol )
         nRow := nRow + 1
         cLine := space( nMargin ) + cBold
         for k := 1 to ::nColumnCount
            if aColWidths[ k ] > 0
               cLine := cLine + ::TextJustify( ::aColumnHeaders[ k ], aColWidths[ k ], ::aColumnJustify[ k ] ) + ' '
            endif
         next k
         cLine := cLine + cUnBold
         ? cLine
         ? space( nMargin ) + replicate( '-', nMaxCol )
         nRow := nRow + 2
      endif   
   next i
   ? space( nMargin ) + replicate( '-', nMaxCol )
   if hmg_len( ::cReportFooter ) > 0
      ? space( nMargin ) + cBold + ::TextJustify( ::cReportFooter, nMaxCol, 2 ) + cUnBold
      nRow := nRow + 1
   endif   
   cLine := ''
   if ::lIncludeDate
      cLine := ::cDatePrefix + ' ' + dtoc( date() ) + ' '
   endif
   if ::lIncludeTime
      cLine := ::cTimePrefix + ' ' + time() + ' '
   endif
   cLine := alltrim( cLine )
   if hmg_len( cLine ) > 0
      ? space( nMargin ) + ::TextJustify( cLine, nMaxCol, ::nDateTimeAlignment )
   endif      
   ? chr(12)
   set alter to
   ::cLastExportFileName = cFileName
return Self
      

METHOD Printer( cPrinter ) CLASS GridPlus
   if PCount() == 0
      return ::cPrinter
   else
      ::cPrinter := cPrinter
   endif
   return self
   
METHOD PaperHeight( nPaperHeight ) CLASS GridPlus
   if PCount() == 0
      return ::nPaperHeight
   else
      ::nPaperHeight := nPaperHeight
   endif
   return self

METHOD PaperWidth( nPaperWidth ) CLASS GridPlus
   if PCount() == 0
      return ::nPaperWidth
   else
      ::nPaperWidth := nPaperWidth
   endif
   return self
   
METHOD TopMargin( nTopMargin ) CLASS GridPlus
   if PCount() == 0
      return ::nTopMargin
   else
      ::nTopMargin := nTopMargin
   endif
   return self

METHOD LeftMargin( nLeftMargin ) CLASS GridPlus
   if PCount() == 0
      return ::nLeftMargin
   else
      ::nLeftMargin := nLeftMargin
   endif
   return self

METHOD RightMargin( nRightMargin ) CLASS GridPlus
   if PCount() == 0
      return ::nRightMargin
   else
      ::nRightMargin := nRightMargin
   endif
   return self

METHOD BottomMargin( nBottomMargin ) CLASS GridPlus
   if PCount() == 0
      return ::nBottomMargin
   else
      ::nBottomMargin := nBottomMargin
   endif
   return self

METHOD ColumnHeaders( aColumnHeaders ) CLASS GridPlus
   if PCount() == 0
      return ::aColumnHeaders
   else
      ::aColumnHeaders := aColumnHeaders
   endif
   return self   
   
METHOD ColumnWidths( aColumnWidths ) CLASS GridPlus
   if PCount() == 0
      return ::aColumnWidths
   else
      ::aColumnWidths := aColumnWidths
   endif
   return self   

METHOD ColumnJustify( aColumnJustify ) CLASS GridPlus
   if PCount() == 0
      return ::aColumnJustify
   else
      ::aColumnJustify := aColumnJustify
   endif
   return self   
   
METHOD ReportHeader1( cReportHeader1 )  CLASS GridPlus
   if PCount() == 0
      return ::cReportHeader1
   else
      ::cReportHeader1 := cReportHeader1
   endif
   return self   
   
METHOD ReportHeader2( cReportHeader2 )  CLASS GridPlus
   if PCount() == 0
      return ::cReportHeader2
   else
      ::cReportHeader2 := cReportHeader2
   endif
   return self   
   
METHOD ReportHeader3( cReportHeader3 )  CLASS GridPlus
   if PCount() == 0
      return ::cReportHeader3
   else
      ::cReportHeader3 := cReportHeader3
   endif
   return self   

METHOD ReportFooter( cReportFooter )  CLASS GridPlus
   if PCount() == 0
      return ::cReportFooter
   else
      ::cReportFooter := cReportFooter
   endif
   return self   
   

METHOD RowHeight( nRowHeight ) CLASS GridPlus
   if PCount() == 0
      return ::nRowHeight
   else
      ::nRowHeight := nRowHeight
   endif
   return self   
   
METHOD GroupColumns( aGroupColumns ) CLASS GridPlus
   if PCount() == 0
      return ::aGroupColumns
   else
      ::aGroupColumns := aGroupColumns
   endif
   return self   

METHOD GroupIndent( nGroupIndent ) CLASS GridPlus
   if PCount() == 0
      return ::nGroupIndent
   else
      ::nGroupIndent := nGroupIndent
   endif
   return self   
   
METHOD MergeHeaders( aMergeHeaders ) Class GridPlus
   if PCount() == 0
      return ::aMergeHeaders
   else
      ::aMergeHeaders := aMergeHeaders
   endif
   return self   
   
METHOD ColumnSum( aColumnSum ) class GridPlus
   if PCount() == 0
      return ::aColumnSum
   else
      ::aColumnSum := aColumnSum
   endif
   return self   

METHOD HorizontalLines( lHorizontalLines ) Class GridPlus
   if PCount() == 0
      return ::lHorizontalLines
   else
      ::lHorizontalLines := lHorizontalLines
   endif
   return self   

METHOD VerticalLines( lVerticalLines ) Class GridPlus
   if PCount() == 0
      return ::lVerticalLines
   else
      ::lVerticalLines := lVerticalLines
   endif
   return self   

METHOD ReportHeaderFont( aReportHeaderFont ) class GridPlus
   if PCount() == 0
      return ::aReportHeaderFont
   else
      ::aReportHeaderFont := aReportHeaderFont
   endif
   return self   

METHOD ReportFooterFont( aReportFooterFont ) class GridPlus
   if PCount() == 0
      return ::aReportFooterFont
   else
      ::aReportFooterFont := aReportFooterFont
   endif
   return self   
   
METHOD ReportFont( aReportFont ) Class GridPlus
   if PCount() == 0
      return ::aReportFont
   else
      ::aReportFont := aReportFont
   endif
   return self   
   
METHOD CellFont( aCellFont ) class GridPlus
   if PCount() == 0
      return ::aCellFont
   else
      ::aCellFont := aCellFont
   endif
   return self   

METHOD PenWidth( nPenWidth ) class GridPlus
   if PCount() == 0
      return ::nPenWidth
   else
      ::nPenWidth := nPenWidth
   endif
   return self   

METHOD WordWrap( lWordWrap ) class GridPlus
   if PCount() == 0
      return ::lWordWrap
   else
      ::lWordWrap := lWordWrap
   endif
   return self   

METHOD PageNumbering( lPageNumbering ) class GridPlus
   if PCount() == 0
      return ::lPageNumbering
   else
      ::lPageNumbering := lPageNumbering
   endif
   return self   

METHOD DPI( nDPI ) class GridPlus
   if PCount() == 0
      return ::nDPI
   else
      ::nDPI := nDPI
      ::nMM2Pixel := nDPI / 25.4
   endif
   return self   

METHOD PageCenter( lPageCenter )  class GridPlus
   if PCount() == 0
      return ::lPageCenter
   else
      ::lPageCenter := lPageCenter
   endif
   return self   

METHOD SpreadWhiteSpace( lSpreadWhiteSpace ) class GridPlus
   if PCount() == 0
      return ::lSpreadWhiteSpace
   else
      ::lSpreadWhiteSpace := lSpreadWhiteSpace
   endif
   return self   
   
METHOD PaperSize( nPaperSize ) CLASS GridPlus
   if PCount() == 0
      return ::nPaperSize
   else
      ::nPaperSize := nPaperSize
   endif
   return Self
   
METHOD IncludeDate( lIncludeDate ) CLASS GridPlus
   if PCount() == 0
      return ::lIncludeDate
   else
      ::lIncludeDate := lIncludeDate
   endif
   return Self

METHOD Includetime( lIncludetime ) CLASS GridPlus
   if PCount() == 0
      return ::lIncludeTime
   else
      ::lIncludeTime := lIncludeTime
   endif
   return Self
   
METHOD DatePrefix( cDatePrefix ) Class GridPlus
   if PCount() == 0
      return ::cDatePrefix
   else
      ::cDatePrefix := cDatePrefix
   endif
   return Self
   
METHOD TimePrefix( cTimePrefix ) CLASS GridPlus
   if PCount() == 0
      return ::cTimePrefix
   else
      ::cTimePrefix := cTimePrefix
   endif
   return Self

METHOD PageNumberPrefix( cPageNumberPrefix ) CLASS GridPlus
   if PCount() == 0
      return ::cPageNumberPrefix
   else
      ::cPageNumberPrefix := cPageNumberPrefix
   endif
   return Self
   
METHOD DateTimeAlignment( nAlignment ) CLASS GridPlus
   if PCount() == 0
      return ::nDateTimeAlignment
   else
      ::nDateTimeAlignment := nAlignment
   endif
   return Self

METHOD PageNumberPosition( nPosition ) CLASS GridPlus
   if PCount() == 0
      return ::nPageNumberPosition
   else
      ::nPageNumberPosition := nPosition
   endif
   return Self
   
METHOD DecimalSymbol( cDecimalSymbol )  CLASS GridPlus
   if PCount() == 0
      return ::cDecimalSymbol
   else
      ::cDecimalSymbol := cDecimalSymbol
   endif
   return self   

METHOD ColumnPicture( aColumnPicture )  CLASS GridPlus
   if PCount() == 0
      return ::aColumnPicture
   else
      ::aColumnPicture := aColumnPicture
   endif
   return self   
   
   
METHOD PageNumberAlignment( nAlignment ) CLASS GridPlus
   if PCount() == 0
      return ::nPageNumberAlignment
   else
      ::nPageNumberAlignment := nAlignment
   endif
   return Self
   
METHOD DefaultColumnWidth( nDefaultColumnWidth ) CLASS GridPlus
   if PCount() == 0
      return ::nDefaultColumnWidth
   else
      ::nDefaultColumnWidth := nDefaultColumnWidth
   endif
   return Self

METHOD TruncateColumns( lTruncateColumns ) CLASS GridPlus
   if PCount() == 0
      return ::lTruncateColumns
   else
      ::lTruncateColumns := lTruncateColumns
   endif
   return Self
   
METHOD Orientation( nOrientation ) CLASS GridPlus
   if PCount() == 0
      return ::nOrientation
   else
      ::nOrientation := nOrientation
   endif
   return Self
   
METHOD Preview( lPreview ) CLASS GridPlus
   if PCount() == 0
      return ::lPreview
   else
      ::lPreview := lPreview
   endif
   return Self

METHOD TextMaxRow( nTextMaxRow ) CLASS GridPlus
   if PCount() == 0
      return ::nTextMaxRow
   else
      ::nTextMaxRow := nTextMaxRow
   endif
   return Self

METHOD LastExportFileName() CLASS GridPlus
   return ::cLastExportFileName
   

METHOD ParseQuote( cData ) class GridPlus
   local i := 0
   local cOut := ""
   for i := 1 to hmg_len( cData )
      if hb_usubstr( cData, i, 1 ) == '"'
         cOut := cOut + hb_usubstr( cData, i, 1 ) + '"'
      else
         cOut := cOut + hb_usubstr( cData, i, 1 )
      endif
   next i
return cOut      

METHOD HTMLAlign( nAlign ) CLASS GridPlus
   default nAlign := 0
   do case
   case nAlign == 1 // right
      return 'RIGHT'
   case nAlign == 2 // Center    
      return 'CENTER'
   otherwise   
      return 'LEFT'
   endcase
return 'LEFT'   


Method TextJustify( cString, nLength, nAlignment ) CLASS GridPlus
   local nStrLen := hmg_len( alltrim( cString ) )
   local cReturn := ''
   default nAlignment := 0 // left
   do case
   case nStrLen > nLength
      // truncate
      cReturn := hb_usubstr( alltrim( cString ), 1, nLength )
   otherwise
      do case
      case nAlignment == 0 // left
         cReturn := alltrim( cString ) 
      case nAlignment == 1 // right
         cReturn := space( nLength - nStrLen ) + alltrim( cString ) 
      case nAlignment == 2 // center
         cReturn := space( int ( ( nLength - nStrLen ) / 2 ) ) + alltrim( cString ) 
      endcase   
      cReturn := cReturn + space( ( nLength - hmg_len( cReturn ) ) )
   endcase
return cReturn

METHOD ShowGUI CLASS GridPlus
   local aColWidths := {}
   local nTotWidth := 0
   local i := 0
   && private aCurrentObj := self
   if hmg_len( ::aData ) == 0
      // nothing to show!
      return nil
   endif
   for i := 1 to ::nColumnCount
      aadd( aColWidths, ::aColumnWidths[ i ] * ::nMM2Pixel )
      nTotWidth := nTotWidth + ( ::aColumnWidths[ i ] * ::nMM2Pixel )
   next i   
   
   define window gp at 0, 0 width 900 height 570 virtual width 1900 title 'Report Configuration' modal nosize // on paint ::DrawScale()
      define image scale
         row 5
         col 10
         width 1860
         height 35
      end image      
      define slider leftmargin
         row 40
         col 0
         width 930
         rangemin 0
         rangemax 930
         onchange ::SliderLeftMarginChanged()
         left .t.
         tickmarks .f.
      end slider
      define slider rightmargin
         row 40
         col 935
         width 930
         rangemin 0
         rangemax 930
         left .t.
         tickmarks .f.
         onchange ::SliderRightMarginChanged()
      end slider
      define grid model
         row 80
         col 10
         width nTotWidth + 30
         headers ::aColumnHeaders
         widths aColWidths
         justify ::aColumnJustify
         itemcount hmg_len( ::aData )
         virtual .t.
         onQueryData ::GPOnQuery()
         onlostfocus ::ColumnSizeCheck()
         height 85
      end grid
      define tab adj at 170, 10 width 880 height 280 
         define page 'Printer/page Setup'   
            define label printerlabel
               row 30
               col 10
               width 150
               value 'Select Printer'
            end label
            define combobox printers
               row 30
               col 160
               width 300
               items aPrinters()
               onchange ::PrinterChanged()
            end combobox
            define label papersizelabel
               row 60
               col 10
               width 150
               value 'Paper Size'
            end label
            define combobox papersizes
               row 60
               col 160
               width 300
               items ::aPaperSizes
               onchange ::PaperSizeChanged()
            end combobox   
            define checkbox customsize
               row 60
               col 470
               width 100
               caption 'Custom'
               onchange ::CustomSizeSelected()
            end checkbox
            define label paperdimension
               row 90
               col 10
               width 150
               value 'Paper Dimension'
            end label
            define label widthlabel
               row 90
               col 160
               value 'Width'
               width 60
            end label
            define textbox width
               row 90
               col 220
               width 60
               inputmask "999.99"
               on change ::PaperWidthChanged()
               numeric .t.
               rightalign .t.
            end textbox
            define label widthmm
               row 90
               col 285
               value "mm"
               width 25
            end label
            define label heightlabel
               row 90
               col 315
               value 'Height'
               width 60
            end label
            define textbox height
               row 90
               col 375
               width 60
               inputmask "999.99"
               on change ::PaperHeightChanged()
               numeric .t.
               rightalign .t.
            end textbox
            define label heightmm
               row 90
               col 440
               value "mm"
               width 25
            end label
            define label pageorientation
               row 120
               col 10
               width 150
               value 'Paper Orientation'
            end label
            define radiogroup orientation
               row 120
               col 160
               width 150
               options { 'Portrait', 'Landscape' }
               onchange ::OrientationChanged()
               horizontal .t.
            end radiogroup
            define frame margins
               row 30
               col 570
               width 185
               height 90
               caption 'Margins'
            end frame
            define label toplabel
               row 60
               col 575
               width 35
               value 'Top'
            end label
            define textbox top
               row 60
               col 610
               width 50
               inputmask "999"
               numeric .t.
               onlostfocus ::MarginChanged()
               rightalign .t.
            end textbox
            define label rightlabel
               row 60
               col 665
               width 35
               value 'Right'
            end label
            define textbox right
               row 60
               col 700
               width 50
               inputmask "999"
               onlostfocus ::MarginChanged()
               numeric .t.
               rightalign .t.
            end textbox
            define label leftlabel
               row 90
               col 575
               width 35
               value 'Left'
            end label
            define textbox left
               row 90
               col 610
               width 50
               inputmask "999"
               onlostfocus ::MarginChanged()
               numeric .t.
               rightalign .t.
            end textbox
            define label bottomlabel
               row 90
               col 665
               width 35
               value 'Bottom'
            end label
            define textbox bottom
               row 90
               col 700
               width 50
               inputmask "999"
               numeric .t.
               onlostfocus ::MarginChanged()
               rightalign .t.
            end textbox
            define label gridlineslabel
               row 150
               col 10
               width 150
               value 'Grid Lines'
            end label
            define checkbox horizontal
               row 150
               col 160
               width 150
               caption 'Horizontal'
               onchange ::lHorizontalLines := this.value
            end checkbox   
            define checkbox vertical
               row 150
               col 310
               width 150
               caption 'Vertical'
               onchange ::lVerticalLines := this.value
            end checkbox   
            define checkbox wordwrap
               row 180
               col 10
               width 150
               caption 'Enable Wordwrap'
               onchange ::lWordWrap := this.value
            end checkbox
            define checkbox pagecenter
               row 180
               col 160 
               width 150
               caption 'Page Centered'
               onchange ( ::lPageCenter := this.value, if( this.value, gp.spreadwhite.value := .f., ) )
            end checkbox
            define checkbox spreadwhite
               row 180
               col 310
               width 150
               caption 'Spread Whitespace'
               onchange ( ::lSpreadWhiteSpace := this.value, if( this.value, gp.pagecenter.value := .f., ) )
            end checkbox 
            define checkbox truncatecol
               row 210
               col 10
               width 400
               fontcolor { 255, 0, 0 }
               caption 'Disable Tiling'
               tooltip 'If enabled, those columns fit in the first tile only will be printed. Other columns are truncated.'
               onchange ::lTruncateColumns := this.value
            end checkbox   
            define checkbox preview
               row 240
               col 10
               width 150
               caption 'Show Preview'
               onchange ::lPreview := this.value
            end checkbox
         end page
         define page 'Font/Header/Footer'
            define label header1label
               row 30
               col 10
               width 150
               value 'Report Header 1'
            end label
            define textbox header1
               row 30
               col 160
               width 530
               onlostfocus ::cReportHeader1 := this.value
            end textbox
            define label header2label
               row 60
               col 10
               width 150
               value 'Report Header 2'
            end label
            define textbox header2
               row 60
               col 160
               width 530
               onlostfocus ::cReportHeader2 := this.value
            end textbox
            define label header3label
               row 90
               col 10
               width 150
               value 'Report Header 3'
            end label
            define textbox header3
               row 90
               col 160
               width 530
               onlostfocus ::cReportHeader3 := this.value
            end textbox
            define label footerlabel
               row 120
               col 10
               width 150
               value 'Report Footer'
            end label
            define textbox footer
               row 120
               col 160
               width 530
               onlostfocus ::cReportFooter := this.value
            end textbox
            define checkbox footerdate
               row 150
               col 10
               width 150
               caption 'Include Date as'
               onchange ::lIncludeDate := this.value
            end checkbox
            define textbox dateprefix
               row 150
               col 160
               width 100
               value 'Date : '
               onlostfocus ::cDatePrefix := this.value
            end textbox
            define checkbox footertime
               row 150
               col 270
               width 100
               caption 'Time as'
               onchange ::lIncludeTime := this.value
            end checkbox
            define textbox timeprefix
               row 150
               col 370
               width 100
               value 'Time : '
               onlostfocus ::cTimePrefix := this.value
            end textbox
            define combobox footeralign
               row 150
               col 480
               width 100
               items { 'Left', 'Right', 'Center' }
               onchange ::nDateTimeAlignment := this.value - 1
            end combobox   
            define label alignmentlabel
               row 150
               col 590
               width 100
               value 'Aligned'
            end label
            define checkbox pagenumbering
               row 180
               col 10
               width 150
               caption 'Page Numbers as'
               onchange ::lPageNumbering := this.value
            end checkbox
            define textbox pageprefix
               row 180
               col 160
               width 100
               value 'Page No. '
               onlostfocus ::cPageNumberPrefix := this.value
            end textbox
            define label pagepositionlabel
               row 180
               col 270
               width 100
               value 'Position'               
            end label
            define combobox pageposition
               row 180
               col 370
               width 100
               items { 'Top', 'Bottom', 'Both' }
               onchange ::nPageNumberPosition := this.value
            end combobox   
            define combobox pagenoalign
               row 180
               col 480
               width 100
               items { 'Left', 'Right', 'Center' }
               onchange ::nPageNumberAlignment := this.value - 1
            end combobox   
            define label pagealignmentlabel
               row 180
               col 590
               width 100
               value 'Aligned'
            end label
            define button headerfont
               row 210
               col 10
               width 100
               caption 'Header Font'
               action ::SelectReportHeaderFont()
            end button
            define button footerfont
               row 210
               col 120
               width 100
               caption 'Footer Font'
               action ::SelectReportFooterFont()
            end button
            define button mainfont
               row 210
               col 230
               width 100
               caption 'Main Report Font'
               action ::SelectReportFont()
            end button
         end page
         define page 'Merge Headings'
            define grid mergeheaders
               row 30
               col 10
               width 300
               height 240
               headers { '#', 'Merge Column Headers' }
               justify { 1, 0 }
               widths { 90, 180 }
//               oncheckboxclicked ::ColumnSumChecked()
            end grid
            define textbox mergeheader
               row 105
               col 320
               width 150
            end textbox
            define button merge
               row 135
               col 320
               width 150
               caption 'Add merge header'
               action ::AddMergeHeader()
            end button   
            define button delmerge
               row 165
               col 320
               width 150
               caption 'Remove merge header'
               action ::RemoveMergeHeader()
            end button   
            define grid mergedheaders
               row 30
               col 480
               width 280
               height 240
               headers { 'From', 'To', 'Header' }
               justify { 1, 1, 0 }
               widths { 50, 50, 150 }
            end grid
         end page
         define page 'Column Sum'
            define grid colsums
               row 30
               col 10
               width 300
               height 240
               headers { 'Summary Columns' }
               widths { 270 }
               oncheckboxclicked ::ColumnSumChecked()
            end grid
         end page
         define page 'Grouping'
            define listbox fromlist
               row 30
               col 10
               width 300
               height 240
               items ::aColumnHeaders
               value 1
            end listbox
            define button addtogroup
               row 120
               col 355
               width 30
               caption '+'
               fontsize 14
               fontname 'Arial'
               action ::AddToGroup()
            end button   
            define button defromgroup
               row 150
               col 355
               width 30
               caption '-'
               fontsize 14
               fontname 'Arial'
               action ::DelFromGroup()
            end button   
            define listbox grouplist
               row 30
               col 410
               width 300
               height 240
            end listbox
            define button moveupgroup
               row 120
               col 725
               width 30
               caption '▲'
               fontsize 14
               fontname 'Arial'
               action ::MoveUpGroup()
            end button   
            define button movedown
               row 150
               col 725
               width 30
               caption '▼'
               fontsize 14
               fontname 'Arial'
               action ::MoveDownGroup()
            end button   
         end page
      end tab
      define button print
         row 465
         col 10
         width 80
         caption 'Print'
         action ::PrintGrid()
      end button
      define button pdf
         row 465
         col 100
         width 80
         caption 'PDF'
         && action ::PrintPDF()
      end button
      define button csv
         row 465
         col 190
         width 80
         caption 'CSV'
         action ::Export2CSV
      end button
      define button html
         row 465
         col 280
         width 80
         caption 'HTML'
         action ::Export2HTML
      end button
      define button text
         row 465
         col 370
         width 80
         caption 'Text'
         action ::Export2TXT
      end button
      define statusbar 
         statusitem 'Paper Size :' width 200
         statusitem 'Content Width :' width 200
         statusitem 'Printable Width :' width 200
         statusitem ''
      end statusbar
   end window
   // init controls
   gp.header1.value := ::cReportHeader1
   gp.header2.value := ::cReportHeader2
   gp.header3.value := ::cReportHeader3
   gp.footer.value := ::cReportFooter
   if hmg_len( ::cPrinter ) > 0
      for i := 1 to gp.printers.itemcount
         if gp.printers.item( i ) == ::cPrinter
            gp.printers.value := i
            exit
         endif
      next i
   endif
   if ::nPaperSize > 0 .and. ::nPaperSize < 256
      gp.papersizes.value := ::nPaperSize
      gp.width.enabled := .f.
      gp.height.enabled := .f.
   endif
   if ::nPaperSize == 256 // custom size
      stopcontroleventprocedure( 'customsize', 'gp', .t. )
      gp.customsize.value := .t.
      gp.papersizes.enabled := .f.
      gp.width.value := ::nPaperWidth
      gp.height.value := ::nPaperHeight
      gp.width.enabled := .t.
      gp.height.enabled := .t.
      stopcontroleventprocedure( 'customsize', 'gp', .f. )
   endif
   stopcontroleventprocedure( 'leftmargin', 'gp', .t. )
   stopcontroleventprocedure( 'rightmargin', 'gp', .t. )
   gp.leftmargin.value := ::nLeftMargin
   gp.rightmargin.value := gp.rightmargin.rangemax - ::nRightMargin
   stopcontroleventprocedure( 'leftmargin', 'gp', .f. )
   stopcontroleventprocedure( 'rightmargin', 'gp', .f. )
   gp.left.value := ::nLeftMargin
   gp.right.value := ::nRightMargin 
   gp.top.value := ::nTopMargin
   gp.bottom.value := ::nBottomMargin
   if ::nOrientation > 0
      gp.orientation.value := ::nOrientation
   endif
   gp.horizontal.value := ::lHorizontalLines
   gp.vertical.value := ::lVerticalLines
   gp.wordwrap.value := ::lWordWrap
   gp.pagecenter.value := ::lPageCenter
   gp.spreadwhite.value := ::lSpreadWhiteSpace
   gp.truncatecol.value := ::lTruncateColumns
   gp.footerdate.value := ::lIncludeDate
   gp.dateprefix.value := ::cDatePrefix
   gp.footertime.value := ::lIncludeTime
   gp.Timeprefix.value := ::cTimePrefix
   gp.footeralign.value := ::nDateTimeAlignment + 1   
   gp.pagenumbering.value := ::lPageNumbering
   gp.pageprefix.value := ::cPageNumberPrefix
   gp.pageposition.value := ::nPageNumberPosition
   gp.pagenoalign.value := ::nPageNumberAlignment + 1   
   gp.preview.value := ::lPreview
   if hmg_len( ::aGroupColumns ) > 0
      for i := 1 to hmg_len( ::aGroupColumns )
         gp.grouplist.additem( ::aColumnHeaders[ ::aGroupColumns[ i ] ] )
      next i
   endif   
   gp.colsums.checkboxenabled := .t.
   gp.mergeheaders.checkboxenabled := .t.
   for i := 1 to hmg_len( ::aColumnHeaders )
      gp.colsums.additem( { ::aColumnHeaders[ i ] } )
   next i
   ::MergeHeadersUpdate()
   if hmg_len( ::aColumnSum ) > 0
      stopcontroleventprocedure( 'colsums', 'gp', .t. )
      gp.colsums.checkboxallitems := .f.
      for i := 1 to hmg_len( ::aColumnSum )
         gp.colsums.checkboxitem( ::aColumnSum[ i ] ) := .t.
      next i
      stopcontroleventprocedure( 'colsums', 'gp', .f. )
   endif
   ::DrawScale()
   ::ControlsFontUpdate()
   gp.center
   gp.activate
return nil


METHOD DrawScale() Class GridPlus
   local nRectRow := 10
   local nRectCol := 10
   local nRectWidth := ::nPaperWidth * ::nMM2Pixel // 1860
   local nRectHeight := 35
   local hDC, BTStruct
   local nCMHeight := 15
   local nHalfCMHeight := 10
   local nMMHeight := 5
   local nMMPenWidth := 0.1
   local nCMPenWidth := 0.15
   local cFontName := 'Arial'
   local nFontSize := 8
   local nPrintableLength := ::nPaperWidth 
   local hBitMap
   hBitMap := BT_BitmapCreateNew( nRectWidth, nRectHeight, { 255, 255, 255 } )
   hDC := BT_CreateDC ( hBitMap,  BT_HDC_BITMAP, @BTstruct )
   nMMCount := 0
   gp.leftmargin.width := ( ::nPaperWidth * ::nMM2Pixel ) / 2 
   gp.rightmargin.width := ( ::nPaperWidth * ::nMM2Pixel ) / 2 
   gp.rightmargin.col := nRectWidth + 10 - gp.rightmargin.width + 10
   gp.leftmargin.rangemin := 0
   gp.leftmargin.rangemax := int( ::nPaperWidth / 2 )
   gp.rightmargin.rangemin := 0
   gp.rightmargin.rangemax := int( ::nPaperWidth / 2 )
   for i := 0 to nRectWidth step ::nMM2Pixel         
      do case 
      case mod( nMMCount, 10 ) == 0 // cm
         BT_DrawLine( hDC, nRectHeight - 2, i,  nRectHeight - nCMHeight, i, { 0, 0, 0 }, nCMPenWidth )
         BT_DrawText( hDC, nRectHeight - 2 - nCMHeight - 10, i, alltrim( str( nMMCount ) ) , cFontName, nFontSize, { 0, 0, 0 }, { 255, 255, 255 }, , BT_TEXT_CENTER )
      case mod( nMMCount, 5 ) == 0 // half cm
         BT_DrawLine( hDC, nRectHeight - 2, i,  nRectHeight - nHalfCMHeight, i, { 0, 0, 0 }, nMMPenWidth )
      otherwise // just mm
         BT_DrawLine( hDC, nRectHeight - 2, i,  nRectHeight - nMMHeight, i, { 0, 0, 0 }, nMMPenWidth )
      endcase
      nMMCount++
   next i   
   // page breaks
   for i := 0 to nRectWidth step ( nPrintableLength * ::nMM2Pixel )
      BT_DrawLine( hDC, 0, i, nRectHeight, i, { 0, 0, 255 }, 2 )
   next i      
   BT_DeleteDC( BTstruct )
   BT_HMGSetImage ( 'gp', 'scale', hBitmap, .t. )
   gp.model.col := ( ::LeftMargin * ::nMM2Pixel ) + 10
   gp.model.width := ( ::nPaperWidth - ::nLeftMargin - ::nRightMargin ) * ::nMM2Pixel
return self

METHOD PrinterChanged() CLASS GridPlus
   local nLineNo := gp.printers.value
   if nLineNo > 0
      ::cPrinter := gp.printers.item( nLineNo )
   endif   
RETURN Self

METHOD PaperSizeChanged() CLASS GridPlus
   local nWO := 0.0
   local nHO := 0.0
   local lSuccess := .f.
   if gp.papersizes.value > 0
      ::nPaperSize := gp.papersizes.value
   else 
      return nil   
   endif   
   if hmg_len( ::cPrinter ) == 0
      return nil
   endif
   nPaperSize := gp.papersizes.value
   SELECT PRINTER ::cPrinter TO lSuccess ORIENTATION ::nOrientation PAPERSIZE ::nPaperSize COPIES 1
   if lSuccess
      nHO := GETPRINTABLEAREAHORIZONTALOFFSET()
      nVO := GETPRINTABLEAREAVERTICALOFFSET()
      ::nPaperWidth := GETPRINTABLEAREAWIDTH() + ( nHO * 2 )
      ::nPaperHeight := GETPRINTABLEAREAHEIGHT() + ( nVO * 2 )   
      gp.width.value := ::nPaperWidth
      gp.height.value := ::nPaperHeight
      gp.width.enabled := .f.
      gp.height.enabled := .f.
      ::DrawScale()
   endif   
return self

METHOD OrientationChanged() CLASS GridPlus
   local nTemp := 0
   if gp.orientation.value > 0
      ::nOrientation := gp.orientation.value
      if gp.customsize.value // if custom size
         stopcontroleventprocedure( 'width', 'gp', .t. )
         stopcontroleventprocedure( 'height', 'gp', .t. )
         if gp.orientation.value == 1 // portrait
            gp.width.value := ::nPaperWidth
            gp.height.value := ::nPaperHeight
         else // landscape
            gp.width.value := ::nPaperHeight
            gp.height.value := ::nPaperWidth
         endif       
         stopcontroleventprocedure( 'width', 'gp', .f. )
         stopcontroleventprocedure( 'height', 'gp', .f. )
         ::DrawScale()   
      else
         ::PaperSizeChanged()
      endif   
   endif   
return Self

METHOD CustomSizeSelected() CLASS GridPlus
   if gp.customsize.value
      ::nPaperSize := 256
      gp.width.enabled := .t.
      gp.height.enabled := .t.
      gp.papersizes.enabled := .f.
   else
      if gp.papersizes.value > 0
         ::nPaperSize := gp.papersizes.value
      else
         ::nPaperSize := 9 // a4
         gp.papersizes.value := ::nPaperSize        
      endif   
      gp.width.enabled := .f.
      gp.height.enabled := .f.
      gp.papersizes.enabled := .t.
   endif   
   ::DrawScale()
return nil

METHOD MarginChanged() CLASS GridPlus
   if .not. iscontroldefined( 'html', 'gp' )
      return nil   
   endif
   if gp.top.value < 0 .or. gp.bottom.value < 0 .or. gp.right.value < 0 .or. gp.left.value < 0
      msgstop( 'Invalid Margin!' )
      return nil
   endif
   ::nTopMargin   := gp.top.value
   ::nBottomMargin := gp.bottom.value
   ::nRightMargin := gp.right.value 
   ::nLeftMargin  := gp.left.value 
   stopcontroleventprocedure( 'leftmargin', 'gp', .t. )
   stopcontroleventprocedure( 'rightmargin', 'gp', .t. )
   gp.leftmargin.value := ::nLeftMargin
   gp.rightmargin.value := gp.rightmargin.rangemax - ::nRightMargin
   stopcontroleventprocedure( 'leftmargin', 'gp', .f. )
   stopcontroleventprocedure( 'rightmargin', 'gp', .f. )
   ::DrawScale()
return nil   

METHOD PaperWidthChanged CLASS GridPlus
   if gp.width.value < 0 
      msgstop( 'Invalid Width!' )
      return nil
   endif
   if gp.customsize.value // custom size is selected. User changes the width
      ::nPaperWidth := gp.width.value
      ::DrawScale()
   endif   
return nil

METHOD PaperHeightChanged CLASS GridPlus
   if gp.height.value < 0 
      msgstop( 'Invalid Height!' )
      return nil
   endif
   if gp.customsize.value // custom size is selected. User changes the width
      ::nPaperHeight := gp.height.value
   endif   
return nil

METHOD ColumnSumChecked CLASS GridPlus
   local i := 0
   asize( ::aColumnSum, 0 )
   for i := 1 to gp.colsums.itemcount
      if gp.colsums.checkboxitem( i )
         aadd( ::aColumnSum, i )
      endif
   next i      
return nil

METHOD AddToGroup CLASS GridPlus
   local nLineNo := gp.fromlist.value
   local i := 0
   if nLineNo > 0
      if gp.grouplist.itemcount < 3 // only 3 levels of groups allowed
         for i := 1 to gp.grouplist.itemcount
            if gp.grouplist.item( i ) == gp.fromlist.item( nLineNo ) // column is already added!
               return nil
            endif
         next i
         gp.grouplist.additem( gp.fromlist.item( nLineNo ) )
         aadd( ::aGroupColumns, nLineNo )
         gp.grouplist.value := gp.grouplist.itemcount
      endif
   endif
return nil

METHOD DelFromGroup CLASS GridPlus
   local nLineNo := gp.grouplist.value
   if nLineNo > 0
      gp.grouplist.deleteitem( nLineNo )
      adel( ::aGroupColumns, nLineNo )
      asize( ::aGroupColumns, hmg_len( ::aGroupColumns ) - 1 )
      if nLineNo > 1
         gp.grouplist.value := nLineNo - 1
      else
         if gp.grouplist.itemcount > 0
            gp.grouplist.value := nLineNo 
         endif
      endif
   endif   
return nil

METHOD MoveUpGroup CLASS GridPlus
   local nLineNo := gp.grouplist.value
   local cTemp := ''
   local nTemp := 0
   if nLineNo > 1
      cTemp := gp.grouplist.item( nLineNo - 1 )
      nTemp := ::aGroupColumns[ nLineNo - 1 ]
      gp.grouplist.item( nLineNo - 1 ) := gp.grouplist.item( nLineNo )
      gp.grouplist.item( nLineNo ) := cTemp
      gp.grouplist.value := nLineNo - 1 
      // in data
      ::aGroupColumns[ nLineNo - 1 ] := ::aGroupColumns[ nLineNo ]
      ::aGroupColumns[ nLineNo ] := nTemp
   endif   
return nil

METHOD MoveDownGroup CLASS GridPlus
   local nLineNo := gp.grouplist.value
   local cTemp := ''
   local nTemp := 0
   if nLineNo < gp.grouplist.itemcount
      cTemp := gp.grouplist.item( nLineNo + 1 )
      nTemp := ::aGroupColumns[ nLineNo + 1 ]
      gp.grouplist.item( nLineNo + 1 ) := gp.grouplist.item( nLineNo )
      gp.grouplist.item( nLineNo ) := cTemp
      gp.grouplist.value := nLineNo + 1 
      // in data
      ::aGroupColumns[ nLineNo + 1 ] := ::aGroupColumns[ nLineNo ]
      ::aGroupColumns[ nLineNo ] := nTemp
   endif   
return nil


METHOD LoadPaperSizes() CLASS GridPlus
   asize( ::aPaperSizes, 0 ) 
   ::aPaperSizes := {;
   "Letter 8 1/2 x 11 in",;               
   "Letter Small 8 1/2 x 11 in",;         
   "Tabloid 11 x 17 in",;                 
   "Ledger 17 x 11 in",;                  
   "Legal 8 1/2 x 14 in",;                
   "Statement 5 1/2 x 8 1/2 in",;         
   "Executive 7 1/4 x 10 1/2 in",;      
   "A3 297 x 420 mm",;                    
   "A4 210 x 297 mm",;                    
   "A4 Small 210 x 297 mm",;              
   "A5 148 x 210 mm",;                    
   "B4 (JIS) 250 x 354",;
   "B5 (JIS) 182 x 257 mm",;              
   "Folio 8 1/2 x 13 in",;                
   "Quarto 215 x 275 mm",;                
   "10x14 in",;                           
   "11x17 in",;                           
   "Note 8 1/2 x 11 in",;                 
   "Envelope #9 3 7/8 x 8 7/8",;          
   "Envelope #10 4 1/8 x 9 1/2",;         
   "Envelope #11 4 1/2 x 10 3/8",;        
   "Envelope #12 4 \276 x 11",;           
   "Envelope #14 5 x 11 1/2",;            
   "C size sheet",;                       
   "D size sheet",;                       
   "E size sheet",;                       
   "Envelope DL 110 x 220mm",;            
   "Envelope C5 162 x 229 mm",;           
   "Envelope C3  324 x 458 mm",;          
   "Envelope C4  229 x 324 mm",;          
   "Envelope C6  114 x 162 mm",;          
   "Envelope C65 114 x 229 mm",;          
   "Envelope B4  250 x 353 mm",;          
   "Envelope B5  176 x 250 mm",;          
   "Envelope B6  176 x 125 mm",;          
   "Envelope 110 x 230 mm",;              
   "Envelope Monarch 3.875 x 7.5 in",;    
   "6 3/4 Envelope 3 5/8 x 6 1/2 in",;    
   "US Std Fanfold 14 7/8 x 11 in",;      
   "German Std Fanfold 8 1/2 x 12 in",;
   "German Legal Fanfold 8 1/2 x 13 in",; 
   "B4 (ISO) 250 x 353 mm",;              
   "Japanese Postcard 100 x 148 mm",;     
   "9 x 11 in",;                          
   "10 x 11 in",;                         
   "15 x 11 in",;                         
   "Envelope Invite 220 x 220 mm",;       
   "RESERVED--DO NOT USE",;               
   "RESERVED--DO NOT USE",;               
   "Letter Extra 9 \275 x 12 in",;        
   "Legal Extra 9 \275 x 15 in",;         
   "Tabloid Extra 11.69 x 18 in",;        
   "A4 Extra 9.27 x 12.69 in",;           
   "Letter Transverse 8 \275 x 11 in",;   
   "A4 Transverse 210 x 297 mm",;         
   "Letter Extra Transverse 9\275 x 12 in",; 
   "SuperA/SuperA/A4 227 x 356 mm",;      
   "SuperB/SuperB/A3 305 x 487 mm",;      
   "Letter Plus 8.5 x 12.69 in",;         
   "A4 Plus 210 x 330 mm",;               
   "A5 Transverse 148 x 210 mm",;         
   "B5 (JIS) Transverse 182 x 257 mm",;   
   "A3 Extra 322 x 445 mm",;              
   "A5 Extra 174 x 235 mm",;              
   "B5 (ISO) Extra 201 x 276 mm",;        
   "A2 420 x 594 mm",;                    
   "A3 Transverse 297 x 420 mm",;         
   "A3 Extra Transverse 322 x 445 mm",;   
   "Japanese Double Postcard 200 x 148 mm",; 
   "A6 105 x 148 mm",;                 
   "Japanese Envelope Kaku #2",;       
   "Japanese Envelope Kaku #3",;       
   "Japanese Envelope Chou #3",;       
   "Japanese Envelope Chou #4",;       
   "Letter Rotated 11 x 8 1/2 11 in",; 
   "A3 Rotated 420 x 297 mm",;         
   "A4 Rotated 297 x 210 mm",;         
   "A5 Rotated 210 x 148 mm",;         
   "B4 (JIS) Rotated 364 x 257 mm",;   
   "B5 (JIS) Rotated 257 x 182 mm",;   
   "Japanese Postcard Rotated 148 x 100 mm",; 
   "Double Japanese Postcard Rotated 148 x 200 mm",; 
   "A6 Rotated 148 x 105 mm",;         
   "Japanese Envelope Kaku #2 Rotated",; 
   "Japanese Envelope Kaku #3 Rotated",; 
   "Japanese Envelope Chou #3 Rotated",; 
   "Japanese Envelope Chou #4 Rotated",; 
   "B6 (JIS) 128 x 182 mm",;           
   "B6 (JIS) Rotated 182 x 128 mm",;   
   "12 x 11 in",;                      
   "Japanese Envelope You #4",;        
   "Japanese Envelope You #4 Rotated",;
   "PRC 16K 146 x 215 mm",;            
   "PRC 32K 97 x 151 mm",;             
   "PRC 32K(Big) 97 x 151 mm",;        
   "PRC Envelope #1 102 x 165 mm",;    
   "PRC Envelope #2 102 x 176 mm",;    
   "PRC Envelope #3 125 x 176 mm",;    
   "PRC Envelope #4 110 x 208 mm",;    
   "PRC Envelope #5 110 x 220 mm",;    
   "PRC Envelope #6 120 x 230 mm",;    
   "PRC Envelope #7 160 x 230 mm",;    
   "PRC Envelope #8 120 x 309 mm",;    
   "PRC Envelope #9 229 x 324 mm",;    
   "PRC Envelope #10 324 x 458 mm",;   
   "PRC 16K Rotated",;                 
   "PRC 32K Rotated",;                 
   "PRC 32K(Big) Rotated",;            
   "PRC Envelope #1 Rotated 165 x 102 mm",; 
   "PRC Envelope #2 Rotated 176 x 102 mm",; 
   "PRC Envelope #3 Rotated 176 x 125 mm",; 
   "PRC Envelope #4 Rotated 208 x 110 mm",; 
   "PRC Envelope #5 Rotated 220 x 110 mm",; 
   "PRC Envelope #6 Rotated 230 x 120 mm",; 
   "PRC Envelope #7 Rotated 230 x 160 mm",; 
   "PRC Envelope #8 Rotated 309 x 120 mm",; 
   "PRC Envelope #9 Rotated 324 x 229 mm",; 
   "PRC Envelope #10 Rotated 458 x 324 mm",; 
}
return nil

Method ColumnSizeCheck() CLASS GridPlus
   local nTotalWidth := 0
   local i := 0
   for i := 1 to gp.model.columncount
      ::aColumnWidths[ i ] := gp.model.columnWidth( i ) / ::nMM2Pixel
   next i   
//   ::DrawScale()
return nil

Method SelectReportHeaderFont() CLASS GridPlus
   local aFont := { }
   // { cFontName, nFontSize, lBold, lItalic, lUnderline, lStrikeout }
   aFont := GetFont( ::aReportHeaderFont[ 1 ], ::aReportHeaderFont[ 2 ], ::aReportHeaderFont[ 3 ], ::aReportHeaderFont[ 4 ], , ::aReportHeaderFont[ 5 ], ::aReportHeaderFont[ 6 ]  )
   if aFont[ 1 ] == ''
      // nothing is selected
   else
      ::aReportHeaderFont[ 1 ] := aFont[ 1 ]
      ::aReportHeaderFont[ 2 ] := aFont[ 2 ]
      ::aReportHeaderFont[ 3 ] := aFont[ 3 ]
      ::aReportHeaderFont[ 4 ] := aFont[ 4 ]
      ::aReportHeaderFont[ 5 ] := aFont[ 6 ]
      ::aReportHeaderFont[ 6 ] := aFont[ 7 ]
      ::ControlsFontUpdate()
   endif   
return nil

Method SelectReportFooterFont() CLASS GridPlus
   local aFont := { }
   // { cFontName, nFontSize, lBold, lItalic, lUnderline, lStrikeout }
   aFont := GetFont( ::aReportFooterFont[ 1 ], ::aReportFooterFont[ 2 ], ::aReportFooterFont[ 3 ], ::aReportFooterFont[ 4 ], , ::aReportFooterFont[ 5 ], ::aReportFooterFont[ 6 ]  )
   if aFont[ 1 ] == ''
      // nothing is selected
   else
      ::aReportFooterFont[ 1 ] := aFont[ 1 ]
      ::aReportFooterFont[ 2 ] := aFont[ 2 ]
      ::aReportFooterFont[ 3 ] := aFont[ 3 ]
      ::aReportFooterFont[ 4 ] := aFont[ 4 ]
      ::aReportFooterFont[ 5 ] := aFont[ 6 ]
      ::aReportFooterFont[ 6 ] := aFont[ 7 ]
      ::ControlsFontUpdate()
   endif   
return nil

Method SelectReportFont() CLASS GridPlus
   local aFont := { }
   // { cFontName, nFontSize, lBold, lItalic, lUnderline, lStrikeout }
   aFont := GetFont( ::aReportFont[ 1 ], ::aReportFont[ 2 ], ::aReportFont[ 3 ], ::aReportFont[ 4 ], , ::aReportFont[ 5 ], ::aReportFont[ 6 ]  )
   if aFont[ 1 ] == ''
      // nothing is selected
   else
      ::aReportFont[ 1 ] := aFont[ 1 ]
      ::aReportFont[ 2 ] := aFont[ 2 ]
      ::aReportFont[ 3 ] := aFont[ 3 ]
      ::aReportFont[ 4 ] := aFont[ 4 ]
      ::aReportFont[ 5 ] := aFont[ 6 ]
      ::aReportFont[ 6 ] := aFont[ 7 ]
      ::ControlsFontUpdate()
   endif   
return nil



Method ControlsFontUpdate() Class GridPlus
   gp.header1.fontname := ::aReportHeaderFont[ 1 ]
   gp.header2.fontname := ::aReportHeaderFont[ 1 ]
   gp.header3.fontname := ::aReportHeaderFont[ 1 ]
   gp.header1.fontsize := ::aReportHeaderFont[ 2 ]
   gp.header2.fontsize := ::aReportHeaderFont[ 2 ]
   gp.header3.fontsize := ::aReportHeaderFont[ 2 ]
   gp.header1.fontbold := ::aReportHeaderFont[ 3 ]
   gp.header2.fontbold := ::aReportHeaderFont[ 3 ]
   gp.header3.fontbold := ::aReportHeaderFont[ 3 ]
   gp.header1.fontitalic := ::aReportHeaderFont[ 4 ]
   gp.header2.fontitalic := ::aReportHeaderFont[ 4 ]
   gp.header3.fontitalic := ::aReportHeaderFont[ 4 ]
   gp.header1.fontunderline := ::aReportHeaderFont[ 5 ]
   gp.header2.fontunderline := ::aReportHeaderFont[ 5 ]
   gp.header3.fontunderline := ::aReportHeaderFont[ 5 ]
   gp.header1.fontstrikeout := ::aReportHeaderFont[ 6 ]
   gp.header2.fontstrikeout := ::aReportHeaderFont[ 6 ]
   gp.header3.fontstrikeout := ::aReportHeaderFont[ 6 ]
   gp.footer.fontname := ::aReportFooterFont[ 1 ]
   gp.footer.fontsize := ::aReportFooterFont[ 2 ] 
   gp.footer.fontbold := ::aReportFooterFont[ 3 ]
   gp.footer.fontitalic := ::aReportFooterFont[ 4 ]
   gp.footer.fontunderline := ::aReportFooterFont[ 5 ]
   gp.footer.fontstrikeout := ::aReportFooterFont[ 6 ]
   gp.model.fontname := ::aReportFont[ 1 ]
   gp.model.fontsize := ::aReportFont[ 2 ]
   gp.model.fontbold := ::aReportFont[ 3 ]
   gp.model.fontitalic := ::aReportFont[ 4 ]
   gp.model.fontunderline := ::aReportFont[ 5 ]
   gp.model.fontstrikeout := ::aReportFont[ 6 ] 
   
return nil
       
Method PrintLen( cString, nFontSize, cFontName ) CLASS GridPlus
return round( gettextwidth( Nil, cString, cFontName ) * 0.072 / 72 * 25.4 * nFontSize, 2 )

METHOD PrintData( nRow, nCol, cData, aFont, cAlign ) Class GridPlus
      _HMG_PRINTER_H_PRINT ( _HMG_SYSDATA [ 374 ] , ; // printerhandle
                     nRow, ; // row
                     nCol,; // col
                     aFont[ 1 ], ; // fontname
                     aFont[ 2 ], ; // size
                     0, 0, 0, ; // colors
                     cData, ;  // data
                     aFont[ 3 ], ; // bold
                     aFont[ 4 ], ; // italic
                     aFont[ 5 ], ; // underline
                     aFont[ 6 ], ; // strikeout
                     .t., .t., .t., cAlign )
return nil                     

METHOD PrintLine( aItems, lFirst, lFontBold ) CLASS GridPlus
   local nTempCol := ::nPrintCurCol
   local i := 0
   local nJustify := 0
   local aJustify := aClone( ::aPrintJustify )
   local aWidths := aClone( ::aPrintWidths )
   local cFontName := ::aReportFont[ 1 ]
   local nFontSize := ::aReportFont[ 2 ]
   default lFontBold := .f.
   if hmg_len( aItems ) == 1 // column header 
      aJustify := { 0 }
      aWidths := { ::nPrintMaxCol }
   endif   
   if hmg_len( aItems ) <> hmg_len( aJustify )
      return nil
   endif
   // first row separator
   if lFirst .and. .not. ::lMergeHeader
      @ ::nPrintCurRow, ::nPrintCurCol - ( ::nColSpacing / 2 ) print line to ::nPrintCurRow, ::nPrintMaxCol penwidth ::nPenWidth
   endif   
   // col separator
   @ ::nPrintCurRow, ::nPrintCurCol - ( ::nColSpacing / 2 ) print line to ::nPrintCurRow + ::nPrintLineHeight, ::nPrintCurCol - ( ::nColSpacing / 2 ) penwidth ::nPenWidth // left most
   @ ::nPrintCurRow, ::nPrintMaxCol print line to ::nPrintCurRow + ::nPrintLineHeight, ::nPrintMaxCol penwidth ::nPenWidth // right most
   for i := 1 to HMG_LEN( aItems )
      nJustify := aJustify[ i ]
      do case
         case nJustify == 0 //left
            if lFontBold
               @ ::nPrintCurRow, nTempCol print aItems[ i ] font cFontName size nFontSize bold
            else   
               @ ::nPrintCurRow, nTempCol print aItems[ i ] font cFontName size nFontSize
            endif   
         case nJustify == 1 //right
            if lFontBold
               @ ::nPrintCurRow, nTempCol + aWidths[ i ] print aItems[ i ] font cFontName size nFontSize bold right
            else
               @ ::nPrintCurRow, nTempCol + aWidths[ i ] print aItems[ i ] font cFontName size nFontSize right
            endif            
         case nJustify == 2 // center
            if lFontBold 
               @ ::nPrintCurRow, nTempCol + ( aWidths[ i ] / 2 ) print aItems[ i ] font cFontName size nFontSize bold center
            else   
               @ ::nPrintCurRow, nTempCol + ( aWidths[ i ] / 2 ) print aItems[ i ] font cFontName size nFontSize center
            endif   
      end case
      nTempCol := nTempCol + aWidths[ i ] + ::nColSpacing
      if ::lVerticalLines
         // column separator
         if i < hmg_len( aItems )
            @ ::nPrintCurRow, nTempCol - ( ::nColSpacing / 2 ) print line to ::nPrintCurRow + ::nPrintLineHeight, nTempCol - ( ::nColSpacing / 2 ) penwidth ::nPenWidth
         endif
      endif         
   next i
   // row separator
   if lFirst
      @ ::nPrintCurRow + ::nPrintLineHeight, ::nPrintCurCol - ( ::nColSpacing / 2 ) print line to ::nPrintCurRow + ::nPrintLineHeight, ::nPrintMaxCol penwidth ::nPenWidth
   else   
      if ::lHorizontalLines
         @ ::nPrintCurRow + ::nPrintLineHeight, ::nPrintCurCol - ( ::nColSpacing / 2 ) print line to ::nPrintCurRow + ::nPrintLineHeight, ::nPrintMaxCol penwidth ::nPenWidth
      endif
   endif   
   if ::nPrintCurRow + ::nPrintLineHeight > ::nPrintMaxRow
      if .not. ::lHorizontalLines // even though no horizontal lines, print the last line to complete the outline box
         @ ::nPrintCurRow + ::nPrintLineHeight, ::nPrintCurCol - ( ::nColSpacing / 2 ) print line to ::nPrintCurRow + ::nPrintLineHeight, ::nPrintMaxCol penwidth ::nPenWidth
      endif         
      ::nPrintCurPage++
      ::StartNewPage()
   endif
return nil




METHOD PrintMultiLine( aItems, lFirst, lFontBold, nMaxLines ) CLASS GridPlus
   local nTempCol := ::nPrintCurCol
   local i := 0
   local nJustify := 0
   local aJustify := aclone( ::aPrintJustify )
   local aWidths := aclone( ::aPrintWidths )
   local cFontName := ::aReportFont[ 1 ]
   local nFontSize := ::aReportFont[ 2 ]
   local nToRow := ::nPrintCurRow + ( ::nPrintLineHeight * nMaxLines )
   default lFontBold := .f.
   if hmg_len( aItems ) <> hmg_len( aJustify )
      return nil
   endif
   // col separator
   @ ::nPrintCurRow, ::nPrintCurCol - ( ::nColSpacing / 2 ) print line to nToRow, ::nPrintCurCol - ( ::nColSpacing / 2 ) penwidth ::nPenWidth // left most
   @ ::nPrintCurRow, ::nPrintMaxCol print line to nToRow, ::nPrintMaxCol penwidth ::nPenWidth // right most
   for i := 1 to HMG_LEN( aItems )
      nJustify := aJustify[ i ]
      do case
         case nJustify == 0 //left
            if lFontBold
               @ ::nPrintCurRow, nTempCol print aItems[ i ] to nToRow, nTempCol + aWidths[ i ] font cFontName size nFontSize bold
            else   
               @ ::nPrintCurRow, nTempCol print aItems[ i ] to nToRow, nTempCol + aWidths[ i ] font cFontName size nFontSize 
            endif   
         case nJustify == 1 //right
            if lFontBold
               @ ::nPrintCurRow, nTempCol print aItems[ i ] to nToRow, nTempCol + aWidths[ i ] font cFontName size nFontSize bold right
            else
               @ ::nPrintCurRow, nTempCol print aItems[ i ] to nToRow, nTempCol + aWidths[ i ] font cFontName size nFontSize right
            endif            
         case nJustify == 2 // center
            if lFontBold 
               @ ::nPrintCurRow, nTempCol print aItems[ i ] to nToRow, nTempCol + aWidths[ i ] font cFontName size nFontSize bold center
            else   
               @ ::nPrintCurRow, nTempCol print aItems[ i ] to nToRow, nTempCol + aWidths[ i ] font cFontName size nFontSize center
            endif   
      end case
      nTempCol := nTempCol + aWidths[ i ] + ::nColSpacing
      if ::lVerticalLines
         // column separator
         if i < hmg_len( aItems )
            @ ::nPrintCurRow, nTempCol - ( ::nColSpacing / 2 ) print line to nToRow, nTempCol - ( ::nColSpacing / 2 ) penwidth ::nPenWidth
         endif
      endif         
   next i
   // row separator
   if ::lHorizontalLines
      @ nToRow, ::nPrintCurCol - ( ::nColSpacing / 2 ) print line to nToRow, ::nPrintMaxCol penwidth ::nPenWidth
   endif
   if ::nPrintCurRow + ( ::nPrintLineHeight * nMaxLines ) > ::nPrintMaxRow
      if .not. ::lHorizontalLines // even though no horizontal lines, print the last line to complete the outline box
         @ ::nPrintCurRow + ( ::nPrintLineHeight * nMaxLines ), ::nPrintCurCol - ( ::nColSpacing / 2 ) print line to ::nPrintCurRow + ( ::nPrintLineHeight * nMaxLines ), ::nPrintMaxCol penwidth ::nPenWidth
      endif         
      ::nPrintCurPage++
      ::StartNewPage()
   endif
return nil

METHOD PrintMergeHeaders( ) CLASS GridPlus
   local nTempCol := ::nPrintCurCol
   local i := 0
   local lFirst := .t.
   local nJustify := 0
   local aJustify := {}
   local aWidths := {}
   local aPrintLine := {}
   local cFontName := ::aReportFont[ 1 ]
   local nFontSize := ::aReportFont[ 2 ]
   local lFontBold := .t.
   for i := 1 to HMG_LEN( ::aPrintColumns )
      for j := 1 to hmg_len( ::aMergeHeaders )
         nStartCol := ::aMergeHeaders[ j, 1 ]
         nEndCol := ::aMergeHeaders[ j, 2 ]
         cHeader := ::aMergeHeaders[ j, 3 ]
         nTotalWidth := 0
         do while ::aPrintColumns[ i ] < nStartCol
            nTotalWidth := nTotalWidth + ::aPrintWidths[ i ]  + ::nColSpacing
            i++
         enddo
         if nTotalWidth > 0
            aadd( aPrintLine, '' )
            aadd( aWidths, nTotalWidth - ::nColSpacing )
            aadd( aJustify, 2 )
         endif   
         if i < hmg_len( ::aPrintColumns )
            nTotalWidth := 0
            do while i <= hmg_len( ::aPrintColumns ) .and. ::aPrintColumns[ i ] <= nEndCol
               nTotalWidth := nTotalWidth + ::aPrintWidths[ i ]  + ::nColSpacing
               i++
            enddo
            if nTotalWidth > 0
               aadd( aPrintLine, cHeader )
               aadd( aWidths, nTotalWidth - ::nColSpacing )
               aadd( aJustify, 2 )
            endif   
         endif   
      next j   
      if i <= hmg_len( ::aPrintColumns )
         nTotalWidth := 0
         do while i <= hmg_len( ::aPrintColumns )
            nTotalWidth := nTotalWidth + ::aPrintWidths[ i ] + ::nColSpacing
            i++
         enddo
         if nTotalWidth > 0
            aadd( aPrintLine, '' )
            aadd( aWidths, nTotalWidth - ::nColSpacing )
            aadd( aJustify, 2 )
         endif   
      endif   
   next i      
   for i :=  1 to hmg_len( aPrintLine )
      if ::PrintLen( aPrintLine[ i ], nFontSize, cFontName ) > aWidths[ i ]
         cData := aPrintLine[ i ]
         nCount := hmg_len( cData )
         do while ::PrintLen( hb_usubstr( cData, 1, nCount ), nFontSize, cFontName ) > aWidths[ i ]
            nCount := nCount - 1 
         enddo
         aPrintLine[ i ] :=  hb_usubstr( cData, 1, nCount ) 
      endif   
   next i   
   
   // first row separator
   if lFirst
      @ ::nPrintCurRow, ::nPrintCurCol - ( ::nColSpacing / 2 ) print line to ::nPrintCurRow, ::nPrintMaxCol penwidth ::nPenWidth
   endif   
   // col separator
   @ ::nPrintCurRow, ::nPrintCurCol - ( ::nColSpacing / 2 ) print line to ::nPrintCurRow + ::nPrintLineHeight, ::nPrintCurCol - ( ::nColSpacing / 2 ) penwidth ::nPenWidth // left most
   @ ::nPrintCurRow, ::nPrintMaxCol print line to ::nPrintCurRow + ::nPrintLineHeight, ::nPrintMaxCol penwidth ::nPenWidth // right most
   for i := 1 to HMG_LEN( aPrintLine )
      nJustify := aJustify[ i ]
      do case
         case nJustify == 0 //left
            if lFontBold
               @ ::nPrintCurRow, nTempCol print aPrintLine[ i ] font cFontName size nFontSize bold
            else   
               @ ::nPrintCurRow, nTempCol print aPrintLine[ i ] font cFontName size nFontSize
            endif   
         case nJustify == 1 //right
            if lFontBold
               @ ::nPrintCurRow, nTempCol + aWidths[ i ] print aPrintLine[ i ] font cFontName size nFontSize bold right
            else
               @ ::nPrintCurRow, nTempCol + aWidths[ i ] print aPrintLine[ i ] font cFontName size nFontSize right
            endif            
         case nJustify == 2 // center
            if lFontBold 
               @ ::nPrintCurRow, nTempCol + ( aWidths[ i ] / 2 ) print aPrintLine[ i ] font cFontName size nFontSize bold center
            else   
               @ ::nPrintCurRow, nTempCol + ( aWidths[ i ] / 2 ) print aPrintLine[ i ] font cFontName size nFontSize center
            endif   
      end case
      nTempCol := nTempCol + aWidths[ i ] + ::nColSpacing
      if ::lVerticalLines
         // column separator
         if i < hmg_len( aPrintLine )
            @ ::nPrintCurRow, nTempCol - ( ::nColSpacing / 2 ) print line to ::nPrintCurRow + ::nPrintLineHeight, nTempCol - ( ::nColSpacing / 2 ) penwidth ::nPenWidth
         endif
      endif         
   next i
   // row separator
   if lFirst
      @ ::nPrintCurRow + ::nPrintLineHeight, ::nPrintCurCol - ( ::nColSpacing / 2 ) print line to ::nPrintCurRow + ::nPrintLineHeight, ::nPrintMaxCol penwidth ::nPenWidth
   else   
      if ::lHorizontalLines
         @ ::nPrintCurRow + ::nPrintLineHeight, ::nPrintCurCol - ( ::nColSpacing / 2 ) print line to ::nPrintCurRow + ::nPrintLineHeight, ::nPrintMaxCol penwidth ::nPenWidth
      endif
   endif   
   if ::nPrintCurRow + ::nPrintLineHeight > ::nPrintMaxRow
      if .not. ::lHorizontalLines // even though no horizontal lines, print the last line to complete the outline box
         @ ::nPrintCurRow + ::nPrintLineHeight, ::nPrintCurCol - ( ::nColSpacing / 2 ) print line to ::nPrintCurRow + ::nPrintLineHeight, ::nPrintMaxCol penwidth ::nPenWidth
      endif         
      ::nPrintCurPage++
      ::StartNewPage()
   endif
return nil



Method StartNewPage() Class GridPlus
   local aPrintLine := {}
   local cFontName := ::aReportFont[ 1 ]
   local nFontSize := ::aReportFont[ 2 ]
   local cHeadFontName := ::aReportHeaderFont[ 1 ]
   local nHeadFontSize := ::aReportHeaderFont[ 2 ]
   ::nPrintCurRow := ::nTopMargin
   if ::lPageNumbering
      if ::nPageNumberPosition == 2 .or. ::nPageNumberPosition == 3 // bottom or both
         cPageNumber := ::cPageNumberPrefix + ' ' + alltrim( str( ::nPrintCurPage - 1, 10, 0 ) )
         do case
         case ::nPageNumberAlignment == 0 // left
            @ ::nPrintMaxRow + ::nPrintLineHeight, ::nPrintLeftMargin print cPageNumber font cFontName size nFontSize
         case ::nPageNumberAlignment == 2 // center
            @ ::nPrintMaxRow + ::nPrintLineHeight, ::nPrintPaperWidth / 2 print cPageNumber font cFontName size nFontSize center
         case ::nPageNumberAlignment == 1 // right
            @ ::nPrintMaxRow + ::nPrintLineHeight, ::nPrintMaxCol print cPageNumber font cFontName size nFontSize right
         endcase
      endif
   endif
   end printpage
   start printpage
   if ::lPageNumbering           
      if ::nPageNumberPosition == 1 .or. ::nPageNumberPosition == 3 // top or both
         cPageNumber := ::cPageNumberPrefix + ' ' + alltrim( str( ::nPrintCurPage, 10, 0 ) )
         do case
         case ::nPageNumberAlignment == 0 // left
            @ ::nPrintCurRow, ::nPrintLeftMargin print cPageNumber font cFontName size nFontSize
         case ::nPageNumberAlignment == 2 // center
            @ ::nPrintCurRow, ::nPrintPaperWidth / 2 print cPageNumber font cFontName size nFontSize center
         case ::nPageNumberAlignment == 1 // right
            @ ::nPrintCurRow, ::nPrintMaxCol print cPageNumber font cFontName size nFontSize right
         endcase
         ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
      endif
   endif
   // headers
   if hmg_len( alltrim( ::cReportHeader1 ) ) > 0
      ::PrintData( ::nPrintCurRow, ::nPrintPaperWidth / 2, ::cReportHeader1, ::aReportHeaderFont, 'CENTER' )
      ::nPrintCurRow := ::nPrintCurRow + int( nHeadFontSize / 72 * 25.4 )  + 3
   endif   
   if hmg_len( alltrim( ::cReportHeader2 ) ) > 0
      ::PrintData( ::nPrintCurRow, ::nPrintPaperWidth / 2, ::cReportHeader2, ::aReportHeaderFont, 'CENTER' )
      ::nPrintCurRow := ::nPrintCurRow + int( nHeadFontSize / 72 * 25.4 )  + 3
   endif   
   if hmg_len( alltrim( ::cReportHeader3 ) ) > 0
      ::PrintData( ::nPrintCurRow, ::nPrintPaperWidth / 2, ::cReportHeader3, ::aReportHeaderFont, 'CENTER' )
      ::nPrintCurRow := ::nPrintCurRow + int( nHeadFontSize / 72 * 25.4 )  + 3
   endif   
   ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
   // column headers
   if ::lMergeHeader
      ::PrintMergeHeaders()
      ::nPrintCurRow := ::nPrintCurRow + ::nPrintLineHeight
   endif   
   ::PrintLine( ::aPrintColumnHeaders, .t., .t. )
return nil   

METHOD StripComma( cString ) Class GridPlus
   LOCAL xValue := ""
   local i := 0
   local cChar := ""
   cString := alltrim( cString )

   for i := HMG_LEN( cString ) to 1 step -1
      cChar := HB_USUBSTR( cString, i, 1 )
      if HMG_ISDIGIT( cChar ) .or. cChar == ::cDecimalSymbol
         xValue := cChar + xValue
      endif
   next i
   if HB_UAT( "-", cString ) > 0 .or. HB_UAT( "DB", cString ) > 0 .or. ( HB_UAT( "(", cString ) > 0 .and. HB_UAT( ")", cString ) > 0 ) 
      xValue := "-" + xValue
   endif
return xValue

METHOD AddMergeHeader() CLASS GridPlus
   local aColSelected := {}
   local aMergeHeaders := {}
   local cHeader := alltrim( gp.mergeheader.value  )
   if hmg_len( cHeader ) == 0
      return nil
   endif
   for i := 1 to gp.mergeheaders.itemcount
      if gp.mergeheaders.checkboxitem( i )
         aLineData := gp.mergeheaders.item( i )
         nCol := val( alltrim( aLineData[ 1 ] ) )
         if nCol > 0
            aadd( aColSelected, nCol )
         endif   
      endif
   next i
   if hmg_len( aColSelected ) <= 1
      return nil
   else
      aColSelected := aSort( aColSelected )   
      nFromCol := aColSelected[ 1 ]
      nToCol := aColSelected[ hmg_len( aColSelected ) ]
      if hmg_len( ::aMergeHeaders ) == 0 .or. ::aMergeHeaders[ hmg_len( ::aMergeHeaders ), 2 ] < nFromCol 
         aadd( ::aMergeHeaders, { nFromCol, nToCol, cHeader } )
      else
         for i := 1 to hmg_len( ::aMergeHeaders )
            if ::aMergeHeaders[ i, 1 ] > nToCol
               asize( ::aMergeHeaders, hmg_len( ::aMergeHeaders ) + 1 )
               aIns( ::aMergeHeaders, i )
               ::aMergeHeaders[ i ] := { nFromCol, nToCol, cHeader }
               exit
            endif
         next i
      endif
      gp.mergeheader.value := ''
      ::MergeHeadersUpdate()
   endif   
return nil

Method MergeHeadersUpdate() CLASS GridPlus
   local i := 0
   gp.mergeheaders.deleteallitems
   gp.mergedheaders.deleteallitems
   for i := 1 to hmg_len( ::aMergeHeaders )
      gp.mergedheaders.additem( { alltrim( str( ::aMergeHeaders[ i, 1 ] ) ), alltrim( str( ::aMergeHeaders[ i, 2 ] ) ), alltrim( ::aMergeHeaders[ i, 3 ]  ) } )
   next i
   for i := 1 to hmg_len( ::aColumnHeaders )   
      lFound := .f.
      for j := 1 to hmg_len( ::aMergeHeaders )
         if i >= ::aMergeHeaders[ j, 1 ] .and. i <= ::aMergeHeaders[ j, 2 ]
            lFound := .t.
            exit
         endif
      next j
      if .not. lFound
         gp.mergeheaders.additem( { str( i ), ::aColumnHeaders[ i ] } )
      endif    
   next i
return nil

Method RemoveMergeHeader() Class GridPlus
   local nLineNo := gp.mergedheaders.value
   if nLineNo > 0
      gp.mergedheaders.deleteitem( nLineNo )
      adel( ::aMergeHeaders, nLineNo )
      asize( ::aMergeHeaders, hmg_len( ::aMergeHeaders ) - 1 )
      ::MergeHeadersUpdate()
   endif   
return nil


function _textfileprint(_filename)
copy file (_filename) to lpt1
return nil


METHOD GPOnQuery() CLASS GridPlus
   local nRow := This.QueryRowIndex
   local nCol := This.QueryColIndex
   this.QueryData := ::aData[ nRow, nCol ]
return nil   

METHOD SliderLeftMarginChanged() CLASS GridPlus
   ::nLeftMargin := gp.leftmargin.value
   gp.left.value := gp.leftmargin.value
   ::MarginChanged()
return nil


METHOD SliderRightMarginChanged() CLASS GridPlus
   ::nRightMargin := gp.rightmargin.rangemax - gp.rightmargin.value
   gp.right.value := ::nRightMargin
   ::MarginChanged()
return nil