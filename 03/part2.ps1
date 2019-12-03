$lat = 0
$long = 0
$first = $true
$visited = @{ }
$distance_traveled = 0
$min_distance_traveled = -1

foreach ($line in Get-Content .\input.txt) {
  foreach ($instruction in $line.Split(",")) {
    $distance = [int]$instruction.SubString(1)
    switch ($instruction.SubString(0, 1)) {
      U {
        for ($i = 0; $i -lt $distance; $i++) {
          $lat++
          $distance_traveled++
          if ($first) {
            $visited["$lat,$long"] = $distance_traveled
          }
          else {
            if ($visited["$lat,$long"]) {
              # Overlap found!
              $total_distance_traveled = $distance_traveled + $visited["$lat,$long"]
              if (($total_distance_traveled -lt $min_distance_traveled) -or ($min_distance_traveled -eq -1)) {
                $min_distance_traveled = $total_distance_traveled
              }
            }
          }
        }
        break;
      }
      D {
        for ($i = 0; $i -lt $distance; $i++) {
          $lat--
          $distance_traveled++
          if ($first) {
            $visited["$lat,$long"] = $distance_traveled
          }
          else {
            if ($visited["$lat,$long"]) {
              # Overlap found!
              $total_distance_traveled = $distance_traveled + $visited["$lat,$long"]
              if (($total_distance_traveled -lt $min_distance_traveled) -or ($min_distance_traveled -eq -1)) {
                $min_distance_traveled = $total_distance_traveled
              }
            }
          }
        }
        break;
      }
      R {
        for ($i = 0; $i -lt $distance; $i++) {
          $long++
          $distance_traveled++
          if ($first) {
            $visited["$lat,$long"] = $distance_traveled
          }
          else {
            if ($visited["$lat,$long"]) {
              # Overlap found!
              $total_distance_traveled = $distance_traveled + $visited["$lat,$long"]
              if (($total_distance_traveled -lt $min_distance_traveled) -or ($min_distance_traveled -eq -1)) {
                $min_distance_traveled = $total_distance_traveled
              }
            }
          }
        }
        break;
      }
      L {
        for ($i = 0; $i -lt $distance; $i++) {
          $long--
          $distance_traveled++
          if ($first) {
            $visited["$lat,$long"] = $distance_traveled
          }
          else {
            if ($visited["$lat,$long"]) {
              # Overlap found!
              $total_distance_traveled = $distance_traveled + $visited["$lat,$long"]
              if (($total_distance_traveled -lt $min_distance_traveled) -or ($min_distance_traveled -eq -1)) {
                $min_distance_traveled = $total_distance_traveled
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
  $distance_traveled = 0
}

Write-Host $min_distance_traveled