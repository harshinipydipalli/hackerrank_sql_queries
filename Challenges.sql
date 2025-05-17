Goal of the Query:
You want to display:

✅ All hackers who created the maximum number of challenges.

✅ Hackers whose number of challenges is unique (i.e., no one else has the same number).

You want to exclude:

❌ Hackers who have a challenge count that is not max and is shared by others.
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

WITH challenge_counts AS (
    SELECT 
        h.hacker_id, 
        h.name, 
        COUNT(c.challenge_id) AS total_challenges
    FROM hackers h
    JOIN challenges c ON h.hacker_id = c.hacker_id
    GROUP BY h.hacker_id, h.name
),
max_challenges AS (
    SELECT MAX(total_challenges) AS max_count
    FROM challenge_counts
),
challenge_freq AS (
    SELECT 
        total_challenges, 
        COUNT(total_challenges) AS count_of_users
    FROM challenge_counts
    GROUP BY total_challenges
)
SELECT 
    cc.hacker_id, 
    cc.name, 
    cc.total_challenges
FROM challenge_counts cc
JOIN challenge_freq cf ON cc.total_challenges = cf.total_challenges
JOIN max_challenges mc ON 1=1

-- This' JOIN max_challenges mc ON 1=1'  is a trick or shortcut to join two tables without any specific matching condition — in other words, it's like saying:
-- “Just attach this table to every row without filtering.”
--You’re joining the single-row max_challenges CTE to every row of the challenge_counts table.

/*✅ Why not join ON cc.total_challenges = mc.max_count?
Because you want to include not just the max count hackers, but also other hackers with unique challenge counts.
So you don't filter the join — you use the value in the WHERE clause */

WHERE 
    cc.total_challenges = mc.max_count  -- always include max creators (keep all max)
    OR cf.count_of_users = 1                      -- include unique counts only (keep if only one hacker has that count)
-- for where why not just use  number_of_challenges_created > max_challenge and number_of_users>1  include
-- because
--If two students created 4 challenges each, and the max is 6, exclude them.
--If two students created 6 challenges each, and 6 is the max, include them.
ORDER BY cc.total_challenges DESC, cc.hacker_id;
