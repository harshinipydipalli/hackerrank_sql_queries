select c.contest_id,hacker_id,name,
sum(t_s),sum(t_a_s),sum(t_v),sum(t_u_v)
from contests c
join colleges cg on c.contest_id=cg.contest_id
join challenges cl on cg.college_id=cl.college_id
left join (select challenge_id,sum(coalesce(total_views,0)) as t_v,
           sum(coalesce(total_unique_views,0)) as t_u_v
           from view_stats
           group by challenge_id
) as v_s
on  v_s.challenge_id=cl.challenge_id
left join(select challenge_id, sum(coalesce(total_submissions,0)) as t_s,
         sum(coalesce(total_accepted_submissions,0)) as t_a_s
         from submission_stats
         group by challenge_id) 
as s_s
on s_s.challenge_id=cl.challenge_id
group by 1,2,3
having sum(t_s)+sum(t_a_s)+sum(t_v)+sum(t_u_v)>0

order by c.contest_id asc
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
  why s_s.challenge_id=cl.challenge_id but not s_s.challenge_id=v_s.challenge_id because only if you view the challenges you can submit the challenges why not join matching rows of it
  💡 Why join both on cl.challenge_id and not s_s.challenge_id = v_s.challenge_id?
1. Relational Integrity:
The challenges table (cl) is the main anchor table.

view_stats and submission_stats are side data about the same challenge.

2. Join target is cl (not v_s):
You're joining both view and submission stats back to the main list of challenges.

If you did:

ON s_s.challenge_id = v_s.challenge_id
That would:

Only match submission stats if there is also a view stat (which violates LEFT JOIN's purpose).

Drop challenges that have submissions but no views — possibly incorrect depending on data quality.

3. LEFT JOIN preserves all challenges:
The goal is probably to get a full list of all challenges, even those:

That were never viewed (i.e., v_s.challenge_id IS NULL)

That were never submitted to (s_s.challenge_id IS NULL)

🔎 About your thought: "you can only submit if you view"
Logically true, but SQL doesn’t enforce this unless your data guarantees it.

Maybe some challenge got submissions via API or bulk tools and didn’t count as a "view".

Maybe views were tracked after submissions started.

The view_stats or submission_stats might be incomplete.

So, SQL joins don’t assume causality — they stick to what’s explicitly present in the data.

✅ Final takeaway:
sql
Copy
Edit
s_s.challenge_id = cl.challenge_id
is used to map submission data to each challenge, not necessarily depending on view data.

If you want to filter to only challenges that were viewed, you could add this after the joins:

sql
Copy
Edit
WHERE v_s.challenge_id IS NOT NULL

  then some times to join we use 1=1 doesnt this violate the data


ChatGPT said:
Excellent follow-up, Shuna! 👏

Let’s demystify the 1=1 join condition — when it’s used, why it doesn’t violate the data (in the right context), and when it can go wrong.

✅ What does 1 = 1 in a join mean?
sql
Copy
Edit
FROM table_a
JOIN table_b ON 1 = 1
This is a Cartesian Join (also called a Cross Join).

It means:

“Join every row of table_a with every row of table_b.”

✅ When is this valid and useful?
Controlled use, like:

Generating combinations (e.g., all dates × products)

Pivoting or simulating rows

Joining with a one-row table for defaults

Temporary table joining for calculations

Example:

sql
Copy
Edit
SELECT e.name, d.holiday_name
FROM employees e
JOIN holidays d ON 1=1
→ This gives every employee × every holiday, which might be what you want if you’re calculating leave eligibility for all dates.

❌ When does it go wrong?
When you accidentally use 1=1 instead of a real join condition, causing huge result sets (n × m rows).

If you forget a WHERE filter afterward, you might mess up totals or logic.

📌 Does it violate data?
No, not technically. SQL lets you do Cartesian joins — it assumes you know what you're doing.

But if you're expecting row alignment like a normal join, yes, logically, it could "violate" your intention.

🔥 Real-life danger example:
sql
Copy
Edit
SELECT c.name, o.order_id
FROM customers c
JOIN orders o ON 1=1
This will join every customer to every order → 💥 messy, slow, incorrect data.

✅ TL;DR
JOIN ON 1=1	Should you use it?
For generating all combinations?	✅ Yes
For actual data relationships?	❌ No
Accidental use in place of proper key join?	🔥 Big probl
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  why use left join for 
 we are uing left join because we are not leaving behind any challenges that are not assigned to colleges
we are getting all challenges irrepective of whether it is adssigned to college or not
 in case if it is not asssiged to any colleges, challenge would have no views and stats in this case left join is used
if the challenge_id is just created it would have no view or stats
even it is assigned to the company but no one has viewed yet - but for this it would get matched rows
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
"Why not just join everything and group by challenge_id at the end — won't it give the same result?"
Short answer:
❌ No, it won’t give the same result in most real-world cases.
🔥 Here’s why — the "Row Explosion Problem"
When you join multiple one-to-many relationships directly (without subqueries or aggregation), the number of rows multiplies.
📊 Example Scenario
Let’s say:
View_Stats has:
3 rows for challenge_id = 101
  | challenge\_id | total\_views |
| ------------- | ------------ |
| 101           | 10           |
| 101           | 5            |
| 101           | 3            |
Submission_Stats has:
4 rows for challenge_id = 101
  | challenge\_id | total\_submissions |
| ------------- | ------------------ |
| 101           | 2                  |
| 101           | 4                  |
| 101           | 6                  |
| 101           | 1                  |


If you join them directly (without subqueries), the database creates a cross join effect for matching keys:
  Since every row in View_Stats matches every row in Submission_Stats (same challenge_id), SQL creates all possible combinations
  | vs.total\_views | ss.total\_submissions |
| --------------- | --------------------- |
| 10              | 2                     |
| 10              | 4                     |
| 10              | 6                     |
| 10              | 1                     |
| 5               | 2                     |
| 5               | 4                     |
| 5               | 6                     |
| 5               | 1                     |
| 3               | 2                     |
| 3               | 4                     |
| 3               | 6                     |
| 3               | 1                     |

3 View_Stats rows × 4 Submission_Stats rows = 12 rows
This multiplies the totals — your SUM(total_views) and SUM(total_submissions) will be inflated because each value appears multiple times.
  and if you do sum it adds up all SUM(total_views) = (10+10+10+10 + 5+5+5+5 + 3+3+3+3) = 132 which is wrong
  instead of 10+5+3 =18 (correct)
  but if you do join in subquery then 
  o/p be for sum
  | challenge\_id | total\_views | total\_submissions |
| ------------- | ------------ | ------------------ |
| 101           | 18           | 13                 |
only if we want to do aggrgation like sum,min,max,count using subquery in join is Good praticse but if you want to join without any aggregation it gives same outp 
  as above of 12 rows so using subquery is redundant 
🛡 Why subqueries fix this:
With subqueries:

You aggregate once per challenge (one row per challenge)

Then join those single rows — no row multiplication

Your SUM() at the end is accurate

  🧩 When subqueries (or CTEs) become necessary:
When you need to summarize or filter data first before joining

To break complex logic into chunks

To avoid multiplication of rows (especially in SUM, AVG, COUNT situations)

When doing multi-level analytics or rankings
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
Your query:
  
FROM contests c 
JOIN colleges cl ON c.contest_id = cl.contest_id
JOIN challenges cg ON c.college_id = cg.college_id

Lets assume this table structure:
contests(contest_id, contest_name)

colleges(college_id, contest_id, college_name)

challenges(challenge_id, college_id, challenge_name)

Correct way to write the JOIN:

FROM contests c
JOIN colleges cl ON c.contest_id = cl.contest_id
JOIN challenges cg ON cl.college_id = cg.college_id

Explanation:
First JOIN: Get colleges that are linked to contests.

Second JOIN: Get challenges that are linked to those colleges.
-----------------------------------------------------------------------------------------------------------------------------------------------------------

🔍 Why not all challenges may have stats?
Because some challenges might not have received any views or submissions yet — especially if:
The contest was just created.
No one attempted the challenge.
Data entry in view_stats or submission_stats is missing for that challenge.

So the challenge exists in the challenges table, but there’s no matching row in the view_stats or submission_stats table — which means the JOIN would return NULL 
  for that challenge’s stats unless we use a LEFT JOIN.

🎯 Real-World Analogy
Think of:
challenges = list of all practice questions.
view_stats = how many students viewed them.
submission_stats = how many tried submitting answers.

Now:
Just because a question exists doesn’t mean a student viewed or submitted it.
So unless you left join, you will lose questions that were never touched.
