unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, Grids, DBGrids, StdCtrls, Vcl.ComCtrls, Vcl.Menus,
  Vcl.ExtCtrls, Vcl.Imaging.jpeg, Vcl.Mask, Vcl.Samples.Spin;

type
  TForm1 = class(TForm)
    ADOConnection1: TADOConnection;
    Q_SviArtikli: TADOQuery;
    Q_KreirajNoviRacun: TADOQuery;
    Q_DodajStavku: TADOQuery;
    DS_KreiranRacun: TDataSource;
    Q_KreiraneStavke: TADOQuery;
    Grid_Artikli: TDBGrid;
    Grid_KreiraniRacun: TDBGrid;
    inNacinPlacanja1: TComboBox;
    inKupac: TEdit;
    inKolicina: TSpinEdit;
    inIznos: TEdit;
    inIznosSaPopustom: TEdit;
    inUkupno: TEdit;
    Dodaj: TButton;
    Zavrsi: TButton;
    Ponisti: TButton;
    Q_StavkeRacuna: TADOQuery;
    Grid_Racuni: TDBGrid;
    Grid_StavkeRacuna: TDBGrid;
    inNacinPlacanja2: TComboBox;
    cbDatum: TCheckBox;
    inDatumOd: TDateTimePicker;
    inDatumDo: TDateTimePicker;
    inIznosOd: TEdit;
    inIznosDo: TEdit;
    Pretraži: TButton;

    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;

    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    StaticText9: TStaticText;
    StaticText10: TStaticText;

    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;

    Image1: TImage;
    Osvezi: TButton;
    Q_ZavrsiKreiranjeRacuna: TADOQuery;
    Q_ObrisiKreiranRacun: TADOQuery;
    Q_PronadjiKreiranRacun: TADOQuery;
    SP_PretragaRacuna: TADOStoredProc;
    DS_Racuni: TDataSource;

    procedure FormCreate(Sender: TObject);
    procedure PretražiClick(Sender: TObject);
    procedure cbDatumClick(Sender: TObject);
    procedure Grid_RacuniCellClick(Column: TColumn);
    procedure Q_StavkeRacunaAfterOpen(DataSet: TDataSet);
    procedure Grid_ArtikliCellClick(Column: TColumn);
    procedure Q_SviArtikliAfterOpen(DataSet: TDataSet);
    procedure inKolicinaChange(Sender: TObject);
    procedure DodajClick(Sender: TObject);
    procedure ZavrsiClick(Sender: TObject);
    procedure Q_KreiraneStavkeAfterOpen(DataSet: TDataSet);
    procedure PonistiClick(Sender: TObject);
    procedure OsveziClick(Sender: TObject);
    procedure SP_PretragaRacunaAfterOpen(DataSet: TDataSet);
    procedure SP_PretragaRacunaAfterScroll(DataSet: TDataSet);
  private
  var
    pArtikalID: integer;
    pNazivArtikla: string;
    pKolicina: integer;
    pIznos: double;
    pPopust:double;
    pIznosSaPopustom:double;
    pUkupno:double;
    pRacunID: integer;

  procedure PrikaziStavkeZaRacun(RacunID: Integer);
  procedure IzracunajStavkeZaRacun;
  procedure OsveziKorpu;
  procedure ResetPrvtVar;
  function KreirajNoviRacun(kupac: string;nacinPlacanja: string):Int64;

  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
procedure TForm1.ResetPrvtVar;
begin
   pRacunID := 0;
    pArtikalID := 0;
    pNazivArtikla := '';
    pKolicina := 0;
    pIznos := 0;
    pPopust := 0;
    pIznosSaPopustom := 0;
    pUkupno:= 0;
    pRacunID :=0;
end;
function tform1.KreirajNoviRacun(kupac: string;nacinPlacanja: string):Int64;
begin
 Q_KreirajNoviRacun.Close;
 Q_KreirajNoviRacun.Parameters.ParamByName('Kupac').Value := kupac;
 Q_KreirajNoviRacun.Parameters.ParamByName('NacinPlacanja').Value := nacinPlacanja;
 Q_KreirajNoviRacun.ExecSQL;
 Q_PronadjiKreiranRacun.close;
 Q_PronadjiKreiranRacun.open;
    if not Q_PronadjiKreiranRacun.IsEmpty then
    begin
    Result := Q_PronadjiKreiranRacun.FieldByName('RacunID').AsInteger;
    Q_PronadjiKreiranRacun.Close;
    end
    else
    begin
    Result := 0;
    Q_PronadjiKreiranRacun.Close;
    end
end;

procedure TForm1.PrikaziStavkeZaRacun(RacunID: Integer);
begin
  Q_StavkeRacuna.Close;
  Q_StavkeRacuna.Parameters.ParamByName('RacunID').Value := RacunID;
  Q_StavkeRacuna.Open;
end;

procedure TForm1.ZavrsiClick(Sender: TObject);
begin
  var sqlString : string;
  if pRacunID <> 0 then
   begin
   Q_ZavrsiKreiranjeRacuna.close;
   Q_ZavrsiKreiranjeRacuna.Parameters.ParamByName('IDparam').Value := pRacunID;
   Q_ZavrsiKreiranjeRacuna.ExecSQL;
   Q_ZavrsiKreiranjeRacuna.Close;
   Q_PronadjiKreiranRacun.Close;
   Q_PronadjiKreiranRacun.Open;
   if Q_PronadjiKreiranRacun.IsEmpty then
   ShowMessage('Računa je uspešno obrisan')
   end
   else
   begin
   ResetPrvtVar;
   end;
end;

procedure TForm1.PretražiClick(Sender: TObject);
var
  iznosOd, iznosDo: double;
begin

  SP_PretragaRacuna.Close;
  if inNacinPlacanja2.ItemIndex <> -1 then
    SP_PretragaRacuna.Parameters.ParamByName('@NacinP').Value := inNacinPlacanja2.Items[inNacinPlacanja2.ItemIndex]
  else
    SP_PretragaRacuna.Parameters.ParamByName('@NacinP').Value := Null;

  if cbDatum.Checked then
  begin
    if inDatumOd.Date <> 0 then
      SP_PretragaRacuna.Parameters.ParamByName('@DatumOd').Value := inDatumOd.Date
    else
      SP_PretragaRacuna.Parameters.ParamByName('@DatumOd').Value := Null;

    if inDatumDo.Date <> 0 then
      SP_PretragaRacuna.Parameters.ParamByName('@DatumDo').Value := inDatumDo.Date
    else
      SP_PretragaRacuna.Parameters.ParamByName('@DatumDo').Value := Null;
  end
  else
  begin
    SP_PretragaRacuna.Parameters.ParamByName('@DatumOd').Value := Null;
    SP_PretragaRacuna.Parameters.ParamByName('@DatumDo').Value := Null;
  end;


  if inIznosOd.Text <> '' then
  begin
    if TryStrToFloat(inIznosOd.Text, iznosOd) then
      SP_PretragaRacuna.Parameters.ParamByName('@IznosOd').Value := iznosOd
    else
    begin
      ShowMessage(Format('Niste uneli ispravan broj: "%s"', [inIznosOd.Text]));
      inIznosOd.SetFocus;
      Exit;
    end;
  end
  else
    SP_PretragaRacuna.Parameters.ParamByName('@IznosOd').Value := Null;

  if inIznosDo.Text <> '' then
  begin
    if TryStrToFloat(inIznosDo.Text, iznosDo) then
      SP_PretragaRacuna.Parameters.ParamByName('@IznosDo').Value := iznosDo
    else
    begin
      ShowMessage(Format('Niste uneli ispravan broj: "%s"', [inIznosDo.Text]));
      inIznosDo.SetFocus;
      Exit;
    end;
  end
  else
    SP_PretragaRacuna.Parameters.ParamByName('@IznosDo').Value := Null;

  SP_PretragaRacuna.Open;

  if SP_PretragaRacuna.IsEmpty then
    ShowMessage('Nema podataka za date kriterijume')

end;


procedure TForm1.OsveziKorpu;
begin
var sqlString: string;
 Q_KreiraneStavke.close;
 Q_KreiraneStavke.Parameters.ParamByName('RacunID').Value := pRacunID;
 Q_KreiraneStavke.Open;
end;

procedure TForm1.DodajClick(Sender: TObject);
begin
var kupac: string;
var nacinPlacanja: string;
kupac := inKupac.Text;
nacinPlacanja := inNacinPlacanja1.Items[inNacinPlacanja1.ItemIndex];
if pRacunID = 0 then
begin
  if (inNacinPlacanja1.ItemIndex <> -1) and (kupac <> '') then
  pRacunID := KreirajNoviRacun(kupac, nacinPlacanja)
  else
  begin
  ShowMessage('Polja Način plaćanja i Kupac ne mogu biti prazna');
  ResetPrvtVar;
  Exit;
  end;
end;

if pRacunID <> 0 then
begin
  if pKolicina <> 0 then
  begin
  Q_DodajStavku.Parameters.ParamByName('RacunID').Value := pRacunID;
  Q_DodajStavku.Parameters.ParamByName('ArtikalID').Value := pArtikalID;
  Q_DodajStavku.Parameters.ParamByName('Kolicina').Value := pKolicina;
  Q_DodajStavku.Parameters.ParamByName('JedinicnaCena').Value := pIznos;
  Q_DodajStavku.Parameters.ParamByName('PopustProcenat').Value := pPopust;
  Q_DodajStavku.Parameters.ParamByName('Ukupno').Value := pUkupno;
  Q_DodajStavku.ExecSQL;
  ShowMessage('Stavka je uspešno dodata!');
  OsveziKorpu;
  Q_SviArtikli.Refresh
  end
  else
  ShowMessage('Količina mora biti veća od nule');
end
else
ShowMessage('Neuspešno kreiranje računa');
end;


procedure TForm1.PonistiClick(Sender: TObject);
var sqlString : string;
begin
  if pRacunID <> 0 then
   begin
   Q_ObrisiKreiranRacun.Close;
   Q_ObrisiKreiranRacun.Parameters.ParamByName('RacunID').Value := pRacunID;
   Q_ObrisiKreiranRacun.ExecSQL;
   if Q_ObrisiKreiranRacun.RowsAffected > 0 then
    ShowMessage('Račun je obrisan.' + IntToStr(pRacunID))
   else
    ShowMessage('Greška: Ne postoji račun čiji je ID ' + IntToStr(pRacunID) + 'i status: Kreiran.');

   Q_SviArtikli.Refresh;
   Q_ObrisiKreiranRacun.Close;
   ResetPrvtVar;
   end;
   OsveziKorpu;
end;

procedure TForm1.OsveziClick(Sender: TObject);
begin
  Q_SviArtikli.Refresh;
end;


procedure TForm1.cbDatumClick(Sender: TObject);
begin
  if cbDatum.Checked then
  begin
    inDatumOd.Enabled := cbDatum.Checked;
    inDatumDo.Enabled := cbDatum.Checked;
    Label3.Font.Color := clBlack;
    Label4.Font.Color := clBlack;
  end
  else
  begin
     inDatumOd.Enabled := False;
     inDatumDo.Enabled := False;
     Label3.Font.Color := clGray;
     Label4.Font.Color := clGray;
  end;
end;

procedure TForm1.Grid_RacuniCellClick(Column: TColumn);
var
  SelektovaniID: Integer;
begin
  if SP_PretragaRacuna.IsEmpty then Exit;
  SelektovaniID := SP_PretragaRacuna.FieldByName('RacunID').AsInteger;
  Label7.Caption := 'Selektovan ID: ' + IntToStr(SelektovaniID);
PrikaziStavkeZaRacun(SelektovaniID);
end;
procedure TForm1.IzracunajStavkeZaRacun();
begin
if Q_SviArtikli.IsEmpty then Exit;
   pIznos := Q_SviArtikli.FieldByName('Cena').AsFloat;
   pPopust :=   Q_SviArtikli.FieldByName('Popust [%]').AsFloat;
   pIznosSaPopustom := pIZnos*(1-pPopust/100);

   pKolicina := inKolicina.Value;
   pUkupno := pKolicina*pIznosSaPopustom;

   inIznos.Text := FloatToStr(pIznos);
   inIznosSaPopustom.Text := FloatToStr(pIznosSaPopustom);
   inUkupno.Text := FloatToStr(pUkupno);
end;

procedure TForm1.Grid_ArtikliCellClick(Column: TColumn);
begin
if Q_SviArtikli.IsEmpty then Exit;
   inKolicina.MaxValue :=  Q_SviArtikli.FieldByName('StanjeKolicina').AsInteger;
   pArtikalID := Q_SviArtikli.FieldByName('ArtikalID').AsInteger;
   pNazivArtikla := Q_SviArtikli.FieldByName('Naziv').AsString;
   Label9.Caption := pNazivArtikla;

   IzracunajStavkeZaRacun();
end;

procedure TForm1.FormCreate(Sender: TObject);

begin
  ADOConnection1.Connected := True;
  WindowState := wsMaximized;
  Position := poScreenCenter;
  cbDatum.Checked := False;
  inDatumOd.Enabled := False;
  inDatumDo.Enabled := False;
  Label3.Font.Color := clGray;
  Label4.Font.Color := clGray;
  DS_Racuni.DataSet := SP_PretragaRacuna;
end;

procedure TForm1.Q_SviArtikliAfterOpen(DataSet: TDataSet);
begin
 Grid_Artikli.Columns[0].Width := 30;
  Grid_Artikli.Columns[1].Width := 200;


end;

procedure TForm1.Q_KreiraneStavkeAfterOpen(DataSet: TDataSet);
begin
  Grid_KreiraniRacun.Columns[0].Width := 250;
  Grid_KreiraniRacun.Columns[1].Width := 80;
  Grid_KreiraniRacun.Columns[2].Width := 80;
  Grid_KreiraniRacun.Columns[3].Width := 80;
  Grid_KreiraniRacun.Columns[4].Width := 80;
end;

procedure TForm1.SP_PretragaRacunaAfterOpen(DataSet: TDataSet);
var
  i: Integer;
begin
Grid_Racuni.Columns[0].Width := 40;
  for i := 1 to Grid_Racuni.Columns.Count - 1 do
    Grid_Racuni.Columns[i].Width := 120;
end;

procedure TForm1.SP_PretragaRacunaAfterScroll(DataSet: TDataSet);
var
  RacunID: Integer;
begin
  if SP_PretragaRacuna.IsEmpty then
  begin
    Q_StavkeRacuna.Close;
    exit;
  end;

  RacunID := SP_PretragaRacuna.FieldByName('RacunID').AsInteger;

  PrikaziStavkeZaRacun(RacunID);
end;

procedure TForm1.Q_StavkeRacunaAfterOpen(DataSet: TDataSet);
var
  i: Integer;
begin
  for i := 0 to Grid_StavkeRacuna.Columns.Count - 1 do
    if Grid_StavkeRacuna.Columns[i].FieldName = 'SortOrder' then
    begin
      Grid_StavkeRacuna.Columns[i].Visible := False;
      Break;
    end;
end;

procedure TForm1.inKolicinaChange(Sender: TObject);
begin
     IzracunajStavkeZaRacun();
end;

end.
