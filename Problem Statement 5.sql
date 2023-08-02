-- 1. 

select personName, count(treatmentID) as 'Number of Treatments', (date_format(from_days((datediff(curdate(), p.dob))), '%Y') + 0) as age 
from patient p join person p2 on p.patientID = p2.personID  
join treatment t using (patientID)
group by patientID 
order by count(treatmentID) desc;

-- 2. 
with t1 as (select date_format(date, '%b') as `Month`,  count(treatmentID) as `Number of Treatments`,
count(p1.gender) as g1 from treatment t join patient p using (patientID)
join person p1 on (p.patientID = p1.personID)
where p1.gender='male' and year(date) = 2021
group by `Month`
order by `Month`), 

t2 as  (select date_format(date, '%b') as `Month`,  count(treatmentID) as `Number of Treatments`, 
count(p1.gender) as g2 from treatment t join patient p using (patientID)
join person p1 on (p.patientID = p1.personID)
where p1.gender='female' and year(date) = 2021
group by `Month`
order by `Month`) 

select month, t1.`Number of Treatments` + t2.`Number of Treatments` as `Number of Treatments`, g1/g2 as `Gender Ratio` from t1 join t2 using (month)
order by `Number of Treatments`;

-- 3. 
select diseaseName, city, count from (
	select diseaseName, city, count(treatmentID) as `count`, 
	rank() over (partition by diseaseName order by count(treatmentID) desc) as rankk from diseasetoaddress d
	group by diseasename, city
) t
where rankk < 4;

-- 4.

with t1 as (select pharmacyName, diseaseName, count(prescriptionID) as `count` from pharmacy p join prescription p2 using (pharmacyID)
join treatment t using (treatmentID) join disease d using (diseaseID)
where year(date) = 2021
group by pharmacyName, diseaseName),
t2 as (
	select pharmacyName, diseaseName, count(prescriptionID) as `count` from pharmacy p join prescription p2 using (pharmacyID)
join treatment t using (treatmentID) join disease d using (diseaseID)
where year(date) = 2022
group by pharmacyName, diseaseName
)

select distinct pharmacyName, t1.diseaseName, max(t1.count) as `2021 Count`, max(t2.count) as `2022 Count` from t1 join t2 using (pharmacyName)
group by pharmacyName, diseaseName
order by pharmacyName;

-- 5.
with t as (select companyName, state, count(claimID) as `count`, rank() over (partition by companyName order by count(claimID) desc) as rankk
from insurancecompany join address using (addressID) join person p using (addressID) join patient p2 on p.personID = p2.patientID join treatment
using (patientID) join claim using (claimID)
group by companyName, state)
select companyName, state from t
where rankk = 1;

