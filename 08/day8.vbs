Set file = CreateObject("Scripting.FileSystemObject").OpenTextFile("input.txt", 1)
text = file.ReadAll()
file.Close
Set file = Nothing

width = 25
height = 6
layerSize = width * height
min = -1
ans = 0
j = 0
Set charCount = CreateObject("Scripting.Dictionary")
Set imageData = CreateObject("Scripting.Dictionary")
For i = 1 to Len(text)
  char = Mid(text, i, 1)

  ' Part 1
  count = 1
  If charCount.Exists(char) Then
    count = charCount(char) + 1
    charCount.Remove char
  End If
  charCount.Add char, count

  ' Part 2
  row = j \ width
  col = j Mod width
  coords = row & "," & col
  If imageData.Exists(coords) Then
    existingChar = imageData(coords)
    If existingChar = 2 Then
      imageData.Remove coords
      imageData.Add coords, char
    End If
  Else
    imageData.Add row & "," & col, char
  End If

  j = j + 1
  If j = layerSize Then
    zero = charCount("0")
    one = charCount("1")
    two = charCount("2")

    If zero < min Or min = -1 Then
      min = zero
      ans = one * two
    End If

    charCount.Remove "0"
    charCount.Remove "1"
    charCount.Remove "2"

    j = 0
  End If
Next

WScript.StdOut.WriteLine "Part 1: "  & ans

WScript.StdOut.WriteLine "Part 2:"
For i = 0 To height - 1
  For j = 0 To width - 1
    char = imageData(i & "," & j)
    ' Convert chars to something that makes the image more clear
    Select Case char
      Case "0"
        WScript.StdOut.Write "."
      Case "1"
        WScript.StdOut.Write "#"
      Case "2"
        WScript.StdOut.Write " "
    End Select
  Next
  WScript.StdOut.WriteLine
Next
