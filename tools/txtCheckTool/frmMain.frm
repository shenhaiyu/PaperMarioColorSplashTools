VERSION 5.00
Begin VB.Form frmMain 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "txtCheckTool   by shenhaiyu  @ 2018"
   ClientHeight    =   4455
   ClientLeft      =   -15
   ClientTop       =   330
   ClientWidth     =   4815
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   OLEDropMode     =   1  'Manual
   ScaleHeight     =   4455
   ScaleWidth      =   4815
   StartUpPosition =   3  '´°¿ÚÈ±Ê¡
   Begin VB.TextBox txtCrLfCount 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      Height          =   270
      Left            =   960
      TabIndex        =   10
      Text            =   "4"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox txtCrLfCountMarker 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      Height          =   270
      Left            =   2310
      TabIndex        =   9
      Text            =   "^"
      Top             =   1320
      Width           =   255
   End
   Begin VB.CheckBox chkCrLfCount 
      Caption         =   "Over     CrLfs mark     in Translated blocks"
      Height          =   255
      Left            =   240
      TabIndex        =   8
      ToolTipText     =   "Usefull for 3 lines text limit in Japan version"
      Top             =   1320
      Width           =   4455
   End
   Begin VB.TextBox txtSpliterLenth 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      Height          =   270
      Left            =   2040
      TabIndex        =   7
      Text            =   "40"
      Top             =   960
      Width           =   975
   End
   Begin VB.TextBox txtSubSpliter 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      Height          =   270
      Left            =   2040
      TabIndex        =   3
      Text            =   "-"
      Top             =   600
      Width           =   975
   End
   Begin VB.CheckBox chkKeepTab 
      Caption         =   "Keep Tabs"
      Height          =   255
      Left            =   3240
      TabIndex        =   1
      Top             =   600
      Value           =   1  'Checked
      Width           =   1335
   End
   Begin VB.TextBox txtMainSpliter 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      Height          =   270
      Left            =   2040
      TabIndex        =   2
      Text            =   "="
      Top             =   240
      Width           =   975
   End
   Begin VB.Label lblSpliterLenth 
      Caption         =   " Spliter lenth:"
      Height          =   255
      Left            =   240
      TabIndex        =   6
      Top             =   960
      Width           =   1695
   End
   Begin VB.Label lblSubSpliter 
      Caption         =   " Sub Spliter Char:"
      Height          =   255
      Left            =   240
      TabIndex        =   5
      Top             =   600
      Width           =   1815
   End
   Begin VB.Label lblMainSpliter 
      Caption         =   "Main Spliter Char:"
      Height          =   255
      Left            =   240
      TabIndex        =   4
      Top             =   240
      Width           =   1815
   End
   Begin VB.Label lblDrag 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Drag all *.txt files here"
      ForeColor       =   &H80000008&
      Height          =   2415
      Left            =   120
      OLEDropMode     =   1  'Manual
      TabIndex        =   0
      Top             =   1920
      Width           =   4575
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'Nintendo WiiU Paper Mario Color Splash translated txt check tool.
'Code by shenhaiyu @ 2018-02-19
'Free to copy and modify but retain the author information please

Option Explicit

Dim strFileName As String
Dim aryContent1() As Byte
Dim aryContent2() As Byte
Dim FileSplitPos As Long

Private Sub Form_Load()
    
    lblDrag.Caption = vbCrLf & vbCrLf & vbCrLf & vbCrLf & vbCrLf & lblDrag.Caption
    
End Sub

Private Sub lblDrag_OLEDragDrop(Data As DataObject, Effect As Long, Button As Integer, Shift As Integer, X As Single, Y As Single)
    
    Dim i As Long
    Dim strFileName As String
    Dim InputFile As String
    Dim OutputFile As String
    
    For i = 1 To Data.Files.Count
        If Data.GetFormat(vbCFFiles) = True Then
            InputFile = Data.Files(i)
            strFileName = CreateObject("Scripting.FileSystemObject").GetBaseName(Data.Files(i))
            OutputFile = Replace(Data.Files(i), strFileName, strFileName & ".chk")
            
            TranslatedFileCheck InputFile, OutputFile, chkKeepTab.Value, txtMainSpliter.Text, txtSubSpliter.Text, Val(txtSpliterLenth)
        End If
    Next
    MsgBox "Well done!"
    
End Sub

Private Sub TranslatedFileCheck(InputFile As String, OutputFile As String, KeepTab As Boolean, MainSpliterChar As String, SubSpliterChar As String, SpliterLenth As Integer)
    
    Dim i As Long
    Dim OldFile() As Byte
    Dim NewFile() As Byte
    Dim FileLen As Long
    Dim OldPos As Long
    Dim NewPos As Long
    Dim SpliterCharCount As Integer
    Dim SpliterLineCount As Integer
    Dim CrLfCount As Integer
    Dim TabStat As Boolean
    
    'Open original file
    FileLen = 0
    Open InputFile For Binary As #1
        FileLen = (LOF(1))
        ReDim OldFile(FileLen) As Byte
        ReDim NewFile(FileLen) As Byte
        Get #1, , OldFile()
    Close #1
    
    'Initialize pointers
    OldPos = 0
    NewPos = 0
    SpliterCharCount = 0
    SpliterLineCount = 0
    CrLfCount = 0
    TabStat = False
    
    'Main loop
    For i = 0 To FileLen - 1
        'Count split line
        If OldFile(OldPos) = Asc(MainSpliterChar) Then
            SpliterCharCount = SpliterCharCount + 1
        Else
            SpliterCharCount = 0
        End If
        If SpliterCharCount = SpliterLenth Then
            SpliterLineCount = SpliterLineCount + 1
            SpliterCharCount = 0
        End If
        If SpliterLineCount = 3 Then SpliterLineCount = 0
        
        'If in the translated text block
        If (SpliterLineCount = 2) Then
            'Main spliter and sub spliter and CrLf chars, and not in tab block
            If TabStat = False And (OldFile(OldPos) = Asc(MainSpliterChar) Or OldFile(OldPos) = Asc(SubSpliterChar) Or OldFile(OldPos) = Asc(vbCr) Or OldFile(OldPos) = Asc(vbLf)) Then
                If OldFile(OldPos) = Asc(vbCr) And OldFile(OldPos + 1) = Asc(vbLf) Then CrLfCount = CrLfCount + 1
                If OldFile(OldPos) = Asc(SubSpliterChar) Then CrLfCount = 0
                If CrLfCount = Val(txtCrLfCount.Text) + 1 And chkCrLfCount.Value = 1 Then
                    NewFile(NewPos) = Asc(txtCrLfCountMarker.Text)
                    NewPos = NewPos + 1
                    CrLfCount = 0
                End If
                NewFile(NewPos) = OldFile(OldPos)
                NewPos = NewPos + 1
            'Other chars
            Else
                If OldFile(OldPos) = Asc("<") Then TabStat = True 'Tab start
                'if in tab block and keep tab
                If KeepTab And TabStat Then
                    NewFile(NewPos) = OldFile(OldPos)
                    NewPos = NewPos + 1
                End If
                If OldFile(OldPos) = Asc(">") Then TabStat = False 'Tab end
            End If
        'If out the translated text block just copy chars
        Else
            CrLfCount = 0
            NewFile(NewPos) = OldFile(OldPos)
            NewPos = NewPos + 1
        End If
        
        OldPos = OldPos + 1 'Move pointer to next char
    Next
    
    'Save New txt
    If Dir(OutputFile) <> "" Then
        Kill OutputFile
    End If
    ReDim Preserve NewFile(NewPos - 1) As Byte
    Open OutputFile For Binary As #2
        Put #2, , NewFile()
    Close #2
    
End Sub
