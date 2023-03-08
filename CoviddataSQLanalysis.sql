SELECT *
FROM CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM CovidVaccinations
--order by 3,4

--Select the Data I am going to be using


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Nigeria

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%Nigeria%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid


SELECT Location, date, total_cases,Population, (total_cases/Population)*100 as PercentPopulationinfected
FROM CovidDeaths
--WHERE location like '%Nigeria%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationinfected
FROM CovidDeaths
--WHERE location like '%Nigeria%'
GROUP BY Location, Population
order by PercentPopulationinfected DESC

--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY Location
order by TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT


--Showing Continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC


--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
--Group by date
order by 1,2



--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100 
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100 
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100 
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store date for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100 
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated
