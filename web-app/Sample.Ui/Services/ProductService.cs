using Azure.Core;
using Azure.Identity;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Net.Http.Headers;

namespace Sample.Ui.Services
{
    public class ProductService : IProductService
    {
        private HttpClient _httpClient;
        private readonly IApiConfigService _apiConfigService;

        public ProductService(IApiConfigService apiConfigService)
        {
            _apiConfigService = apiConfigService;
            _httpClient = GetClient().Result;
        }

        private async Task<HttpClient> GetClient()
        {
            // The resource URI of the App Registration
            var jwt = string.Empty;
            var apiAuthUri = _apiConfigService.Get(ApiConfigType.ApiAuthUri);
            if (!string.IsNullOrWhiteSpace(apiAuthUri))
            {
                jwt = await GetTokenAsync(apiAuthUri);
            }
            var httpClient = new HttpClient()
            {
                BaseAddress = new Uri(_apiConfigService.Get(ApiConfigType.ApiUri))
            };

            if (apiAuthUri != null)
            {
                // Add the JWT to the request headers as a bearer token (this is the default for the `validate-azure-ad-token` policy, but you could override it and use a different header)
                httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", jwt);
            }

            return httpClient;
        }

        public static async Task<string> GetTokenAsync(string? targetAppUri)
        {
            // Use the built in ManagedIdentityCredential class to retrieve the managed identity, filtering on client ID if user assigned. We could also use the DefaultAzureCredential class to make debugging simpler.
            var msiCredentials = new ManagedIdentityCredential();

            // Use the GetTokenAsync method to generate a JWT for use in a HTTP request
            var accessToken = await msiCredentials.GetTokenAsync(new TokenRequestContext(new[] { $"{targetAppUri}/.default" }));
            var jwt = accessToken.Token;
            return jwt;
        }

        public async Task<ProductsResult> GetProducts()
        {
            var productResponse = await _httpClient.GetAsync("/api/products");

            var result = new ProductsResult()
            {
                Success = productResponse.IsSuccessStatusCode,
                ErrorMessage = productResponse.ReasonPhrase,
            };

            if (productResponse.IsSuccessStatusCode)
            {
                var products = JsonConvert.DeserializeObject<List<Product>>(await productResponse.Content.ReadAsStringAsync());
                result.Products = products;
            }

            return result;
        }

        public async Task<ProductResult> GetProduct(int id)
        {
            var productResponse = await _httpClient.GetAsync($"/api/products/{id}");

            var result = new ProductResult()
            {
                Success = productResponse.IsSuccessStatusCode,
                ErrorMessage = productResponse.ReasonPhrase,
            };

            if (productResponse.IsSuccessStatusCode)
            {
                var product = JsonConvert.DeserializeObject<Product>(await productResponse.Content.ReadAsStringAsync());
                result.Product = product;
            }

            return result;
        }

        public async Task<ProductResult> UpdateProduct(Product product)
        {

            var productResponse = await _httpClient.PutAsJsonAsync($"/api/products/{product.Id}", product);

            var result = new ProductResult()
            {
                Success = productResponse.IsSuccessStatusCode,
                ErrorMessage = productResponse.ReasonPhrase,
            };

            if (productResponse.IsSuccessStatusCode)
            {
                result.Product = product;
            }

            return result;
        }

        public async Task<ProductResult> CreateProduct(Product product)
        {
            var productResponse = await _httpClient.PostAsJsonAsync($"/api/products", product);

            var result = new ProductResult()
            {
                Success = productResponse.IsSuccessStatusCode,
                ErrorMessage = productResponse.ReasonPhrase,
            };

            if (productResponse.IsSuccessStatusCode)
            {
                var newProduct = JsonConvert.DeserializeObject<Product>(await productResponse.Content.ReadAsStringAsync());
                result.Product = newProduct;
            }

            return result;
        }
    }
}
