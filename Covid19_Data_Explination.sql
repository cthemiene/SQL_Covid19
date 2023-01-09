/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


-- Select Data that we are going to be starting with
SELECT [location],[date],total_cases,new_cases,total_deaths,population
FROM    [owid-covid-data_deaths1]
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
-- Cast from int to decimal
SELECT [location],[date],total_cases, total_deaths, FORMAT((CAST(total_deaths AS DECIMAL(18,4))/CAST(total_cases AS DECIMAL(18,4))), 'P2') as DeathPercent
FROM    [owid-covid-data_deaths1]
WHERE LOCATION like '%state%'
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT [location],[date],total_cases, population, FORMAT((CAST(total_cases AS DECIMAL(18,4))/CAST(population AS DECIMAL(18,4))), 'P2') as CaughtPercent
FROM    [owid-covid-data_deaths1]
--WHERE LOCATION like '%state%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(cast(total_cases as int)) as HighestInfectionCount,  Max((cast(total_cases as decimal)/cast(population as decimal)))*100 as PercentPopulationInfected
From [owid-covid-data_deaths1]
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [owid-covid-data_deaths1]
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [owid-covid-data_deaths1]
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(cast(new_cases as decimal))*100 as DeathPercentage
FROM [owid-covid-data_deaths1]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as decimal)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [owid-covid-data_deaths1]  dea
JOIN [owid-covid-data_vaccination1]  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [owid-covid-data_deaths1] dea
Join [owid-covid-data_vaccination1] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [owid-covid-data_deaths1] dea
Join [owid-covid-data_vaccination1] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
/* 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [owid-covid-data_deaths1] dea
Join [owid-covid-data_vaccination1] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null  */
