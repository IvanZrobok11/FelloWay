using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace FelloWay.Api.OpenApi;

public class SharedContractsDocumentFilter(IWebHostEnvironment environment) : IDocumentFilter
{
    public void Apply(OpenApiDocument swaggerDoc, DocumentFilterContext context)
    {
        var contractsRoot = OpenApiContractMerger.ResolveContractsRoot(environment);
        if (!Directory.Exists(contractsRoot))
        {
            return;
        }

        var merged = OpenApiContractMerger.LoadMerged(contractsRoot);

        foreach (var path in merged.Paths)
        {
            swaggerDoc.Paths[path.Key] = path.Value;
        }

        swaggerDoc.Components ??= new OpenApiComponents();
        merged.Components ??= new OpenApiComponents();

        foreach (var schema in merged.Components.Schemas)
        {
            swaggerDoc.Components.Schemas[schema.Key] = schema.Value;
        }

        foreach (var parameter in merged.Components.Parameters)
        {
            swaggerDoc.Components.Parameters[parameter.Key] = parameter.Value;
        }

        foreach (var response in merged.Components.Responses)
        {
            swaggerDoc.Components.Responses[response.Key] = response.Value;
        }

        foreach (var scheme in merged.Components.SecuritySchemes)
        {
            swaggerDoc.Components.SecuritySchemes[scheme.Key] = scheme.Value;
        }

        swaggerDoc.Info.Description = merged.Info.Description;
    }
}
