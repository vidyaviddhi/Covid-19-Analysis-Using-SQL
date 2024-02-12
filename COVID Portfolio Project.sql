Select * 
From Portfolioprojects..CovidDeaths
Where continent is not null
order by 3,4

--Select * 
--From Portfolioprojects..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolioprojects..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolioprojects..CovidDeaths
Where location like '%state%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--shows what percentage of population got covid
Select Location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolioprojects..CovidDeaths
--Where location like '%state%'
Where continent is not null
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount ,Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolioprojects..CovidDeaths
--Where location like '%state%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc 


-- Showing Countries with Highest Death Count per Population
Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioprojects..CovidDeaths
--Where location like '%state%'
Where continent is not null
Group by Location
order by TotalDeathCount desc 

--LET'S BREAK THINGS DOWN BY CONTINENT

---Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
--From Portfolioprojects..CovidDeaths
--Where location like '%state%'
--Where continent is not null
--Group by continent
--order by TotalDeathCount desc 

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioprojects..CovidDeaths
--Where location like '%state%'
Where continent is  null
Group by location
order by TotalDeathCount desc 

---showing continents with the highest death count per population
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioprojects..CovidDeaths
Where location like '%state%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select date,SUM(New_cases) as total_cases,SUM(cast(New_deaths as int)) as total_deaths,SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolioprojects..CovidDeaths
--Where location like '%state%'
Where continent is not null
group by date
order by 1,2

Select SUM(New_cases) as total_cases,SUM(cast(New_deaths as int)) as total_deaths,SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolioprojects..CovidDeaths
--Where location like '%state%'
Where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location,dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
order by 2,3


---use cte

with PopvsVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


----TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




---Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated 
