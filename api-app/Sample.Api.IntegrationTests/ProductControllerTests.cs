using IntegrationTests.Helpers;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.VisualStudio.TestPlatform.TestHost;
using Newtonsoft.Json;
using Sample.Api.Data;
using Sample.Api.Models;
using System.Net;

namespace Sample.Api.IntegrationTests
{
    [TestClass]
    public class ProductControllerTests
    {
        private readonly TestWebApplicationFactory<Program> _factory;
        private readonly HttpClient _httpClient;

        public ProductControllerTests()
        {
            _factory = new TestWebApplicationFactory<Program>();
            _httpClient = _factory.CreateClient();
        }

        [TestMethod]
        public void CanGetAListOfProducts()
        {
            using (var scope = _factory.Services.CreateScope())
            {
                var context = scope.ServiceProvider.GetService<SampleApiContext>();
                if (context != null)
                {
                    context.Product.AddRange(context.GetSeedDataProducts());
                    context.SaveChanges();
                }
            }

            var response = _httpClient.GetAsync("/api/products").Result;
            Assert.AreEqual(HttpStatusCode.OK, response.StatusCode);

            var productsJson = response.Content.ReadAsStringAsync().Result;
            var products = JsonConvert.DeserializeObject<List<Product>>(productsJson);

            Assert.IsNotNull(products);
            Assert.AreEqual(2, products.Count());
        }
    }
}