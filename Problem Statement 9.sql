-- 1.

select state, gender, count(diseaseID) as `Autism Patient Count`
from address a 
join person p using (addressID)
join patient p2 on p.personID = p2.patientID 
join treatment t using (patientID)
join disease using (diseaseID)
where diseaseName = 'Autism'
group by state, gender
order by state, gender;

-- 2.

select planName, companyName,  
count(if (year(date) = 2020, 1, NULL)) as `2020`,
count(if (year(date) = 2021, 1, NULL)) as `2021`, 
count(if (year(date) = 2022, 1, null)) as `2022`, 
count(claimID) as `Total Claims`
from insurancecompany i join insuranceplan i2 using (companyID)
join claim using (UIN)
join treatment t using (claimID)
group by planName, companyName
order by `Total Claims` desc;

-- 3.

with t as (select state, diseaseName, count(*) as countt, row_number () over (partition by state order by count(*) desc) as max, 
row_number () over (partition by state order by count(*)) as min
from diseasetoaddress d
group by state, diseaseName)

select state, diseaseName, countt as `Aggregate Count` from t
where max = 1 or min = 1
order by state, countt desc;

-- 4.

select pharmacyName, diseaseName, count(if(year(date)=2022, 1, NULL)) as `Number of Prescriptions in 2022`, 
count(prescriptionID) as `Total Prescriptions Per Disease`,
sum(count(prescriptionID)) over (partition by pharmacyName) as `Total Prescriptions Overall`
from pharmacy p join prescription p2 using (pharmacyID)
join treatment t using (treatmentID)
join disease d using (diseaseID)
group by pharmacyName, diseaseName
order by pharmacyName, `Number of Prescriptions in 2022` desc, `Total Prescriptions Per Disease` desc;

-- 5.

select diseaseName, gender, count(if(year(date)=2022, 1, NULL)) as `Number of People Affected` 
from disease d join treatment t using (diseaseID)
join patient p using (patientID)
join person p2 on p2.personID = p.patientID
group by diseaseName, gender
order by diseaseName, gender;