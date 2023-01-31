codeunit 50800 HelloApic
{
    procedure PingApic(): Text
    var
        Request: HttpRequestMessage;
        ReqHeaders: HttpHeaders;
        ReqBody: HttpContent;
        Client: HttpClient;
        Response: HttpResponseMessage;
        ResponseText: Text;

        TokenURL: Label 'https://login.microsoftonline.com/f25493ae-1c98-41d7-8a33-0be75f5fe603/oauth2/v2.0/token';
        ClientID: Label 'ea3c9e85-531b-445d-a565-b6c40d92aefb';
        ClientSecret: label 'lLA7Q~0iLKsYkmMSbXd8_7dPXqWKBiG-6ouEL';
        Scope: Label 'api://461d56b3-85d8-42bf-8ebf-9765a6d77beb/.default';
        APIUrl: label 'https://apitest-awe.volvo.com/vfs/dev/sampleconnectivityapi';
        MessageText: Label '{"template_id":"Hello BC"}';
    begin
        Request.Method := 'POST';
        Request.GetHeaders(ReqHeaders);
        ReqHeaders.Clear();
        ReqHeaders.Add('Authorization', CreateOAuthToken(TokenURL, ClientID, ClientSecret, Scope));
        //ReqHeaders.Add('Content-type', 'application/json');
        ReqHeaders.Add('X-IBM-Client-Id', 'be739ee534a560e5f0c35c8e52ca7d77');
        ReqHeaders.Add('X-IBM-Client-Secret', '8332736de74ad3aee620b7d81116c57e');
        ReqBody.WriteFrom(MessageText);
        request.Content(ReqBody);
        Request.SetRequestUri(APIUrl);
        Client.Send(Request, Response);
        Response.Content.ReadAs(ResponseText);
        exit(ResponseText);
    end;


    local procedure CreateOAuthToken(AuthorityURI: text; ClientID: text; ClientSecret: text; Scope: text): Text;
    var
        OAuth2: Codeunit OAuth2;
        Scopes: List of [Text];
        OAuthFailedErr: Label 'Failed to retrieve access token\%1', Comment = '%1 is the error text';
        AuthHeaderTxt: label 'Bearer %1', Locked = true;
    begin
        if (AccessToken = '') or (AccesTokenExpires = 0DT) or (AccesTokenExpires > CurrentDateTime) then begin
            Scopes.Add(Scope);


            if not OAuth2.AcquireTokenWithClientCredentials(ClientID, ClientSecret,
                                                            AuthorityURI, '', Scopes, AccessToken) then
                Error(OAuthFailedErr, GetLastErrorText());
            AccesTokenExpires := CurrentDateTime + (3599 * 1000);
        end;

        exit(StrSubstNo(AuthHeaderTxt, AccessToken));

    end;

    var
        AuthorityTxt: Label 'https://login.microsoftonline.com/{AadTenantId}/oauth2/v2.0/token';
        AccessToken: Text;
        AccesTokenExpires: DateTime;

}
