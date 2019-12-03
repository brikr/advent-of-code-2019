$lat = 0
$long = 0
$first = $true
$visited = @{ }
$min_distance = -1

foreach ($line in Get-Content .\test-input.txt) {
  foreach ($instruction in $line.Split(",")) {
    $distance = [int]$instruction.SubString(1)
    switch ($instruction.SubString(0, 1)) {
      U {
        for ($i = 0; $i -lt $distance; $i++) {
          $lat++
          if ($first) {
            $visited["$lat,$long"] = $true
          }
          else {
            if ($visited["$lat,$long"]) {
              # Overlap found!
              $distance_from_origin = [Math]::Abs($lat) + [Math]::Abs($long);
              if (($distance_from_origin -lt $min_distance) -or ($min_distance -eq -1)) {
                $min_distance = $distance_from_origin
              }
            }
          }
        }
        break;
      }
      D {
        for ($i = 0; $i -lt $distance; $i++) {
          $lat--
          if ($first) {
            $visited["$lat,$long"] = $true
          }
          else {
            if ($visited["$lat,$long"]) {
              # Overlap found!
              $distance_from_origin = [Math]::Abs($lat) + [Math]::Abs($long);
              if (($distance_from_origin -lt $min_distance) -or ($min_distance -eq -1)) {
                $min_distance = $distance_from_origin
              }
            }
          }
        }
        break;
      }
      R {
        for ($i = 0; $i -lt $distance; $i++) {
          $long++
          if ($first) {
            $visited["$lat,$long"] = $true
          }
          else {
            if ($visited["$lat,$long"]) {
              # Overlap found!
              $distance_from_origin = [Math]::Abs($lat) + [Math]::Abs($long);
              if (($distance_from_origin -lt $min_distance) -or ($min_distance -eq -1)) {
                $min_distance = $distance_from_origin
              }
            }
          }
        }
        break;
      }
      L {
        for ($i = 0; $i -lt $distance; $i++) {
          $long--
          if ($first) {
            $visited["$lat,$long"] = $true
          }
          else {
            if ($visited["$lat,$long"]) {
              # Overlap found!
              $distance_from_origin = [Math]::Abs($lat) + [Math]::Abs($long);
              if (($distance_from_origin -lt $min_distance) -or ($min_distance -eq -1)) {
                $min_distance = $distance_from_origin
              }
            }
          }
        }
        break;
      }
    }
  }
  $first = $false
  $lat = 0
  $long = 0
}

Write-Host $min_distance