/*
Covid 19 Data Exploration
Skils Used: Joins, CTE's, Templ Tables, Windows Functions, Creating Views, Coverting Data Types

*/

select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- select data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2



-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2



-- Countries with Highest Infection Rate compared to Population
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location,population
order by PercentPopulationInfected desc

-- countries with the hightest death count per population 
Select location, population, max(cast(total_deaths as int)) as HighestDeathCount --, max((total_deaths/population)*100) as PercentPopulationDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by HighestDeathCount desc


--- BREAKING THINGS DOWN BY CONTINENT
--- showing continent with highest death count per population
Select continent, max(cast(total_deaths as int)) as HighestDeathCount --, max((total_deaths/population)*100) as PercentPopulationDeath
from PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by HighestDeathCount desc


--- GLOBAL NUMBERS

select 
sum(new_cases) as total_cases,
sum(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select * from CovidVaccinations
select * from CovidDeaths


--- Looking at total Population vs Vaccinations




select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)* 100 : cant get percent vaccinated so will use CTE in the next code block 

---  ^ adding up new vaccinations as rolling total by location 

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) -- CTE columns must match used query
as 
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)* 100 : cant get percent vaccinated so will use CTE in the next code block 

---  ^ adding up new vaccinations as rolling total by location 

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3  -- cant use order by in CTE views
)

select *, (RollingPeopleVaccinated/Population) * 100
from PopvsVac


--- Temp Table
DROP table if exists ##PercentPopulationVaccinated --- drops the table when rerunning so duplicate tables are not created
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)* 100 

---  ^ adding up new vaccinations as rolling total by location 

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3  -- cant use order by in CTE 

select *, (RollingPeoplevaccinated/Population)*100
from #PercentPopulationVaccinated



---Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated as 

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)* 100 


from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--- order by 2,3 


Select * from PercentPopulationVaccinated --- now this view is stored under views table