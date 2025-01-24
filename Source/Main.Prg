#include <hmg.ch> 

#define adUseNone             1
#define adUseServer           2
#define adUseClient           3

#define adOpenForwardOnly     0
#define adOpenKeySet          1
#define adOpenDynamic         2
#define adOpenStatic          3

#define adLockReadOnly        1
#define adLockPessimistic     2
#define adLockOptimistic      3
#define adLockBatchOptimistic 4

#define adCmdText             1
#define adCmdTable            2
#define adCmdStoredProc       4
#define adCmdUnknown          8
#define adCmdFile           256
#define adCmdTableDirect    512

#define adSchemaTables       20
#define adSchemaColumns      4

#define adIndex 0x100000


Function Main
   set century on
   set date ital
   public oConnection := nil
   public nDesktopWidth := getdesktopwidth()
   public nDesktopHeight := getdesktopheight()
   public aDaybook := {}
   public aLedger := {}
   public aStock := {}
   public aForensics := {}
   public aTables := {}
   public aTablesData := {}
   public aTablesFields := {}
   public cFontName := "Arial"
   public nPages := 4
   public cCompany := ''
   public nDefaultPages := 4
   public aGridData := {}
   public cConnStatus := 'Connect Tally! (Disconnected)'
   public c_All_Vouchers := '$Date, $VoucherTypeName, $VoucherNumber, $LedgerName, $Amount, $DrCr, $DebitAmount, $CreditAmount, $ParentLedger, $PrimaryGroup, $PartyLedgerName, $PartyGSTIN, $LedgerGSTIN, $VoucherNarration, $BillRef, $BillType, $IsOptional, $CompanyName, $FromDate, $ToDate'
   
   define window main at 0,0 width nDesktopWidth height nDesktopHeight - 40 title "Tally Connector!" main icon "tally"
	  define toolbar tools buttonsize 35, 35 imagesize 30,30 strictwidth
	     button connect picture "disconnected" action connect() tooltip cConnStatus + " " + "Click here to connect Tally ODBC" separator
		 button importall picture "importall" action importall() tooltip "Click here to import/refresh all tables at once"
		 button importdaybook picture "daybook" action importdaybook() tooltip "Click here to import/refresh daybook"
		 button importledger picture "ledger" action importledger() tooltip "Click here to import/refresh ledger"
		 button importstock picture "stock" action importstock() tooltip "Click here to import/refresh stock master" 
		 button importforensics picture "forensic" action importforensics() tooltip "Click here to import/refresh forensics" separator
		 button exportxl picture "excel" action export2excel() tooltip 'Click to Export all tables to Excel. Excel Required.'
		 button exportxml picture "xml" action exportexcelxml() tooltip 'Click to Export all tables to Excel XML Format (Fast). Excel not required.' separator
         button removeempty picture 'coldel' tooltip 'Enable to remove empty columns while adding data to tab' check		 
         button nodollar picture 'nodollar' tooltip 'Enable to remove $ symbol in the Column Names while importing' check separator
		 
         button about picture "about" action showabout() tooltip 'Click here to know more about Tally Connector!'
         button exit picture "exit" action main.release() tooltip 'Click here to close Tally Connector'     
	  end toolbar 
      define label portlabel
         row 65
         col 10
         width 40
         value "Port"
      end label
      define textbox port
         row 60
         col 50
         width 50
         value "9000"
      end textbox
	  
      define label tableslabel
         row 65
         col 110
         width 60
         value "Tables"
      end label
      define combobox tables
         row 60
         col 170
         width 300
         sort .t.
      end combobox
      define button addtab
         row 60
         col 470
         width 100
         caption "Add Tab"
         picture "newitem" 
         height 35
         PICTALIGNMENT Left
         action addtotab()
         tooltip "Click here to add this table to tab"
      end button
	  
      define button tablecsv
         row 60
         col 580
         width 80
         height 35
         picture "csv" 
         PICTALIGNMENT Left
         caption "CSV"
         fontbold .t.
         tooltip 'Click to Export the selected table to CSV'
         action exporttable( .t. )
      end button
      define button tablehtml
         row 60
         col 670
         width 80
         height 35
         picture "html" 
         caption "HTML"
         fontbold .t.
         tooltip 'Click to Export the selected table to HTML Table'
         PICTALIGNMENT Left
         action exporttable( .f. )
      end button
      define progressbar pb
         row 60
         col 990
         width 150
         rangemin 0
         rangemax 1000
         smooth .t.
      end progressbar
      define label status
         row 10
         col 990
         width 300
         value ""
         fontbold .t.
      end label
         
      define tab datatab row 100  col 10 width nDesktopWidth - 40 height nDesktopHeight - 210 fontbold .t. 
         define page "Daybook" image "daybook"
            define button daycsv
               row 50
               col 10
               width 80
               height 35
               picture "csv" 
               PICTALIGNMENT Left
               caption "CSV"
               fontbold .t.
               tooltip 'Click to Export to CSV'
               action exportdaybookcsv()
            end button
            define button dayhtml
               row 50
               col 100
               width 80
               height 35
               picture "html" 
               caption "HTML"
               fontbold .t.
               tooltip 'Click to Export to HTML Table'
               PICTALIGNMENT Left
               action exportdaybookhtml()
            end button
            define grid daybook
               row 90
               col 10
               width nDesktopWidth - 60  
               height nDesktopHeight - 310
               headers { "$Key", "$MasterId", "$AlterID", "$VoucherNumber", "$Date", "$VoucherTypeName", "$Led_Lineno", "$Type", "$LedgerName", "$Amount", "$Led_Parent", "$Led_Group", "$Party_LedName", "$Vch_GSTIN", "$Led_GSTIN", "$Party_GST_Type", "$GST_Classification", "$Narration", "$EnteredBy", "$LastEventinVoucher", "$UpdatedDate", "$UpdatedTime", "$Nature_Led", "$Led_MID", "$CompanyName", "$Year_from", "$Year_to", "$Company_number", "$Path" }
               widths { 100, 100, 100, 100, 100, 100, 100, 100, 150, 120, 150, 150, 150, 100, 100, 100, 100, 150, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100 }
               justify { 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0 }
               virtual .t.
               onchange updatedaybook()
               onquerydata querydaybook()
            end grid
            define label daybookvalue
              row 50
              col nDesktopWidth - 160  
              width 100
              fontbold .t.
              value ""
            end label
         end page
         define page "Ledger Master"  image "ledger"
            define button ledgercsv
               row 50
               col 10
               width 80
               height 35
               picture "csv" 
               caption "CSV"
               fontbold .t.
               tooltip 'Click to Export to CSV'
               PICTALIGNMENT Left
               action exportledgercsv()
            end button
            define button ledgerhtml
               row 50
               col 100
               width 80
               height 35
               picture "html" 
               caption "HTML"
               fontbold .t.
               tooltip 'Click to Export to HTML Table'
               PICTALIGNMENT Left
               action exportledgerhtml()
            end button
            define grid ledger1
               row 90
               col 10
               width nDesktopWidth - 60  
               height nDesktopHeight - 310
               headers { "$Name", "$_PrimaryGroup", "$Parent", "$OpeningBalance", "$ClosingBalance", "$_PrevYearBalance", "$IsRevenue", "$PartyGSTIN", "$MasterId", "$AlterID", "$Nature_Led", "$UpdatedDate", "$UpdatedTime", "$CreatedBy", "$CreatedDate", "$AlteredDate", "$AlteredBy", "$LastVoucherDate", "$CompanyName", "$Year_from", "$Year_to", "$Company_number", "$Path" }
               widths { 100, 100, 100, 100, 100, 100, 100, 100, 150, 120, 150, 150, 150, 100, 100, 100, 100, 150, 100, 100, 100, 100, 100 }
               justify { 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0 }
               virtual .t.
               onchange updateledger()
               onquerydata queryledger()
            end grid
            define label ledgervalue
              row 50
              col nDesktopWidth - 160  
              width 100
              fontbold .t.
              value ""
            end label
         end page
         define page "Stock Master"  image "stock"
            define button stockcsv
               row 50
               col 10
               width 80
               height 35
               picture "csv" 
               caption "CSV"
               fontbold .t.
               tooltip 'Click to Export to CSV'
               PICTALIGNMENT Left
               action exportstockcsv()
            end button
            define button stockhtml
               row 50
               col 100
               width 80
               height 35
               picture "html" 
               caption "HTML"
               fontbold .t.
               tooltip 'Click to Export to HTML Table'
               PICTALIGNMENT Left
               action exportstockhtml()
            end button
            define grid stock  
               row 90
               col 10
               width nDesktopWidth - 60  
               height nDesktopHeight - 310 // 38
               headers { "$MasterId", "$AlterID", "$Name", "$PartnoParent", "$Category", "$OpeningBalance", "$ClosingBalance", "$ClosingRate", "$ClosingValue", "$LastPurcCost", "$LastPurcDate", "$LastPurcParty", "$LastPurcPrice", "$LastPurcQty", "$LastSaleDate", "$LastSaleParty", "$LastSaleQty", "$LastVoucherDate", "$EnteredBy", "$GSTTypeofSupply", "$CostingMethod", "$ValuationMethod", "$BaseUnits", "$AdditionalUnits", "$_HSNCode", "$_IntegratedTax", "$_CentralTax", "$_StateTax", "$_HSNDescription", "$_InwardQuantity", "$_InwardValue", "$_OutwardQuantity", "$_OutwardValue", "$CompanyName", "$Year_from", "$Year_to", "$Company_number", "$Path"  }
               widths { 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100 }
               justify { 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0 }
               virtual .t.
               onchange updatestock()
               onquerydata querystock()
            end grid
            define label stockvalue
              row 50
              col nDesktopWidth - 160  
              width 100
              fontbold .t.
              value ""
            end label
         end page
         define page "Forensics" image "forensic"
            define button forensiccsv
               row 50
               col 10
               width 80
               height 35
               picture "csv" 
               caption "CSV"
               fontbold .t.
               tooltip 'Click to Export to CSV'
               PICTALIGNMENT Left
               action exportforensicscsv()
            end button
            define button forensichtml
               row 50
               col 100
               width 80
               height 35
               picture "html" 
               caption "HTML"
               fontbold .t.
               tooltip 'Click to Export to HTML Table'
               PICTALIGNMENT Left
               action exportforensicshtml()
            end button
            define grid forensics
               row 90
               col 10
               width nDesktopWidth - 60  
               height nDesktopHeight - 310 // 13
               headers { "$Name", "$Createdby", "$CreatedDate", "$Masterid", "$Alterid", "$Alteredon", "$Alteredby", "$Updateddatetime", "$LastVoucherDate", "$Parent", "$_PrimaryGroup", "$$AscrAmt:$openingBalance", "$$AscrAmt:$_ClosingBalance" }
               widths { 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100 }
               justify { 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 1 }
               virtual .t.
               onchange updateforensics()
               onquerydata queryforensics()
            end grid
            define label forensicsvalue
              row 50
              col nDesktopWidth - 160  
              width 100
              fontbold .t.
              value ""
            end label
         end page
      end tab    
      DEFINE CONTROL CONTEXT MENU datatab
            MENUITEM 'Remove Table' ACTION removetable() IMAGE 'delitem' TOOLTIP 'Delete this table'
      END MENU
	   define statusbar fontbold .t.
         statusitem "Welcome to Tally Connector!" width 200 
         statusitem ""  width 400
         statusitem "Tally not connected! Run Tally and Click Connect Tally!" width 400
         statusitem "" width 100
      end statusbar  
      on key ESCAPE action main.release()      
   end window
   main.importall.enabled := .f.
   main.importdaybook.enabled := .f.
   main.importledger.enabled := .f.
   main.importstock.enabled := .f.
   main.importforensics.enabled := .f.
   main.removeempty.value := .t.
   main.nodollar.value := .t.
   main.pb.hide
   Main.Activate
Return



function connect
   local cPort := main.port.value
   local cConnection := "dsn=TallyODBC64_" + cPort 
   local cOut := ''
   local aTableList := {}
   local nRecords := 0
   if .not. msgyesno( "Are you sure you want to connect to Tally? Please ensure the following prerequisites are met before proceeding:" + chr(10) + chr(13) + "  1. Tally must be running in 64-bit mode." + chr(10) + chr(13) + "  2. ODBC must be enabled." + chr(10) + chr(13) + "  3. The Tally Connector TDL must already be loaded. " + chr(10) + chr(13) + "For additional information, please refer to the About page.", "Tally Connector!")
      return nil
   endif
   main.status.value := 'Checking ' + "TallyODBC64_" + cPort  + ' as ODBC Source'
   hb_processRun( 'powershell.exe -WindowStyle Hidden Get-OdbcDsn -Name "Tally*"',, @cOut )
   main.status.value := ''
   if hmg_len( cOut ) == 0
      msgstop( "Tally ODBC is not found! Check whether Tally is running!" )
      return nil
   endif
   if at( 'TallyODBC64_' + cPort, cOut ) == 0
      msgstop( 'TallyODBC64_' + cPort + ' is not a valid ODBC source. Verify whether the port number is right!' )
      if at( 'TallyODBC64_', cOut ) > 0
         msginfo( 'However Tally ODBC is available in this source ' + substr( cOut, at( 'TallyODBC64_', cOut ), 16 ) )
         return nil
      endif
   endif
   BEGIN SEQUENCE
      oConnection := TOleauto():New('ADODB.Connection')
      oConnection:ConnectionTimeout := 120
      oConnection:Open(cConnection)
   RECOVER
      MsgStop('No connection! Please check whether Tally is running, ODBC is enabled in Tally and also the port number is correct! You should have TallyODBC64_XXXX where XXXX refers to the port number in ODBC 64 Bit Data Sources',"ODBC Connection")
      return nil
   END SEQUENCE
   asize( aTables, 0 )
   main.statusbar.item(2) := ""
   main.statusbar.item(3) := "Tally Connected Successfully! Keep running Tally"
   cConnStatus := 'Connect Tally (Connected)'
   main.connect.tooltip := cConnStatus
   main.connect.picture := "Connected"
   main.redraw
   oRecSet := TOleAuto():New('ADODB.Recordset')
   oRecSet:CursorLocation = adUseClient
   oRecSet := oConnection:OpenSchema(adSchemaTables)
   nRecords := oRecSet:RecordCount()
   for i := 0 to nRecords - 1
      aadd( aTableList, any2str(oRecSet:Fields(2):value ) )
      oRecSet:MoveNext()
   next i   
   main.tables.deleteallitems()
   if hmg_len( aTableList ) > 0
      aTables := aclone( aSort( aTableList ) )
      for i := 1 to hmg_len( aTables )
         main.tables.additem( aTables[ i ] )
      next i
      main.tables.value := 1
   endif      
   oRecSet := TOleAuto():New('ADODB.Recordset')
   oRecSet:CursorLocation = adUseClient
   cQuery := "SELECT $Name, $_ThisYearBeg, $_ThisYearEnd from company"
   oRecSet:Open( cQuery , oConnection , adOpenForwardOnly , adLockReadOnly )  
   nRecords := oRecSet:RecordCount()
   if nRecords > 0
      cCompany := oRecSet:Fields(0):Value + " (" + any2str( oRecSet:Fields(1):Value ) + " to " + any2str( oRecSet:Fields(2):Value ) + ")"
   endif   
   main.title := "Tally Connector!" + " -> " + cCompany
   main.statusbar.item(2) := cCompany
   if ascan( aTableList, 'A__DayBook' ) == 0 
      msginfo( 'Tally Connector TDL is not loaded. Tables ( Daybook, Ledger Master, Stock Master and Forensics ) can not be loaded! For more details click About Button.', 'Tally Connector' )
   else   
      main.importall.enabled := .t.
      main.importdaybook.enabled := .t.
      main.importledger.enabled := .t.
      main.importstock.enabled := .t.
      main.importforensics.enabled := .t.
   endif   
   return nil
   
function importall
   if oConnection == nil
      msgstop( "Tally is not connected! Connect to tally first!", "Tally Connector" )
      return nil
   endif      
   if msgyesno( "Are you sure to import/refresh all tables?", "Tally Connector!")
      importdaybook()
      importledger()
      importstock()
      importforensics()   
      msginfo( "All tables are imported", "Tally Connector!")
   endif   
   return nil
   

function importdaybook()   
   local aLine := {}
   local nRecords := 0
   local nFields := 29
   if oConnection == nil
      msgstop( "Tally is not connected! Connect to tally first!", "Tally Connector" )
      return nil
   endif      
   oRecSet := TOleAuto():New('ADODB.Recordset')
   oRecSet:CursorLocation = adUseClient
   cQuery := "SELECT $Key, $MasterId, $AlterID, $VoucherNumber, $Date, $VoucherTypeName, $Led_Lineno, $Type, $LedgerName, $Amount, $Led_Parent, $Led_Group, $Party_LedName, $Vch_GSTIN, $Led_GSTIN, $Party_GST_Type, $GST_Classification, $Narration, $EnteredBy, $LastEventinVoucher, $UpdatedDate, $UpdatedTime, $Nature_Led, $Led_MID, $CompanyName, $Year_from, $Year_to, $Company_number, $Path FROM A__DayBook"
   main.status.value := "Please wait...downloading from daybook"
   oRecSet:Open( cQuery , oConnection , adOpenForwardOnly , adLockReadOnly )  
   nRecords := oRecSet:RecordCount()
   asize(aDaybook, 0)
   main.pb.show
   for i := 0 to nRecords - 1
      asize(aLine, 0)
      main.status.value := "Processing " + alltrim( str( i + 1 ) ) + " records of " + alltrim( str( nRecords ) )
      main.pb.value := int(((i+1) / nRecords) * 1000)
      for j := 0 to nFields - 1
         do case
            case j == 1 .or. j == 2  .or. j == 6 .or. j == 23 .or. j == 27
               aadd(aLine, any2str(int(oRecSet:Fields(j):value)))
            otherwise   
               aadd(aLine, any2str((oRecSet:Fields(j):value)))
         endcase   
      next j
      aadd(aDaybook, aclone(aLine))
      oRecSet:MoveNext()
   next i
   main.daybook.itemcount := nRecords
   if nRecords > 0
      main.daybook.value := 1
   endif
   main.pb.hide
   main.status.value := ""
   nColCount := main.daybook.columncount
   if main.nodollar.value
	   for i := 1 to nColCount
	      cFieldName := main.daybook.columnheader( i )
		   if hb_uleft( cFieldName, 1 ) == "$"
		      cFieldName := hb_uright( cFieldName, hmg_len( cFieldName ) - 1 )
			   main.daybook.columnheader( i ) := cFieldName
	      endif
      next i
   else
	   for i := 1 to nColCount
	      cFieldName := main.daybook.columnheader( i )
		   if hb_uleft( cFieldName, 1 ) <> "$"
		      cFieldName := "$" + cFieldName
			   main.daybook.columnheader( i ) := cFieldName
	      endif
      next i
   endif
   updatedaybook()
return nil

function querydaybook
   local nRow := this.queryrowindex
   local nCol := this.querycolindex
   this.querydata := aDaybook[ nRow, nCol ]
return nil

function updatedaybook
   local nLine := main.daybook.value
   if hmg_len( aDaybook ) > 0
      main.daybookvalue.value := alltrim(str( nLine ) ) + "/" + alltrim(str( hmg_len(aDaybook) ) )
   else
      main.daybookvalue.value := ""
   endif
return nil

function exportdaybookcsv
   local oGP := GridPlus():New()
   
   if hmg_len( aDaybook ) == 0
      msgstop( "Nothing to export!", "Tally Connector!")
      return nil
   endif
   oGP:AddArrayData( aDaybook )
   oGP:ColumnHeaders := { "$Key", "$MasterId", "$AlterID", "$VoucherNumber", "$Date", "$VoucherTypeName", "$Led_Lineno", "$Type", "$LedgerName", "$Amount", "$Led_Parent", "$Led_Group", "$Party_LedName", "$Vch_GSTIN", "$Led_GSTIN", "$Party_GST_Type", "$GST_Classification", "$Narration", "$EnteredBy", "$LastEventinVoucher", "$UpdatedDate", "$UpdatedTime", "$Nature_Led", "$Led_MID", "$CompanyName", "$Year_from", "$Year_to", "$Company_number", "$Path" }
   oGP:ColumnJustify := { 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0 }
   oGP:ColumnWidths := { 20, 10, 10, 20, 10, 20, 10, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20 }
   oGP:Export2CSV()
return nil

function exportdaybookhtml
   local oGP := GridPlus():New()
   
   if hmg_len( aDaybook ) == 0
      msgstop( "Nothing to export!", "Tally Connector!")
      return nil
   endif
   oGP:AddArrayData( aDaybook )
   oGP:ColumnHeaders := { "$Key", "$MasterId", "$AlterID", "$VoucherNumber", "$Date", "$VoucherTypeName", "$Led_Lineno", "$Type", "$LedgerName", "$Amount", "$Led_Parent", "$Led_Group", "$Party_LedName", "$Vch_GSTIN", "$Led_GSTIN", "$Party_GST_Type", "$GST_Classification", "$Narration", "$EnteredBy", "$LastEventinVoucher", "$UpdatedDate", "$UpdatedTime", "$Nature_Led", "$Led_MID", "$CompanyName", "$Year_from", "$Year_to", "$Company_number", "$Path" }
   oGP:ColumnJustify := { 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0 }
   oGP:ColumnWidths := { 20, 10, 10, 20, 10, 20, 10, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20 }
   oGP:Export2HTML()
return nil



function importledger
   local aLine := {}
   local nRecords := 0
   local nFields := 23
   if oConnection == nil
      msgstop( "Tally is not connected! Connect to tally first!", "Tally Connector" )
      return nil
   endif      
   oRecSet := TOleAuto():New('ADODB.Recordset')
   oRecSet:CursorLocation = adUseClient
   cQuery := "SELECT $Name, $_PrimaryGroup, $Parent, $OpeningBalance, $ClosingBalance, $_PrevYearBalance, $IsRevenue, $PartyGSTIN, $MasterId, $AlterID, $Nature_Led, $UpdatedDate, $UpdatedTime, $CreatedBy, $CreatedDate, $AlteredDate, $AlteredBy, $LastVoucherDate, $CompanyName, $Year_from, $Year_to, $Company_number, $Path FROM A__M_Ledger"
   main.status.value := "Please wait...downloading from ledger"
   oRecSet:Open( cQuery , oConnection , adOpenForwardOnly , adLockReadOnly )  
   nRecords := oRecSet:RecordCount()
   asize(aLedger, 0)
   main.pb.show
   for i := 0 to nRecords - 1
      asize(aLine, 0)
      main.status.value := "Processing " + alltrim( str( i + 1 ) ) + " records of " + alltrim( str( nRecords ) )
      main.pb.value := int(((i+1) / nRecords) * 1000)
      for j := 0 to nFields - 1
         do case
            case j == 6 .or. j == 8 .or. j == 9  .or. j == 21
               aadd(aLine, any2str(int(oRecSet:Fields(j):value)))
            otherwise   
               aadd(aLine, any2str((oRecSet:Fields(j):value)))
         endcase   
      next j
      aadd(aLedger, aclone(aLine))
      oRecSet:MoveNext()
   next i
   main.ledger1.itemcount := nRecords
   if nRecords > 0
      main.ledger1.value := 1
   endif
   main.pb.hide
   main.status.value := ""
   nColCount := main.ledger1.columncount
   if main.nodollar.value
	   for i := 1 to nColCount
	      cFieldName := main.ledger1.columnheader( i )
		   if hb_uleft( cFieldName, 1 ) == "$"
		      cFieldName := hb_uright( cFieldName, hmg_len( cFieldName ) - 1 )
			   main.ledger1.columnheader( i ) := cFieldName
	      endif
      next i
   else
	   for i := 1 to nColCount
	      cFieldName := main.ledger1.columnheader( i )
		   if hb_uleft( cFieldName, 1 ) <> "$"
		      cFieldName := "$" + cFieldName
			   main.ledger1.columnheader( i ) := cFieldName
	      endif
      next i
   endif
   updateledger()
return nil


function queryledger
   local nRow := this.queryrowindex
   local nCol := this.querycolindex
   this.querydata := aLedger[ nRow, nCol ]
return nil

function updateledger
   local nLine := main.ledger1.value
   if hmg_len( aLedger ) > 0
      main.ledgervalue.value := alltrim(str( nLine ) ) + "/" + alltrim(str( hmg_len(aLedger) ) )
   else
      main.ledgervalue.value := ""
   endif
return nil

function exportledgercsv
   local oGP := GridPlus():New()
   
   if hmg_len( aLedger ) == 0
      msgstop( "Nothing to export!", "Tally Connector!")
      return nil
   endif
   oGP:AddArrayData( aLedger )
   oGP:ColumnHeaders := { "$Name", "$_PrimaryGroup", "$Parent", "$OpeningBalance", "$ClosingBalance", "$_PrevYearBalance", "$IsRevenue", "$PartyGSTIN", "$MasterId", "$AlterID", "$Nature_Led", "$UpdatedDate", "$UpdatedTime", "$CreatedBy", "$CreatedDate", "$AlteredDate", "$AlteredBy", "$LastVoucherDate", "$CompanyName", "$Year_from", "$Year_to", "$Company_number", "$Path" }
   oGP:ColumnJustify := { 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0 }
   oGP:ColumnWidths := { 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30 }
   oGP:Export2CSV()
return nil

function exportledgerhtml
   local oGP := GridPlus():New()
   
   if hmg_len( aLedger ) == 0
      msgstop( "Nothing to export!", "Tally Connector!")
      return nil
   endif
   oGP:AddArrayData( aLedger )
   oGP:ColumnHeaders := { "$Name", "$_PrimaryGroup", "$Parent", "$OpeningBalance", "$ClosingBalance", "$_PrevYearBalance", "$IsRevenue", "$PartyGSTIN", "$MasterId", "$AlterID", "$Nature_Led", "$UpdatedDate", "$UpdatedTime", "$CreatedBy", "$CreatedDate", "$AlteredDate", "$AlteredBy", "$LastVoucherDate", "$CompanyName", "$Year_from", "$Year_to", "$Company_number", "$Path" }
   oGP:ColumnJustify := { 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0 }
   oGP:ColumnWidths := { 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30 }
   oGP:Export2HTML()
return nil







function importstock
   local aLine := {}
   local nRecords := 0
   local nFields := 38
   if oConnection == nil
      msgstop( "Tally is not connected! Connect to tally first!", "Tally Connector" )
      return nil
   endif      
   oRecSet := TOleAuto():New('ADODB.Recordset')
   oRecSet:CursorLocation = adUseClient
   cQuery := "SELECT $MasterId, $AlterID, $Name, $PartnoParent, $Category, $OpeningBalance, $ClosingBalance, $ClosingRate, $ClosingValue, $LastPurcCost, $LastPurcDate, $LastPurcParty, $LastPurcPrice, $LastPurcQty, $LastSaleDate, $LastSaleParty, $LastSaleQty, $LastVoucherDate, $EnteredBy, $GSTTypeofSupply, $CostingMethod, $ValuationMethod, $BaseUnits, $AdditionalUnits, $_HSNCode, $_IntegratedTax, $_CentralTax, $_StateTax, $_HSNDescription, $_InwardQuantity, $_InwardValue, $_OutwardQuantity, $_OutwardValue, $CompanyName, $Year_from, $Year_to, $Company_number, $Path FROM A__M_Stock"
   main.status.value := "Please wait...downloading from Stock"
   oRecSet:Open( cQuery , oConnection , adOpenForwardOnly , adLockReadOnly )  
   nRecords := oRecSet:RecordCount()
   asize(aStock, 0)
   main.pb.show
   for i := 0 to nRecords - 1
      asize(aLine, 0)
      main.status.value := "Processing " + alltrim( str( i + 1 ) ) + " records of " + alltrim( str( nRecords ) )
      main.pb.value := int(((i+1) / nRecords) * 1000)
      for j := 0 to nFields - 1
         do case
            case j == 0 .or. j == 1 .or. j == 36
               aadd(aLine, any2str(int(oRecSet:Fields(j):value)))
            otherwise   
               aadd(aLine, any2str((oRecSet:Fields(j):value)))
         endcase   
      next j
      aadd(aStock, aclone(aLine))
      oRecSet:MoveNext()
   next i
   main.stock.itemcount := nRecords
   if nRecords > 0
      main.stock.value := 1
   endif
   main.pb.hide
   main.status.value := ""
   nColCount := main.stock.columncount
   if main.nodollar.value
	   for i := 1 to nColCount
	      cFieldName := main.stock.columnheader( i )
		   if hb_uleft( cFieldName, 1 ) == "$"
		      cFieldName := hb_uright( cFieldName, hmg_len( cFieldName ) - 1 )
			   main.stock.columnheader( i ) := cFieldName
	      endif
      next i
   else
	   for i := 1 to nColCount
	      cFieldName := main.stock.columnheader( i )
		   if hb_uleft( cFieldName, 1 ) <> "$"
		      cFieldName := "$" + cFieldName
			   main.stock.columnheader( i ) := cFieldName
	      endif
      next i
   endif
   updatestock()
return nil

function querystock
   local nRow := this.queryrowindex
   local nCol := this.querycolindex
   this.querydata := aStock[ nRow, nCol ]
return nil

function updatestock
   local nLine := main.stock.value
   if hmg_len( aStock ) > 0
      main.stockvalue.value := alltrim(str( nLine ) ) + "/" + alltrim(str( hmg_len(aStock) ) )
   else
      main.stockvalue.value := ""
   endif
return nil

function exportstockcsv
   local oGP := GridPlus():New()
   
   if hmg_len( aStock ) == 0
      msgstop( "Nothing to export!", "Tally Connector!")
      return nil
   endif
   oGP:AddArrayData( aStock )
   oGP:ColumnHeaders := { "$MasterId", "$AlterID", "$Name", "$PartnoParent", "$Category", "$OpeningBalance", "$ClosingBalance", "$ClosingRate", "$ClosingValue", "$LastPurcCost", "$LastPurcDate", "$LastPurcParty", "$LastPurcPrice", "$LastPurcQty", "$LastSaleDate", "$LastSaleParty", "$LastSaleQty", "$LastVoucherDate", "$EnteredBy", "$GSTTypeofSupply", "$CostingMethod", "$ValuationMethod", "$BaseUnits", "$AdditionalUnits", "$_HSNCode", "$_IntegratedTax", "$_CentralTax", "$_StateTax", "$_HSNDescription", "$_InwardQuantity", "$_InwardValue", "$_OutwardQuantity", "$_OutwardValue", "$CompanyName", "$Year_from", "$Year_to", "$Company_number", "$Path"  }
   oGP:ColumnJustify := { 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0 }
   oGP:ColumnWidths := { 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30 }
   oGP:Export2CSV()
return nil

function exportstockhtml
   local oGP := GridPlus():New()
   
   if hmg_len( aStock ) == 0
      msgstop( "Nothing to export!", "Tally Connector!")
      return nil
   endif
   oGP:AddArrayData( aStock )
   oGP:ColumnHeaders := { "$MasterId", "$AlterID", "$Name", "$PartnoParent", "$Category", "$OpeningBalance", "$ClosingBalance", "$ClosingRate", "$ClosingValue", "$LastPurcCost", "$LastPurcDate", "$LastPurcParty", "$LastPurcPrice", "$LastPurcQty", "$LastSaleDate", "$LastSaleParty", "$LastSaleQty", "$LastVoucherDate", "$EnteredBy", "$GSTTypeofSupply", "$CostingMethod", "$ValuationMethod", "$BaseUnits", "$AdditionalUnits", "$_HSNCode", "$_IntegratedTax", "$_CentralTax", "$_StateTax", "$_HSNDescription", "$_InwardQuantity", "$_InwardValue", "$_OutwardQuantity", "$_OutwardValue", "$CompanyName", "$Year_from", "$Year_to", "$Company_number", "$Path"  }
   oGP:ColumnJustify := { 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0 }
   oGP:ColumnWidths := { 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30 }
   oGP:Export2HTML()
return nil



function importforensics
   local aLine := {}
   local nRecords := 0
   local nFields := 13
   if oConnection == nil
      msgstop( "Tally is not connected! Connect to tally first!", "Tally Connector" )
      return nil
   endif      
   oRecSet := TOleAuto():New('ADODB.Recordset')
   oRecSet:CursorLocation = adUseClient
   cQuery := "Select $Name, $Createdby, $CreatedDate, $Masterid, $Alterid, $Alteredon, $Alteredby, $Updateddatetime, $LastVoucherDate, $Parent, $_PrimaryGroup, $$AscrAmt:$openingBalance, $$AscrAmt:$_ClosingBalance from ledger order by $Alterid desc"
   main.status.value := "Please wait...downloading from Forensics"
   oRecSet:Open( cQuery , oConnection , adOpenForwardOnly , adLockReadOnly )  
   nRecords := oRecSet:RecordCount()
   asize(aForensics, 0)
   main.pb.show
   for i := 0 to nRecords - 1
      asize(aLine, 0)
      main.status.value := "Processing " + alltrim( str( i + 1 ) ) + " records of " + alltrim( str( nRecords ) )
      main.pb.value := int(((i+1) / nRecords) * 1000)
      for j := 0 to nFields - 1
         do case
            case j == 3 .or. j == 4
               aadd(aLine, any2str(int(oRecSet:Fields(j):value)))
            otherwise   
               aadd(aLine, any2str((oRecSet:Fields(j):value)))
         endcase   
      next j
      aadd(aForensics, aclone(aLine))
      oRecSet:MoveNext()
   next i
   main.Forensics.itemcount := nRecords
   if nRecords > 0
      main.forensics.value := 1
   endif
   main.pb.hide
   main.status.value := ""
   nColCount := main.forensics.columncount
   if main.nodollar.value
	   for i := 1 to nColCount
	      cFieldName := main.forensics.columnheader( i )
		   if hb_uleft( cFieldName, 1 ) == "$"
		      cFieldName := hb_uright( cFieldName, hmg_len( cFieldName ) - 1 )
			   main.forensics.columnheader( i ) := cFieldName
	      endif
      next i
   else
	   for i := 1 to nColCount
	      cFieldName := main.forensics.columnheader( i )
		   if hb_uleft( cFieldName, 1 ) <> "$"
		      cFieldName := "$" + cFieldName
			   main.forensics.columnheader( i ) := cFieldName
	      endif
      next i
   endif
   updateforensics()
return nil

function queryforensics
   local nRow := this.queryrowindex
   local nCol := this.querycolindex
   this.querydata := aForensics[ nRow, nCol ]
return nil

function updateforensics
   local nLine := main.forensics.value
   if hmg_len( aForensics ) > 0
      main.forensicsvalue.value := alltrim(str( nLine ) ) + "/" + alltrim(str( hmg_len(aForensics) ) )
   else
      main.forensicsvalue.value := ""
   endif
return nil

function exportforensicscsv
   local oGP := GridPlus():New()
   if hmg_len( aForensics ) == 0
      msgstop( "Nothing to export!", "Tally Connector!")
      return nil
   endif
   oGP:AddArrayData( aForensics )
   oGP:ColumnHeaders := { "$Name", "$Createdby", "$CreatedDate", "$Masterid", "$Alterid", "$Alteredon", "$Alteredby", "$Updateddatetime", "$LastVoucherDate", "$Parent", "$_PrimaryGroup", "$$AscrAmt:$openingBalance", "$$AscrAmt:$_ClosingBalance" }
   oGP:ColumnWidths := { 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30 }
   oGP:ColumnJustify := { 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 1 }
   oGP:Export2CSV()
return nil

function exportforensicshtml
   local oGP := GridPlus():New()
   if hmg_len( aForensics ) == 0
      msgstop( "Nothing to export!", "Tally Connector!")
      return nil
   endif
   oGP:AddArrayData( aForensics )
   oGP:ColumnHeaders := { "$Name", "$Createdby", "$CreatedDate", "$Masterid", "$Alterid", "$Alteredon", "$Alteredby", "$Updateddatetime", "$LastVoucherDate", "$Parent", "$_PrimaryGroup", "$$AscrAmt:$openingBalance", "$$AscrAmt:$_ClosingBalance" }
   oGP:ColumnWidths := { 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30 }
   oGP:ColumnJustify := { 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 1 }
   oGP:Export2HTML()
return nil


function export2excel
   local i := 0, j := 0, k := 0
   local cFileName := ''
   Local oExcel,  oSheet, oBook   
   local nRow := 0
   local cSheetName := ''
   local aSheets := {}
   local aCurData := {}
   local aCurFields := {}
   local aFields := {}
   local aSize := {}
   local aJustify := {}
   if hmg_len( aDaybook ) == 0 .and. hmg_len( aLedger ) == 0 .and. hmg_len( aStock ) == 0 .and. hmg_len( aForensics ) == 0 .and. nPages <= 4
      msgstop( "Noting to Export! Import any or all tables first!", "Tally Connector!")
      return nil
   endif
   cFileName :=  PutFile( { { 'Excel Files (*.xlsx)', '*.xlsx' }, { 'All Files (*.*)', '*.*' } }, 'Save as Excel File...' )
   if hmg_len( cFileName ) > 0
      if .not. hmg_upper( hb_usubstr( cFileName, hmg_len( cFileName ) - 4, 5 ) ) == '.XLSX'
         cFileName := cFileName + '.xlsx'   
      endif
      if file( cFileName )
         if msgyesno( 'File Exists! Do you want to overwrite?' )
            ferase( cFileName )
            if file( cFileName )
               msgstop( 'Could not overwrite! File already opened? Close the file and retry or save in another file.' )
               return nil
            endif               
         else
            return nil         
         endif   
      endif   
   else
      return nil   
   endif
   main.status.value := "Opening Excel..."
   oExcel := win_oleCreateObject( "Excel.Application" )
   if oExcel == NIL
      MsgStop({"Error: "+win_oleErrorText()})
      main.status.value := ""
      RETURN NIL
   endif
   oExcel:Visible := .F.
   oExcel:WorkBooks:Add()
   if hmg_len( aDayBook ) > 0 
      main.status.value := "Started Exporting Daybook"
      oExcel:sheets:add()
      oSheet := oExcel:ActiveSheet()
      cSheetName := 'DayBook'
      oSheet:Name := cSheetName
      nRow := 1 
      nItemCount := hmg_len( aDayBook )
      aColumnHeaders := { "$Key", "$MasterId", "$AlterID", "$VoucherNumber", "$Date", "$VoucherTypeName", "$Led_Lineno", "$Type", "$LedgerName", "$Amount", "$Led_Parent", "$Led_Group", "$Party_LedName", "$Vch_GSTIN", "$Led_GSTIN", "$Party_GST_Type", "$GST_Classification", "$Narration", "$EnteredBy", "$LastEventinVoucher", "$UpdatedDate", "$UpdatedTime", "$Nature_Led", "$Led_MID", "$CompanyName", "$Year_from", "$Year_to", "$Company_number", "$Path" }
      aColumnwidths := { 100, 100, 100, 100, 100, 100, 100, 100, 150, 120, 150, 150, 150, 100, 100, 100, 100, 150, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100 }
      aColumnjustify := { 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0 }
      cHTML := html_table( "", aDayBook, aColumnHeaders, aColumnWidths, aColumnjustify )
      system.clipboard := cHTML
      oSheet:Paste()
      nRows := oSheet:UsedRange:Rows:Count()
      nCols := oSheet:UsedRange:Columns:Count()
      oSheet:UsedRange:wraptext := .f.
      for j := 1 to nCols
         oSheet:Columns( j ):AutoFit()
      next j   
   endif   
   if hmg_len( aLedger ) > 0 
      main.status.value := "Started Exporting Ledger Master"
      oExcel:sheets:add()
      oSheet := oExcel:ActiveSheet()
      cSheetName := 'Ledger Master'
      oSheet:Name := cSheetName
      nRow := 1 
      nItemCount := hmg_len( aLedger )
      aColumnHeaders := { "$Name", "$_PrimaryGroup", "$Parent", "$OpeningBalance", "$ClosingBalance", "$_PrevYearBalance", "$IsRevenue", "$PartyGSTIN", "$MasterId", "$AlterID", "$Nature_Led", "$UpdatedDate", "$UpdatedTime", "$CreatedBy", "$CreatedDate", "$AlteredDate", "$AlteredBy", "$LastVoucherDate", "$CompanyName", "$Year_from", "$Year_to", "$Company_number", "$Path" }
      aColumnJustify := { 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0 }
      aColumnWidths := { 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30 }
      cHTML := html_table( "", aLedger, aColumnHeaders, aColumnWidths, aColumnjustify )
      system.clipboard := cHTML
      oSheet:Paste()
      nRows := oSheet:UsedRange:Rows:Count()
      nCols := oSheet:UsedRange:Columns:Count()
      oSheet:UsedRange:wraptext := .f.
      for j := 1 to nCols
         oSheet:Columns( j ):AutoFit()
      next j   
   endif   
   if hmg_len( aStock ) > 0 
      main.status.value := "Started Exporting Stock"
      oExcel:sheets:add()
      oSheet := oExcel:ActiveSheet()
      cSheetName := 'Stock Master'
      oSheet:Name := cSheetName
      nRow := 1 
      nItemCount := hmg_len( aStock )
      aColumnHeaders := { "$MasterId", "$AlterID", "$Name", "$PartnoParent", "$Category", "$OpeningBalance", "$ClosingBalance", "$ClosingRate", "$ClosingValue", "$LastPurcCost", "$LastPurcDate", "$LastPurcParty", "$LastPurcPrice", "$LastPurcQty", "$LastSaleDate", "$LastSaleParty", "$LastSaleQty", "$LastVoucherDate", "$EnteredBy", "$GSTTypeofSupply", "$CostingMethod", "$ValuationMethod", "$BaseUnits", "$AdditionalUnits", "$_HSNCode", "$_IntegratedTax", "$_CentralTax", "$_StateTax", "$_HSNDescription", "$_InwardQuantity", "$_InwardValue", "$_OutwardQuantity", "$_OutwardValue", "$CompanyName", "$Year_from", "$Year_to", "$Company_number", "$Path"  }
      aColumnJustify := { 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0 }
      aColumnWidths := { 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30 }
      cHTML := html_table( "", aStock, aColumnHeaders, aColumnWidths, aColumnjustify )
      system.clipboard := cHTML
      oSheet:Paste()
      nRows := oSheet:UsedRange:Rows:Count()
      nCols := oSheet:UsedRange:Columns:Count()
      oSheet:UsedRange:wraptext := .f.
      for j := 1 to nCols
         oSheet:Columns( j ):AutoFit()
      next j   
   endif   
   if hmg_len( aForensics ) > 0 
      main.status.value := "Started Exporting Forensics"
      oExcel:sheets:add()
      oSheet := oExcel:ActiveSheet()
      cSheetName := 'Forensics'
      oSheet:Name := cSheetName
      nRow := 1 
      nItemCount := hmg_len( aForensics )
      aColumnHeaders := { "$Name", "$Createdby", "$CreatedDate", "$Masterid", "$Alterid", "$Alteredon", "$Alteredby", "$Updateddatetime", "$LastVoucherDate", "$Parent", "$_PrimaryGroup", "$$AscrAmt:$openingBalance", "$$AscrAmt:$_ClosingBalance" }
      aColumnWidths := { 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30 }
      aColumnJustify := { 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 1 }
      cHTML := html_table( "", aForensics, aColumnHeaders, aColumnWidths, aColumnjustify )
      system.clipboard := cHTML
      oSheet:Paste()
      nRows := oSheet:UsedRange:Rows:Count()
      nCols := oSheet:UsedRange:Columns:Count()
      oSheet:UsedRange:wraptext := .f.
      for j := 1 to nCols
         oSheet:Columns( j ):AutoFit()
      next j   
   endif   
   // other tables
   if nPages > 4
      for i := 5 to nPages
         cTable := main.datatab.caption( i )
         aCurTable := {}
         aFields := {}
         aJustify := {}
         nRows := getproperty( 'main', cTable, 'itemcount' )
         for j := 1 to nRows
            aadd( aCurTable, getproperty( 'main', cTable, 'item', j ) )
         next j
         for j := 1 to hmg_len( aCurTable[ 1 ] )
            aadd( aFields, getproperty( 'main', cTable, 'ColumnHEADER', j ) )
            aadd( aJustify, getproperty( 'main', cTable, 'ColumnJUSTIFY', j ) )
         next j   
         if hmg_len( aCurTable ) > 0
            main.status.value := "Started Exporting " + cTable
            oExcel:sheets:add()
            oSheet := oExcel:ActiveSheet()
            cSheetName := cTable
            oSheet:Name := cSheetName
            nRow := 1 
            asize( aSize, 0 )
            for j := 1 to hmg_len( aFields )
               aadd( aSize, 30 )
            next j   
            nItemCount := hmg_len( aCurTable )
            aColumnHeaders := aFields
            aColumnWidths := aSize
            aColumnJustify := aJustify
            cHTML := html_table( "", aCurTable, aColumnHeaders, aColumnWidths, aColumnjustify )
            system.clipboard := cHTML
            oSheet:Paste()
            nRows := oSheet:UsedRange:Rows:Count()
            nCols := oSheet:UsedRange:Columns:Count()
            oSheet:UsedRange:wraptext := .f.
            for j := 1 to nCols
               oSheet:Columns( j ):AutoFit()
            next j   
         endif            
      next i
   endif      
   main.status.value := "Saving Excel Workbook"
   oBook := oExcel:ActiveWorkBook()   
   oBook:SaveAs( cFileName )
   oExcel:DisplayAlerts = .t.
   oExcel:Quit()
   main.status.value := ""
   ShellExecute( "Open", 0, cFileName )
return nil   


FUNCTION Any2Str( xAny )

   LOCA cRVal  := '???',;
        nType  :=  0,;
        aCases := { { "A", { | x | "{...}" } },;                
                    { "B", { | x | "{||}" } },;                
                    { "C", { | x | x }},;
                    { "M", { | x | x   } },;                   
                    { "D", { | x | DTOC( x ) } },;             
                    { "L", { | x | IF( x,"Y","N") } },;    
                    { "N", { | x | alltrim(str( x ))  } },;
                    { "O", { | x | ":Object:" } },;
                    { "U", { | x | "" } } }
                    
   IF (nType := ASCAN( aCases, { | a1 | VALTYPE( xAny ) == a1[ 1 ] } ) ) > 0
      cRVal := EVAL( aCases[ nType, 2 ], xAny )
   ENDIF    
                   

RETURN cRVal


function html_table( cHeader, aTable, aColumnHeaders, aColumnWidths, aColumnJustify, aDataJustify, lColHeaders )
   local nTotalWidth := 0
   local cHTML := ''
   local nRows := 0
   local aLineData := {}
   local nColumnCount := 0
   local i := 0, j := 0
   local lDataJustify := .f.
   local cAlign := 'LEFT'
   local cStatus := main.status.value
   
   default cHeader := ''
   default aColumnHeaders := {}
   default aColumnWidths := {}
   default aColumnJustify := {}
   default aDataJustify := {}
   default lColHeaders := .t.
   if valtype( aTable ) == 'A'
      if hmg_len( aTable ) == 0
         return nil
      endif
   else   
      return nil
   endif
   if hmg_len( aDataJustify ) > 0
      lDataJustify := .t.
   endif
   nRows := hmg_len( aTable )
   nColumnCount := hmg_len( aColumnHeaders )
   for i := 1 to nColumnCount
      nTotalWidth := nTotalWidth + aColumnWidths[ i ] 
   next i
   
   // report headers table   
   && cHTML := cHTML + '<TABLE Width="' + alltrim( str( nTotalWidth ) ) + '">' + CRLF
   && if hmg_len( cHeader ) > 0
      && cHTML := cHTML + '<TR><TD align="CENTER" class="TD1"><font size=3><u>' + cHeader + '</u></font></TD></TR>' + CRLF
   && endif
   && cHTML := cHTML + '</TABLE>' + CRLF
   
   
   // Main Table
   
   cHTML := cHTML + '<TABLE Width="' + alltrim( str( nTotalWidth ) ) + '">' + CRLF
   
   // Column Headers
   if lColHeaders
      cHTML := cHTML + '<TR>' + CRLF
      for i := 1 to nColumnCount
         if aColumnWidths[ i ] > 0
            cAlign := if( aColumnJustify[ i ] == 1, 'RIGHT', if( aColumnJustify[ i ] == 2, 'CENTER', 'LEFT' ) )
            cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aColumnWidths[ i ] ) ) + ' ALIGN="' + cAlign + '" border-width=0><B>' + aColumnHeaders[ i ] + '</B></TD>' + CRLF
         endif
      next i
      cHTML := cHTML + '</TR>' + CRLF
   endif   
   
   // Now it is time for data
   
   for i := 1 to nRows
      main.status.value := cStatus + " " + alltrim( str( i ) ) + "/" + alltrim( str( nRows ) )
      aLineData := aTable[ i ]
      cHTML := cHTML + '<TR>' + CRLF
      for j := 1 to nColumnCount
         if aColumnWidths[ j ] > 0
            cAlign := if( aColumnJustify[ j ] == 1, 'RIGHT', if( aColumnJustify[ j ] == 2, 'CENTER', 'LEFT' ) )
            if lDataJustify
               cAlign := if( aDataJustify[ i, j ] == 1, 'RIGHT', if( aDataJustify[ i, j ] == 2, 'CENTER', 'LEFT' ) )
            endif    
            if valtype( aLineData[ j ] ) == 'U'
               aLineData[ j ] := ''
            endif
            cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aColumnWidths[ j ] ) ) + ' ALIGN="' + cAlign + '">' + aLineData[ j ] + '</TD>' + CRLF
         endif
      next j
      cHTML := cHTML + '</TR>' + CRLF
   next i
   cHTML := cHTML + '</TABLE>' + CRLF
   && fWrite( oFile, cHTML )   
   && html_para( oFile ) 
return cHTML


function addtotab
   local nValue := main.tables.value
   local cTable := ''
   local aLine := {}
   local nRecords := 0
   local nFields := 13
   local oRecSet
   local aData := {}
   local aFields := {}
   local aSize := {}
   local aJustify := {}
   local nCurCol := 0
   local aEmptyCols := {}
   local lIsEmpty := .f.
   local aNewFields := {}
   local aNewJustify := {}
   local aNewData := {}
   local aCurData := {}
   local aCurFields := {}
   local cColumns := ''
   
   if nValue > 0
      cTable := main.tables.item( nValue )
      if oConnection == nil
         msgstop( "Tally is not connected! Connect to tally first!", "Tally Connector" )
         return nil
      endif
	  if cTable == '_All_Vouchers' // all vouchers
	     cColumns := c_All_Vouchers
      else
	     cColumns := '*'
	  endif
      oRecSet := TOleAuto():New('ADODB.Recordset')
      oRecSet:CursorLocation = adUseClient
      cQuery := "Select " + cColumns + " from " + cTable
      main.status.value := "Please wait...downloading from " + cTable
      oRecSet:Open( cQuery , oConnection , adOpenForwardOnly , adLockReadOnly )  
      nRecords := oRecSet:RecordCount()
      if nRecords == 0
         main.status.value := ""
         msgstop( 'This table is empty!' )
         return nil
      endif
      for i := 1 to nPages
         if main.datatab.caption( i ) == cTable
            msgstop( 'This table is already added in the tab.' )
            return nil
         endif
      next i
      nPages := nPages + 1
      main.datatab.addpage( nPages, cTable, 'newtable' )
      main.pb.show
      nFields := oRecSet:Fields:Count
      aFields := {}
      aJustify := {}
      for i := 0 to nFields - 1
	     cFieldName := oRecSet:Fields( i ):name
		 if main.nodollar.value
		    if hb_usubstr( cFieldName, 1, 1 ) == '$'
			   cFieldName := hb_uright( cFieldName, hmg_len( cFieldName ) - 1 )
			endif
         endif
         aadd( aFields, cFieldName )
         nType := oRecSet:Fields( i ):Type
         if nType == 133 .or. nType == 5 // date or number
            aadd( aJustify, 1 )
         else
            aadd( aJustify, 0 )
         endif    
      next i         
      for i := 0 to nRecords - 1
         asize(aLine, 0)
         main.status.value := "Processing " + alltrim( str( i + 1 ) ) + " records of " + alltrim( str( nRecords ) )
         main.pb.value := int(((i+1) / nRecords) * 1000)
         for j := 0 to nFields - 1
            BEGIN SEQUENCE WITH {| oErr | Break( oErr ) }
               aadd(aLine, any2str((oRecSet:Fields(j):value)))
            recover
               aadd(aLine, 'Error!')
            end SEQUENCE
         next j
         aadd(aData, aclone(aLine))
         oRecSet:MoveNext()
      next i
      
      if main.removeempty.value
         asize( aNewFields, 0 )
         asize( aNewData, 0 )
         asize( aEmptyCols, 0 )
         asize( aNewJustify, 0 )
         aCurData := aclone( aData )
         aCurFields := aclone( aFields )
         nRows := hmg_len( aCurData )
         if nRows > 0
            nCols := hmg_len( aCurData[ 1 ] )
            for j := 1 to nCols
               lIsEmpty := .t.
               for k := 1 to nRows
                  if hmg_len( aCurData[ k, j ] ) > 0
                     lIsEmpty := .f.
                     exit
                  endif
               next k
               if lIsEmpty
                  aadd( aEmptyCols, j )
               endif
            next j
            if hmg_len( aEmptyCols ) > 0 // empty columns
               for j := 1 to nRows
                  asize( aLine, 0 )
                  for k := 1 to nCols
                     if ascan( aEmptyCols, k ) == 0 // not empty!
                        aadd( aLine, aCurData[ j, k ] )
                     endif
                  next k
                  aadd( aNewData, aclone( aLine ) )
               next j
               asize( aNewFields, 0 )
               for k := 1 to nCols
                  if ascan( aEmptyCols, k ) == 0 // not empty!
                     aadd( aNewFields, aCurFields[ k ] )
                     aadd( aNewJustify, aJustify[ k ] )
                  endif
               next k
               aData := aclone( aNewData )
               aFields := aclone( aNewFields )
               aJustify := aclone( aNewJustify )
            endif
         endif
      endif
      asize( aSize, 0 )
      for i := 1 to hmg_len( aFields )
         aadd( aSize, 100 )
      next i         
      define grid &cTable
         parent main
         row 90
         col 10
         width nDesktopWidth - 60  
         height nDesktopHeight - 310
         headers aFields
         widths aSize
         justify aJustify
         items aclone( aData )
      end grid
      main.datatab.addcontrol( cTable, nPages, 90, 10 )
      if hmg_len( aData ) > 0
         setproperty( "main", cTable, "Value", 1 )
      endif   
      main.pb.hide
      main.status.value := ""
   endif
return nil


function exporttable( lCSV )
   local nValue := main.tables.value
   local oGP := GridPlus():New()
   local cTable := ""
   local aFields := {}
   local aArray := {}
   local aSize := {}
   local aJustify := {}
   local aLine := {}
   local aData := {}
   local nCurCol := 0
   local aEmptyCols := {}
   local lIsEmpty := .f.
   local aNewFields := {}
   local aNewData := {}
   local aCurData := {}
   local aCurFields := {}
   
   default lCSV := .t.
   if nValue > 0
      cTable := main.tables.item( nValue )
      if oConnection == nil
         msgstop( "Tally is not connected! Connect to tally first!", "Tally Connector" )
         return nil
      endif      
      oRecSet := TOleAuto():New('ADODB.Recordset')
      oRecSet:CursorLocation = adUseClient
      cQuery := "Select * from " + cTable
      main.status.value := "Please wait...downloading from " + cTable
      oRecSet:Open( cQuery , oConnection , adOpenForwardOnly , adLockReadOnly )  
      nRecords := oRecSet:RecordCount()
      if nRecords == 0
         msgstop( 'This table is empty!' )
         return nil
      endif
      main.pb.show
      nFields := oRecSet:Fields:Count
      aFields := {}
      for i := 0 to nFields - 1
         aadd( aFields, oRecSet:Fields( i ):name )
      next i         
      for i := 0 to nRecords - 1
         asize(aLine, 0)
         main.status.value := "Processing " + alltrim( str( i + 1 ) ) + " records of " + alltrim( str( nRecords ) )
         main.pb.value := int(((i+1) / nRecords) * 1000)
         for j := 0 to nFields - 1
            BEGIN SEQUENCE WITH {| oErr | Break( oErr ) }
               aadd(aLine, any2str((oRecSet:Fields(j):value)))
            recover
               aadd(aLine, 'Error!')
            end SEQUENCE
         next j
         aadd(aData, aclone(aLine))
         oRecSet:MoveNext()
      next i
      if main.removeempty.value
         asize( aNewFields, 0 )
         asize( aNewData, 0 )
         asize( aEmptyCols, 0 )
         aCurData := aclone( aData )
         aCurFields := aclone( aFields )
         nRows := hmg_len( aCurData )
         if nRows > 0
            nCols := hmg_len( aCurData[ 1 ] )
            for j := 1 to nCols
               lIsEmpty := .t.
               for k := 1 to nRows
                  if hmg_len( aCurData[ k, j ] ) > 0
                     lIsEmpty := .f.
                     exit
                  endif
               next k
               if lIsEmpty
                  aadd( aEmptyCols, j )
               endif
            next j
            if hmg_len( aEmptyCols ) > 0 // empty columns
               for j := 1 to nRows
                  asize( aLine, 0 )
                  for k := 1 to nCols
                     if ascan( aEmptyCols, k ) == 0 // not empty!
                        aadd( aLine, aCurData[ j, k ] )
                     endif
                  next k
                  aadd( aNewData, aclone( aLine ) )
               next j
               asize( aNewFields, 0 )
               for k := 1 to nCols
                  if ascan( aEmptyCols, k ) == 0 // not empty!
                     aadd( aNewFields, aCurFields[ k ] )
                  endif
               next k
               aData := aclone( aNewData )
               aFields := aclone( aNewFields )
            endif
         endif
      endif
      main.pb.hide
      main.status.value := ""
      asize( aSize, 0 )
      asize( aJustify, 0 )
      for i := 1 to hmg_len( aFields )
         aadd( aSize, 100 )
         aadd( aJustify, 0 )
      next i         
      oGP:AddArrayData( aData )
      oGP:ColumnHeaders := aFields
      oGP:ColumnJustify := aJustify
      oGP:ColumnWidths := aSize
      if lCSV 
         oGP:Export2CSV()      
      else
         oGP:Export2HTML()      
      endif   
   endif   
return nil


function removetable
   local nTabValue:= main.datatab.value
   local nIndex := 0
   nIndex := nTabValue - nDefaultPages
   if nIndex <= 0
      msgstop( 'Default Tables can not be deleted!' )
      return nil
   endif
   if .not. msgyesno( 'Are you sure to delete this table?', 'Tally Connector' )
      return nil
   endif
   cTable := main.datatab.caption( nTabValue )
   if iscontroldefined( &cTable, "MAIN" ) // remove control
      domethod( "MAIN", cTable, "RELEASE" )
   endif   
   main.datatab.deletepage( nTabValue )
   nPages := nPages - 1
   if nPages > 4
      if nPages > 0
         if nIndex <= nPages
            main.datatab.value := nIndex + nDefaultPages
         else
            main.datatab.value := nPages + nDefaultPages
         endif
      else
         main.datatab.value := 4
      endif
   endif
return nil 


function showabout
   define window about at 0, 0 width 1110 height 580 title 'About Tally Connector!' icon 'tally' modal  nosize  
      define image connector
         row 10
         col 10
         width 512
         height 512
         picture "connector"
      end image
      define label powered
         row 10
         col 530
         value 'Developed By:'
         width 150
         height 40
         fontname cFontName
         fontsize 16
         fontbold .t.
      end label
      define hyperlink hmgforum
         row 10
         col 690
         width 400
         fontname cFontName
         fontsize 14
         fontbold .t.
         value 'CA S. Rathinagiri'
         tooltip "Go to LinkedIn page"
         address 'http://www.linkedin.com/in/ca-rathinagiri-subbiah-2055042a'
         handcursor .t.
      end hyperlink
      define label techcalabel
         row 70
         col 530
         value 'TechCA:'
         width 150
         height 40
         fontname cFontName
         fontsize 16
         fontbold .t.
      end label
      define hyperlink techca
         row 70
         col 690
         width 340
         fontname cFontName
         fontsize 14
         fontbold .t.
         value 'Tally Connector TechCA.app Page'
         tooltip 'Go to TechCA.app Tally Connector Page'
         address 'http://www.techca.app/viewtopic.php?t=34'
         handcursor .t.
      end hyperlink
      define label reqd
         row 130
         col 530
         value 'This software requires Tally Connector TDL installed, loaded and running in Tally. Otherwise, you can not load exclusive daybook, ledger master, stock master and forensics tables. Click Above Link for more details.'
         width 570
         height 150
         fontcolor { 255, 0, 0 }
         fontname cFontName
         fontsize 12
         fontbold .t.
      end label
      define hyperlink mailid
         row 290
         col 530
         width 220
         fontname cFontName
         fontsize 9
         fontbold .t.
         value 'Contact me: srathinagiri@gmail.com'
         tooltip 'Mail to srathinagiri@gmail.com'
         address 'srathinagiri@gmail.com'
         handcursor .t.
      end hyperlink
      on key ESCAPE action about.release()
   end window
   about.CENTER
   about.activate
return nil


function exportexcelxml
   local cFileName := ''
   local fHandle := nil
   local cXML := ''
   local cLBr := chr( 10 )
   local nRow := 0
   local cSheetName := ''
   local aSheets := {}
   local aCurData := {}
   local aCurFields := {}
   local aFields := {}
   local aSize := {}
   local aJustify := {}
   local nSheets := 0
   if hmg_len( aDaybook ) == 0 .and. hmg_len( aLedger ) == 0 .and. hmg_len( aStock ) == 0 .and. hmg_len( aForensics ) == 0 .and. nPages <= nDefaultPages
      msgstop( "Noting to Export! Import any or all tables first!", "Tally Connector!")
      return nil
   endif
   cFileName := PutFile ( { { "Excel XML Files (*.xml)", "*.xml" } }, "Export to Excel XML file (XML)", , .f. ) 
   if hmg_len( alltrim( cFileName ) ) == 0
      return nil
   endif
   if at( ".xml", hmg_lower( cFileName) ) > 0
      if .not. hb_uright( hmg_lower( cFileName), 4 ) == ".xml"
         cFileName := cFileName + ".xml"
      endif
   else
      cFileName := cFileName + ".xml"
   endif
   fHandle := fcreate( cFileName )
   if fHandle < 0
      msgstop( "File "+ cFileName + " could not be created!" )
      return nil
   endif
   if hmg_len( aDaybook ) > 0 
      nSheets++
   endif
   if hmg_len( aLedger ) > 0 
      nSheets++
   endif
   if hmg_len( aStock ) > 0 
      nSheets++
   endif
   if hmg_len( aForensics ) > 0 
      nSheets++
   endif
   if nPages > nDefaultPages
      nSheets := nSheets + nPages - nDefaultPages
   endif   
   cXML := cXML + '<?xml version="1.0"?>' + cLBr
   cXML := cXML + '<?mso-application progid="Excel.Sheet"?>' + cLBr
   cXML := cXML + '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"' + cLBr
   cXML := cXML + 'xmlns:o="urn:schemas-microsoft-com:office:office"' + cLBr
   cXML := cXML + 'xmlns:x="urn:schemas-microsoft-com:office:excel"' + cLBr
   cXML := cXML + 'xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"' + cLBr
   cXML := cXML + 'xmlns:html="http://www.w3.org/TR/REC-html40">' + cLBr
   cXML := cXML + '<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">' + cLBr
   cXML := cXML + '<ActiveSheet>' + alltrim( str( nSheets ) ) + '</ActiveSheet>' + cLBr
   cXML := cXML + '</ExcelWorkbook>' + cLBr
   cXML := cXML + '<Styles>' + cLBr
   cXML := cXML + '<Style ss:ID="Default" ss:Name="Normal">' + cLBr
   cXML := cXML + '<Alignment ss:Vertical="Bottom"/>' + cLBr
   cXML := cXML + '<Borders/>' + cLBr
   cXML := cXML + '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + cLBr
   cXML := cXML + '<Interior/>' + cLBr
   cXML := cXML + '<NumberFormat/>' + cLBr
   cXML := cXML + '<Protection/>' + cLBr
   cXML := cXML + '</Style>' + cLBr
   cXML := cXML + '<Style ss:ID="myDateStyle">' + cLBr
   cXML := cXML + '<Font ss:Color="#000000"/>' + cLBr
   cXML := cXML + '<NumberFormat ss:Format="dd-mm-yyyy"/>' + cLBr
   cXML := cXML + '</Style>' + cLBr
   cXML := cXML + '</Styles>' + cLBr
   cXML := cXML + '' + cLBr
   fWrite( fHandle, cXML )   
   cXML := ''
   
   if hmg_len( aDayBook ) > 0
      main.status.value := "Started Exporting Daybook"
      cSheetName := 'DayBook'
      cXML := cXML + '<Worksheet ss:Name="' + cSheetName + '">' + cLBr
      nRows := hmg_len( aDayBook )
      aColumnHeaders := { "$Key", "$MasterId", "$AlterID", "$VoucherNumber", "$Date", "$VoucherTypeName", "$Led_Lineno", "$Type", "$LedgerName", "$Amount", "$Led_Parent", "$Led_Group", "$Party_LedName", "$Vch_GSTIN", "$Led_GSTIN", "$Party_GST_Type", "$GST_Classification", "$Narration", "$EnteredBy", "$LastEventinVoucher", "$UpdatedDate", "$UpdatedTime", "$Nature_Led", "$Led_MID", "$CompanyName", "$Year_from", "$Year_to", "$Company_number", "$Path" }
      nCols := hmg_len( aColumnHeaders )
      aColumnjustify := { 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0 }
      cXML := cXML + '<Table ss:ExpandedColumnCount="' + alltrim( str( nCols ) ) + '" ss:ExpandedRowCount="' + alltrim( str(nRows + 1) ) + '" x:FullColumns="1"' + cLBr
      cXML := cXML + 'x:FullRows="1" ss:DefaultRowHeight="15">' + cLBr
      cXML := cXML + '<Row>' + cLBr
      for i := 1 to hmg_len( aColumnHeaders )   
         cXML := cXML + '<Cell><Data ss:Type="String">' + aColumnHeaders[ i ] + '</Data></Cell>' + cLBr
      next i      
      cXML := cXML + '</Row>' + cLBr
      for i := 1 to nRows
         main.status.value := "Daybook " + alltrim( str( i ) ) + '/' + alltrim( str( nRows ) )
         cXML := cXML + '<Row>' + cLBr
         for j := 1 to nCols
            if aColumnJustify[ j ] == 1
               cData := aDayBook[ i, j ]
               if hmg_len( cData  ) == 10 .and. hb_usubstr( cData, 3, 1 ) == '-' .and. hb_usubstr( cData, 6, 1 ) == '-'  // date
                  cXML := cXML + '<Cell ss:StyleID="myDateStyle"><Data ss:Type="DateTime">' + hb_usubstr( cData, 7, 4 ) + '-' + hb_usubstr(cData, 4, 2) + '-' + hb_usubstr( cData, 1, 2 ) + '</Data></Cell>' + cLBr
               else   
                  cXML := cXML + '<Cell><Data ss:Type="Number">' + cData + '</Data></Cell>' + cLBr
               endif   
            else   
               cXML := cXML + '<Cell><Data ss:Type="String">' + aDayBook[ i, j ] + '</Data></Cell>' + cLBr
            endif   
         next j      
         cXML := cXML + '</Row>' + cLBr
      next i
      cXML := cXML + '</Table>' + cLBr
      cXML := cXML + '</Worksheet>' + cLBr
      fWrite( fHandle, cXML )   
      cXML := ''
   endif   
   main.status.value := ""
   if hmg_len( aLedger ) > 0
      main.status.value := "Started Exporting Ledger"
      cSheetName := 'Ledger Master'
      cXML := cXML + '<Worksheet ss:Name="' + cSheetName + '">' + cLBr
      nRows := hmg_len( aLedger )
      aColumnHeaders := { "$Name", "$_PrimaryGroup", "$Parent", "$OpeningBalance", "$ClosingBalance", "$_PrevYearBalance", "$IsRevenue", "$PartyGSTIN", "$MasterId", "$AlterID", "$Nature_Led", "$UpdatedDate", "$UpdatedTime", "$CreatedBy", "$CreatedDate", "$AlteredDate", "$AlteredBy", "$LastVoucherDate", "$CompanyName", "$Year_from", "$Year_to", "$Company_number", "$Path" }
      nCols := hmg_len( aColumnHeaders )
      aColumnjustify := { 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0 }
      cXML := cXML + '<Table ss:ExpandedColumnCount="' + alltrim( str( nCols ) ) + '" ss:ExpandedRowCount="' + alltrim( str(nRows + 1) ) + '" x:FullColumns="1"' + cLBr
      cXML := cXML + 'x:FullRows="1" ss:DefaultRowHeight="15">' + cLBr
      cXML := cXML + '<Row>' + cLBr
      for i := 1 to hmg_len( aColumnHeaders )   
         cXML := cXML + '<Cell><Data ss:Type="String">' + aColumnHeaders[ i ] + '</Data></Cell>' + cLBr
      next i      
      cXML := cXML + '</Row>' + cLBr
      for i := 1 to nRows
         main.status.value := "Ledger Master " + alltrim( str( i ) ) + '/' + alltrim( str( nRows ) )
         cXML := cXML + '<Row>' + cLBr
         for j := 1 to nCols
            if aColumnJustify[ j ] == 1
               cData := aLedger[ i, j ]
               if hmg_len( cData  ) == 10 .and. hb_usubstr( cData, 3, 1 ) == '-' .and. hb_usubstr( cData, 6, 1 ) == '-'  // date
                  cXML := cXML + '<Cell ss:StyleID="myDateStyle"><Data ss:Type="DateTime">' + hb_usubstr( cData, 7, 4 ) + '-' + hb_usubstr(cData, 4, 2) + '-' + hb_usubstr( cData, 1, 2 ) + '</Data></Cell>' + cLBr
               else   
                  cXML := cXML + '<Cell><Data ss:Type="Number">' + cData + '</Data></Cell>' + cLBr
               endif   
            else   
               cXML := cXML + '<Cell><Data ss:Type="String">' + aLedger[ i, j ] + '</Data></Cell>' + cLBr
            endif   
         next j      
         cXML := cXML + '</Row>' + cLBr
      next i
      cXML := cXML + '</Table>' + cLBr
      cXML := cXML + '</Worksheet>' + cLBr
      fWrite( fHandle, cXML )   
      cXML := ''
   endif   
   main.status.value := ""
   if hmg_len( aStock ) > 0
      main.status.value := "Started Exporting Stock Master"
      cSheetName := 'Stock Master'
      cXML := cXML + '<Worksheet ss:Name="' + cSheetName + '">' + cLBr
      nRows := hmg_len( aStock )
      aColumnHeaders := { "$MasterId", "$AlterID", "$Name", "$PartnoParent", "$Category", "$OpeningBalance", "$ClosingBalance", "$ClosingRate", "$ClosingValue", "$LastPurcCost", "$LastPurcDate", "$LastPurcParty", "$LastPurcPrice", "$LastPurcQty", "$LastSaleDate", "$LastSaleParty", "$LastSaleQty", "$LastVoucherDate", "$EnteredBy", "$GSTTypeofSupply", "$CostingMethod", "$ValuationMethod", "$BaseUnits", "$AdditionalUnits", "$_HSNCode", "$_IntegratedTax", "$_CentralTax", "$_StateTax", "$_HSNDescription", "$_InwardQuantity", "$_InwardValue", "$_OutwardQuantity", "$_OutwardValue", "$CompanyName", "$Year_from", "$Year_to", "$Company_number", "$Path"  }
      nCols := hmg_len( aColumnHeaders )
      aColumnjustify := { 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0 }
      cXML := cXML + '<Table ss:ExpandedColumnCount="' + alltrim( str( nCols ) ) + '" ss:ExpandedRowCount="' + alltrim( str(nRows + 1) ) + '" x:FullColumns="1"' + cLBr
      cXML := cXML + 'x:FullRows="1" ss:DefaultRowHeight="15">' + cLBr
      cXML := cXML + '<Row>' + cLBr
      for i := 1 to hmg_len( aColumnHeaders )   
         cXML := cXML + '<Cell><Data ss:Type="String">' + aColumnHeaders[ i ] + '</Data></Cell>' + cLBr
      next i      
      cXML := cXML + '</Row>' + cLBr
      for i := 1 to nRows
         main.status.value := "Stock Master " + alltrim( str( i ) ) + '/' + alltrim( str( nRows ) )
         cXML := cXML + '<Row>' + cLBr
         for j := 1 to nCols
            if aColumnJustify[ j ] == 1
               cData := aStock[ i, j ]
               if hmg_len( cData  ) == 10 .and. hb_usubstr( cData, 3, 1 ) == '-' .and. hb_usubstr( cData, 6, 1 ) == '-'  // date
                  cXML := cXML + '<Cell ss:StyleID="myDateStyle"><Data ss:Type="DateTime">' + hb_usubstr( cData, 7, 4 ) + '-' + hb_usubstr(cData, 4, 2) + '-' + hb_usubstr( cData, 1, 2 ) + '</Data></Cell>' + cLBr
               else   
                  cXML := cXML + '<Cell><Data ss:Type="Number">' + cData + '</Data></Cell>' + cLBr
               endif   
            else   
               cXML := cXML + '<Cell><Data ss:Type="String">' + aStock[ i, j ] + '</Data></Cell>' + cLBr
            endif   
         next j      
         cXML := cXML + '</Row>' + cLBr
      next i
      cXML := cXML + '</Table>' + cLBr
      cXML := cXML + '</Worksheet>' + cLBr
      fWrite( fHandle, cXML )   
      cXML := ''
   endif   
   main.status.value := ""
      
   if hmg_len( aForensics ) > 0
      main.status.value := "Started Exporting Forensics"
      cSheetName := 'Forensics'
      cXML := cXML + '<Worksheet ss:Name="' + cSheetName + '">' + cLBr
      nRows := hmg_len( aForensics )
      aColumnHeaders := { "$Name", "$Createdby", "$CreatedDate", "$Masterid", "$Alterid", "$Alteredon", "$Alteredby", "$Updateddatetime", "$LastVoucherDate", "$Parent", "$_PrimaryGroup", "$$AscrAmt:$openingBalance", "$$AscrAmt:$_ClosingBalance" }
      nCols := hmg_len( aColumnHeaders )
      aColumnjustify := { 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 1 }
      cXML := cXML + '<Table ss:ExpandedColumnCount="' + alltrim( str( nCols ) ) + '" ss:ExpandedRowCount="' + alltrim( str(nRows + 1) ) + '" x:FullColumns="1"' + cLBr
      cXML := cXML + 'x:FullRows="1" ss:DefaultRowHeight="15">' + cLBr
      cXML := cXML + '<Row>' + cLBr
      for i := 1 to hmg_len( aColumnHeaders )   
         cXML := cXML + '<Cell><Data ss:Type="String">' + aColumnHeaders[ i ] + '</Data></Cell>' + cLBr
      next i      
      cXML := cXML + '</Row>' + cLBr
      for i := 1 to nRows
         main.status.value := "Forensics " + alltrim( str( i ) ) + '/' + alltrim( str( nRows ) )
         cXML := cXML + '<Row>' + cLBr
         for j := 1 to nCols
            if aColumnJustify[ j ] == 1
               cData := aForensics[ i, j ]
               if hmg_len( cData  ) == 10 .and. hb_usubstr( cData, 3, 1 ) == '-' .and. hb_usubstr( cData, 6, 1 ) == '-'  // date
                  cXML := cXML + '<Cell ss:StyleID="myDateStyle"><Data ss:Type="DateTime">' + hb_usubstr( cData, 7, 4 ) + '-' + hb_usubstr(cData, 4, 2) + '-' + hb_usubstr( cData, 1, 2 ) + '</Data></Cell>' + cLBr
               else   
                  cXML := cXML + '<Cell><Data ss:Type="Number">' + cData + '</Data></Cell>' + cLBr
               endif   
            else   
               cXML := cXML + '<Cell><Data ss:Type="String">' + aForensics[ i, j ] + '</Data></Cell>' + cLBr
            endif   
         next j      
         cXML := cXML + '</Row>' + cLBr
      next i
      cXML := cXML + '</Table>' + cLBr
      cXML := cXML + '</Worksheet>' + cLBr
      fWrite( fHandle, cXML )   
      cXML := ''
   endif   
   main.status.value := ""
         
   for k := 5 to nPages
      cTable := main.datatab.caption( k )
      aCurTable := {}
      aFields := {}
      aJustify := {}
      nRows := getproperty( 'main', cTable, 'itemcount' )
      for j := 1 to nRows
         aadd( aCurTable, getproperty( 'main', cTable, 'item', j ) )
      next j
      nCols := hmg_len( aCurTable[ 1 ] )
      for j := 1 to nCols
         aadd( aFields, getproperty( 'main', cTable, 'ColumnHEADER', j ) )
         aadd( aJustify, getproperty( 'main', cTable, 'ColumnJUSTIFY', j ) )
      next j   
      main.status.value := "Started Exporting " + cTable
      cSheetName := cTable
      cXML := cXML + '<Worksheet ss:Name="' + cTable + '">' + cLBr
      nRows := hmg_len( aCurTable )
      aColumnHeaders := aclone( aFields )
      aColumnjustify := aclone( aJustify )
      cXML := cXML + '<Table ss:ExpandedColumnCount="' + alltrim( str( nCols ) ) + '" ss:ExpandedRowCount="' + alltrim( str(nRows + 1) ) + '" x:FullColumns="1"' + cLBr
      cXML := cXML + 'x:FullRows="1" ss:DefaultRowHeight="15">' + cLBr
      cXML := cXML + '<Row>' + cLBr
      for i := 1 to hmg_len( aColumnHeaders )   
         cXML := cXML + '<Cell><Data ss:Type="String">' + aColumnHeaders[ i ] + '</Data></Cell>' + cLBr
      next i      
      cXML := cXML + '</Row>' + cLBr
      for i := 1 to nRows
         main.status.value := cTable + " " + alltrim( str( i ) ) + '/' + alltrim( str( nRows ) )
         cXML := cXML + '<Row>' + cLBr
         for j := 1 to nCols
            if aColumnJustify[ j ] == 1
               cData := aCurTable[ i, j ]
               if hmg_len( cData  ) == 10 .and. hb_usubstr( cData, 3, 1 ) == '-' .and. hb_usubstr( cData, 6, 1 ) == '-'  // date
                  cXML := cXML + '<Cell ss:StyleID="myDateStyle"><Data ss:Type="DateTime">' + hb_usubstr( cData, 7, 4 ) + '-' + hb_usubstr(cData, 4, 2) + '-' + hb_usubstr( cData, 1, 2 ) + '</Data></Cell>' + cLBr
               else
                  if cData == 'Error!'
                     cXML := cXML + '<Cell><Data ss:Type="String">' + cData + '</Data></Cell>' + cLBr
                  else   
                     cXML := cXML + '<Cell><Data ss:Type="Number">' + cData + '</Data></Cell>' + cLBr
                  endif   
               endif   
            else   
               cXML := cXML + '<Cell><Data ss:Type="String">' + aCurTable[ i, j ] + '</Data></Cell>' + cLBr
            endif   
         next j      
         cXML := cXML + '</Row>' + cLBr
      next i
      cXML := cXML + '</Table>' + cLBr
      cXML := cXML + '</Worksheet>' + cLBr
      fWrite( fHandle, cXML )   
      cXML := ''
      main.status.value := ""
   next k   
   cXML := cXML + '</Workbook>' + cLBr
   fWrite( fHandle, cXML )   
   if fclose( fHandle )
      msginfo( 'Exported to file ' + cFileName + ' Successfully!' )
   else   
      msgstop( 'Error in Saving the File - ' + cFileName + '!' )
   endif
return nil

function findcolumns
   local cColumns := ''
   local cTableName := ''
   local nLineNo := main.tables.value
   local oRecSet := nil
   local nRecords := 0, i := 0
   if nLineNo > 0
      cTableName := main.tables.item(nLineNo)
   else
      return nil
   endif
   oRecSet := TOleAuto():New('ADODB.Recordset')
   oRecSet:CursorLocation = adUseClient
   oRecSet := oConnection:OpenSchema(adSchemaColumns, {nil, nil, cTableName})
   nRecords := oRecSet:RecordCount()
  set alter to x
  set alter on
  msginfo( any2str(nRecords) )
   for i := 0 to nRecords - 1
	  ?any2str(oRecSet:Fields(3):value )
      cColumns := cColumns + any2str(oRecSet:Fields(3):value )
      if i < nRecords - 1 	  
	     cColumns := cColumns + ","
      endif		 
      oRecSet:MoveNext()
   next i   
   set alter to
   msginfo( cColumns )
return cColumns