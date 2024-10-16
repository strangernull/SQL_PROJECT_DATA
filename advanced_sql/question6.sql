/**

Practice Problem 1
Question: Write a query to find the average salary both yearly (salary_year_avg) and hourly (salary_hour_avg) for job postings that were posted after June 1, 2023.
Group the results by job schedule type.

**/

SELECT *
FROM job_postings_fact
LIMIT 5

-- Practice
select  
    job_schedule_type,
    AVG(salary_hour_avg) avg_hour_salary,
    AVG(salary_year_avg) avg_year_salary
from
    job_postings_fact
where job_posted_date ::DATE > '2023-06-01'
group by
    job_schedule_type
LIMIT 10;

-- GPT:
SELECT 
    job_schedule_type,
    AVG(salary_hour_avg) AS avg_hoursalary,
    AVG(salary_year_avg) AS avg_yearsalary,
    MIN(job_posted_date::date) AS first_post_date  -- 显示最早的发布日期，所有未被聚合的列都必须出现在 GROUP BY 子句中
FROM 
    job_postings_fact
WHERE 
    job_posted_date::date > '2023-06-01'
GROUP BY 
    job_schedule_type
LIMIT 5;

/**

Practice Problem 2
Question: Write a query to count the number of job postings for each month in 2023,
adjusting the job_posted_date to be in 'America/New_York' time zone before extracting the month.
Assume the job_posted_date is stored in UTC. Group by and order by the month.

**/

select 
    EXTRACT(Month from (job_posted_date at time zone 'UTC' at time zone 'America/New_York')) as month_agg,
    count(job_id) as number_of_job
from 
job_postings_fact
where  
    EXTRACT(year from job_posted_date) = 2023
group by month_agg
order by month_agg desc
LIMIT 12



/**

Practice Problem 3
Question: Write a query to find companies (include company name) that have posted jobs offering health insurance, 
where these postings were made in the second quarter of 2023. Use date extraction to filter by quarter.

**/


select *
from job_postings_fact
LIMIT 2

select *
from company_dim
LIMIT 2

-- job_health_insurance, job_country, 

select
    j.job_country,
    c.name
from 
job_postings_fact j join company_dim c 
on j.company_id = c.company_id
where j.job_health_insurance = True and EXTRACT(quarter from j.job_posted_date) = 2 and EXTRACT(year from j.job_posted_date) = 2023
LIMIT 5


-- Note From Luke：Practice Problem 6:
/**
Create table from other tables：
？Question:
    Jan 2023 jobs,
    Feb 2023 jobs,
    Mar 2023 jobs
**/



