#include <Array.au3>
#include <StringConstants.au3>

$original_input = FileRead(@ScriptDir & "\input.txt")
$input = $original_input

For $i = 1 To 100
  $input = FFT($input)
Next
ConsoleWrite("Part 1: " & $input & @CRLF)

; Get index defined by first seven digits, and account for the fact that we are only using the second half of the numbers
$ans_idx = StringLeft($original_input, 7) + 1
$ans_idx -= StringLen($original_input) * 10000 / 2

; Duplicate the number 5k times
; Puzzle calls for 10k, but we only care about the second half
$input = ""
For $i = 1 To 5000
  $input &= $original_input
Next

; Get the number from our answer index to the end (since we don't care about digits before it)
$input = StringMid($input, $ans_idx)

For $i = 1 To 100
  $input = Fast_FFT($input)
  ;~ ConsoleWrite("Phase " & $i & ": " & StringLeft($input, 8) & @CRLF)
Next
; Get the 8 digits of the answer
$answer = StringLeft($input, 8)
ConsoleWrite("Part 2: " & $answer)

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

; Only calculates FFT for the second half of the number (the first half is left in tact)
Func Fast_FFT($second_half)
  Local $digits = StringSplit($second_half, "")
  Local $size = $digits[0]
  Local $next[$size]

  ; Last digits don't change
  $next[$size-1] = Mod($digits[$size], 10)

  For $i = $size - 2 To 0 Step -1
    ; next[i] = prev[i] + next[i+1] (but account for off-by-ones)
    $next[$i] = Mod($digits[$i+1] + $next[$i+1], 10)
  Next

  Return _ArrayToString($next, "")
EndFunc
