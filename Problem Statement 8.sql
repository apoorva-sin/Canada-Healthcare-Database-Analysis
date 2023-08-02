-- 1. 
-- For each age(in years), how many patients have gone for treatment?

SELECT TIMESTAMPDIFF(YEAR, dob, CURDATE()) AS age, COUNT(*) AS numTreatments
FROM Patient
JOIN Treatment using (patientID)
GROUP BY age
ORDER BY numTreatments DESC;

-- Ans - 1. Grouped by age alias directly
-- 2. Removed join on Person table 
-- 3. Replaced ON clause with USING 

-------------------------------------------------------------------------------------------------

-- 2. 
-- For each city, Find the number of registered people, number of pharmacies, and number of insurance companies.

select city, count(personID) as `Person Count`, count(pharmacyID)  as `Pharmacy Count`, count(companyID) as `Company Count` from address a 
left join insurancecompany i using (addressID)
left join person p using (addressID)
left join pharmacy p2 using (addressID)
group by city
order by `Person Count` desc, `Pharmacy Count` desc, `Company Count` desc;

-- Ans - Replaced the entire query with a single select statement with all joins in one.

---------------------------------------------------------------------------------------------------

-- 3.
-- Total quantity of medicine for each prescription prescribed by Ally Scripts
-- If the total quantity of medicine is less than 20 tag it as "Low Quantity".
-- If the total quantity of medicine is from 20 to 49 (both numbers including) tag it as "Medium Quantity".
-- If the quantity is more than equal to 50 then tag it as "High quantity".

select 
prescriptionID, sum(quantity) as totalQuantity,
CASE WHEN sum(quantity) < 20 THEN 'Low Quantity'
WHEN sum(quantity) < 50 THEN 'Medium Quantity'
ELSE 'High Quantity' END AS Tag

FROM Contain
JOIN Prescription using (prescriptionID)
JOIN Pharmacy using (pharmacyID)
where pharmacyName = 'Ally Scripts'
group by prescriptionID;

-- Ans - Replaced ON clause with USING 

---------------------------------------------------------------------------------------------------

-- 4.
-- The total quantity of medicine in a prescription is the sum of the quantity of all the medicines in the prescription.
-- Select the prescriptions for which the total quantity of medicine exceeds
-- the avg of the total quantity of medicines for all the prescriptions.

with t as (
		
	select prescriptionID, sum(quantity) as totalQuantity
	from Prescription p join Contain c using (prescriptionID)
	group by prescriptionID
	order by prescriptionID
	)

select * from T
where totalQuantity > (select avg(totalQuantity) from T);

-- Ans - 1. Removed unnecesary tables and joins which were not asked by the problem statement.
-- 2. Replaced ON clause with USING in joins. 

---------------------------------------------------------------------------------------------------

-- 5.

-- Select every disease that has 'p' in its name, and 
-- the number of times an insurance claim was made for each of them. 

SELECT diseaseName, COUNT(*) as numClaims
FROM Disease
JOIN Treatment using (diseaseID)
JOIN Claim using(claimID)
WHERE diseaseName LIKE '%p%'
GROUP BY diseaseName;

-- Ans - 1. Removed unnecesary sub-query.
-- 2. Replaced ON clause with USING in joins. 





