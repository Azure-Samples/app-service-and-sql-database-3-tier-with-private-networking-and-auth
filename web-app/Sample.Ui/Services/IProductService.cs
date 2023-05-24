namespace Sample.Ui.Services
{
    public interface IProductService
    {
        Task<ProductsResult> GetProducts();
        Task<ProductResult> GetProduct(int id);
        Task<ProductResult> UpdateProduct(Product product);
        Task<ProductResult> CreateProduct(Product product);
    }
}