unit URest.Model;

interface

uses
   System.SysUtils, System.JSON, REST.Types, REST.Client, Data.Bind.Components,
   Data.Bind.ObjectScope;

type
   TRest = class
      private
         vClient   : TRESTClient;
         vRequest  : TRESTRequest;
         vResponse : TRESTResponse;

         constructor Create;
         procedure ConfiguraRequest;
      public
         function GetDatos(pUrl, pAuth : String) : TJSONArray;
      published
         class function getInstancia : TRest;
   end;

implementation

var
   _instance : TRest;

{ TRestRequest }

constructor TRest.Create;
begin
   inherited Create;
   ConfiguraRequest;
end;

class function TRest.getInstancia : TRest;
begin
   if _instance = nil then
      _instance := TRest.Create;

   Result := _instance;
end;

procedure TRest.ConfiguraRequest;
begin
   try
      if vClient = nil then
         vClient := TRESTClient.Create(nil);

      if vRequest = nil then
         vRequest := TRESTRequest.Create(nil);

      if vResponse = nil then
         vResponse := TRESTResponse.Create(nil);

      vRequest.Client   := vClient;
      vRequest.Response := vResponse;
   except
      on e:Exception do
      begin
         raise Exception.Create('Falha ao configurar Request: ' + e.Message);
      end;
   end;
end;

function TRest.GetDatos(pUrl, pAuth: String): TJSONArray;
var
   xObjJsonValue : TJSONValue;
   xObjJson      : TJSONObject;
begin
   Result := nil;
   try
      vClient.BaseURL := pUrl;
      vRequest.Method := rmGET;

      if pAuth <> EmptyStr then
      begin
         vRequest.Params.AddHeader('Authorization', pAuth);
         vRequest.Params.ParameterByName('Authorization').Options := [poDoNotEncode];
      end;

      vRequest.Execute;

      if vResponse.StatusCode = 200 then
      begin
         xObjJsonValue := TJSONObject.ParseJSONValue(vResponse.Content);

         if xObjJsonValue is TJSONArray then
            Result := TJSONArray(xObjJsonValue)
         else
         if xObjJsonValue is TJSONObject then
         begin
            Result   := TJSONArray.Create;
            xObjJson := TJSONObject(xObjJsonValue);

            Result.AddElement(xObjJson);
         end
         else
            if xObjJsonValue <> nil then
               FreeAndNil(xObjJsonValue);
      end;
   except
      on e:Exception do
      begin
         raise Exception.Create('Falha ao obter os dados: ' + e.Message);
      end;
   end;
end;

end.
