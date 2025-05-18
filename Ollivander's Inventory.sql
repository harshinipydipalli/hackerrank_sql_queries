Goal of this query
-- find min_gold_coins needed to purchase 
-- this quality wand,that is  high power and high age, non-evil( if the value of is_evil is 0, it means that the wand is not evil)
To find each non-evil wand (is_evil = 0),

For each combination of power and age,

Get the minimum number of gold galleons (coins_needed) needed to buy a wand with that power and age,

And then list those wands (their id, age, coins_needed, power),

Sorted by descending power, and if powers are the same, then by descending age.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select w.id,wp.age,w.coins_needed,w.power from wands w 
join Wands_Property wp on w.code=wp.code
join(
select wp.age,min(coins_needed) as min_coins, w.power
from Wands w 
 join Wands_Property wp on w.code=wp.code
where is_evil=0 
group by 1,3) as sub
on w.power=sub.power AND wp.age = sub.age AND w.coins_needed = sub.min_coins 
-- It matches each wand (w) with the subquery result (sub) only if all three conditions are true:
--The wand’s power equals the power in the subquery.
--The wand’s age equals the age in the subquery.
--The wand’s coins_needed equals the minimum coins needed for that (power, age) group.
--gives match of the same power, same age, and min coins
where is_evil=0 
group by 1,2,3,4
order by w.power desc, wp.age desc;
