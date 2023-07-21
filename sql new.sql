---Q1---
select
market
from dim_customer
where region='apac'and customer='Atliq Exclusive';

---Q2---
WITH yearly_counts AS (
  SELECT
    f.fiscal_year,
    COUNT(DISTINCT d.product_code) AS uniq_product
  FROM
    gdb023.fact_gross_price d
  JOIN
    fact_gross_price f ON d.product_code = f.product_code
  WHERE
    f.fiscal_year IN (2020, 2021)
  GROUP BY
    f.fiscal_year
)
SELECT
  curr.fiscal_year,
  curr.uniq_product AS uniq_product2021,
  prev.uniq_product AS uniq_product2020,
  ((curr.uniq_product - prev.uniq_product) / prev.uniq_product) * 100 AS percentage_change
FROM
  yearly_counts curr
JOIN
  yearly_counts prev ON curr.fiscal_year = 2021 AND prev.fiscal_year = 2020

  
  ---Q3---
  SELECT 
segment,
count(product) as product_count
FROM
 gdb023.dim_product
group by
 segment
order by
 product_count desc;

---Q4---

with cte1 as 
(SELECT
d.segment,
count(d.product) as product_count_21 
 FROM dim_product d
 join fact_gross_price g
 on d.product_code=g.product_code
 where fiscal_year=' 2021'
 group by d.segment
 order by product_count_21  desc),
 cte2 as 
 ( SELECT
d.segment,
count(d.product) as product_count_20 
 FROM dim_product d
 join fact_gross_price g
 on d.product_code=g.product_code
 where fiscal_year='2020'
 group by d.segment
 order by product_count_20  desc)
 
 select 
 c.segment,
 c.product_count_21,
 d.product_count_20,
  (c.product_count_21-d.product_count_20) as difference
  from cte1 c
join cte2 d
on c.segment=d.segment
group by  
 c.segment,
 c.product_count_21,
 d.product_count_20
 order by difference desc
 
  ---Q5---
  
WITH cte AS (
    SELECT
        d.product,
        d.product_code,
        f.manufacturing_cost,
        ROW_NUMBER() OVER (ORDER BY f.manufacturing_cost DESC) AS rn_highest,
        ROW_NUMBER() OVER (ORDER BY f.manufacturing_cost ASC) AS rn_lowest
    FROM
        dim_product d
        join fact_manufacturing_cost f 
        on d.product_code=f.product_code
)
SELECT
    product_code,
    product,
    manufacturing_cost
FROM
    cte
WHERE
     rn_lowest = 1 or rn_highest = 1
     order by manufacturing_cost desc



---Q6---


select 
  d.customer_code,
  d.customer, 
   round(avg(f.pre_invoice_discount_pct),2) as avg_cus_disc
from 
    dim_customer d 
join 
    fact_pre_invoice_deductions f
on
    d.customer_code=f.customer_code
where 
    f.fiscal_year='2021' 
and
    d.market='india'
group by 
d.customer_code,
d.customer
order by 
avg_cus_disc desc
limit 5;


---Q7---
WITH cte1 AS (
  SELECT
    MONTHNAME(f.date) AS month,
    f.fiscal_year AS year,
    g.gross_price * f.sold_quantity AS Gross_sales_Amount
  FROM
    gdb023.dim_customer AS d
    JOIN fact_sales_monthly AS f ON d.customer_code = f.customer_code
    JOIN fact_gross_price AS g ON f.fiscal_year = g.fiscal_year
  WHERE
    d.customer = 'Atliq Exclusive'
  GROUP BY
  MONTH,YEAR,GROSS_SALES_AMOUNT
)
SELECT
  CONCAT(month, '/', year) AS month_year,
  SUM(Gross_sales_Amount) AS Gross_sales_Amount
FROM
  cte1
GROUP BY
  month,
  year
ORDER BY
  Gross_sales_Amount DESC;
  
  ---Q8---
  
  SELECT
     quarter(date) as quarter, 
     sum(sold_quantity) as total_sold_quantity
FROM
      gdb023.fact_sales_monthly
where 
     fiscal_year='2020'
group by 
   quarter
order by 
    total_sold_quantity desc

---Q9---

WITH cte1 AS (
    SELECT 
        d.channel,
        SUM(g.gross_price * f.sold_quantity) AS gross_sales_mln
    FROM 
        dim_customer d
    JOIN 
        fact_sales_monthly f ON d.customer_code = f.customer_code
    JOIN 
        fact_gross_price g ON f.product_code = g.product_code
    WHERE 
        g.fiscal_year = '2021'
    GROUP BY 
        d.channel
),
cte2 AS (
    SELECT 
        SUM(g.gross_price * f.sold_quantity) AS total_sales
    FROM 
        fact_gross_price g
    JOIN 
        fact_sales_monthly f ON g.product_code = f.product_code
    WHERE 
        g.fiscal_year = '2021'
)
SELECT 
    cte1.channel,
    ROUND(cte1.gross_sales_mln, 2) AS gross_sales_mln,
    ROUND((cte1.gross_sales_mln / cte2.total_sales) * 100, 2) AS percentage
FROM 
    cte1
JOIN 
    cte2
    on 1=1
ORDER BY 
    cte1.gross_sales_mln DESC
    limit 1
    
    
    ---Q10---
    
    with cte1 as 
(SELECT 
 d.division,
 d.product_code,
 d.product,
sum(f.sold_quantity) as total_sold_quantity,
dense_rank() over(partition by d.division order by sum(f.sold_quantity) desc) as rank_order
from 
dim_product d
join 
fact_sales_monthly f
on 
d.product_code=f.product_code
 where 
 f.fiscal_year='2021'
 group by  
 d.division,
 d.product_code,
 d.product
 order by 
 total_sold_quantity desc)
 
 select division,product_code,
 product,total_sold_quantity,rank_order
 from cte1
 where rank_order<=3
 order by division,total_sold_quantity desc
