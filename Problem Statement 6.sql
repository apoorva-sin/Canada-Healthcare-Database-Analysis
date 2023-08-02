-- 1. 
with t as (
select distinct pharmacyID, pharmacyName, quantity, hospitalExclusive from pharmacy p 
join keep k using (pharmacyID) 
join medicine m using (medicineID)
join prescription p2 using (pharmacyID)
join treatment t using (treatmentID)
where year(date) = 2022
), t1 as (select pharmacyID, sum(quantity) as total from t group by pharmacyID)
, t2 as (select pharmacyID, sum(quantity) as hospitalExclusiveTotal from t where hospitalExclusive = 'S' group by pharmacyID)

select pharmacyID, pharmacyName, hospitalExclusiveTotal, round(hospitalExclusiveTotal * 100 / total, 2) as `Percentage`
from t1 join t2 using (pharmacyID) 
join t using (pharmacyID)
group by t2.pharmacyID;


-- 2.
with t as (select state, treatmentID, claimID from address a 
join person p using (addressID)
join patient p2 on p.personID = p2.patientID 
join treatment t using (patientID)
left join claim c using (claimID))
, t1 as (select state, count(treatmentID) as nullCount from t where claimID is null group by state)
, t2 as (select state, count(treatmentID) as totalCount from t group by state)

select state, round(nullCount / totalCount, 2) as 'Ratio of Treatments with Unclaimed Insurance'
from t1 join t2 using (state);

-- 3. 
with t as (select state, diseaseName, count(diseaseID) as countt, 
row_number() over (partition by state order by count(diseaseID) desc) as maxRank,
row_number() over (partition by state order by count(diseaseID) asc) as minRank
from diseasetoaddress
group by state, diseaseID)

select state, diseaseName, countt as `Most/Least Treated Diseases ` from t 
where maxRank = 1 or minRank = 1
order by state, countt desc;

-- 4. 
select city, count(personID) as `Number of People`, count(patientID) as  `Number of Patients`, round(count(patientID)*100/count(personID), 2) as Percentage
from address a join person p using(addressID)
left join patient p2 on p.personID = p2.patientID
group by city
having count(personID) > 10
order by Percentage desc;

-- 5.
select pharmacyName, sum(quantity) as TotalQuantity from pharmacy p 
join keep k using (pharmacyID)
join medicine m using (medicineID)
where substanceName like '%ranitidin%'
group by pharmacyName
order by TotalQuantity desc
limit 3;
