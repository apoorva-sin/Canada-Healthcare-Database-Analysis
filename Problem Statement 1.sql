-- 1

with age_data as (
	select patientID, (date_format(from_days((datediff(curdate(), p.dob))), '%Y') + 0) as age from patient p 
	join treatment t using (patientID) 
	where year(t.date) = '2022'
)
	
	
select (
	case when a.age between 0 and 14 then 'Children'
	when a.age between 15 and 24 then 'Youth'
	when a.age between 25 and 64 then 'Adults'
	else 'Seniors' end) as Age_Category, count(*) as Category_Count
	
from age_data a 
group by Age_Category;

-- 2

with new_table as (
	select diseaseName as Disease, gender as gender, count(*) as count from 
	diseaseToAddress d
	group by diseaseID, gender 
	order by diseaseID
)
select t1.Disease, round((t2.count / t1.count), 3) as Ratio from new_table t1
join new_table t2 using (Disease)
where t1.gender = 'female' and t2.gender = 'male'
order by Ratio desc;


-- 3. Ans - Ratio is not that different.

select gender, count(treatmentID) as 'Number of Treatments', 
	count(claimID) as 'Number of Claims', 
	(count(treatmentID) / count(claimID)) as Ratio 
from diseasetoaddress 
group by gender;
	

-- 4.

delimiter $$
create procedure generateInventoryReport()

begin
	select pharmacyName, sum(quantity) as TotalQuantity, 
		sum(quantity*maxPrice) as TotalMaxPrice, 
		sum(discount*0.01*quantity*maxPrice) as TotalPriceAfterDiscount from pharmacy p 
	join keep k using (pharmacyID)
	join medicine m using (medicineID)
	group by pharmacyID;	
end $$
delimiter ;

call generateInventoryReport();

-- 5.

select pharmacyName, max(Quantity) as 'Max Quantity', min(Quantity) as 'Min Quantity', round(avg(Quantity), 0) as 'Average Quantity'
from pharmacy p 
join prescription p2 using (pharmacyID) 
join contain c using (prescriptionID)
group by pharmacyID;











