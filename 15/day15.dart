import 'dart:async';
import 'dart:convert';
import 'dart:io';

main() async {
  var maze = await buildMaze();
  print(maze);
}

Future<Maze> buildMaze() async {
  var completer = new Completer<Maze>();
  Process.start('./day9', []).then((Process process) {
    var auto = true;
    var desiredDirection = 1;
    var timesHitOrigin = 0;

    var lat = 0,
        long = 0,
        minLat = 0,
        maxLat = 0,
        minLong = 0,
        maxLong = 0,
        nextLat = 1, // First auto instruction is up
        nextLong = 0;
    var map = new Map<String, String>();
    map['0,0'] = '.';
    process.stdout.transform(utf8.decoder).listen((data) {
      // From robot
      var response = data.trim();

      // Update position and map data
      switch (response) {
        case '0':
          {
            // Hit wall; didn't move
            map['$nextLat,$nextLong'] = '#';
            desiredDirection = counterClockwise(desiredDirection);
          }
          break;
        case '1':
          {
            // Moved
            lat = nextLat;
            long = nextLong;
            if (map['$lat,$long'] == null) {
              map['$lat,$long'] = '.';
            }
            desiredDirection = clockwise(desiredDirection);
          }
          break;
        case '2':
          {
            // Moved and found oxygen system
            lat = nextLat;
            long = nextLong;
            map['$lat,$long'] = 'o';
            desiredDirection = clockwise(desiredDirection);
          }
          break;
      }

      // Update known bounds
      var bounds =
          getBounds(nextLat, minLat, maxLat, nextLong, minLong, maxLong);
      minLat = bounds[0];
      maxLat = bounds[1];
      minLong = bounds[2];
      maxLong = bounds[3];

      nextLat = lat;
      nextLong = long;

      if (auto) {
        if (lat == 0 && long == 0) {
          timesHitOrigin++;
          if (timesHitOrigin > 1) {
            completer.complete(new Maze(map, minLat, maxLat, minLong, maxLong));
            process.kill();
            return;
          }
        }
        switch (desiredDirection) {
          case 1:
            {
              nextLat = lat + 1;
            }
            break;
          case 2:
            {
              nextLat = lat - 1;
            }
            break;
          case 3:
            {
              nextLong = long - 1;
            }
            break;
          case 4:
            {
              nextLong = long + 1;
            }
            break;
        }
        process.stdin.writeln("$desiredDirection");
      } else {
        // Print the map
        // printMaze(map, lat, minLat, maxLat, long, minLong, maxLong);
        print(
            'Currently at lat=$lat, long=$long (minLat=$minLat, maxLat=$maxLat, minLong=$minLong, maxLong=$maxLong)');
        stdout.write('How to move? ');
      }
    });

    // stdin.transform(utf8.decoder).listen((input) {
    //   // To robot
    //   switch (input.trim()) {
    //     case 'u':
    //       {
    //         nextLat = lat + 1;
    //         process.stdin.writeln('1');
    //       }
    //       break;
    //     case 'd':
    //       {
    //         nextLat = lat - 1;
    //         process.stdin.writeln('2');
    //       }
    //       break;
    //     case 'l':
    //       {
    //         nextLong = long - 1;
    //         process.stdin.writeln('3');
    //       }
    //       break;
    //     case 'r':
    //       {
    //         nextLong = long + 1;
    //         process.stdin.writeln('4');
    //       }
    //       break;
    //     default:
    //       {
    //         print('Invalid input! Ignoring');
    //       }
    //   }
    // });

    if (auto) {
      process.stdin.writeln("$desiredDirection");
    } else {
      print('D');
      stdout.write('How to move? ');
    }
  });

  return completer.future;
}

getBounds(int currentLat, int minLat, int maxLat, int currentLong, int minLong,
    int maxLong) {
  if (currentLat < minLat) {
    minLat = currentLat;
  } else if (currentLat > maxLat) {
    maxLat = currentLat;
  }

  if (currentLong < minLong) {
    minLong = currentLong;
  } else if (currentLong > maxLong) {
    maxLong = currentLong;
  }

  return [minLat, maxLat, minLong, maxLong];
}

printMaze(Maze maze, int currentLat, int currentLong) {
  for (int lat = maze.maxLat; lat >= maze.minLat; lat--) {
    for (int long = maze.minLong; long <= maze.maxLong; long++) {
      if (lat == currentLat && long == currentLong) {
        if (maze.map['$lat,$long'] == 'o') {
          stdout.write('O');
        } else {
          stdout.write('D');
        }
      } else if (maze.map['$lat,$long'] != null) {
        stdout.write(maze.map['$lat,$long']);
      } else {
        stdout.write(' ');
      }
    }
    print('');
  }
}

clockwise(int dir) {
  switch (dir) {
    case 1:
      {
        // Up -> Right
        return 4;
      }
      break;
    case 2:
      {
        // Down -> Left
        return 3;
      }
      break;
    case 3:
      {
        // Left -> Up
        return 1;
      }
      break;
    case 4:
      {
        // Right -> Down
        return 2;
      }
      break;
  }
}

counterClockwise(int dir) {
  switch (dir) {
    case 1:
      {
        // Up -> Left
        return 3;
      }
      break;
    case 2:
      {
        // Down -> Right
        return 4;
      }
      break;
    case 3:
      {
        // Left -> Down
        return 2;
      }
      break;
    case 4:
      {
        // Right -> Up
        return 1;
      }
      break;
  }
}

class Maze {
  Map<String, String> map;
  int minLat, maxLat, minLong, maxLong;

  Maze(Map<String, String> map, int minLat, int maxLat, int minLong,
      int maxLong) {
    this.map = map;
    this.minLat = minLat;
    this.maxLat = maxLat;
    this.minLong = minLong;
    this.maxLong = maxLong;
  }

  @override
  String toString() {
    var buffer = new StringBuffer();
    for (int lat = this.maxLat; lat >= this.minLat; lat--) {
      for (int long = this.minLong; long <= this.maxLong; long++) {
        if (this.map['$lat,$long'] != null) {
          buffer.write(this.map['$lat,$long']);
        } else {
          buffer.write(' ');
        }
      }
      buffer.write('\n');
    }
    return buffer.toString();
  }
}
