with recursive star_pattern as 
(
    select 20 as n  -- just says n=20 in sql
    union all -- combines  this query (select 20 as n) and this query (select n-1 from star_pattern where n>1 queries)
    select n-1 from star_pattern where n>1 -- n-1 keeps on reducing n value to 19 -> 18 -> 17 and evey time it happens new n value is formed and it is printed in repeat
  
n > 1   | Original `n` | n-1 | `REPEAT('* ', n)` | 
--3-- |  -----1------ | -4- | -------2--------- | 
3 > 1 T | 3            | 2   | `* * * `          | 
2 > 1 T | 2            | 1   | `* * `            |
1 > 1 F | 1            | -   | `* `              | 

)
select repeat('* ',n) as pattern from star_pattern;
-- repeat is a function in sql if repaet('hi ',5) is written hi would be repeated 5 times

--sample output
* * * * * * * * * * * * * * * * * * * *  -- there are 20
* * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * 
* * * * * * * * * * * * * 
* * * * * * * * * * * * 
* * * * * * * * * * * 
* * * * * * * * * * 
* * * * * * * * * 
* * * * * * * * 
* * * * * * * 
* * * * * * 
* * * * * 
* * * * 
* * * 
* * 
* 
