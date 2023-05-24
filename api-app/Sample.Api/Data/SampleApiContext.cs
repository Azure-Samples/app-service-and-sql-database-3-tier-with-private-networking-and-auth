using Microsoft.EntityFrameworkCore;
using Sample.Api.Models;

namespace Sample.Api.Data
{
    public class SampleApiContext : DbContext
    {
        public SampleApiContext (DbContextOptions<SampleApiContext> options)
            : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Product>().HasData(GetSeedDataProducts());
        }

        public DbSet<Product> Product { get; set; } = default!;

        public Product[] GetSeedDataProducts() => new Product[]
        {
            new Product
            {
                Id = 1,
                Name = "Super Shampoo",
                Description = @"Lovely shampoo for your hair",
                Category = "Personal Hygiene"
            },
            new Product
            {
                Id = 2,
                Name = "Super Hand Soap",
                Description = "Great for cleaning hands",
                Category = "Personal Hygiene"
            }
        }; 
    }
}
