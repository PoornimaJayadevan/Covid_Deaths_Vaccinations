Use project;

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- 2. 


Select continent, date, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
--and location not in ('World', 'European Union', 'International')
Group by continent, date
order by TotalDeathCount desc

-- 3.


Select continent, Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected --The column total_cases represents a rolling sum
From CovidDeaths
Where continent is not null
Group by Location, Population, continent
order by PercentPopulationInfected desc;


-- 4.

Select continent, Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Where continent is not null
Group by continent, Location, Population, date
order by PercentPopulationInfected desc

--5

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
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
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac