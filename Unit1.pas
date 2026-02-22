unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, Grids, DBGrids, StdCtrls, Vcl.ComCtrls, Vcl.Menus,
  Vcl.ExtCtrls, Vcl.Imaging.jpeg, Vcl.Mask, Vcl.Samples.Spin;

type
  TForm1 = class(TForm)
    ADOConnection1: TADOConnection;
    Q_Racuni_SelectAll: TADOQuery;
    Q_StavkeRacuna: TADOQuery;
    Q_Artikli_SelectAll: TADOQuery;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    Label1: TLabel;
    ComboBox1: TComboBox;
    Button2: TButton;
    Label2: TLabel;
    DateTimePicker1: TDateTimePicker;
    Label3: TLabel;
    DateTimePicker2: TDateTimePicker;
    Label4: TLabel;
    Label5: TLabel;
    Edit2: TEdit;
    Label7: TLabel;
    Image1: TImage;
    Shape1: TShape;
    StaticText1: TStaticText;
    DBGrid3: TDBGrid;
    Label9: TLabel;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    SpinEdit1: TSpinEdit;
    Edit1: TEdit;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    ComboBox2: TComboBox;
    Edit4: TEdit;
    Button3: TButton;
    Edit3: TEdit;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    Edit5: TEdit;
    Shape2: TShape;
    StaticText9: TStaticText;
    Shape3: TShape;
    Q_NoviRacun: TADOQuery;
    Q_Stavke_Add: TADOQuery;
    DataSource4: TDataSource;
    DBGrid4: TDBGrid;
    Q_KreiraneStavke: TADOQuery;
    StaticText4: TStaticText;
    Button1: TButton;
    Button4: TButton;
    Shape4: TShape;
    StaticText10: TStaticText;
    Shape5: TShape;
    CheckBox1: TCheckBox;




    procedure FormCreate(Sender: TObject);

    procedure Button2Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Q_Racuni_SelectAllAfterOpen(DataSet: TDataSet);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure Q_StavkeRacunaAfterOpen(DataSet: TDataSet);
    procedure Q_Racuni_SelectAllAfterScroll(DataSet: TDataSet);
    procedure DBGrid2CellClick(Column: TColumn);
    procedure Q_Artikli_SelectAllAfterOpen(DataSet: TDataSet);
    procedure SpinEdit1Change(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Q_KreiraneStavkeAfterOpen(DataSet: TDataSet);
    procedure Button4Click(Sender: TObject);

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



  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.PrikaziStavkeZaRacun(RacunID: Integer);
begin
  Q_StavkeRacuna.Close;
  Q_StavkeRacuna.Parameters.ParamByName('RacunID').Value := RacunID;
  Q_StavkeRacuna.Open;
end;

procedure TForm1.Button1Click(Sender: TObject);
//button ZAVRSI
begin
  var sqlString : string;
  if pRacunID <> 0 then
   begin
   Q_NoviRacun.close;
    sqlString :='declare @RacunID int = :IDparam;'+
             'declare @Ukupno decimal  = (SELECT SUM(Ukupno) FROM [Historian1].[dbo].[StavkeRacuna] WHERE RacunID = @RacunID); ' +
             'UPDATE [dbo].[Racuni] SET [DatumPrometa] = GETDATE() ,[Ukupno] = @Ukupno,[Porez] = @Ukupno*0.2' +
             ',[UkupnoSaPorezom] = @Ukupno*1.2 ,[Status] = 2 WHERE RacunID = @RacunID ';

   Q_NoviRacun.SQL.Text := sqlString;
   Q_NoviRacun.Parameters.ParamByName('IDparam').Value := pRacunID;
   Q_NoviRacun.ExecSQL;
   Q_NoviRacun.Close;
   end
   else
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
end;

procedure TForm1.Button2Click(Sender: TObject);
var sqlString : string;
sqlSubString : string;
paramCount : Integer;
iznos: Double;
begin
  Q_Racuni_SelectAll.Close;
  Q_Racuni_SelectAll.SQL.Clear;
 paramCount := 0;
  sqlString := 'SELECT  RacunID,BrojRacuna,DatumIzdavanja,DatumPrometa,Kupac,NacinPlacanja,Ukupno,Porez,UkupnoSaPorezom,Statusi.Oznaka as Status,Napomena FROM [Historian1].[dbo].[Racuni] left join Statusi on Racuni.Status = Statusi.StatusID ';

  if ComboBox1.ItemIndex <> -1  then
    begin
      sqlString := sqlString + ' WHERE NacinPlacanja = :NacinPlacanja';
      paramCount := paramCount + 1;
    end;

    if CheckBox1.Checked then
     begin
   if DateTimePicker1.Date <> 0 then
   begin
    if paramCount = 0  then
      sqlSubString := ' Where '
    else
      sqlSubString := ' And ';

   sqlString := sqlString + sqlSubString    + 'DatumIzdavanja > :DatumOd';
   paramCount := paramCount + 1;
   end;

   if DateTimePicker2.Date <> 0 then
   begin
    if paramCount = 0  then
      sqlSubString := ' Where '
    else
      sqlSubString := ' And ';

   paramCount := paramCount + 1;
   sqlString := sqlString + sqlSubString    + 'DatumIzdavanja < :DatumDo';
   end;
   end;
   if Edit2.Text <> '' then
    begin
      try
    iznos := StrToFloat(Edit2.Text);
  except
    on E: Exception do
    begin
      ShowMessage('Niste uneli ispravan broj');
      Edit2.SetFocus;
      Exit;
    end;
  end;
    if paramCount = 0  then
      sqlSubString := ' Where '
    else
      sqlSubString := ' And ';

   paramCount := paramCount + 1;
   sqlString := sqlString + sqlSubString    + 'UkupnoSaPorezom > :Iznos';
   end;
   ////////////////////  zavrsena provera parametara i sql query formiran /////////////////////////////////////

   Q_Racuni_SelectAll.SQL.Add(sqlString);

     if ComboBox1.ItemIndex <> -1  then
      Q_Racuni_SelectAll.Parameters.ParamByName('NacinPlacanja').Value  := ComboBox1.Items[ComboBox1.ItemIndex];
       if CheckBox1.Checked then
       begin
     if DateTimePicker1.Date <> 0 then
      Q_Racuni_SelectAll.Parameters.ParamByName('DatumOd').Value  := DateTimePicker1.Date;
     if DateTimePicker2.Date <> 0 then
      Q_Racuni_SelectAll.Parameters.ParamByName('DatumDo').Value  := DateTimePicker2.Date;
       end;
     if Edit2.Text <> '' then
      Q_Racuni_SelectAll.Parameters.ParamByName('Iznos').Value  := iznos;

    Q_Racuni_SelectAll.Open;

end;

procedure TForm1.OsveziKorpu;
begin
var sqlString: string;
Q_KreiraneStavke.close;
sqlString := 'DECLARE @RacunID INT = :RacunID; ' +
  ' ' +
  'SELECT Artikli.Naziv, Kolicina, JedinicnaCena, PopustProcenat, Ukupno ' +
  'FROM [Historian1].[dbo].[StavkeRacuna] ' +
  'LEFT JOIN Artikli ON StavkeRacuna.ArtikalID = Artikli.ArtikalID ' +
  'WHERE RacunID = @RacunID ' +
  'UNION ALL ' +
  'SELECT ''UKUPNO:'', NULL, NULL, NULL, SUM(Ukupno) ' +
  'FROM [Historian1].[dbo].[StavkeRacuna] WHERE RacunId = @RacunID ' +
  'UNION ALL ' +
  'SELECT ''PDV:'', NULL, NULL, NULL, SUM(Ukupno) * 0.2 ' +
  'FROM [Historian1].[dbo].[StavkeRacuna] WHERE RacunId = @RacunID ' +
  'UNION ALL ' +
  'SELECT ''UKUPNO SA PDV:'', NULL, NULL, NULL, SUM(Ukupno) * 1.2 ' +
  'FROM [Historian1].[dbo].[StavkeRacuna] WHERE RacunId = @RacunID;';

  Q_KreiraneStavke.sql.Text := sqlString;
  Q_KreiraneStavke.Parameters.ParamByName('RacunID').Value := pRacunID;
  Q_KreiraneStavke.Open;
end;

procedure TForm1.Button3Click(Sender: TObject);
//DODAJ button
begin
 var sqlString: string;
 var kupac: string;
 var nacinPlacanja: string;
 kupac := Edit4.Text;
 if ComboBox2.ItemIndex <> -1 then
 nacinPlacanja := ComboBox2.Items[ComboBox2.ItemIndex];

 if pKolicina <> 0 then
  begin
 sqlString := 'Select * from Racuni where Status = 1'; //status kreiran
 Q_NoviRacun.Close;
 Q_NoviRacun.SQL.Text := sqlString;
 Q_NoviRacun.Open;
 if Q_NoviRacun.IsEmpty then
   begin
    Q_NoviRacun.Close;
    sqlString := 'INSERT INTO [dbo].[Racuni] ([DatumIzdavanja],[Kupac],[NacinPlacanja],[Status])'
     + 'VALUES (getdate(),:Kupac, :NacinPlacanja ,1)';
     Q_NoviRacun.SQL.Text := sqlString;
     Q_NoviRacun.Parameters.ParamByName('Kupac').Value := kupac;
     Q_NoviRacun.Parameters.ParamByName('NacinPlacanja').Value := nacinPlacanja;
     Q_NoviRacun.ExecSQL;
   end;

   // get pRacunID
   sqlString := 'Select RacunID from Racuni where Status = 1'; //status kreiran
   Q_NoviRacun.SQL.Text := sqlString;
   Q_NoviRacun.Open;
   if not Q_NoviRacun.IsEmpty then
   begin
    pRacunID := Q_NoviRacun.FieldByName('RacunID').AsInteger;
     Q_NoviRacun.Close;
   end
  else
  begin
    pRacunID := 0;
     Q_NoviRacun.Close;
    ShowMessage('Neuspelo kreiranje racuna');
    Exit;
  end;
     Q_Stavke_Add.SQL.Text := 'INSERT INTO [dbo].[StavkeRacuna] ' +
                       '(RacunID, ArtikalID, Kolicina, JedinicnaCena, PopustProcenat, Ukupno) ' +
                       'VALUES (:RacunID, :ArtikalID, :Kolicina, :JedinicnaCena, :PopustProcenat, :Ukupno)';

  Q_Stavke_Add.Parameters.ParamByName('RacunID').Value := pRacunID;
  Q_Stavke_Add.Parameters.ParamByName('ArtikalID').Value := pArtikalID;
  Q_Stavke_Add.Parameters.ParamByName('Kolicina').Value := pKolicina;
  Q_Stavke_Add.Parameters.ParamByName('JedinicnaCena').Value := pIznos;
  Q_Stavke_Add.Parameters.ParamByName('PopustProcenat').Value := pPopust;
  Q_Stavke_Add.Parameters.ParamByName('Ukupno').Value := pUkupno;


  Q_Stavke_Add.ExecSQL;
  ShowMessage('Stavka je uspešno dodata!');
  OsveziKorpu;
  end
  else
  ShowMessage('Kolicina ne moze biti nula');
  end;

procedure TForm1.Button4Click(Sender: TObject);
//PONISTI button
var sqlString : string;
begin
   if pRacunID <> 0 then
   begin
   Q_KreiraneStavke.close;
   sqlString := 'DELETE FROM [dbo].[StavkeRacuna] WHERE RacunId = :RacunID';
   Q_KreiraneStavke.SQL.Text := sqlString;
   Q_KreiraneStavke.Parameters.ParamByName('RacunID').Value := pRacunID;
   Q_KreiraneStavke.ExecSQL;

   Q_KreiraneStavke.close;
   Q_NoviRacun.Close;
   sqlString := 'DELETE FROM [dbo].[Racuni] WHERE RacunId = :RacunID AND Status = 1';
   Q_NoviRacun.SQL.Text := sqlString;
   Q_NoviRacun.Parameters.ParamByName('RacunID').Value := pRacunID;
   Q_NoviRacun.ExecSQL;
   if Q_NoviRacun.RowsAffected > 0 then
    ShowMessage('Uspešno obrisan')
   else
    ShowMessage('Greška: Ne postiji racun ciji je ID ' + IntToStr(pRacunID) + 'i status: Kreiran.');

   Q_NoviRacun.Close;

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
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Checked then
  begin
    DateTimePicker1.Enabled := CheckBox1.Checked;
    DateTimePicker2.Enabled := CheckBox1.Checked;
    Label3.Font.Color := clBlack;       // sivo (bledo)
    Label4.Font.Color := clBlack;
  end
  else
  begin
     DateTimePicker1.Enabled := False;
     DateTimePicker2.Enabled := False;
     Label3.Font.Color := clGray;
     Label4.Font.Color := clGray;
  end;
end;

procedure TForm1.DBGrid1CellClick(Column: TColumn);
var
  SelektovaniID: Integer;
begin
  if Q_Racuni_Selectall.IsEmpty then Exit;
  SelektovaniID := Q_Racuni_SelectAll.FieldByName('RacunID').AsInteger;
  Label7.Caption := 'Selektovan ID: ' + IntToStr(SelektovaniID);
PrikaziStavkeZaRacun(SelektovaniID);
end;
procedure TForm1.IzracunajStavkeZaRacun();
begin
if Q_Artikli_SelectAll.IsEmpty then Exit;
   pIznos := Q_Artikli_SelectAll.FieldByName('Cena').AsFloat;
   pPopust :=   Q_Artikli_SelectAll.FieldByName('Popust [%]').AsFloat;
   pIznosSaPopustom := pIZnos*(1-pPopust/100);

   pKolicina := SpinEdit1.Value;
   pUkupno := pKolicina*pIznosSaPopustom;

   Edit1.Text := FloatToStr(pIznos);
   Edit3.Text := FloatToStr(pIznosSaPopustom);
   Edit5.Text := FloatToStr(pUkupno);
end;

procedure TForm1.DBGrid2CellClick(Column: TColumn);
begin
if Q_Artikli_SelectAll.IsEmpty then Exit;
   SpinEdit1.MaxValue :=  Q_Artikli_SelectAll.FieldByName('StanjeKolicina').AsInteger;
   pArtikalID := Q_Artikli_SelectAll.FieldByName('ArtikalID').AsInteger;
   pNazivArtikla := Q_Artikli_SelectAll.FieldByName('Naziv').AsString;
   Label9.Caption := pNazivArtikla;

   IzracunajStavkeZaRacun();
end;

procedure TForm1.FormCreate(Sender: TObject);

begin
  ADOConnection1.Connected := True;
  Width := 1200;
  Height := 800;
  Position := poScreenCenter;
  CheckBox1.Checked := False;
  DateTimePicker1.Enabled := False;
  DateTimePicker2.Enabled := False;
  Label3.Font.Color := clGray;
  Label4.Font.Color := clGray;
end;

procedure TForm1.Q_Artikli_SelectAllAfterOpen(DataSet: TDataSet);
begin
 DBGrid2.Columns[0].Width := 30;
  DBGrid2.Columns[1].Width := 200;


end;

procedure TForm1.Q_KreiraneStavkeAfterOpen(DataSet: TDataSet);
begin
  DBGrid4.Columns[0].Width := 250;
  DBGrid4.Columns[1].Width := 80;
  DBGrid4.Columns[2].Width := 80;
  DBGrid4.Columns[3].Width := 80;
  DBGrid4.Columns[4].Width := 80;
end;

procedure TForm1.Q_Racuni_SelectAllAfterOpen(DataSet: TDataSet);
var
  i: Integer;
begin
DBGrid1.Columns[0].Width := 40;
  for i := 1 to DBGrid1.Columns.Count - 1 do
    DBGrid1.Columns[i].Width := 120;
end;

procedure TForm1.Q_Racuni_SelectAllAfterScroll(DataSet: TDataSet);
var
  RacunID: Integer;
begin
  if Q_Racuni_SelectAll.IsEmpty then
  begin
    Q_StavkeRacuna.Close;
    exit;
  end;

  RacunID := Q_Racuni_SelectAll.FieldByName('RacunID').AsInteger;

  PrikaziStavkeZaRacun(RacunID);
end;

procedure TForm1.Q_StavkeRacunaAfterOpen(DataSet: TDataSet);
var
  i: Integer;
begin
  for i := 0 to DBGrid3.Columns.Count - 1 do
    if DBGrid3.Columns[i].FieldName = 'SortOrder' then
    begin
      DBGrid3.Columns[i].Visible := False;
      Break;
    end;
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
     IzracunajStavkeZaRacun();
end;

end.
