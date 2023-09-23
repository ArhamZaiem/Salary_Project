select *
from companies

select *
from salaries

select *
from functions

select *
from employees

select *
into emp_dataset
from salaries
left join companies
on salaries.comp_name = companies.company_name
left join functions
on salaries.func_code = functions.function_code
left join employees
on salaries.employee_id = employees.employee_code_emp

select *
from emp_dataset


select CONCAT (employee_id, cast (date as date)) as id
, cast (date as date) pay_month
, employee_id
, employee_name
, (GEN_M_F)
, age
, salary
, function_group
, company_name
, company_city
, company_state
, company_type
, const_site_category
into df_employee
from emp_dataset

select *
from df_employee

sp_rename 'df_employee.GEN_M_F', 'gender', 'column'

update df_employee
set id = ltrim(rtrim(id))
, pay_month = ltrim(rtrim(pay_month))
, employee_id = ltrim(rtrim(employee_id))
, employee_name = ltrim(rtrim(employee_name))
, gender = ltrim(rtrim(gender))
, age = ltrim(rtrim(age))
, salary = ltrim(rtrim(salary))
, function_group = ltrim(rtrim(function_group))
, company_name = ltrim(rtrim(company_name))
, company_city = ltrim(rtrim(company_city))
, company_state = ltrim(rtrim(company_state))
, company_type = ltrim(rtrim(company_type))
, const_site_category = ltrim(rtrim(const_site_category))

select *
from df_employee
where id is null
or pay_month is null
or employee_id is null
or employee_name is null
or gender is null
or age is null
or salary is null
or function_group is null
or company_name is null
or company_city is null
or company_state is null
or company_type is null
or const_site_category is null

select count(*) missing_salary_count 
from df_employee
where salary is null

select count(*) missing_const_site_category_count
from df_employee
where const_site_category is null

delete from df_employee
where salary is null
delete from df_employee
where const_site_category is null

select * from df_employee


select distinct(gender)
from df_employee 

update df_employee
set gender = (case gender 
when 'M' then 'Male'
when 'F' then 'Female'
else 'gender'
end)


select distinct(const_site_category)
from df_employee 

update df_employee
set const_site_category = 'Commercial'
where const_site_category = 'Commerciall'
  
select distinct(company_state)
from df_employee

update df_employee
set company_state = 'Goias'
where company_state = 'GOIAS'


select distinct(id), count(id) duplicates
from df_employee
group by id
having count(id) > 1 


with cte as 
(select *,
row_number()
over(
partition by pay_month, employee_id
order by employee_id) row_num
from df_employee)
delete from cte where row_num > 1


--DATA EXPLORATORY ANALYSIS

--1. Finding out whether the average salary is increasing or decreasing after the month of Januray, 2022

select pay_month
, round(avg(salary),2) average_salary
, case
when avg(salary) > (select avg(salary)
from df_employee
where pay_month = '2022-01-01') then 'Increased'
when avg(salary) < (select avg(salary)
from df_employee
where pay_month = '2022-01-01') then 'Decreased'
else 'Base_month' 
end salary_category
from df_employee 
group by pay_month
order by pay_month

--2. How effective is the HR program to reduce the gender gap

select gender, count(gender) gender_count
from df_employee
group by gender

--3. How is the salary distributed across the states

select company_state
, count(id)
, min(salary) min_salary
, max(salary) max_salary
, round(avg(salary), 2) as average_salary
from df_employee
group by company_state


--4. What is our spending on each Function Group

select function_group, sum(salary) salary_provided_to_each_group
from df_employee
group by function_group
order by 2 desc

--5. On what construction site are we spending the most

select top 1 const_site_category
, sum(salary) const_site_spending_the_most_salary
from df_employee
group by const_site_category
order by 2 desc

