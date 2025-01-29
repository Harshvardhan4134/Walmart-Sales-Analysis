select * from walmart_sales

---problem statement 1 find the different payment methods and transaction

select payment_method,
count(*) as trans
from walmart_sales
group by payment_method

---problem statement 2 find the highest rating category displaying each branch and avg rating

select * from
(
select branch,
       category,
	   avg(rating) as avg_rating,
	   rank() over (partition by branch order by avg (rating)desc) as rank
from walmart_sales
group by branch, category
order by 1,3 desc 
) 
where rank = 1

---- problem statement 3 find the busiest day for each branch by the number of transactions

select 
branch,
to_char(to_date(date, 'dd-mm-yy'), 'day') as formatted_day,
count(*) as no_of_trans
from walmart_sales
group by branch, formatted_day
order by branch, no_of_trans desc

--- problem statement 4 list out the total quantity sold per the payment method

select payment_method,
-- count(*) 
sum(quantity) as qty_sold
from walmart_sales
group by payment_method

--- problem statement 5 determine the average rating, min rating and max rating of category for each city

select 
city,
category,
avg(rating) as avg_rating,
min(rating) as min_rating,
max(rating) as max_rating
from walmart_sales
group by city, category

---problem statement 6 calculate the total profit for each category by considering total_profit as
--- (unit_profit * quantity * profit margin). list category and profit margin, order from highest to lowest

select 
category,
sum(total) as total_revenue,
sum(total * profit_margin) as profit 
from walmart_sales
group by category

--- problem statement 7 determine the common payment method for each branch, display branch and preferred payment method

with cte
as
(
select 
branch,
payment_method,
count(*) as total_trans,
rank()over (partition by branch order by count(*) desc) as rank
from walmart_sales 
group by branch, payment_method
)
select * from cte where rank = 1

--- problem statement 8 categorize  sales into 3 groups mrng, aftrn, eveng, find which of the shift and number of invoices

select 
branch,
case 
when extract (hour from (time::time)) < 12 then'morning'
when extract (hour from (time::time)) between 12 and 16 then 'afternoon'
else 'evening'
end day_time,
count(*)
from walmart_sales
group by 1, 2
order by 1,3 desc

--- problem statement 9 identify 5 branch with highest decrease ratio from last year (current year 2023 to last year 2022)
--- revenue decrease ratio = last yr revenue-current yr rev/last rev*100


SELECT 
    *, 
    EXTRACT(YEAR FROM TO_DATE(date, 'dd-mm-yy')) AS fr_year
FROM walmart_sales;


with revenue_2022
as
(
select branch,
sum(total) as revenue
from walmart_sales
where extract(year from to_date(date, 'dd-mm-yy')) = 2022
group by 1
), 

revenue_2023
as
(
select branch,
sum(total) as revenue
from walmart_sales
where extract(year from to_date(date, 'dd-mm-yy')) = 2023
group by 1
)

select 
ls.branch,
ls.revenue as last_yr_revenue,
cs.revenue as cr_yr_revenue,
round((ls.revenue - cs.revenue)::numeric/ls.revenue::numeric * 100, 2) as rev_dec_ratio
from revenue_2022 as ls
join
revenue_2023 as cs
on ls.branch = cs.branch
where ls.revenue > cs.revenue
order by 4 desc
limit 5


