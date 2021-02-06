unit Rotas.Bancos;

interface

uses Horse;

procedure Bancos_Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses System.SysUtils, uDM, System.JSON, Horse.Commons, DataSet.Serialize, uFuncoes;

procedure Bancos_Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    ADM: TDM;
    sID: String;
begin
    Req.Params.TryGetValue('id', sID);
    ADM := TDM.Create(nil);
    try
        ADM.qrBancos.Close;
        if not sID.IsEmpty then
        begin
            ADM.qrBancos.SQL.Add('where id = :id');
            ADM.qrBancos.Params[0].AsString := sID;
        end;
        ADM.qrBancos.Open;

        if ADM.qrBancos.RecordCount = 0 then
            GerarErro(Res, 'Nenhuma informação localizada.');
        if sID.IsEmpty then
            Res.Send<TJSONArray>(ADM.qrBancos.ToJSONArray())
        else
            Res.Send<TJSONObject>(ADM.qrBancos.ToJSONObject());
    finally
        ADM.Free;
    end;
end;

end.
