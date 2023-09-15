with calendar_filtered as (
select 
date as reporting_date
from schema.calendar 
where date(date) >= (select min(date(created_at)) from schema.with_start_and_stop_dates)
and date <= current_date()
)

--generate a tables numbers
,cohort_30d_aging_bin as (
select 
n as cohort_30d_aging_bin from  schema.numbers where mod(n, 30) = 0 
)

,staging as (
select 
name,
id,
reporting_date,
date(created_at) as approximate_start_date,
case when end_date is null then current_date() else end_date end as end_date_or_current_date
from schema.with_start_and_stop_dates, calendar_filtered cf
)

,final as (
select 
*, 
date_diff(reporting_date,approximate_start_date,day) as days_active
from staging
where reporting_date between approximate_start_date and end_date_or_current_date
order by name, reporting_date
)

select 
s.*
from final s 
inner join cohort_30d_aging_bin cab on s.days_active = cab.cohort_30d_aging_bin
order by s.days_active
