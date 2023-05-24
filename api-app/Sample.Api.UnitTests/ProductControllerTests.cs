using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Internal;
using Sample.Api.Controllers;
using Sample.Api.Data;

namespace Sample.Api.UnitTests
{
    [TestClass]
    public class ProductControllerTests
    {
        [TestMethod]
        public void CanGetAListOfProducts()
        {
            var options = new DbContextOptionsBuilder<SampleApiContext>()
            .UseInMemoryDatabase(databaseName: "ProductsDatabase")
            .Options;

            using (var context = new SampleApiContext(options))
            {
                context.Product.AddRange(context.GetSeedDataProducts());
                context.SaveChanges();

                var controller = new ProductsController(context);
                var result = controller.GetProduct().Result;

                Assert.IsNotNull(result);
                                
                var products = result.Value;
                Assert.IsNotNull(products);

                Assert.AreEqual(2, products.Count());
            }
        }
    }
}