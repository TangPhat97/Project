SELECT *
FROM	Project..CovidDeaths
Where continent is not null 
ORDER BY 3,4

--SELECT *
--FROM	Project..CovidVaccinations
--ORDER BY 1,2

--Select data that we are going to be using

SELECT	Location, date, total_cases, new_cases,total_deaths, population
FROM Project.dbo.CovidDeaths
Where continent is not null 
ORDER BY 1,2


-- Looking at Total Cases VS Total Deaths
SELECT	Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Project..CovidDeaths
WHERE location LIKE '%nam'
and continent is not null 
ORDER BY 1,2

-- Looking at Total Cases VS Population
-- Show what pepple got covid
SELECT	Location, date, total_cases, population, (total_cases/population)*100 AS PeopleGotCovidPercentage
FROM Project..CovidDeaths
WHERE location LIKE '%nam'
AND continent is not null 
ORDER BY 1,2

 --Looking at Countries  with the highest infection rate compared population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Project..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--Looking the date have greatest number of Vietnamese who infected Covid
SELECT date,population,
(SELECT MAX(total_cases) FROM Project..CovidDeaths WHERE location LIKE '%nam') AS Vietnameseinfected
FROM Project..CovidDeaths
--WHERE location LIKE '%nam'
AND total_cases= (SELECT MAX(total_cases) FROM Project..CovidDeaths WHERE location LIKE '%nam')

--Looking the date have minimum number of Vietnamese who infected Covid
SELECT date,population,
(SELECT min(total_cases) FROM Project..CovidDeaths WHERE location LIKE '%nam') AS Vietnameseinfected
FROM Project..CovidDeaths
WHERE location LIKE '%nam'
AND total_cases= (SELECT min(total_cases) FROM Project..CovidDeaths WHERE location LIKE '%nam')


--Showing the contient with the highest Death count per Population
SELECT continent,  MAX(CAST(Total_deaths AS INT )) AS TotalDeathCount 
FROM Project..CovidDeaths
WHERE continent  IS NOT NULL
Group by continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Project..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
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
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

