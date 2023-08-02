-- 1. 

select medicineID, companyName, productName, description, substanceName,(
	case 
		when productType = 1 
		then 'Generic'
		when productType = 2 
		then 'Patent'
		when productType = 3 
		then 'Reference'
		when productType = 4 
		then 'Similar'
		when productType = 5 
		then 'New'
		when productType = 6 
		then 'Specific'
		when productType = 7 
		then 'Biological'
		else 'Dinamized'
		end 
	), taxCriteria, hospitalExclusive, governmentDiscount, taxImunity, maxPrice from medicine
	where (productType in (1, 2, 3) and taxCriteria = 'I')
	or (productType in (4, 5, 6) and taxCriteria = 'II');
	
-- 2. 

select prescriptionID, sum(quantity) as totalQuantity, 
(case 
	when sum(quantity) < 20 then 'Low Quantity' 
	when sum(quantity) < 50 then 'Medium Quantity' 
	else 'High Quantity' end 
) as Tag from contain
group by prescriptionID
order by prescriptionID;

-- 3.

select medicineID, (case when quantity > 7500 then 'HIGH QUANTITY' when quantity < 1000 then 'LOW QUANTIY' end) as Quantity, 
(case when discount  > 30 then 'HIGH QUANTITY' when discount = 0 then 'NONE' end) as Discount from keep 
where pharmacyID = (select pharmacyID from pharmacy where pharmacyName = 'Spot RX')
and ((quantity > 7500 and discount = 0) or (quantity < 1000 and discount > 30));

-- 4. 

set @average = (select avg(maxPrice) from medicine);
select productName, (case when maxPrice > @average * 2 then 'Costly' when maxPrice < 0.5 * @average then 'Affordable' end) from medicine
where ((maxPrice > @average * 2) or (maxPrice < 0.5 * @average))
and medicineID in (select medicineID from keep where pharmacyID = (select pharmacyID from pharmacy where pharmacyName like '%HealthDirect%'))
order by productName;

-- 5. 

select personName, gender, dob, 
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
on p.patientID = p2.personID;
