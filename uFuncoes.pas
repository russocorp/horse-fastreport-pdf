unit uFuncoes;

interface

uses System.Classes, Firedac.Comp.Client, System.SysUtils, System.MaskUtils, Firedac.Stan.Param, System.IniFiles,
    uDM, Horse;

function DataSql(Data1, Data2: TDateTime): string; overload;

function DataSql(Data: TDateTime): string; overload;

function Formatar(Texto: string; TamanhoDesejado: Integer; AcrescentarADireita: Boolean = True; CaracterAcrescentar: char = ' '): string;

function ValidaCPF(Num: string): Boolean;

function ValidaCNPJ(Num: string): Boolean;

function SomenteNumero(Texto: string): string;

function RemoveAcento(Str: string; ARemoverApostrofo: Boolean = False): string;

function StrZero(Num, Size: Integer): string;

function GUIDToString2(const Guid: TGUID): string;

function ValorExtenso(Valor: Extended; Moeda: Boolean): string;

function FormatarTelefone(ATelefone: String): String;

function DirSistema: String;

function NomeArquivoValido(Nome: string): string;

function LerIni(ATabela, ACampo: string; ADefault: string = ''): string;

procedure GerarErro(Res: THorseResponse; AMensagem: String; AMensagemInterna: string = '');

function GetClaims(Req: THorseRequest; AClaim: String): String;

function ValidarData(AData: String): TDateTime;

implementation

uses Horse.Commons, uLogArquivo, System.JSON;

function DataSql(Data1, Data2: TDateTime): string;
begin
    Result := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Data1)) + ' and ' + QuotedStr(FormatDateTime('yyyy-mm-dd  hh:nn:ss', Data2));
end;

function DataSql(Data: TDateTime): string;
begin
    Result := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Data));
end;

function Formatar(Texto: string; TamanhoDesejado: Integer; AcrescentarADireita: Boolean = True; CaracterAcrescentar: char = ' '): string;
var
    QuantidadeAcrescentar, TamanhoTexto, PosicaoInicial, i: Integer;
begin
    case CaracterAcrescentar of
        '0' .. '9', 'a' .. 'z', 'A' .. 'Z':
            ; { Não faz nada }
    else
        CaracterAcrescentar := ' ';
    end;

    Texto := Trim(AnsiUpperCase(Texto));
    TamanhoTexto := Length(Texto);
    for i := 1 to (TamanhoTexto) do
    begin
        if Pos(Texto[i], ' 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ`~''"!@#$%^&*()_-+=|/\{}[]:;,.<>') = 0 then
        begin
            case Texto[i] of
                'Á', 'À', 'Â', 'Ä', 'Ã':
                    Texto[i] := 'A';
                'É', 'È', 'Ê', 'Ë':
                    Texto[i] := 'E';
                'Í', 'Ì', 'Î', 'Ï':
                    Texto[i] := 'I';
                'Ó', 'Ò', 'Ô', 'Ö', 'Õ':
                    Texto[i] := 'O';
                'Ú', 'Ù', 'Û', 'Ü':
                    Texto[i] := 'U';
                'Ç':
                    Texto[i] := 'C';
                'Ñ':
                    Texto[i] := 'N';
            else
                Texto[i] := ' ';
            end;
        end;
    end;

    QuantidadeAcrescentar := TamanhoDesejado - TamanhoTexto;
    if QuantidadeAcrescentar < 0 then
        QuantidadeAcrescentar := 0;
    if CaracterAcrescentar = '' then
        CaracterAcrescentar := ' ';
    if TamanhoTexto >= TamanhoDesejado then
        PosicaoInicial := TamanhoTexto - TamanhoDesejado + 1
    else
        PosicaoInicial := 1;

    if AcrescentarADireita then
        Texto := Copy(Texto, 1, TamanhoDesejado) + StringOfChar(CaracterAcrescentar, QuantidadeAcrescentar)
    else
        Texto := StringOfChar(CaracterAcrescentar, QuantidadeAcrescentar) + Copy(Texto, PosicaoInicial, TamanhoDesejado);

    Result := AnsiUpperCase(Texto);
end;


function ValidaCPF(Num: string): Boolean;
var
    n1, n2, n3, n4, n5, n6, n7, n8, n9: Integer;
    d1, d2: Integer;
    digitado, calculado: string;
    i: Integer;
    Repetido: Boolean;
begin
    Num := SomenteNumero(Num);

    if Length(Num) <> 11 then
    begin
        Result := False;
        exit;
    end;

    Repetido := True;
    for i := 1 to 11 do
    begin
        if Num[1] <> Num[i] then
        begin
            Repetido := False;
            break;
        end;
    end;

    if Repetido then
    begin
        Result := False;
        exit;
    end;
    try
        n1 := StrToInt(Num[1]);
        n2 := StrToInt(Num[2]);
        n3 := StrToInt(Num[3]);
        n4 := StrToInt(Num[4]);
        n5 := StrToInt(Num[5]);
        n6 := StrToInt(Num[6]);
        n7 := StrToInt(Num[7]);
        n8 := StrToInt(Num[8]);
        n9 := StrToInt(Num[9]);
        d1 := n9 * 2 + n8 * 3 + n7 * 4 + n6 * 5 + n5 * 6 + n4 * 7 + n3 * 8 + n2 * 9 + n1 * 10;
        d1 := 11 - (d1 mod 11);
        if d1 >= 10 then
            d1 := 0;
        d2 := d1 * 2 + n9 * 3 + n8 * 4 + n7 * 5 + n6 * 6 + n5 * 7 + n4 * 8 + n3 * 9 + n2 * 10 + n1 * 11;
        d2 := 11 - (d2 mod 11);
        if d2 >= 10 then
            d2 := 0;
        calculado := IntToStr(d1) + IntToStr(d2);
        digitado := Num[10] + Num[11];
        if calculado = digitado then
            ValidaCPF := True
        else
            ValidaCPF := False;
    except
        Result := False;
    end;
end;

function ValidaCNPJ(Num: string): Boolean;
var
    n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12: Integer;
    d1, d2: Integer;
    digitado, calculado: string;
begin
    Num := SomenteNumero(Num);

    if length(Num) <> 14 then
    begin
        Result := False;
        exit;
    end;

    n1 := StrToInt(Num[1]);
    n2 := StrToInt(Num[2]);
    n3 := StrToInt(Num[3]);
    n4 := StrToInt(Num[4]);
    n5 := StrToInt(Num[5]);
    n6 := StrToInt(Num[6]);
    n7 := StrToInt(Num[7]);
    n8 := StrToInt(Num[8]);
    n9 := StrToInt(Num[9]);
    n10 := StrToInt(Num[10]);
    n11 := StrToInt(Num[11]);
    n12 := StrToInt(Num[12]);
    d1 := n12 * 2 + n11 * 3 + n10 * 4 + n9 * 5 + n8 * 6 + n7 * 7 + n6 * 8 + n5 * 9 + n4 * 2 + n3 * 3 + n2 * 4 + n1 * 5;
    d1 := 11 - (d1 mod 11);
    if d1 >= 10 then
        d1 := 0;
    d2 := d1 * 2 + n12 * 3 + n11 * 4 + n10 * 5 + n9 * 6 + n8 * 7 + n7 * 8 + n6 * 9 + n5 * 2 + n4 * 3 + n3 * 4 + n2 * 5 + n1 * 6;
    d2 := 11 - (d2 mod 11);
    if d2 >= 10 then
        d2 := 0;
    calculado := IntToStr(d1) + IntToStr(d2);
    digitado := Num[13] + Num[14];
    if calculado = digitado then
        Result := true
    else
        Result := False;
end;

function SomenteNumero(Texto: string): string;
var
    i: Integer;
    Aux: string;
begin
    Aux := '';
    for i := 1 to Length(Texto) do
    begin
        if Texto[i] in ['0' .. '9'] then
            Aux := Aux + Texto[i];
    end;
    Result := Aux;
end;

function RemoveAcento(Str: string; ARemoverApostrofo: Boolean = False): string;
{ Remove caracteres acentuados de uma string }
const
    ComAcento = 'àâêôûãõáéíóúçüÀÂÊÔÛÃÕÁÉÍÓÚÇÜ&';
    SemAcento = 'aaeouaoaeioucuAAEOUAOAEIOUCU@';
var
    xx, Tam, x: Integer;
    Str2: string;
begin
    for x := 1 to Length(Str) do
    begin
        if Pos(Str[x], ComAcento) <> 0 then
        begin
            Str[x] := SemAcento[Pos(Str[x], ComAcento)];
        end;
    end;

    Str := Trim(Str);

    Str2 := '';

    Tam := Length(Str);
    for xx := 1 to Tam do
    begin
        if Copy(Str, xx, 1) <> '@' then
        begin
            Str2 := Str2 + Copy(Str, xx, 1);
        end;
    end;
    if ARemoverApostrofo then
        Str := StringReplace(Str2, #39, '', [])
    else
        Str := Str2;
    Result := Str;
end;

function StrZero(Num, Size: Integer): string;
var
    Text: string;
    i, Tam: Integer;
begin
    Text := IntToStr(Num);
    Tam := Length(Text);
    for i := 1 to (Size - Tam) do
        Text := '0' + Text;
    Result := Text;
end;

function GUIDToString2(const Guid: TGUID): string;
begin
    SetLength(Result, 36);
    StrLFmt(PChar(Result), 36, '%.8x-%.4x-%.4x-%.2x%.2x-%.2x%.2x%.2x%.2x%.2x%.2x',
        [Guid.d1, Guid.d2, Guid.D3, Guid.D4[0], Guid.D4[1], Guid.D4[2], Guid.D4[3],
        Guid.D4[4], Guid.D4[5], Guid.D4[6], Guid.D4[7]]);
end;

function VersaoExe: string;
begin
    Result := '1.0.0.0';
end;

function ValorExtenso(Valor: Extended; Moeda: Boolean): string;
var
    Centavos, centena, Milhar, Milhao, Bilhao, Texto: string;
    vValorAux: Extended;
const
    Unidades: array [1 .. 9] of string = ('um', 'dois', 'três', 'quatro', 'cinco', 'seis', 'sete', 'oito', 'nove');
    Dez: array [1 .. 9] of string = ('onze', 'doze', 'treze', 'quatorze', 'quinze', 'dezesseis', 'dezessete', 'dezoito', 'dezenove');
    Dezenas: array [1 .. 9] of string = ('dez', 'vinte', 'trinta', 'quarenta', 'cinqüenta', 'sessenta', 'setenta', 'oitenta', 'noventa');
    Centenas: array [1 .. 9] of string = ('cento', 'duzentos', 'trezentos', 'quatrocentos', 'quinhentos', 'seiscentos',
        'setecentos', 'oitocentos', 'novecentos');

    function ifs(Expressao: Boolean; CasoVerdadeiro, CasoFalso: string): string;
    begin
        if Expressao then
            Result := CasoVerdadeiro
        else
            Result := CasoFalso;
    end;

    function MiniExtenso(Valor: ShortString): string;
    var
        unidade, dezena, centena: string;
    begin
        if (Valor[2] = '1') and (Valor[3] <> '0') then
        begin
            unidade := Dez[StrToInt(Valor[3])];
            dezena := '';
        end
        else
        begin
            if Valor[2] <> '0' then
                dezena := Dezenas[StrToInt(Valor[2])];
            if Valor[3] <> '0' then
                unidade := Unidades[StrToInt(Valor[3])];
        end;
        if (Valor[1] = '1') and (unidade = '') and (dezena = '') then
            centena := 'cem'
        else if Valor[1] <> '0' then
            centena := Centenas[StrToInt(Valor[1])]
        else
            centena := '';

        Result := centena + ifs((centena <> '') and ((dezena <> '') or (unidade <> '')), ' e ', '') + dezena + ifs((dezena
            <> '') and (unidade <> ''), ' e ', '') + unidade;
    end;
begin
    vValorAux := 0;
    if Valor = 0 then
    begin
        if Moeda then
            Result := ''
        else
            Result := 'zero';

        exit;
    end
    else if Valor < 0 then
    begin
        vValorAux := Valor;
        Valor := Valor * -1;
    end;

    Texto := FormatFloat('000000000000.00', Valor);
    Centavos := MiniExtenso('0' + Copy(Texto, 14, 2));
    centena := MiniExtenso(Copy(Texto, 10, 3));
    Milhar := MiniExtenso(Copy(Texto, 7, 3));

    if Milhar <> '' then
        Milhar := Milhar + ' mil';

    Milhao := MiniExtenso(Copy(Texto, 4, 3));

    if Milhao <> '' then
        Milhao := Milhao + ifs(Copy(Texto, 4, 3) = '001', ' milhão', ' milhões');

    Bilhao := MiniExtenso(Copy(Texto, 1, 3));

    if Bilhao <> '' then
        Bilhao := Bilhao + ifs(Copy(Texto, 1, 3) = '001', ' bilhão', ' bilhões');

    Result := Bilhao + ifs((Bilhao <> '') and (Milhao + Milhar + centena <> ''), ifs((Pos(' e ', Bilhao) > 0) or (Pos(' e ',
        Milhao + Milhar + centena) > 0), ', ', ' e '), '') + Milhao + ifs((Milhao <> '') and (Milhar + centena <> ''),
        ifs((Pos(' e ', Milhao) > 0) or (Pos(' e ', Milhar + centena) > 0), ', ', ' e '), '') + Milhar + ifs((Milhar <>
        '') and (centena <> ''), ifs(Pos(' e ', centena) > 0, ', ', ' e '), '') + centena;

    if Moeda then
    begin
        if (Bilhao <> '') and (Milhao + Milhar + centena = '') then
            Result := Bilhao + ' de reais'
        else if (Milhao <> '') and (Milhar + centena = '') then
            Result := Milhao + ' de reais'
        else
            Result := Bilhao + ifs((Bilhao <> '') and (Milhao + Milhar + centena <> ''), ifs((Pos(' e ', Bilhao) > 0) or
                (Pos(' e ', Milhao + Milhar + centena) > 0), ', ', ' e '), '') + Milhao + ifs((Milhao <> '') and (Milhar
                + centena <> ''), ifs((Pos(' e ', Milhao) > 0) or (Pos(' e ', Milhar + centena) > 0), ', ', ' e '), '')
                + Milhar + ifs((Milhar <> '') and (centena <> ''), ifs(Pos(' e ', centena) > 0, ', ', ' e '), '') +
                centena + ifs(Int(Valor) = 1, ' real', ' reais');
        if Centavos <> '' then
        begin
            if Valor > 1 then
                Result := Result + ' e ' + Centavos + ifs(Copy(Texto, 14, 2) = '01', ' centavo', ' centavos')
            else
                Result := Centavos + ifs(Copy(Texto, 14, 2) = '01', ' centavo', ' centavos');
        end;
    end;
    if vValorAux < 0 then
        Result := Result + ' negativo';
end;

function FormatarTelefone(ATelefone: String): String;
begin
    if ATelefone.Length = 8 then
        Result := FormatMaskText('0000\-0000;0;', ATelefone.Trim)
    else if ATelefone.Length = 10 then
        Result := FormatMaskText('\(00\) 0000\-0000;0;', ATelefone.Trim)
    else if ATelefone.Length = 11 then
        Result := FormatMaskText('\(00\) 00000\-0000;0;', ATelefone.Trim)
    else
        Result := ATelefone;
end;

function DirSistema: String;
begin
    Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
end;

function NomeArquivoValido(Nome: string): string;
var
    I: Integer;
begin
    Result := '';
    for I := 1 to length(Nome) do
    begin
        if Nome[I] in ['<', '>', '"', '[', ']', '|', '/'] then
            Result := Result + '_'
        else
            Result := Result + Nome[I];
    end;
end;

function LerIni(ATabela, ACampo: string; ADefault: string = ''): string;
var
    ServerIni: TIniFile;
    sNomeArquivo: String;
begin
    sNomeArquivo := ParamStr(0);
    sNomeArquivo := ChangeFileExt(sNomeArquivo, '.ini');
    ServerIni := TIniFile.Create(sNomeArquivo);
    Result := ServerIni.ReadString(ATabela, ACampo, ADefault);
    ServerIni.Free;
end;

procedure GerarErro(Res: THorseResponse; AMensagem: String; AMensagemInterna: string = '');
begin
    if AMensagemInterna.IsEmpty then
        Log.Erro(AMensagem)
    else
        Log.Erro(AMensagem + sLineBreak + AMensagemInterna);
    Res.Send<TJSONObject>(TJSONObject.Create(TJSONPair.Create('error', AMensagem))).Status(THTTPStatus.BadRequest);
    raise EHorseCallbackInterrupted.Create;
end;

function GetClaims(Req: THorseRequest; AClaim: String): String;
var
    JO: TJSONObject;
begin
    // Função para pegar valor do claim da chave JWT da requisição.
    JO := Req.Session<TJSONObject>;
    Result := JO.GetValue<string>(AClaim);
end;

function ValidarData(AData: String): TDateTime;
var
    Formato: TFormatSettings;
begin
    Formato.DateSeparator := '-';
    Formato.ShortDateFormat := 'yyyy-mm-dd';
    try
        Result := StrToDate(AData, Formato);
    except
        raise Exception.Create('Data inválida.');
    end;
end;

end.
