using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Sample.Ui.Services;

namespace Sample.Ui.Pages
{
    public class ProductsModel : PageModel
    {
        private readonly IProductService _productService;

        public List<Product>? Products { get; set; }

        public ProductsModel(IProductService productService)
        {
            _productService = productService;
        }

        public void OnGet()
        {
            var result = _productService.GetProducts().Result;
            if(result.Success)
            {
                Products = result.Products ?? new List<Product>(); 
            }
        }
    }
}
