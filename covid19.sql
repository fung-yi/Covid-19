select * from CovidDeaths
where continent is not null
order by 3,4

select * from CovidVaccinations
where continent is not null
order by 3,4

-- Select Data that we are gooing to be using
Select location,  date , total_cases, new_cases, total_deaths,population
from CovidDeaths
where continent is not null
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you cnotract covid in your country
Select location,  date , total_cases, total_deaths,
        CAST(total_deaths AS DOUBLE)/CAST(total_cases AS DOUBLE)*100 as DeathPercentage
from CovidDeaths
where location like '%state%' and continent is not null
order by 1, 2

-- Looking at Total Cases vs population
-- Shows what perecentage of population got Covid
Select location,  date , population, 
        CAST(total_cases AS DOUBLE)/CAST(population AS DOUBLE)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%state%' and continent is not null
order by 1, 2


-- Looking at Countries with Highest Infectiion Rate compared to Population
Select location,  population, max(total_cases) as HighestInfectionCount, 
        CAST(total_cases AS DOUBLE)/CAST(population AS DOUBLE)*100 as PercentPopulationInfected
from CovidDeaths
where continent is not null
group by location
order by PercentPopulationInfected desc

 
-- Showing Countires with Highest Death Count per population
Select location, max(cast(total_deaths as INTEGER)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the hightest death count per population
Select location, max(cast(total_deaths as INTEGER)) as TotalDeathCount
from CovidDeaths
where continent is null 
      and not(location like "%income%" ) 
      and not(location like "%union%" )
	  and not(location like "%world%" )
group by location
order by TotalDeathCount desc


-- Showing income with the hightest death count per population
Select location, max(cast(total_deaths as INTEGER)) as TotalDeathCount
from CovidDeaths
where continent is null 
        and (location like "%income%" )
        --and ((location like "%income%" ) or (location like "%world%" ) )
group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select  date, sum(new_cases) as daily_new_cases,sum(cast(new_deaths as int)) as daily_new_deaths, 
        sum(cast(new_deaths as double))/sum(cast(new_cases as double))*100 as daily_new_DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2



Select  date, sum(total_cases),sum(total_deaths),
        sum(cast(total_deaths as double))/sum(cast(total_cases as double))*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2


-- Looking at Total population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as integer)) OVER 
         (PARTITION by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths as dea join CovidVaccinations as vac
   on dea.location=vac.location
      and dea.date=vac.date
WHERE dea.continent is not NULL
order by 2,3



-- USE CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as integer)) OVER 
         (PARTITION by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths as dea join CovidVaccinations as vac
   on dea.location=vac.location
      and dea.date=vac.date
WHERE dea.continent is not NULL

)
select * , (cast (RollingPeopleVaccinated as double)/cast (Population as double))*100
from PopvsVac

-- TEMP TABLE
DROP Table if exists PercentPopulationVaccinated

Create Table PercentPopulationVaccinated
(
continent TEXT,
Location TEXT,
Date TEXT,
Population INTEGER,
New_vaccinations INTEGER,
RollingPeopleVaccinated INTEGER)

Insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as integer)) OVER 
         (PARTITION by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths as dea join CovidVaccinations as vac
   on dea.location=vac.location
      and dea.date=vac.date
WHERE dea.continent is not NULL

select * , (cast (RollingPeopleVaccinated as double)/cast (Population as double))*100
from PercentPopulationVaccinated

DROP Table if exists PercentPopulationVaccinated

-- Creating View to store date for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as integer)) OVER 
         (PARTITION by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths as dea join CovidVaccinations as vac
   on dea.location=vac.location
      and dea.date=vac.date
WHERE dea.continent is not NULL

select * from PercentPopulationVaccinated