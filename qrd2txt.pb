EnableExplicit

Procedure$ Plural(Count, Word$)
	If Count = 1
		ProcedureReturn Word$
	EndIf
	; Definitely not general-purpose.
	ProcedureReturn Word$ + "s"
EndProcedure

Procedure$ TXTPath(QRDPath$)
	Protected Ext$
	Ext$ = GetExtensionPart(QRDPath$)
	If Ext$ <> ""
		ProcedureReturn Left(QRDPath$, Len(QRDPath$) - Len(Ext$) - 1) + ".txt"
	EndIf
	ProcedureReturn QRDPath$ + ".txt"
EndProcedure

Procedure ConvertFile(QRDPath$)
	Protected DB, File, OutPath$, Text$
	OutPath$ = TXTPath(QRDPath$)
	DB = OpenDatabase(#PB_Any, QRDPath$, "", "")
	If Not DB
		MessageRequester("Error", "Failed to open " + QRDPath$, #PB_MessageRequester_Error)
		ProcedureReturn 0
	EndIf
	If Not DatabaseQuery(DB, "SELECT value FROM shelf WHERE key='raw.text'")
		CloseDatabase(DB)
		MessageRequester("Error", "Failed to query " + QRDPath$, #PB_MessageRequester_Error
		ProcedureReturn 0
	EndIf
	If NextDatabaseRow(DB)
		Text$ = GetDatabaseString(DB, 0)
	EndIf
	FinishDatabaseQuery(DB)
	CloseDatabase(DB)
	If Text$ = ""
		MessageRequester("Warning", "No text content found in " + QRDPath$, #PB_MessageRequester_Warning)
		ProcedureReturn 0
	EndIf
	File = CreateFile(#PB_Any, OutPath$)
	If Not File
		MessageRequester("Error", "Cannot create output file " + OutPath$)
		ProcedureReturn 0
	EndIf
	WriteString(File, Text$, #PB_UTF8)
	CloseFile(File)
	ProcedureReturn 1
EndProcedure

Define SelectedFile$, SuccessMessage$, Converted, Total
UseSQLiteDatabase()
SelectedFile$ = OpenFileRequester("Select QRD File(s)", "", "QRD Files (*.qrd)|*.qrd|All Files (*.*)|*.*", 0, #PB_Requester_MultiSelection)
If SelectedFile$ = ""
	End
EndIf
Repeat
	Total + 1
	Converted + ConvertFile(SelectedFile$)
	SelectedFile$ = NextSelectedFileName()
Until SelectedFile$ = ""
If Total = 1 And Converted = 1
	SuccessMessage$ = "Successfully converted 1 file."
Else
	SuccessMessage$ = "Successfully converted " + Converted + " of " + Total + " " + Plural(Total, "file") + "."
EndIf
MessageRequester("Done", SuccessMessage$, #PB_MessageRequester_Info)
