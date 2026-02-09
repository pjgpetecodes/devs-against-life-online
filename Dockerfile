# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY DevsAgainstLife/DevsAgainstLife.csproj DevsAgainstLife/
RUN dotnet restore DevsAgainstLife/DevsAgainstLife.csproj

# Copy everything else and build
COPY DevsAgainstLife/ DevsAgainstLife/
COPY black-cards.txt .
COPY white-cards.txt .
WORKDIR /src/DevsAgainstLife
RUN dotnet build DevsAgainstLife.csproj -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish DevsAgainstLife.csproj -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 80
EXPOSE 443

COPY --from=publish /app/publish .
COPY --from=publish /src/black-cards.txt /app/
COPY --from=publish /src/white-cards.txt /app/

ENTRYPOINT ["dotnet", "DevsAgainstLife.dll"]
