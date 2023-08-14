Select *
From PortfolioProject1..CovidDeaths
Order By 3, 4

Select *
From PortfolioProject1..CovidDeaths
Where continent is not null
Order By 3,4

--Select *
--From PortfolioProject1..CovidVaccinations
--Order By 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
Order By 1,2

--Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%nigeria%'
Order By 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, Population, total_cases, (total_cases/population)*100 AS DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%nigeria%'
Order By 1,2

--Looking at countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100
AS PercentPopulationInfected
From PortfolioProject1..CovidDeaths
Group By Location, Population
Order By PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast (total_deaths as int)) AS TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null
Group By Location
Order By TotalDeathCount desc

--Showing continents with the highest death count per population

Select Continent, MAX(cast(total_deaths as int))
AS TotalDeathCount
From PortfolioProject1..CovidDeaths
Where Continent is not null
Group By Continent
Order By TotalDeathCount desc

Select location, MAX(cast(total_deaths as int))
AS TotalDeathCount
From PortfolioProject1..CovidDeaths
Where Continent is null
Group By location
Order By TotalDeathCount desc

--Global Numbers
Select date, Population, total_cases, (total_cases/population)*100 AS DeathPercentage
From PortfolioProject1..CovidDeaths
--Where location like '%nigeria%'
Where continent is not null
Order By 1,2


-- Global Numbers across the world
Select date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))
/SUM(New_Cases)*100 AS DeathPercentage
From PortfolioProject1..CovidDeaths
Where continent is not null
Group By date
Order By 1,2


-- Death cases across the world

Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))
/SUM(New_Cases)*100 AS DeathPercentage
From PortfolioProject1..CovidDeaths
Where continent is not null
--Group By date
Order By 1,2

-- Merging the CovidDeaths and CovidVaccinations Table

Select *
From PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
Order By 2,3

-- Rolling People Vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date)
AS RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
Order By 2,3



-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
As
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date)
AS RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac


-- Calculating the Percentage of the Rolling People Vaccinated 
--Run it with CTE then edit the last select statment to remove errors

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
As
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date)
AS RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date)
AS RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date)
AS RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated



Select *
From PercentPopulationVaccinated

