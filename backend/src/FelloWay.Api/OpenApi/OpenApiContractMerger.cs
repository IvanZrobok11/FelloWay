using System.Text;
using Microsoft.OpenApi.Models;
using Microsoft.OpenApi.Readers;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using YamlDotNet.Serialization;

namespace FelloWay.Api.OpenApi;

/// <summary>
/// Merges domain OpenAPI YAML files from <c>shared/api-contracts</c> for Swashbuckle.
/// </summary>
public static class OpenApiContractMerger
{
    private static readonly string[] DomainOrder = ["common", "auth", "users", "events"];

    public static string ResolveContractsRoot(IWebHostEnvironment environment)
    {
        var candidates = new[]
        {
            Path.GetFullPath(Path.Combine(environment.ContentRootPath, "..", "..", "..", "..", "shared", "api-contracts")),
            Path.GetFullPath(Path.Combine(environment.ContentRootPath, "..", "..", "..", "shared", "api-contracts")),
        };

        return candidates.FirstOrDefault(Directory.Exists) ?? candidates[0];
    }

    public static OpenApiDocument LoadMerged(string contractsRoot)
    {
        OpenApiDocument? merged = null;
        var reader = new OpenApiStreamReader();
        var yamlDeserializer = new DeserializerBuilder().Build();

        foreach (var domain in DomainOrder)
        {
            var file = Path.Combine(contractsRoot, domain, "openapi.yaml");
            if (!File.Exists(file))
            {
                continue;
            }

            using var yamlReader = File.OpenText(file);
            var yamlObject = yamlDeserializer.Deserialize(yamlReader);
            var json = NormalizeFragmentJson(JsonConvert.SerializeObject(yamlObject));
            using var stream = new MemoryStream(Encoding.UTF8.GetBytes(json));
            var doc = reader.Read(stream, out _);
            if (doc is null)
            {
                continue;
            }

            merged = merged is null ? doc : Merge(merged, doc);
        }

        merged ??= new OpenApiDocument
        {
            Info = new OpenApiInfo
            {
                Title = "FelloWay API",
                Version = "v1",
            },
        };

        merged.Info ??= new OpenApiInfo { Title = "FelloWay API", Version = "v1" };
        merged.Info.Title = "FelloWay API";
        merged.Info.Version = "v1";
        merged.Info.Description =
            "Merged from shared/api-contracts (auth, users, common, events). " +
            "Runtime routes are implemented in FelloWay.Api controllers.";

        return merged;
    }

    private static OpenApiDocument Merge(OpenApiDocument target, OpenApiDocument source)
    {
        foreach (var path in source.Paths)
        {
            target.Paths[path.Key] = path.Value;
        }

        target.Components ??= new OpenApiComponents();
        source.Components ??= new OpenApiComponents();

        MergeComponentDictionary(target.Components.Schemas, source.Components.Schemas);
        MergeComponentDictionary(target.Components.Parameters, source.Components.Parameters);
        MergeComponentDictionary(target.Components.Responses, source.Components.Responses);
        MergeComponentDictionary(target.Components.SecuritySchemes, source.Components.SecuritySchemes);

        return target;
    }

    private static void MergeComponentDictionary<T>(IDictionary<string, T> target, IDictionary<string, T> source)
        where T : class
    {
        foreach (var entry in source)
        {
            target[entry.Key] = entry.Value;
        }
    }

    private static string NormalizeFragmentJson(string json)
    {
        var document = JObject.Parse(json);
        document["paths"] ??= new JObject();
        document["openapi"] ??= "3.0.3";
        return document.ToString(Formatting.None);
    }
}
