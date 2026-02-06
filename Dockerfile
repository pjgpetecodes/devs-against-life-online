# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY DevelopersAgainstHumanity/DevelopersAgainstHumanity.csproj DevelopersAgainstHumanity/
RUN dotnet restore DevelopersAgainstHumanity/DevelopersAgainstHumanity.csproj

# Copy everything else and build
COPY DevelopersAgainstHumanity/ DevelopersAgainstHumanity/
COPY black-cards.txt .
COPY white-cards.txt .
WORKDIR /src/DevelopersAgainstHumanity
RUN dotnet build DevelopersAgainstHumanity.csproj -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish DevelopersAgainstHumanity.csproj -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 80
EXPOSE 443

COPY --from=publish /app/publish .
COPY --from=publish /src/black-cards.txt /app/
COPY --from=publish /src/white-cards.txt /app/

ENTRYPOINT ["dotnet", "DevelopersAgainstHumanity.dll"]
