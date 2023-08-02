-- 1.

drop procedure ps1;
delimiter $$

create procedure ps1 (
	in id int
)

begin
	with t as (
	select planName, diseaseName, count(claimID) as countt 
	from insuranceplan 
	join claim using (UIN)
	join treatment t using (claimID)
	join disease d using (diseaseID)
	where companyID = id
	group by planName, diseaseName
	), t1 as (select planName, diseaseName, countt, first_value (diseaseName) over (partition by planName order by countt desc) as `Most Common Disease` from t)
	select planName, diseaseName, countt from t1
	where diseaseName = `Most Common Disease`;	
end $$

delimiter ;

call ps1(1118);

-- 2. 

delimiter $$

create procedure ps2 (
	in dName varchar(100)
)

begin
	
	with t as (
		select pharmacyName, count(if(year(date)=2021, 1, NULL)) as c1, count(if(year(date)=2022, 1, NULL)) as c2 from pharmacy p 
		join prescription p2 using (pharmacyID)
		join treatment t using (treatmentID)
		join disease using (diseaseID)
		where diseaseName = dName
		group by pharmacyName
	), 

	t1 as (
		select *, row_number () over (order by c1 desc) as roww from t
	),
	
	t2 as (
		select *, row_number () over (order by c2 desc) as roww from t
	) 

	select dName, t1.pharmacyName as `Top 2021 Pharmacies`, t2.pharmacyName as `Top 2022 Pharmacies`, t1.c1 as `2021 Count`, t2.c2 as `2022 Count`  from t1
	join t2 using(roww)
	where roww < 4;
	
end $$

delimiter ;

call ps2('Asthma');
call ps2('Psoriasis');

-- No, there are no coomon pharmacies from the years 2021 and 2022, so the report mentioned in the question is false, atleast for the cases of
-- Asthma and Psoriasis.

-- 3. 

delimiter $$

create procedure ps3 (
	in stateName varchar(100)
)

begin
	
	with t as (
		select state, count(patientID) as c1, count(companyID) as c2, count(companyID)/count(patientID) as ratio from address a 
		left join insurancecompany i using (addressID)
		join person p using (addressID)
		join patient p2 on p.personID = p2.patientID 
		group by state
	),
	t2 as (
		select avg(ratio) as avg_insurance_patient_ratio from t
	)
		
	select c1 as `num_patients`, c2 as `num_insurance_companies`, ratio as `insurance_patient_ratio`, 
	if(ratio>t2.avg_insurance_patient_ratio, 'Not Recommended', 'Recommended') as `Recommendation`
	from t, t2
	where state = stateName;
	
end $$

delimiter ;

call ps3('MD');

-- 4.

drop table PlacesAdded;

create table if not exists PlacesAdded (
	placeID int primary key auto_increment,
	placeName varchar(100),
	placeType enum('state', 'city'),
	timeAdded timestamp
);

---

drop trigger if exists insertAddressTrigger;

delimiter $$

create trigger insertAddressTrigger 
before insert on address 
for each row

begin 
	declare new_state_bool int default 0;
	declare new_city_bool int default 0;

	select count(*) into new_state_bool from address a
	where state = new.state;

	select count(*) into new_city_bool from address a
	where city = new.city;

	if new_state_bool = 0 then
	insert into placesadded(placeName, placeType, timeAdded) values (new.state, 'state', NOW());

	end if;

	if new_city_bool = 0 then
	insert into placesadded(placeName, placeType, timeAdded) values (new.city, 'city', NOW());

	end if;	

	
end $$

delimiter ;

select distinct state, city from address;

insert into address values (111115, 'Address Part', 'Mumbai', 'State3', 123456);
select * from placesadded;

delete from address
where address1 like '%dress Part%';

-- 5.

drop table if exists Keep_Log;
create table if not exists Keep_Log (
	id int primary key auto_increment, 
	medicineID int not null,
	quantity int	
);

---
drop trigger if exists updateKeepTrigger;

delimiter $$

create trigger updateKeepTrigger 
after update on keep 
for each row 

begin 
	insert into keep_log (medicineID, quantity) values (new.medicineID, new.quantity - old.quantity);	
end $$

delimiter ;

select * from keep limit 10;

update keep 
set quantity = 6000
where medicineID = 44661;

select * from keep_log;