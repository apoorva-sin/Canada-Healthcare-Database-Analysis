-- 1. 
drop procedure claim_app;
delimiter $$
create procedure claim_app (
	in id int,
	out ans varchar(100)
)

begin
	declare avgg decimal(10,2);
	declare curr_count int;
	
	with t as 
	(
		select count(claimID) as countt from claim join treatment using (claimID) group by diseaseID
	)
	select avg(countt) into avgg from t;
	
	select count(claimID) into curr_count from claim join treatment using (claimID) where diseaseID = id;

	set ans = if(curr_count > avgg, 'Claimed Higher than Average', 'Claimed Lower than Average');	
end $$ 

delimiter ;

call claim_app(5, @ans);
select @ans;

-- 2.

drop procedure joseph_app;
delimiter $$
create procedure joseph_app (
    in id int,
    out disease_name varchar(100),
    out number_of_male_treated int,
    out number_of_female_treated int,
    out more_treated_gender varchar(8)    
)

begin
    select diseaseName into disease_name from disease d where diseaseID = id;

    select count(gender) into number_of_male_treated from disease 
    join treatment using (diseaseID) 
    join patient p2 using (patientID)
    join person p on p2.patientID = p.personID 
    where gender = 'male' and diseaseID = id;

    select count(gender) into number_of_female_treated from disease 
    join treatment using (diseaseID) 
    join patient p2 using (patientID)
    join person p on p2.patientID = p.personID 
    where gender = 'female' and diseaseID = id;

    if number_of_male_treated > number_of_female_treated then 
   		set more_treated_gender = 'male';
   	elseif number_of_male_treated < number_of_female_treated then 
   		set more_treated_gender = 'female';
    else 
   		set more_treated_gender = 'same';
    end if;

end $$
delimiter ;

call joseph_app(5, @disease_name, @number_of_male_treated, @number_of_female_treated, @more_treated_gender);

select @disease_name, @number_of_male_treated, @number_of_female_treated, @more_treated_gender;

-- 3.
with t as (select distinct companyName, planName, count(claimID) as countt from insurancecompany i
join insuranceplan i2 using (companyID)
join claim c using (UIN)
group by companyName, planName), 

t1 as (select *, dense_rank() over (partition by companyName order by countt desc) as roww from t),
t2 as (select *, dense_rank() over (partition by companyName order by countt) as roww from t)

select companyName, planName, 'Most Claimed'  as `Claim Frequency` from t1
where roww between 1 and 3
union 

select companyName, planName, 'Least Claimed'  as `Claim Frequency` from t2
where roww between 1 and 3

order by companyName, `Claim Frequency`;

-- 4.

with base as (select patientID, 
(case 
	when year(dob) >= 2005 and gender = 'male' then 'YoungMale'
	when year(dob) >= 2005 and gender = 'female' then 'YoungFemale'
	when year(dob) >= 1985 and gender = 'male' then 'AdultMale'
	when year(dob) >= 1985 and gender = 'female' then 'AdultFemale'
	when year(dob) >= 1970 and gender = 'male' then 'MidAgeMale'
	when year(dob) >= 1970 and gender = 'female' then 'MidAgeFemale'
	when year(dob) < 1970 and gender = 'male' then 'ElderMale'
	else 'ElderFemale'	
end) as Category from patient p join person p2
on p.patientID = p2.personID),

t as (select diseaseName, category, count(*) as countt from base join treatment using (patientID) join disease using (diseaseID)
group by diseaseName, category
order by diseaseName), 

t1 as (select diseaseName, category, countt, row_number() over (partition by diseaseName order by countt desc) as roww from t)

select diseaseName, category from t1 
where roww = 1;

-- 5.

with t as (select companyName, productName, description, maxprice, (case when maxprice > 1000 then 'Pricey' when maxprice < 5 then 'Affordable' else 'nothing' end)
as category
from medicine)

select * from t 
where category like '%ford%' or category like '%cey%'
order by maxprice desc;
