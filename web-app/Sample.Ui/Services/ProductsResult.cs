namespace Sample.Ui.Services
{
    public class ProductsResult
    {
        public List<Product>? Products { get; set; }

        public string? ErrorMessage { get; set; }

        public bool Success { get; set; }
    }
}
