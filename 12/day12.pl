#!/usr/bin/env perl

sub print_moons {
  foreach (@_) {
    my $x = $_->{pos}{x};
    my $y = $_->{pos}{y};
    my $z = $_->{pos}{z};
    print "pos=<x=$x, y=$y, z=$z>, ";
    $x = $_->{vel}{x};
    $y = $_->{vel}{y};
    $z = $_->{vel}{z};
    print "vel=<x=$x, y=$y, z=$z>\n";
  }
}

sub print_moons2 {
  print "pos x=(";
  foreach(@_) {
    my $px = $_->{pos}{x};
    print "$px,";
  }
  print ")\npos y=(";
  foreach(@_) {
    my $py = $_->{pos}{y};
    print "$py,";
  }
  print ")\npos z=(";
  foreach(@_) {
    my $pz = $_->{pos}{z};
    print "$pz,";
  }
  print ")\nvel x=(";
  foreach(@_) {
    my $vx = $_->{vel}{x};
    print "$vx,";
  }
  print ")\nvel y=(";
  foreach(@_) {
    my $vy = $_->{vel}{y};
    print "$vy,";
  }
  print ")\nvel z=(";
  foreach(@_) {
    my $vz = $_->{vel}{z};
    print "$vz,";
  }
  print ")\n";
}

sub sign {
 ($val) = @_;
  if ($val > 0) {
    return 1;
  } elsif ($val < 0) {
    return -1;
  } else {
    return 0;
  }
}

sub time_step {
  my @moons = @_;
  my $count = scalar @moons;
  # Apply gravity
  for ($i = 0; $i < $count; $i++) {
    for ($j = $i + 1; $j < $count; $j++) {
      my $dx = $moons[$i]->{pos}{x} - $moons[$j]->{pos}{x};
      $moons[$i]->{vel}{x} -= sign($dx);
      $moons[$j]->{vel}{x} += sign($dx);

      my $dy = $moons[$i]->{pos}{y} - $moons[$j]->{pos}{y};
      $moons[$i]->{vel}{y} -= sign($dy);
      $moons[$j]->{vel}{y} += sign($dy);

      my $dz = $moons[$i]->{pos}{z} - $moons[$j]->{pos}{z};
      $moons[$i]->{vel}{z} -= sign($dz);
      $moons[$j]->{vel}{z} += sign($dz);
    }
  }

  # Apply velocity
  foreach (@moons) {
    $_->{pos}{x} += $_->{vel}{x};
    $_->{pos}{y} += $_->{vel}{y};
    $_->{pos}{z} += $_->{vel}{z};
  }
}

sub total_energy {
  my $total = 0;
  foreach (@_) {
    my $pe = 0;
    my $ke = 0;
    $pe += abs($_->{pos}{x});
    $pe += abs($_->{pos}{y});
    $pe += abs($_->{pos}{z});
    $ke += abs($_->{vel}{x});
    $ke += abs($_->{vel}{y});
    $ke += abs($_->{vel}{z});
    $total += $pe * $ke;
  }
  return $total;
}

sub gcd {
  ($a, $b) = @_;

  if ($b == 0) {
    return $a;
  } else {
    return gcd($b, $a % $b);
  }
}

sub lcm {
  $ans = $_[0];

  foreach (@_) {
    $ans = ($_ * $ans) / gcd($_, $ans);
  }

  return $ans;
}

sub get_moons {
  open(FH, '<', 'input.txt') or die $!;

  @moons = ();

  while (<FH>) {
    ($x, $y, $z) = ($_ =~ /<x=(-?\d+), y=(-?\d+), z=(-?\d+)>/);
    push(@moons, {
      pos => {
        x => $x,
        y => $y,
        z => $z
      },
      vel => {
        x => 0,
        y => 0,
        z => 0
      }
    });
  }

  return @moons;
}

@moons = get_moons();

# Part 1: 1k reps
for ($time = 1; $time <= 1000; $time++) {
  time_step(@moons);
}

$energy = total_energy(@moons);
print "Part 1: $energy\n";

# Part 2: Detect loop
@moons = get_moons();

$x_repeat = 0;
$y_repeat = 0;
$z_repeat = 0;

$time = 0;
while ($x_repeat == 0 || $y_repeat == 0 || $z_repeat == 0) {
  time_step(@moons);
  $time++;
  if ($x_repeat == 0) {
    $is_zero = 1;
    foreach (@moons) {
      if ($_->{vel}{x} != 0) {
        $is_zero = 0;
        last;
      }
    }
    if ($is_zero) {
      $x_repeat = $time;
    }
  }
  if ($y_repeat == 0) {
    $is_zero = 1;
    foreach (@moons) {
      if ($_->{vel}{y} != 0) {
        $is_zero = 0;
        last;
      }
    }
    if ($is_zero) {
      $y_repeat = $time;
    }
  }
  if ($z_repeat == 0) {
    $is_zero = 1;
    foreach (@moons) {
      if ($_->{vel}{z} != 0) {
        $is_zero = 0;
        last;
      }
    }
    if ($is_zero) {
      $z_repeat = $time;
    }
  }
}

$ans = lcm($x_repeat, $y_repeat, $z_repeat) * 2;
print "Part 2: $ans\n";
