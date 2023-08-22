-- the whol dataset

select Location , date , total_cases , new_cases , total_deaths , population
from covid..CovidDeaths$
order by 1 , 2 ;


-- Looking at total_cases vs total_deaths

select Location , date , total_cases  , total_deaths ,CONCAT( round(( (total_deaths / total_cases) * 100) , 2) ,  '%' ) as "death percentage"
from covid..CovidDeaths$
where location = 'Egypt'
order by 1 , 2 ;


-- Looking at total_cases vs population

select Location , date , population  ,CONCAT( round(( (total_cases / population) * 100) , 2) ,  '%' ) as "Infected people"
from covid..CovidDeaths$
where location = 'Egypt'
order by 1 , 2 ;


-- Looking at Highest infection count

select Location , population , max(total_cases) as 'Highest infection count' ,max(CONCAT( round(( (total_cases / population) * 100) , 2) ,  '%' )) as " highest Infected people"
from covid..CovidDeaths$
group by Location , population
order by 4 desc , 3 ;


-- Looking at countries with highst death count

select Location , population , max(cast(total_deaths as bigint)) as 'Highest death count' 
from covid..CovidDeaths$
where continent is not null
group by Location , population
order by 3 desc;

-- continent

-- Looking at continent with highst death count

select location , population , max(cast(total_deaths as bigint)) as 'Highest death count' 
from covid..CovidDeaths$
where continent is  null
group by Location , population
order by 3 desc;


-- Global

select sum(new_cases) as 'total new cases', sum( cast (new_deaths as bigint)) as 'total new deaths' , (sum( cast (new_deaths as bigint)) / sum(new_cases) ) as 'new death percentage'
from covid..CovidDeaths$
where continent is not null
--group by date
order by 3 desc;


-- Looking at total population vs vaccenation

select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
, sum( cast(vac.new_vaccinations as bigint)) over (partition by dea.Location order by dea.Location , dea.date) as 'Rolling vaccinated people'
from covid..CovidDeaths$ dea
join covid..Covidvaccenations$ vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 5 desc;


-- making cte

with popvc (continent , Location, date, population, new_vaccinations, RollingVaccinatedPeople)
as
(
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
, sum( cast(vac.new_vaccinations as bigint)) over (partition by dea.Location order by dea.Location , dea.date) as RollingVaccinatedPeople
from covid..CovidDeaths$ dea
join covid..Covidvaccenations$ vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
)

select * , concat((RollingVaccinatedPeople / population) * 100 ,'%') 
from popvc
order by 7desc;

create view RollPOfVaccinations as
with popvc (continent , Location, date, population, new_vaccinations, RollingVaccinatedPeople)
as
(
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
, sum( cast(vac.new_vaccinations as bigint)) over (partition by dea.Location order by dea.Location , dea.date) as RollingVaccinatedPeople
from covid..CovidDeaths$ dea
join covid..Covidvaccenations$ vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
)

select * , concat((RollingVaccinatedPeople / population) * 100 ,'%')  as PercentageVaccedRolls
from popvc
-- order by 7desc;