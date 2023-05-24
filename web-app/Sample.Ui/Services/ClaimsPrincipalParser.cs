using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Http;

namespace Sample.Ui.Services
{

    public static class ClaimsPrincipalParser
    {
        private class ClientPrincipalClaim
        {
            [JsonPropertyName("typ")]
            public string? Type { get; set; }
            [JsonPropertyName("val")]
            public string? Value { get; set; }
        }

        private class ClientPrincipal
        {
            [JsonPropertyName("auth_typ")]
            public string? IdentityProvider { get; set; }
            [JsonPropertyName("name_typ")]
            public string? NameClaimType { get; set; }
            [JsonPropertyName("role_typ")]
            public string? RoleClaimType { get; set; }
            [JsonPropertyName("claims")]
            public IEnumerable<ClientPrincipalClaim>? Claims { get; set; }
        }

        public static ClaimsPrincipal Parse(HttpRequest req)
        {
            var principal = new ClientPrincipal();

            if (req.Headers.TryGetValue("X-MS-CLIENT-PRINCIPAL", out var header))
            {
                var data = header[0];
                var decoded = Convert.FromBase64String(data ?? string.Empty);
                var json = Encoding.UTF8.GetString(decoded);
                principal = JsonSerializer.Deserialize<ClientPrincipal>(json, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            }

            /** 
             *  At this point, the code can iterate through `principal.Claims` to
             *  check claims as part of validation. Alternatively, we can convert
             *  it into a standard object with which to perform those checks later
             *  in the request pipeline. That object can also be leveraged for 
             *  associating user data, etc. The rest of this function performs such
             *  a conversion to create a `ClaimsPrincipal` as might be used in 
             *  other .NET code.
             */

            var identity = new ClaimsIdentity(principal?.IdentityProvider,"name", "");
            if (principal?.Claims != null)
            {
                identity.AddClaims(principal.Claims.Select(c => new Claim(c.Type ?? string.Empty, c.Value ?? string.Empty)));
            }

            var claimsPrincipal = new ClaimsPrincipal(identity);
            return claimsPrincipal;
        }
    }
}