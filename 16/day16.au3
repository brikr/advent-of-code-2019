#include <Array.au3>
#include <StringConstants.au3>

$input = FileRead(@ScriptDir & "\testinput.txt")

ConsoleWrite("Phase 0: " & $input & @CRLF)
For $i = 1 To 1
  $input = Fast_FFT($input)
  ConsoleWrite("Phase " & $i & ": " & $input & @CRLF)
Next
ConsoleWrite($input)

Func FFT($input)
  Local $pattern = [0, 1, 0, -1]
  Local $digits = StringSplit($input, "")

  Local $sum[$digits[0]]
  For $i = 1 To $digits[0]
    For $j = 1 To $digits[0]
      $pattern_idx = Mod(Floor($j / $i), 4)
      $multiplicant = $pattern[$pattern_idx]
      $product = $digits[$j] * $multiplicant
      $sum[$i-1] += $product
    Next
    $sum[$i-1] = Mod(Abs($sum[$i-1]), 10)
  Next

  Return _ArrayToString($sum, "")
EndFunc

Func Fast_FFT($input)
  Local $digits = StringSplit($input, "")
  Local $size = $digits[0]
  Local $next[$size]

  ; Last digits don't change
  $next[$size-1] = Mod($digits[$size], 10)

  For $i = $size - 2 To 0 Step -1
    ; next[i] = prev[i] + next[i+1] (but account for off-by-ones)
    ConsoleWrite("i=" & $i & ",digits[i+1]=" & $digits[$i+1] & ",next[i+1]=" & $next[$i+1] & @CRLF)
    $next[$i] = Mod($digits[$i+1] + $next[$i+1], 10)
  Next

  Return _ArrayToString($next, "")
EndFunc
