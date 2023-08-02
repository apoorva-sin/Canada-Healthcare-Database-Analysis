-- 1.

select pharmacyName, count(date) as Frequency from pharmacy p 
join keep k using (pharmacyID)
join medicine m using (medicineID)
join prescription p2 using (pharmacyID)
join treatment t using (treatmentID)
where hospitalExclusive = 'S' and year(date) in ('2021', '2022')
group by pharmacyName
order by Frequency desc;


-- 2.

select planName as 'Plan Name', companyName as 'Company Name', count(t.treatmentID) as 'Number of Treatments' from insuranceplan i 
join insurancecompany i2 using (companyID)
join claim c using (UIN)
join treatment t using (claimID)
group by planName, companyName
order by count(t.treatmentID) desc ;

-- 3.

with frequency as (	
	select companyName, planName, count(claimID) as freq from insurancecompany i 
	join insuranceplan i2 using (companyID)
	join claim using (UIN)
	group by companyName, planName
), 
maxMinInsured as (
	select companyName, max(freq) as maxClaimed,  min(freq) as minClaimed from frequency
	group by companyName), 
maxInsured as ( 
	select f.companyName as 'Company Name', f.planName as 'Most Claimed' from maxMinInsured m 
	join frequency f on f.freq = m.maxClaimed and f.companyName = m.companyName
), 
minInsured as ( 
	select f.companyName as 'Company Name', f.planName as 'Least Claimed' from maxMinInsured m 
	join frequency f on f.freq = m.minClaimed and f.companyName = m.companyName
)

select distinct * from maxInsured 
join minInsured using (`Company Name`);

-- 4. 

select state as `State`, 
count(personID) as `Number of People`,  
count(patientID) as `Number of Patients`, 
count(personID) / count(patientID) as `Ratio`
from address a 
join person p using (addressID)
left join patient p2 on p.personID = p2.patientID
group by state
order by `Ratio` ;

-- 5. 

select pharmacyName as `Pharmacy Name`, sum(quantity) as `Total Quantity` from prescriptionToAddress
join treatment t using (treatmentID)
where state = 'AZ' and taxCriteria = 'I' and year(date) = '2021'
group by pharmacyName
order by `Total Quantity` desc;
