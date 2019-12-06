.mode column
.headers on
.open day6.db

DROP TABLE IF EXISTS direct_orbits;
DROP TABLE IF EXISTS all_orbits;
DROP TABLE IF EXISTS me_and_santa;

CREATE TABLE direct_orbits(parent txt, child txt);

.separator )
.import input.txt direct_orbits

CREATE TABLE all_orbits(parent txt, child txt);

-- Recursively find all indirect orbit relationships
WITH RECURSIVE traverse(parent, child) AS (
  SELECT parent, child
    FROM direct_orbits

  UNION ALL

  SELECT traverse.parent, direct_orbits.child
    FROM direct_orbits, traverse
    WHERE direct_orbits.parent = traverse.child AND direct_orbits.child IS NOT NULL
)
INSERT INTO all_orbits
SELECT * FROM traverse ORDER BY parent ASC;

SELECT COUNT(*) AS `Part 1` FROM all_orbits;

CREATE TABLE me_and_santa(parent txt, child txt);

-- Find my path to COM and Santa's path to COM
WITH RECURSIVE traverse(parent, child) AS (
  SELECT parent, child
    FROM direct_orbits
    WHERE child = 'YOU'

  UNION ALL

  SELECT direct_orbits.parent, direct_orbits.child
    FROM direct_orbits, traverse
    WHERE direct_orbits.child = traverse.parent AND direct_orbits.parent IS NOT NULL
)
INSERT INTO me_and_santa
SELECT * FROM traverse;

WITH RECURSIVE traverse(parent, child) AS (
  SELECT parent, child
    FROM direct_orbits
    WHERE child = 'SAN'

  UNION ALL

  SELECT direct_orbits.parent, direct_orbits.child
    FROM direct_orbits, traverse
    WHERE direct_orbits.child = traverse.parent AND direct_orbits.parent IS NOT NULL
)
INSERT INTO me_and_santa
SELECT * FROM traverse;

-- The distance from me to Santa is the number of unique records that exist in me_and_santa, minus 2 (because we are just counting the planets *between* us)
SELECT (COUNT(*) - 2) AS `Part 2` FROM (
  SELECT *
  FROM me_and_santa
  GROUP BY parent, child
  HAVING COUNT(*) = 1
);
