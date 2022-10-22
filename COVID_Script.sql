select * from [Covid project]..[Covid-deaths]
--Where continent is not null
order by 3,4

--select * from [Covid project]..[Covid-Vaccination]
--order by 3,4


--select the data that we are going to be using
select location,date, total_cases, new_cases, total_deaths, population 
from [Covid project]..[Covid-deaths]
order by 3

--Looking at total cases vs total deaths 
--likelihood of dying if you get covid in France
select location,date, total_cases, total_deaths, Case total_cases when 0 then 0 else 100*(total_deaths/total_cases) end as DeatPercentage
from [Covid project]..[Covid-deaths]
Where location like '%France%'
order by 1,2

-- looking at total cases vs population
--shows percentage of population who got covid
select location,date, total_cases, population, 100*(total_cases/population) as CasesPercentage
from [Covid project]..[Covid-deaths]
Where location like '%France%'
order by 1,2


-- Looking at countries with highest infection rate campared to population
select location,Max(population) as population, max(total_cases) as highestNumberOfCases,  100*Max((total_cases/population)) as CasesPercentage
from [Covid project]..[Covid-deaths]
--Where location like '%France%'
group by location, population
order by 4 Desc

-- Looking at countries with highest death count campared to population
select location,Max(population) as population, max(CAST(total_deaths as bigint)) as MaxDeaths,  100*Max((total_deaths/population)) as MaxDeathPercentage
from [Covid project]..[Covid-deaths]
--Where location like '%France%'
where continent is not null
group by location, population
order by 3 Desc

--BREAKING DOWN BY CONTINENT
-- Looking at continents with highest death count campared to population
select continent,Max(population) as Maxpopulation, max(CAST(total_deaths as bigint)) as MaxDeaths
from [Covid project]..[Covid-deaths]
--Where location like '%France%'
where continent is not null
group by continent
order by 3 Desc

-- GLOBAL NUMBERS
select  SUM(new_cases) as Cases, SUM(Cast(new_deaths as bigint)) as Deaths,100*(SUM(Cast(new_deaths as bigint))/SUM(new_cases)) as DeathsPercentage
from [Covid project]..[Covid-deaths]
Where continent is not null
--group by date
order by 1,2


--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as rollingPeopleVaccinated
from [dbo].[Covid-Vaccination] vac
Join [dbo].[Covid-deaths] dea on dea.location=vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--USE CTE

With Popvsvac ( continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as rollingPeopleVaccinated

from [dbo].[Covid-Vaccination] vac
Join [dbo].[Covid-deaths] dea on dea.location=vac.location
and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, 100*RollingPeopleVaccinated/population 
from Popvsvac


-- CREATE TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as rollingPeopleVaccinated
from [dbo].[Covid-Vaccination] vac
Join [dbo].[Covid-deaths] dea on dea.location=vac.location
and dea.date = vac.date
Where dea.continent is not null

Select *, 100*RollingPeopleVaccinated/population 
from #PercentPopulationVaccinated


-- Creating View to store data for visualization

Create view  PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as rollingPeopleVaccinated
from [dbo].[Covid-Vaccination] vac
Join [dbo].[Covid-deaths] dea on dea.location=vac.location
and dea.date = vac.date
 -- Where dea.continent is not null
