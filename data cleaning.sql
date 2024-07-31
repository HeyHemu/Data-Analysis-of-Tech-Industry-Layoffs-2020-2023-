## data cleaning
select *
from layoffs;

# 1.removing duplicates
#2. standizing data
# 3. NULL and blank values
#4. remove any cols/rows 

#Instead of working on raw data,we will create aduplicate table to work on
#creating table
create table layoffs_staging
like layoffs;

select * 
from layoffs_staging;

#insert Data
insert into layoffs_staging
select *
from world_layoffs.layoffs;


#1. removing duplicates

#creating a row number to each row making unique all columns, if there are rou numbers 2 and 3 meaning, it is row 2 with same info. A DUPLICATE
select * ,
row_number() over (partition by company,location,industry, total_laid_off,Percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging;

#creating a CTE
with duplicate_cte as 
(
select * ,
row_number() over (partition by company,location,industry, total_laid_off,Percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging
)

delete 
from duplicate_cte
where row_num >1  ; #updating or deleting on CTE doent work 
#we creatting a duplicate table to delete extra rows
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

# inserting staing table data to staging2
select *
from layoffs_staging2;

insert into layoffs_staging2
select * ,
row_number() over (partition by company,location,industry, total_laid_off,Percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging;

#once data inserted we can delete rows
delete
from layoffs_staging2
where row_num >1;


#standadiszing data
#removing extra spaces from company coloumn, see there are extra spaces in company
	select company, trim(company)
	from layoffs_staging2;

#update current table by trimming spaces
update layoffs_staging2
set company = trim(company);

update layoffs_staging2
set industry = trim(industry);

#lets see a case anywhere we need to group few industries,
	select distinct industry
	from layoffs_staging2
	order by 1;

# crypto and crypto currency is same. lets chnage it 

	select *
	from layoffs_staging2
	where industry like "crypto%" ;# see  how many other crypto exists, compbine all them

update layoffs_staging2
set industry = 'crypto'
where industry like "crypto%";

# lets see location has issues
	select distinct location
    from layoffs_staging2
    order by 1; #seems everything unique and no grouping required

#lets see country has issues
select distinct country
    from layoffs_staging2
    order by 1; # looks there are 2 united states , one is with .period 
    
update layoffs_staging2
set country = 'united states'
where country like "united states%";


# if we see date here is a text column, lets chnage it to date formate
	select`date`,
	str_to_date(`date`,'%m/%d/%Y')
	from layoffs_staging2;
#lets update date column
update layoffs_staging2
set `date` = str_to_date(`date`,'%m/%d/%Y');

alter table layoffs_staging2
modify column `date` date;


#working with NULL and blank values
#we have null values in total laif _off and percentage laid 
#lets try to work with rows where it is null in both rows

	select *
	from layoffs_staging2
	where total_laid_off is null
	and percentage_laid_off is null;

#lets see industry col has null and blanks
	select distinct industry
    from layoffs_staging2;
    
    
	select *
    from layoffs_staging2
    where industry is null
    or industry ="";
# here AIRBNB is blank lets see if else where AIRBNB is present to find its industry

	select *
    from layoffs_staging2
    where company ="airbnb"; #it says industry as travel, as above line has data init it is relevant to keep rows, we will populate the industry column with data by adding travel to it
    
    
    select *
    from layoffs_staging2 as t1
    join 
    layoffs_staging2 as t2
    on t1.company = t2.company
    and t1.location=t2.location
    where (t1.industry is null or t1.industry ="")
    and t2.industry is not null;
    
    #updating every black cols with null
    update  layoffs_staging2 
    set industry = null
    where industry ="";
    # we come to know what company has indusrt on it
    #lets select only cols we need
    select t1.industry,t2.industry
    from layoffs_staging2 as t1
    join 
    layoffs_staging2 as t2
    on t1.company = t2.company
    and t1.location=t2.location
    where (t1.industry is null or t1.industry ="")
    and t2.industry is not null;
    
# lets update the cols with cols where data is present in industry
update  layoffs_staging2 as t1
join layoffs_staging2 as t2
  on t1.company = t2.company
  set t1.industry = t2.industry
  where (t1.industry is null or t1.industry ="")
    and t2.industry is not null;
    
# if we check AIR BNB is updated with industry
#lets see do we still have any null or blanks
select *
    from layoffs_staging2
    where industry is null
    or industry ="";

# seems ballys interactive is alone and doent have supporting row with industry name

#lets delete rows/cols  with null values
	select *
	from layoffs_staging2
	where total_laid_off is null
	and percentage_laid_off is null;
  
  delete 
  from layoffs_staging2
	where total_laid_off is null
	and percentage_laid_off is null;
  
#lets take off cols

alter table layoffs_staging2
drop column row_num;

select *
	from layoffs_staging2

