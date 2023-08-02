-- 1.
with countPharmacy as (
	select city, count(pharmacyID) as cPharm
	from address a 
	join pharmacy p using (addressID)
	group by city
), countPrescription as (
	select city, count(prescriptionID) as cPres
	from address a 
	join pharmacy p using (addressID)
	join prescription p2 using (pharmacyID)
	group by city
)

select city, cPharm/cPres as 'Pharmacy to Prescription Ratio', cPres as 'Total Prescriptions'
from countPharmacy join countPrescription using(city)
where cPres > 100
order by cPharm/cPres;

-- 2. 

with d1 as (
	select city, diseaseName, count(*) as countt, row_number() over (partition by city order by count(*) desc) as row_num from diseasetoaddress 
	where state='AL'
	group by city, diseaseName
), d2 as (
	select city, max(countt) as max_count from d1 
	group by city
)

select d1.city as `City`, d1.diseaseName as `Disease Name`, d1.countt as `Count` from d1 
join d2 on d1.countt = d2.max_count and d1.city = d2.city
where d1.row_num = 1
order by `City`;


-- 3. 

alter table insuranceplan drop index insuranceIndex; 

with d1 as (
	select diseaseName, planName, count(*) as countt from insurancetoaddress i 
	join disease d using (diseaseID)
	group by diseaseName, planName
), d2 as (
	select diseaseName, max(countt) as max_count, min(countt) as min_count from d1
	group by diseaseName
),
d3 as ( 
	select d1.diseaseName as `Disease Name`, d1.planName as `Most Claimed Insurance Plan` from d1
	join d2 on d1.countt = d2.max_count and d1.diseaseName = d2.diseaseName
),
d4 as (
	select d1.diseaseName as `Disease Name`, d1.planName as `Least Claimed Insurance Plan` from d1
	join d2 on d1.countt = d2.min_count and d1.diseaseName = d2.diseaseName
)

select distinct * from d3
join d4 using (`Disease Name`)
order by `Disease Name`;

-- 4. 

with sameFam as (
	select addressID, count(patientID) as countt from diseaseToAddress
	group by addressID
	having countt > 1
)

select diseaseName, count(addressID) as `Number of People Affected` from diseaseToAddress
join sameFam s using (addressID)
group by diseaseName
order by count(addressID) desc;

-- 5.

select state, count(treatmentID)/ count(claimID) as `Ratio` from insuranceToAddress
where date between '2021-04-01' and '2022-03-31'
group by state
order by `Ratio` desc;


