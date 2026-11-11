' Builds scripts/access/pokemon_wk10_class01.accdb - the finished Week 10 Class 1 demo database.
' Contents (matches the Class 1 demo in notes/wk10-ms-access-intro-lab.pptx):
'   Tables    Region, Town, Trainer (data from Region.csv / Town.csv / Trainer.csv in this folder)
'   Relations Region 1-many Town, Town 1-many Trainer (referential integrity on, no cascades)
'   Queries   qryTrainerHome (Kanto trainers, sorted), qryTrainersPerRegion (totals query)
'   Forms     frmRegion (main form) with sfrmTown (datasheet subform, linked on RegionID)
'   Reports   rptTownsByRegion (towns grouped by region)
' Needs Microsoft Access installed. VBScript, not PowerShell: PowerShell's COM binding drops the
' acSaveYes argument and Access stops on a hidden "Save As" dialog.
'   cscript //nologo scripts\access\build_wk10_class01.vbs
Option Explicit

Const acForm = 2, acReport = 3, acSaveYes = 1
Const acLabel = 100, acTextBox = 109, acSubform = 112
Const acDetail = 0, acPageHeader = 3, acPageFooter = 4, acGroupLevel1Header = 5
Const acQuitSaveNone = 2
Const TW = 1440   ' twips per inch

Dim fso, here, dbPath, app, db
Set fso = CreateObject("Scripting.FileSystemObject")
here = fso.GetParentFolderName(WScript.ScriptFullName)
dbPath = fso.BuildPath(here, "pokemon_wk10_class01.accdb")
If fso.FileExists(dbPath) Then fso.DeleteFile dbPath, True

Set app = CreateObject("Access.Application")
On Error Resume Next
Build
If Err.Number <> 0 Then WScript.Echo "ERROR " & Err.Number & ": " & Err.Description
On Error GoTo 0
app.Quit acQuitSaveNone   ' everything wanted is already saved; never stop on a save prompt
Set app = Nothing

Sub Build()
    On Error GoTo 0
    app.NewCurrentDatabase dbPath
    Set db = app.CurrentDb

    ' ---------- Tables ----------
    db.Execute "CREATE TABLE Region (RegionID COUNTER CONSTRAINT PK_Region PRIMARY KEY, RegionName TEXT(50) NOT NULL)"
    db.Execute "CREATE TABLE Town (TownID COUNTER CONSTRAINT PK_Town PRIMARY KEY, TownName TEXT(50) NOT NULL, RegionID LONG)"
    db.Execute "CREATE TABLE Trainer (TrainerID TEXT(3) CONSTRAINT PK_Trainer PRIMARY KEY, TrainerName TEXT(50) NOT NULL, TownID LONG)"
    LoadCsv "Region": LoadCsv "Town": LoadCsv "Trainer"

    ' ---------- Relationships (Enforce Referential Integrity, no cascade) ----------
    AddRel "RegionTown", "Region", "Town", "RegionID"
    AddRel "TownTrainer", "Town", "Trainer", "TownID"

    ' ---------- Queries ----------
    Dim j
    j = "FROM Region INNER JOIN (Town INNER JOIN Trainer ON Town.TownID = Trainer.TownID) ON Region.RegionID = Town.RegionID"
    db.CreateQueryDef "qryTrainerHome", "SELECT Trainer.TrainerName, Town.TownName, Region.RegionName " & j & _
        " WHERE ((Region.RegionName)=""Kanto"") ORDER BY Trainer.TrainerName;"
    db.CreateQueryDef "qryTrainersPerRegion", "SELECT Region.RegionName, Count(Trainer.TrainerID) AS CountOfTrainerID " & j & _
        " GROUP BY Region.RegionName;"

    Dim f, c, n

    ' ---------- Subform: sfrmTown (datasheet of towns) ----------
    Set f = app.CreateForm()
    f.RecordSource = "Town"
    f.DefaultView = 2          ' Datasheet
    f.Caption = "Town"
    Set c = app.CreateControl(f.Name, acTextBox, acDetail, "", "TownName", 1.4 * TW, 0.2 * TW, 2.5 * TW, 0.3 * TW)
    c.Name = "TownName"
    Set c = app.CreateControl(f.Name, acLabel, acDetail, "TownName", , 0.2 * TW, 0.2 * TW, 1.1 * TW, 0.3 * TW)
    c.Caption = "TownName"
    SaveAs acForm, f.Name, "sfrmTown"

    ' ---------- Main form: frmRegion (Region on top, its towns below) ----------
    Set f = app.CreateForm()
    f.RecordSource = "Region"
    f.Caption = "frmRegion"
    f.DefaultView = 0          ' Single Form
    f.Width = 6 * TW
    f.Section(acDetail).Height = 3.6 * TW
    Set c = app.CreateControl(f.Name, acTextBox, acDetail, "", "RegionName", 1.5 * TW, 0.25 * TW, 2.5 * TW, 0.3 * TW)
    c.Name = "RegionName"
    Set c = app.CreateControl(f.Name, acLabel, acDetail, "RegionName", , 0.25 * TW, 0.25 * TW, 1.15 * TW, 0.3 * TW)
    c.Caption = "RegionName"
    Set c = app.CreateControl(f.Name, acLabel, acDetail, "", , 0.25 * TW, 0.8 * TW, 2 * TW, 0.3 * TW)
    c.Caption = "Town": c.FontBold = True
    Set c = app.CreateControl(f.Name, acSubform, acDetail, "", , 0.25 * TW, 1.15 * TW, 4.5 * TW, 2.2 * TW)
    c.Name = "Town"
    c.SourceObject = "Form.sfrmTown"
    c.LinkMasterFields = "RegionID"
    c.LinkChildFields = "RegionID"
    SaveAs acForm, f.Name, "frmRegion"

    ' ---------- Report: rptTownsByRegion ----------
    Dim r
    Set r = app.CreateReport()
    r.RecordSource = "SELECT Region.RegionID, Region.RegionName, Town.TownName FROM Region INNER JOIN Town ON Region.RegionID = Town.RegionID;"
    r.Caption = "Towns by Region"
    app.CreateGroupLevel r.Name, "RegionID", True, False    ' one header per region, in RegionID order (Kanto, Johto, Hoenn)
    app.CreateGroupLevel r.Name, "TownName", False, False   ' towns A-Z inside each region
    r.Section(acPageHeader).Height = 0.7 * TW
    Set c = app.CreateReportControl(r.Name, acLabel, acPageHeader, "", ,0.25 * TW, 0.15 * TW, 4 * TW, 0.45 * TW)
    c.Caption = "Towns by Region": c.FontSize = 18: c.FontBold = True
    r.Section(acGroupLevel1Header).Height = 0.4 * TW
    Set c = app.CreateReportControl(r.Name, acTextBox, acGroupLevel1Header, "", "RegionName", 0.25 * TW, 0.05 * TW, 3 * TW, 0.3 * TW)
    c.Name = "RegionName": c.FontBold = True: c.FontSize = 12: c.BorderStyle = 0
    r.Section(acDetail).Height = 0.3 * TW
    Set c = app.CreateReportControl(r.Name, acTextBox, acDetail, "", "TownName", 0.75 * TW, 0, 3 * TW, 0.28 * TW)
    c.Name = "TownName"
    c.BorderStyle = 0
    r.Section(acPageFooter).Height = 0.35 * TW
    Set c = app.CreateReportControl(r.Name, acTextBox, acPageFooter, "", "=""Page "" & [Page] & "" of "" & [Pages]", 4 * TW, 0.05 * TW, 2 * TW, 0.25 * TW)
    c.TextAlign = 3: c.BorderStyle = 0
    SaveAs acReport, r.Name, "rptTownsByRegion"

    WScript.Echo "Built " & dbPath
End Sub

Sub SaveAs(objType, tmpName, finalName)
    app.DoCmd.Close objType, tmpName, acSaveYes
    app.DoCmd.Rename finalName, objType, tmpName
End Sub

Sub LoadCsv(t)
    Dim ts, header, cols, line, vals, i, v
    Set ts = fso.OpenTextFile(fso.BuildPath(here, t & ".csv"), 1)
    header = ts.ReadLine
    Do Until ts.AtEndOfStream
        line = Trim(ts.ReadLine)
        If line <> "" Then
            cols = Split(line, ",")   ' these CSVs have no quoted commas
            For i = 0 To UBound(cols)
                v = cols(i)
                If Not IsNumeric(v) Then v = "'" & Replace(v, "'", "''") & "'"
                cols(i) = v
            Next
            db.Execute "INSERT INTO " & t & " (" & header & ") VALUES (" & Join(cols, ", ") & ")"
        End If
    Loop
    ts.Close
End Sub

Sub AddRel(relName, oneTable, manyTable, fieldName)
    Dim rel, fld
    Set rel = db.CreateRelation(relName, oneTable, manyTable, 0)
    Set fld = rel.CreateField(fieldName)
    fld.ForeignName = fieldName
    rel.Fields.Append fld
    db.Relations.Append rel
End Sub
