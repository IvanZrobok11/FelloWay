FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY admin/ ./admin/
RUN dotnet restore admin/FelloWay.Admin.csproj \
    && dotnet publish admin/FelloWay.Admin.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "FelloWay.Admin.dll"]
