USE CORN_EXPORT;

SELECT * FROM cornproductionn;
select * from rate2020;
select * from rate2021;
select * from rate2022;

#Let,s Clear dataset formatings first (cornproduction)
#check dataset details
select * from cornproduction;
select column_name , data_type , character_maximum_length from information_schema.columns
where table_name = 'cornproduction' and 
	  table_schema = 'corn_export';

#rename columns becauuse our columns get on 1/2 rows instant of header
alter table cornproduction 
rename column `Crop: Maize` to `Sr_NO`;
alter table cornproduction 
RENAME column MyUnknownColumn TO State ,
rename column `MyUnknownColumn_[0]` to District , 
rename column `MyUnknownColumn_[1]` to `Production(T)`;

# give proper structure and save as table
create table cornproductionn as 
select State , District , '2019' as year , `Production(T)` from cornproduction
union all 
select State , District , '2020' as year ,`MyUnknownColumn_[2]` from cornproduction
union all 
select State , District , '2021' as year ,`MyUnknownColumn_[3]` from cornproduction;

#delete unwanted rows first 2 because column names goes on first two rows
delete from cornproduction limit 2 ;

#save as new table 
select * from cornproductionn;

#change datatypes
select column_name , data_type , character_maximum_length from information_schema.columns
where table_name = 'cornproductionn' and table_schema = 'corn_export';

#change datatype (District - varchar , production(t) - int , state - varchar , year - int ) 
alter table cornproductionn
modify column State varchar(45) ,
modify column District varchar(45) ;
alter table cornproductionn
modify column `year` year; #(for change datatype of Production(T) you need to remove all null value from thier first)

    #temprory desable safe mode ( for replace blank space with null value  
SET SQL_SAFE_UPDATES = 0; # - Optionally, re-enable safe updates ( SET SQL_SAFE_UPDATES = 1; )

   #replace that blank space with null value
UPDATE cornproductionn
SET `Production(T)` = NULL
WHERE `Production(T)` = '';

   #chnage datatype 
alter table cornproductionn
modify column `Production(T)` bigint;

#finding null value and replace them
 select sum(State is null) from cornproductionn;
 select sum(`year` is null) from cornproductionn;
 select sum(District is null) from cornproductionn;
 select sum(`Production(T)` is null) from cornproductionn; # ( null values present ) 
 
 # finding avg of `Production(T)` 
 select avg(`Production(T)`) from cornproductionn;
 
 #update null values with avg of production(T)
 update cornproductionn
 set `Production(T)` = ifnull(`Production(T)` , '53756')
 where `Production(T)` is null;
 
 #cornproductionn is ready for analysis 
 select * from cornproductionn;
 
 #GET READY TO OTHER DATASET 
 SELECT COLUMN_NAME , DATA_TYPE , character_maximum_length from information_schema.columns 
 where table_name = "rate2020" and 
       table_schema = "corn_export";
 # change datatype ( corp - text , district - text , m price - int , state - text , year - text )
 select * from rate2020;
 
 # drop unwanted columns crop 
  alter table rate2020
  drop column crop ;
  
alter table rate2020
modify District VARCHAR(45) ,
MODIFY State VARCHAR(45),
MODIFY `Market-Price(in Rupees Per Quintal)` INT;

#UPDATE YEAR COLUMN WITH YEAR 2020 ( FIRSTLY CHECK THERE BLANK VALUE OR NULL VALUES ) 
SELECT sum(`Year` is null ) as yearnull from rate2020; # showing 0 null means that all are blank value 

update rate2020
set Year = null 
where year = '' ; # fill space with null value 

#fill null with year 2020  but change datatpe first

alter table rate2020
modify `year` year ; #datatpe chnaged 

update rate2020
set `year` = ifnull(`year` , 2020)
where `year` is null ; #replaced year null with 2020 

#check null if null then replace it
select sum(District IS NULL ) , SUM(State IS NULL) , SUM(year IS NULL) ,SUM(`Market-Price(in Rupees Per Quintal)` IS NULL)
FROM rate2020; #no null value in table 

#dataset ready for analysisi
select * from rate2020;

#take next dataset
select * from rate2021;

#drop unwanted columns
alter table rate2021
drop column Crop;

#check datatypes and table details 
select column_name , data_type , character_maximum_length from information_schema.columns
where table_name = "rate2021" and 
      table_schema ="corn_export";
      
 #change datatype ( District - text , MP-int , State - text , Year - Text )
 
   #before change datatype deal with year columns (change blank value ) 
   update rate2021 
   set year = null 
   where year = '';
   
   #check null value 
   select sum(`year` is null) , sum(District is null) , sum(State is null) ,sum(`Market-Price(in Rupees Per Quintal)` is null
   ) from rate2021;
   
   #UPDATE YEAR NULL WITH 2021
   UPDATE rate2021
   SET `Year` = IFNULL(`Year`, 2021)
   WHERE `Year` IS NULL;
   
   #datatype changed 
   ALTER TABLE rate2021
   modify `Year` year ,
   modify District varchar(45),
   modify State varchar(45) ,
   modify `Market-Price(in Rupees Per Quintal)` int;
   
   #data ready for analysis 
   select * from rate2021;
   
   #next dataset 2022
   select * from rate2022;
   
   #check datatype and change datatype 
   select column_name , data_type , character_maximum_length from information_schema.columns
   where   table_name = 'rate2022' and table_schema  =  'coen_export';
   
     #change datatype ( year - text , State -n text , District - text , Market-Price(in Rupees Per Quintal) - text )
     
	# change blank value of year column into null 
   update rate2022
   set Year = null
   where Year = '' ;
   
   #change datatype 
   alter table rate2022 
   modify District VARCHAR(45),
   MODIFY  State VARCHAR(45),
   MODIFY Year Year ,
   modify `Market-Price(in Rupees Per Quintal)` int ;

   #deal with null value ( check and delete or replace )
   select sum(District is null) , sum(State is null) , sum(`Year` is null) , sum(`Market-Price(in Rupees Per Quintal)` is null
   ) from rate2022;   # year has 208 null value 
   
   #deal with null value 
   update rate2022
   set Year = 2022
   where year is null ;   #fill null value with 2022
   
   #dataset ready for analysis
   select * from rate2022;
   
   
## Project ##

 #Reduce Cost 
#- FR01. Display average, min, max production by district & state
   # BY State 
   select State , min(`Production(T)`) as Min_Production , max(`Production(T)`) as Max_Production 
   ,avg(`Production(T)`) as Avg_Production from cornproductionn 
   group by State ;
   # By District 
   select District , max(`Production(T)`) as Max_Production , min(`Production(T)`) as Min_Production , avg(`Production(T)`)
   AS Avg_Production from cornproductionn 
   group by District ;

#-FR02. Reduce activity and man power where production below than state average Maharashtra
   select * from
   ( select * ,
   case 
   when `Production(T)` < ( Select avg(`Production(T)`) FROM cornproductionn where `year` = 2019) then "LESSTHANSTATE AVG" 
   WHEN `Production(T)` < ( select avg(`Production(T)`) from cornproductionn where `year` = 2020) then "Less than state avg"
   when `Production(T)` < (select avg(`Production(T)`) from cornproductionn where `year` = 2021) then "Less tahn state avg"
   else "Good" 
   end as avg_satus from cornproductionn ) as xxx 
   where avg_satus != "Good";
   
#-FR03. Reduce activity and man power where production below and state average and near to min of state for each year of Maharashtra
with ranked as (
       SELECT *,
         PERCENT_RANK() OVER (PARTITION BY year ORDER BY `Production(T)` ASC) AS production_rank
  FROM cornproductionn
  WHERE state = 'Maharashtra'
)
SELECT *
FROM ranked
WHERE production_rank <= 0.25;  -- bottom 10% producers for that year 
 

#-FR04. Try to avoid that district where corn rate always on high over the year of Maharashtra
WITH maha_avg_2020 AS (
    SELECT AVG(`Market-Price(in Rupees Per Quintal)`) AS avg_price
    FROM rate2020
    WHERE State = 'Maharashtra'
),
maha_avg_2021 AS (
    SELECT AVG(`Market-Price(in Rupees Per Quintal)`) AS avg_price
    FROM rate2021
    WHERE State = 'Maharashtra'
),
maha_avg_2022 AS (
    SELECT AVG(`Market-Price(in Rupees Per Quintal)`) AS avg_price
    FROM rate2022
    WHERE State = 'Maharashtra'
)

SELECT DISTINCT r20.District
FROM rate2020 r20
JOIN rate2021 r21 ON r20.District = r21.District AND r20.State = r21.State
JOIN rate2022 r22 ON r20.District = r22.District AND r20.State = r22.State
JOIN maha_avg_2020 m20 ON TRUE
JOIN maha_avg_2021 m21 ON TRUE
JOIN maha_avg_2022 m22 ON TRUE
WHERE r20.State = 'Maharashtra'
  AND r20.`Market-Price(in Rupees Per Quintal)` > m20.avg_price
  AND r21.`Market-Price(in Rupees Per Quintal)` > m21.avg_price
  AND r22.`Market-Price(in Rupees Per Quintal)` > m22.avg_price;

#-FR05. Try to avoid that district where rate always on top over the year and production near minimun of state or below that avg of state 

WITH max_rate_2020 AS (
    SELECT MAX(`Market-Price(in Rupees Per Quintal)`) AS max_rate
    FROM rate2020
    WHERE State = 'Maharashtra'
),
max_rate_2021 AS (
    SELECT MAX(`Market-Price(in Rupees Per Quintal)`) AS max_rate
    FROM rate2021
    WHERE State = 'Maharashtra'
),
max_rate_2022 AS (
    SELECT MAX(`Market-Price(in Rupees Per Quintal)`) AS max_rate
    FROM rate2022
    WHERE State = 'Maharashtra'
),

-- Step 2: Maharashtra average production across all 3 years
maha_avg_production AS (
    SELECT AVG(`Production(T)`) AS avg_prod
    FROM cornproductionn
    WHERE State = 'Maharashtra'
),

-- Step 3: Get districts with rate greater than max and below avg production
qualified_districts AS (
    SELECT cp.District
    FROM cornproductionn cp
    JOIN rate2020 r20 ON cp.District = r20.District AND cp.State = r20.State AND cp.Year = 2020 AND r20.State = 'Maharashtra'
    JOIN rate2021 r21 ON cp.District = r21.District AND cp.State = r21.State AND cp.Year = 2021 AND r21.State = 'Maharashtra'
    JOIN rate2022 r22 ON cp.District = r22.District AND cp.State = r22.State AND cp.Year = 2022 AND r22.State = 'Maharashtra'
    JOIN max_rate_2020 m20 ON r20.`Market-Price(in Rupees Per Quintal)` > m20.max_rate
    JOIN max_rate_2021 m21 ON r21.`Market-Price(in Rupees Per Quintal)` > m21.max_rate
    JOIN max_rate_2022 m22 ON r22.`Market-Price(in Rupees Per Quintal)` > m22.max_rate
    GROUP BY cp.District
    HAVING SUM(`cp`.`Production(T)`) / COUNT(cp.Year) < (SELECT avg_prod FROM maha_avg_production)
)

-- Final result
SELECT * FROM qualified_districts;
#-FR06.Note - we don,t have your operation data otherwise we help you in best way next time provide that also !

# High-potential territories for expansion
#- FR07. State with low price and high production 
     
     WITH PLESSTHAN20 AS ( SELECT State FROM rate2020 
     where `Market-Price(in Rupees Per Quintal)` > ( select avg(`Market-Price(in Rupees Per Quintal)`) from rate2020)) ,
     PLESSTHAN21 AS ( SELECT State from rate2021
     where `Market-Price(in Rupees Per Quintal)` > ( select avg(`Market-Price(in Rupees Per Quintal)`) from rate2021)) ,
     PlESSTHAN22 AS ( SELECT State from rate2022
     where `Market-Price(in Rupees Per Quintal)` > ( select avg(`Market-Price(in Rupees Per Quintal)`) from rate2022)) 
#- FR08. State where average price always less than national average price for all 3 year 

#- FR09. Identify state where production high and in that state identify which district on top for give high production for all 3 years top 10
#-FR10. Identify which district gives maximun production for all 3 year all over india
#-FR11. District where avg production always on more than nationonal average for 3 year
#-FR12. State where avg rate always more than national avgerage rate for all 3 year 
#-FR13. Identify state which have more than national avgerage rate for all 3 year , and in that state which district are on top regarding rate
#-FR14. District which average rate more than national average rate for all 3 year  
#-FR15. District of MP where maximun production & less than national average rate
#-FR16. District of Gujrat where maximun production & less than national average rate
#-FR17. District of Karnatka where maximun production & less than national average rate
