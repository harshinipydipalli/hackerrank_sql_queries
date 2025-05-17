with cte as(
select name,
case
when marks between 0 and 10 then 1
when marks between 10 and 19 then 2
when marks between 20 and 29 then 3
when marks between 30 and 39 then 4
when marks between 40 and 49 then 5
when marks between 50 and 59 then 6
when marks between 60 and 69 then 7
when marks between 70 and 79 then 8
when marks between 80 and 89 then 9
when marks between 90 and 100 then 10

end as grade, marks

from students )

select
case when grade>=8 then name
else null
end as passed_name , grade,marks
from cte
order by grade desc,passed_name asc , marks asc;
