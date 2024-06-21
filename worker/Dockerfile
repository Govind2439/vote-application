# Use the official .NET 8 SDK image as a build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY src/Worker/Worker.csproj ./src/Worker/
RUN dotnet restore ./src/Worker

# Copy the remaining files and build
COPY src/Worker/ ./src/Worker/
RUN dotnet publish ./src/Worker -c Release -o /app/out

# Use the official .NET 8 runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build-env /app/out .

# Set the entry point for the container
ENTRYPOINT ["dotnet", "Worker.dll"]

