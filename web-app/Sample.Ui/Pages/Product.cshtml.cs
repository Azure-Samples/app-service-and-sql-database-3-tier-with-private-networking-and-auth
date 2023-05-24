using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Sample.Ui.Services;

namespace Sample.Ui.Pages
{
    public class ProductModel : PageModel
    {
        private readonly IProductService _productService;

        [BindProperty]
        public Product? Product { get; set; }

        public ProductModel(IProductService productService)
        {
            _productService = productService;
        }

        public void OnGet(int id)
        {
            var result = _productService.GetProduct(id).Result;
            if(result.Success)
            {
                Product = result.Product ?? new Product(); 
            }
            else
            {
                Product = new Product();
            }
        }

        public async Task<IActionResult> OnPostAsync(int id)
        {
            if (!ModelState.IsValid)
            {
                return Page();
            }

            if (Product != null)
            {

                var result = id == 0 ? await _productService.CreateProduct(Product) : await _productService.UpdateProduct(Product);
                if (result.Success)
                {
                    Product = result.Product ?? new Product();
                }
            }

            return id == 0 ? RedirectToPage("Product", new { id = Product?.Id ?? 0 }) : Page();
        }
    }
}
