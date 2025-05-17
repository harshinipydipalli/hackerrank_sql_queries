

-- getting the max score of hacker for every new challenge, here we are ingoring other scores of the same challenge if he has submitted multiple times
with max_score as (
select hacker_id, challenge_id, max(score) as max_score_of_each_challenge from submissions 
group by hacker_id, challenge_id),

-- now, sum of the highest scores is done (dependent cte)
as sum_max_score(
select hacker_id , sum(max_score_of_each_challenge) as total_of_max_scores
from max_score
    group by hacker_id ),-- here we group by action because this is creating another temp table

-- filter the hackers, if score is 0 then dont print there names
as filter(
    select h.hacker_id, h.name,m.total_of_max_scores
    from hackers h left join max_score m 
    on h.hacker_id=m.hacker_id
    where m.total_of_max_scores>0)
---- No, you should not use HAVING t.total_score > 0 in the FilteredHackers CTE — because you're not aggregating anything in that specific query.
-- 🔸 WHERE is used to filter rows before grouping or when no aggregation is involved.
-- 🔸 HAVING is used to filter after aggregation, such as after a GROUP BY.
-- ❓ Can you use HAVING without GROUP BY?
--✅ Yes, you can — but only if you're using an aggregate function in the SELECT.
 /* SELECT hacker_id, name
FROM Hackers
HAVING name LIKE 'A%';
No GROUP BY, and no aggregates → ❌ HAVING makes no sense here
*/
-- When you aggregate (using SUM, COUNT, MIN, etc.), you can use that value in the same query, but not in the WHERE clause — you use it in the SELECT or HAVING clause.
    
-- main query
    select * from filter
    ORDER BY total_score DESC, hacker_id ASC;

/you can also solve this using subquery to check version of the sql egine use select version();
--or you can also solve this with subquery
-- 🧠 Subqueries don’t always mean slower performance — it depends more on the indexes and query plan than whether it's a CTE or subquery.
--✅ Subqueries in SELECT or JOINs (when used wisely like you did) are inline views — MySQL can optimize them more aggressively.

select 
h.hacker_id, h.name, sum(max_score_of_each_challenge_of_hacker) as total_score
from hackers h
join (
    select hacker_id, challenge_id,max(score) as   max_score_of_each_challenge_of_hacker 
    from submissions
    group by hacker_id, challenge_id ) as max_score 
  --as max_score m , This is invalid syntax. You cannot give two aliases (max_score and m) for the same subquery. You should pick one alias.
    on h.hacker_id= max_score.hacker_id
    group by h.hacker_id, h.name
    having total_score > 0  -- here having is used because there is aggregation of sum
order by total_score desc, hacker_id asc;
    
-- According to referential integrity, if hacker_id is not present in hackers it will not be present in submissions table but are there chances that hacker_id in submissons table be null. 
--under normal database design and constraints:
    --No, hacker_id in Submissions should never be NULL.
    --And any hacker_id in Submissions must exist in Hackers.
--and also if i want to remove any hacker from the database first i must remove all his submissions right only then i can drop the specific hacker in hackers table?????????
    --You cannot delete a hacker from the Hackers table if there are still submissions referencing that hacker in the Submissions table.
    --You must first delete all submissions related to that hacker (or update them) to remove the references.
    --Only then you can delete the hacker from the Hackers table without violating the foreign key constraint.
    


