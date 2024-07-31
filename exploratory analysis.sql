# we got no agenda, we gonna keep exploring to find somehting useful

# Exploratory data Analsyis
Select * 
from layoffs_staging2;

# Find Max total layoffs
select max(total_laid_off)
from layoffs_staging2;

#find which comany laid off most
select company, `date`
from layoffs_staging2
where total_laid_off = 12000;

# Find Max total layoffs & max percentage laid off
select max(total_laid_off) , max(percentage_laid_off)
from layoffs_staging2; # there is a company laid 100% people

#lets find out 100% laid off Companies.

Select *
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc;

#how many of them laid 100%
Select count(company)
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc;
#total companies
select distinct count(company)
from layoffs_staging2;

#lets find out 100% laid off Companies, where there is funding

Select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

# find which compny has highest layoff

Select company, Sum(total_laid_off) as total 
from layoffs_staging2
group by company
order by 2 desc;

#find the date range of data
Select min(`date`), max(`date`)
from layoffs_staging2;

#lets find which industry is hit much layoffs
Select industry,Sum(total_laid_off) as total 
from layoffs_staging2
group by industry
order by 2 desc;

#which country has highest laidoffs

Select country,Sum(total_laid_off) as total 
from layoffs_staging2
group by country
order by 2 desc;

#which years has highest layoffs, year wise analysis
 select year(`date`), sum(total_laid_off)
 from layoffs_staging2
group by year(`date`)
order by 2 desc; # for 2023 the data is only for 3 months yet have 125677 layoffs

#find funding stage wrise analysis 
 select stage, sum(total_laid_off)
 from layoffs_staging2
group by stage
order by 2 desc;

#find average percentage laid off per company
 select company, avg(percentage_laid_off)
 from layoffs_staging2
group by company
order by 2 desc;

#date wise layoffs
select year(`date`) as year, month(`date`) as month , sum(total_laid_off) #or substring(`date`6,2) as month
from layoffs_staging2
where `date` is not null
group by  year,month
order by year,month;

# rolling total

with Rolling_total as 
(
	select year(`date`) as year, month(`date`) as month , sum(total_laid_off)  as Total_off#or substring(`date`6,2) as month
	from layoffs_staging2
	where `date` is not null
	group by  year,month
	order by year,month
    )
    select year,month, total_off, sum(total_off) over(order by year,month) as rolling_total
    from Rolling_total;
    
# how cmapnies are laying off year by year
Select company, Sum(total_laid_off) as total 
from layoffs_staging2
group by company
order by 2 desc;


Select company,year(`date`), Sum(total_laid_off)
from layoffs_staging2
group by company, `date`
order by company asc;

#ranking which which year they laid off most

Select company,year(`date`), Sum(total_laid_off)
from layoffs_staging2
group by company, `date`
order by 3 desc;

With company_year(company,years,total_laid_off) as
(
Select company,year(`date`), Sum(total_laid_off)
from layoffs_staging2
group by company, `date`
order by company asc
) 
select *, dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
order by ranking;

#filter top 5 companies per year
With company_year(company,years,total_laid_off) as
(
Select company,year(`date`), Sum(total_laid_off)
from layoffs_staging2
group by company, `date`
), company_year_rank as 
(
select *, dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
)
select *
from company_year_rank
where ranking <=5;
