namespace Sample.Ui.Services
{
    public class ApiConfigService : IApiConfigService
    {
        private readonly Dictionary<ApiConfigType, string> _apiConfig;

        public ApiConfigService()
        {
            _apiConfig = new Dictionary<ApiConfigType, string>
            {
                { ApiConfigType.ApiUri , Environment.GetEnvironmentVariable("ApiUri") ?? "https://localhost:7099/" },
                { ApiConfigType.ApiAuthUri, Environment.GetEnvironmentVariable("ApiAuthUri") ?? "" }
            };
        }

        public string Get(ApiConfigType configType)
        {
            return _apiConfig[configType];
        }
    }

    public enum ApiConfigType
    {
        ApiUri,
        ApiAuthUri
    }
}
