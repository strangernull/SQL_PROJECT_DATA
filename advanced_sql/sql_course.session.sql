SELECT * FROM job_postings_fact
LIMIT 100;


SELECT job_posted_date
FROM job_postings_fact
LIMIT 10;

-- Handling Date:
-- ::Date        :将 TIMESTAMP 数据类型转换为 DATE，移除时间部分，只保留日期。
-- AT TIME ZONE  :将 TIMESTAMP 转换为指定时区的时间。这在不同地理位置间处理时间戳时特别有用。
-- EXTRACT       :从 DATE 或 TIMESTAMP 中提取特定的日期部分（如年、月、日、小时等）。
-- AGE()         :计算两个日期之间的差异，返回年、月、日的格式。SELECT AGE('2024-10-09', '2022-10-09');
-- DATE_PART()   :类似于 EXTRACT. SELECT DATE_PART('year', '2024-10-09'::DATE);
-- INTERVAL      :用于表示时间间隔，可以与日期进行加减操作。SELECT '2024-10-09'::DATE + INTERVAL '1 day';
-- TO_CHAR()     :将 DATE 或 TIMESTAMP 转换为指定格式的字符串。 SELECT TO_CHAR(NOW(), 'YYYY-MM-DD');

/**

SELECT timestamp_column::DATE AS date_column
FROM table_name;

:: used for casting, which means converting a value from one data type to another ,
you can use it to convert a host of different data types

eg: SELECT '2023-02-19'::DATE, '123'::INTEGER, 'true'::BOOLEAN, '3.14'::REAL;
将字符串 '2023-02-19' 转换为 DATE
将字符串 '123' 转换为整数
将字符串 'true' 转换为布尔值
将字符串 '3.14' 转换为浮点数
**/

SELECT '2023-09-25'::DATE;

SELECT 
    job_title_short as title,
    job_location as lcoation,
    job_posted_date ::DATE as date
from job_postings_fact
LIMIT 20

/**
SELECT timestamp_column AT TIME ZONE '时区名称'
FROM table_name;

AT TIME ZONE - converts timestamps between different time zones: 
It can be used on timestamps with or without time zone information

将 TIMESTAMP 转换为指定时区：
    SELECT '2024-10-09 15:30:00' AT TIME ZONE 'UTC';
将 TIMESTAMP WITH TIME ZONE 转换为 UTC：
    SELECT '2024-10-09 15:30:00+02' AT TIME ZONE 'UTC';

**/

SELECT 
    job_title_short as title,
    job_location as lcoation,
    job_posted_date at time zone 'EST' as date_time
from job_postings_fact
LIMIT 20

SELECT 
    job_title_short as title,
    job_location as lcoation,
    job_posted_date at time zone 'UTC' at time zone 'EST' as date_time
from job_postings_fact
LIMIT 20

/**
SELECT 
    EXTRACT(part FROM column_name) AS new_column_name
FROM 
    table_name;

**/

SELECT 
    job_title_short as title,
    job_location as lcoation,
    job_posted_date at time zone 'UTC' at time zone 'EST' as date_time,
    EXTRACT (Month FROM job_posted_date) as date_month
from job_postings_fact
LIMIT 20

-- count how many job IDS for each month
select 
    count(job_id),
    EXTRACT (Month FROM job_posted_date) as date_month
from job_postings_fact
group by date_month;

-- I only care about data analyst roles:
select 
    count(job_id) as job_posted_count,
    EXTRACT (Month FROM job_posted_date) as date_month
from job_postings_fact
where job_title_short = 'Data Analyst'
group by date_month
order by job_posted_count;


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

-- January
CREATE TABLE january_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

-- February
CREATE TABLE february_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

-- March
CREATE TABLE march_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

-- Test:

select * from january_jobs LIMIT 5;

-- CASE Expression in SQL: A CASE expression in SQL allows you to apply conditional logic within a SELECT query, 
-- similar to an IF-ELSE structure in programming languages.
/**

SELECT
    CASE
        WHEN column_name = 'Value1' THEN 'Description for Value1'
        WHEN column_name = 'Value2' THEN 'Description for Value2'
        ELSE 'Other'
    END AS column_description
FROM
    table_name;

CASE: This begins the case expression.
WHEN: Specifies the condition that will be evaluated. If this condition is TRUE, the corresponding THEN part is executed.
THEN: Specifies the result that will be returned if the condition in the WHEN clause is met (i.e., the condition is TRUE).
ELSE (optional): Specifies the default result if none of the WHEN conditions are met.
END: This concludes the CASE expression.
AS column_description: This is the alias that assigns a name to the output column resulting from the CASE expression.
**/

-- Test:

select 
    job_location,
    job_title_short,
    CASE    
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
from
    job_postings_fact
-- WHERE location_category = 'Local'; ！ 错误：不能直接在 WHERE 子句中使用 SELECT 子句中定义的别名；WHERE 子句的执行顺序在 SELECT 之前，因此在 WHERE 执行时，location_category 这个别名还不存在。

select 
    count(job_id),
    CASE
        when job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END as location_category
from job_postings_fact
where job_title_short = 'Data Analyst'
group by location_category;

-- CASE WHEN Practice Problem:
/**
Practice Problem 1 Summary:

Question Description:
You want to categorize the salaries for each job posting to see if they fit your desired salary range. The specific requirements are:

Put salary into different buckets.
Define what constitutes high, standard, or low salary based on your own conditions.
Why do this? It helps you easily determine which job postings are worth looking at based on salary. Bucketing is a common practice in data analysis when viewing categories.
Only focus on data analyst roles.
Order the results from highest to lowest salary.

Approach:

Use the CASE WHEN statement in SQL to categorize salaries.
Use a WHERE clause to filter for "Data Analyst" positions.
Finally, use ORDER BY to sort the results by salary from highest to lowest.
SQL Syntax Used:

CASE: Starts the conditional logic expression.
WHEN: Specifies the condition that triggers the following result.
THEN: The result or action to return when the condition is met.
ELSE: Defines a default result if none of the conditions are met.
END: Concludes the CASE expression.
ORDER BY: Sorts the results by salary in descending order.

**/

select * from job_postings_fact LIMIT 5;

select *
from(
    select
        job_title_short,
        salary_year_avg,
        
        case
            WHEN salary_year_avg > 200000 THEN 'Hign Salary'
            WHEN salary_year_avg between 123268 and 200000 THEN 'Standard Salary'
            ELSE 'Low salary'
        END as job_category
    from
    job_postings_fact
    where job_title_short = 'Data Analyst'
    -- order by salary_year_avg
)
where job_category = 'Standard Salary'


select
    max(salary_year_avg),
    MIN(salary_year_avg),
    avg(salary_year_avg)

from job_postings_fact

-- Subqueries and CTEs:
-- Subqueries and Common Table Expressions (CTEs) are used for organizing and simplifying complex queries.

-- Purpose: Helps break down the query into smaller, more manageable parts.
-- When to use one over the other?

-- Subqueries: Are better suited for simpler queries. 子查询（Subqueries）：适用于较简单的查询。
-- CTEs: Are more appropriate for more complex queries. CTE（公共表表达式）：适用于更复杂的查询。
 
 /**
Subqueries:
A Subquery is a query nested inside a larger query. It can be used in the SELECT, FROM, and WHERE clauses to simplify or modularize complex queries.

Key Points:

Subqueries can help break down complex logic by embedding one query within another.
They are commonly used to calculate intermediate results or filter data before the outer query is executed.
 **/

select *
from
    (
        select 
    *
from    
    job_postings_fact
where EXTRACT(month from job_posted_date) = 1
    ) as january_jobs01;

/**
Common Table Expressions (CTEs):
A Common Table Expression (CTE) defines a temporary result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement.

Defined with WITH: A CTE starts with the WITH keyword, followed by the name of the CTE, and the query that defines it.

**/

with january_jobs02 as (
    select *
    from job_postings_fact
    where EXTRACT(month from job_posted_date) = 1
)

select * from january_jobs02;

--
select
    name as company_name,
    company_id
from
    company_dim
where 
    company_id in (
        select
        company_id
        -- job_no_degree_mention
        from job_postings_fact
        where job_no_degree_mention = true
        order by company_id
    );
/**
    IN字句只能接受单列（一个值）进行比较，不能直接处理多列或者多个值组合。

    SELECT column_name
    FROM table_name
    WHERE column_name IN (SELECT single_column FROM another_table);

    IN字句无法处理多列比较，所以会出现语法错误。：
    SELECT column_name
    FROM table_name
    WHERE (column1, column2) IN (SELECT column1, column2 FROM another_table); -- 错误

    处理多列条件的替代方案：
    使用EXISTS：你可以使用EXISTS来代替IN，用于多列的条件比较。
    使用JOIN：你也可以通过表连接（JOIN）来实现多列的比较。

    
**/

-- 使用EXISTS来检查job_postings_fact表中是否存在company_id匹配 且job_no_degree_mention为true的记录。
SELECT
    name AS company_name,
    company_id
FROM
    company_dim cd
WHERE
    EXISTS (
        SELECT 1 -- 在EXISTS查询中，SELECT 1 更高效，因为数据库不需要解析和返回完整的行数据。SELECT 1 只返回一个简单的值来确认是否有记录存在。
        FROM job_postings_fact jpf
        WHERE jpf.company_id = cd.company_id
        AND jpf.job_no_degree_mention = true
    );

/**
区别：
IN：
子查询返回的结果是一个列表（如 company_id），然后外部查询检查 company_dim 表中的 company_id 是否在这个列表中。
适用于子查询返回单列的情况。

EXISTS：
EXISTS 只是检查是否存在符合条件的记录，内部子查询不需要返回具体的值。它更关注是否有匹配的行。
**/

--CTEs - Common Table Expression
-- Notes:

-- CTE - A temporary result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement.
-- Exists only during the execution of a query. 只在查询执行期间存在，并且可以在主查询或其他CTE中引用。
-- It's a defined query that can be referenced in the main query or other CTEs.
-- WITH - used to define CTE at the beginning of a query.


-- example：
WITH january_jobs AS (  -- CTE definition starts here
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
)  -- CTE definition ends here

SELECT *
FROM january_jobs;

/*
Find the companies that have the most job openings.
- Get the total number of job postings per company id
- Return the total number of jobs with the company name
*/

-- test:
select * from company_dim LIMIT 2; -- company_id, name, link, link_goolge
select * from job_postings_fact LIMIT 2; --
-- test(mine):
select 
    count(*) as total_jobs,
    cd.name as company_name
from 
    company_dim cd left join job_postings_fact jf on cd.company_id = jf.company_id
group by cd.company_id;

-- Luke's code:

with company_job_count as(
    select
    count(*) as total_jobs,
    company_id
    from
    job_postings_fact
    group by company_id
    )

select c.name as company_name,
       cjc.total_jobs
from company_dim c left join company_job_count cjc on c.company_id = cjc.company_id
order by cjc.total_jobs desc;

/**
Practice Problem 1
❓Question: Identify the top 5 skills that are most frequently mentioned in job postings.
Use a subquery to find the skill IDs with the highest counts in the skills_job_dim table 
and then join this result with the skills_dim table to get the skill names.

🔍 Hints:
💡 Solution:
📝 Result:
**/

select * from skills_job_dim limit 2; -- job_id, skill_id
select * from skills_dim limit 2; -- skill_id, skills, type
-- Solution:
select
    sd.skills,
    skill_count_table.skill_count
from
    skills_dim sd
join
(
    select 
        skill_id,
        count(*) as skill_count 
    from skills_job_dim
    group by skill_id
    order by skill_count desc
    limit 5
) as skill_count_table
on sd.skill_id = skill_count_table.skill_id;

-- Solution2:

with skill_count_table as (
    select 
        count(*) as skill_count,
        skill_id
    from 
        skills_job_dim
    group by skill_id
    order by skill_count desc
    limit 5
)
select 
    sd.skills,
    sct.skill_count
from skill_count_table sct
left join skills_dim sd on sct.skill_id = sd.skill_id;

/**
Practice Problem 2
❓Question: Determine the size category ('Small', 'Medium', or 'Large') 
for each company by first identifying the number of job postings they have. 
Use a subquery to calculate the total job postings per company. 
A company is considered 'Small' if it has less than 10 job postings, 'Medium' if the number of job postings is between 10 and 50, and 'Large' if it has more than 50 job postings. 
Implement a subquery to aggregate job counts per company before classifying them based on size.

🔍 Hints:
💡 Solution:
📝 Result:
**/

select * from  company_dim limit 2 -- company_id, name, link, link_google, thumbnail

select * from job_postings_fact limit 1; 
-- job_id, company_id, job_title_short, job_title, job_location, job_via, job_schedule_type, job_work_from_home, search_location, job_posted_date, job_no_degree_mention..


-- CTE（Common Table Expression：
WITH job_count_table AS (
    SELECT 
        COUNT(jpf.job_id) AS job_count,  -- Use COUNT(jpf.job_id) to ensure correct counting
        cd.company_id,
        cd.name
    FROM 
        company_dim cd 
    LEFT JOIN 
        job_postings_fact jpf 
        ON cd.company_id = jpf.company_id
    GROUP BY 
        cd.company_id,
        cd.name
)

select
    company_id,
    name,
    job_count,
    case
        when job_count < 10 then 'small'
        when job_count between 10 and 50 then 'medium'
        ELSE 'large'
    end as size_category
from job_count_table;

-- subquery:

SELECT 
    cd.company_id, 
    cd.name, 
    job_counts.job_count,
    CASE 
        WHEN job_counts.job_count < 10 THEN 'Small'
        WHEN job_counts.job_count BETWEEN 10 AND 50 THEN 'Medium'
        ELSE 'Large'
    END AS size_category
FROM 
    company_dim cd
LEFT JOIN (
    SELECT 
        company_id, 
        COUNT(job_id) AS job_count
    FROM 
        job_postings_fact
    GROUP BY 
        company_id
) AS job_counts
ON cd.company_id = job_counts.company_id;

-- Problem 7:
/**
    Problem Statement:

    Find the count of the number of remote job postings per skill. 没种技能对应的远程工作的数量
    Display the top 5 skills by their demand in remote jobs. 远程工作里 需求最高的5种技能
    Include skill ID, name, and count of postings requiring the skill.  展示：skill ID, name, 该技能的需求数量
**/

select * from skills_dim limit 1; --skill_id, skills, type
select * from skills_job_dim limit 1; -- job_id , skill_id
select * 
from job_postings_fact
where job_work_from_home = True
limit 10; -- job_id,company_id

--test:

select * 
from  job_postings_fact
where job_work_from_home = True
limit 5

select 
    sd.skill_id,
    sd.skills,
    count(*) as skill_count
from
skills_dim as sd
inner join (
    select *
    from   skills_job_dim as sjd
    inner join job_postings_fact as jpf 
    on sjd.job_id = jpf.job_id
    where jpf.job_work_from_home = True and jpf.job_title_short = 'Data Analyst'
) as remote_job_table 
on sd.skill_id = remote_job_table.skill_id
group by sd.skill_id,  sd.skills
order by skill_count desc
limit 5


-- GPT:
SELECT 
    sd.skill_id, 
    sd.skills, 
    COUNT(*) AS skill_count
FROM 
    skills_dim sd
INNER JOIN (
    SELECT 
        sjd.skill_id 
    FROM 
        skills_job_dim sjd
    INNER JOIN 
        job_postings_fact jpf 
        ON sjd.job_id = jpf.job_id
    WHERE 
        jpf.job_work_from_home 
) AS remote_job_table 
ON 
    sd.skill_id = remote_job_table.skill_id
GROUP BY 
    sd.skill_id, sd.skills
ORDER BY 
    skill_count DESC
LIMIT 5;


--Luke's code:

with remote_job_skills as(
select 
        skd.skill_id,
        count(*) as skill_count
from skills_job_dim skd 
inner join job_postings_fact jpf
on skd.job_id = jpf.job_id
where jpf.job_work_from_home = True and jpf.job_title_short = 'Data Analyst'
group by skd.skill_id
)

select 
    rjs.skill_id,
    sd.skills,
    rjs.skill_count 
from remote_job_skills as rjs
inner join skills_dim as sd
on rjs.skill_id = sd.skill_id
order by rjs.skill_count desc
limit 5;

-- Union:
/**

UNION Operators
Combine result sets of two or more SELECT statements into a single result set.

UNION: Remove duplicate rows
UNION ALL: Includes all duplicate rows

⚠️ Note: Each SELECT statement within the UNION must have the same number of columns in the result sets 
with similar data types.
**/


/**
1. 代码功能：

该查询使用 UNION 操作符，将 一月（january_jobs）和二月（february_jobs）的职位信息合并为一个结果集。
去重：如果一月和二月的数据中有重复的职位记录，UNION 只会保留一次该记录。

**/
-- Get jobs and companies from January
SELECT 
    job_title_short,
    company_id,
    job_location
FROM 
    january_jobs

UNION

-- Get jobs and companies from February
SELECT 
    job_title_short,
    company_id,
    job_location
FROM 
    february_jobs;


/**
Extracted Text for Notes:
🤝 UNION ALL

📝 Notes:

UNION ALL – combine the result of two or more SELECT statements.
They need to have the same amount of columns, and the data type must match.所有行都会保留，包括重复的行。

2. 使用 UNION ALL 的规则：

列数必须相同：
每个 SELECT 语句返回的列数量必须一致。
数据类型必须匹配：
对应位置的列必须是相同或兼容的数据类型。
**/

-- Union Problem:
/**
UNION Operators - Practice Problem 1

Practice Problem 1

❓ Question:

Get the corresponding skill and skill type for each job posting in Q1.
Include those without any skills, too.
Why? Look at the skills and the type for each job in the first quarter that has a salary > $70,000.
**/

with q1_job_table as(
    select 
        job_id,
        salary_year_avg,
        job_title_short
    from january_jobs

    Union

    select 
        job_id,
        salary_year_avg,
        job_title_short
    from february_jobs

    Union

    select
        job_id,
        salary_year_avg,
        job_title_short
    from march_jobs
)

select 
    skills_dim.skills,
    skills_dim.type,
    q1_job_table.salary_year_avg
from q1_job_table 
inner join skills_job_dim
on q1_job_table.job_id =  skills_job_dim.job_id
inner join skills_dim
on skills_dim.skill_id = skills_job_dim.skill_id
WHERE q1_job_table.salary_year_avg > 70000
order by q1_job_table.salary_year_avg desc
limit 5

-- Problem 8:
/**
    Find job postings from the first quarter that have a salary greater than $70K  
    – Combine job posting tables from the first quarter of 2023 (Jan–Mar)  
    – Gets job postings with an average yearly salary > $70,000
**/

select *
from(
    select 
        *
    from january_jobs
    Union all
    select
        *
    from february_jobs
    Union all
    select 
        *
    from march_jobs
)
limit 5 -- job_posted_date


with q1_job_info as (
    select 
        *
    from january_jobs
    Union all
    select
        *
    from february_jobs
    Union all
    select 
        *
    from march_jobs
)

select 
    *
    -- EXTRACT(year from job_posted_date) as year_select，EXTRACT() 函数的结果不会直接作为新列名保存在数据集中。具体来说，WHERE 子句不能识别在 SELECT 子句中临时计算的列（如 year_select）。
from q1_job_info
where EXTRACT(year from job_posted_date) = 2023 and q1_job_info.salary_year_avg > 70000 and q1_job_info.job_title_short = 'Data Analyst'
order by q1_job_info.salary_year_avg desc;

-- Luke's code:

SELECT 
    job_title_short,
    job_location,
    job_via,
    job_posted_date::DATE,  -- 确保日期字段类型正确
    salary_year_avg
FROM (
    SELECT * FROM january_jobs
    UNION ALL
    SELECT * FROM february_jobs
    UNION ALL
    SELECT * FROM march_jobs
) AS quarter1_job_postings
WHERE 
    salary_year_avg > 70000 
    AND job_title_short = 'Data Analyst'
ORDER BY 
    salary_year_avg DESC;






