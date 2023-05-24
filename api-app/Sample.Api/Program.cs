using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Sample.Api.Data;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<SampleApiContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("SampleApiContext") ?? throw new InvalidOperationException("Connection string 'SampleApiContext' not found.")));

// Add services to the container.
builder.Services.AddControllers();

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();

// Make the implicit Program class public so test projects can access it
public partial class Program { }