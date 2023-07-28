Use project;
SELECT * FROM CovidDeaths
where continent is not null
ORDER BY 3, 4;

----SELECT * FROM CovidVaccinations
--ORDER BY 3, 4;

SELECT location, date, total_cases,
new_cases, total_deaths, population FROM CovidDeaths
where continent is not null
ORDER BY 1,2;

--Looking at total cases vs total deaths
--Shows the likelihood of dying if you contract covid in a particular country
SELECT location, date, total_cases, total_deaths,
(total_deaths/total_cases) * 100 as DeathPercentage
FROM CovidDeaths
where continent is not null
--WHERE location LIKE '%INDIA'
ORDER BY 1, 2

--Looking at the total cases vs population
SELECT location, date, population, total_cases,
(total_cases/population) * 100 as CovidPositivePercentage
FROM CovidDeaths
--where continent is not null
WHERE location LIKE '%INDIA'
ORDER BY 1, 2

--Looking at countries with highest infection rate with respect to population

SELECT location, population, MAX(total_cases) AS HighestInfectioncount, 
(MAX(total_cases)/population) * 100 as HighestInfectionRate
FROM CovidDeaths
where continent is not null
GROUP BY location, population
ORDER BY HighestInfectionRate DESC

--Showing countries with highest death rate per population

SELECT location, population, MAX(cast (total_deaths as INT)) AS TotalDeathcount, 
(MAX(cast (total_deaths as INT))/population) * 100 as HighestDeathRate
FROM CovidDeaths
where continent is not null
GROUP BY location, population
ORDER BY TotalDeathcount DESC

--Looking at data with respect to continent
--Showng the continents with the highest death count

SELECT location, MAX(cast (total_deaths as INT)) AS TotalDeathcount 
FROM CovidDeaths
where continent is null
GROUP BY location
ORDER BY TotalDeathcount DESC


--Global Numbers (New cases, Deaths and Death Percentage for the whole world grouped by dates)

SELECT date, SUM(new_cases) AS newtotalcases, 
SUM(CAST(new_deaths as INT)) AS totaldeaths, 
SUM(CAST(new_deaths as INT))/SUM(new_cases) * 100 
AS DeathPercentage
FROM CovidDeaths
WHERE  continent is not null
GROUP BY date
ORDER BY 1

--Overall Total cases and death percentage

SELECT SUM(new_cases) AS newtotalcases, 
SUM(CAST(new_deaths as INT)) AS totaldeaths, 
SUM(CAST(new_deaths as INT))/SUM(new_cases) * 100 
AS DeathPercentage
FROM CovidDeaths
WHERE  continent is not null

--Using second table too
SELECT * FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations,
 SUM(CAST(new_vaccinations AS int)) 
 OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date)
 AS Rollingpeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


--USE CTE
with popvsvac (continent, location, date, population, New_vaccinations, Rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS Rollingpeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
Select *, (Rollingpeoplevaccinated/population)*100 from popvsvac;


With popvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



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
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated