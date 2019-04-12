unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids,StrUtils, StdCtrls;

type
  TForm1 = class(TForm)
    btn1: TButton;
    grp1: TGroupBox;
    lbl1: TLabel;
    strngrd1: TStringGrid;
    btn2: TButton;
    mmo1: TMemo;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure strngrd1Click(Sender: TObject);
    procedure strngrd1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
type
  Tcoordinate = record
    dateX:integer;
    dateY:integer;
    path:string;
  end;
type
  Tarrays = array[0..4,0..4] of integer;

function GetStrCounts(ASubStr, AStr: string): Integer;    //�����ַ����ִ���
function ErasePath:Boolean;   //��ȥ�켣���ָ�С��ԭʼ״̬
function CellDraw:boolean;  //���ݾ������grid
function GoWay(var Matrix:Tarrays;x,y:integer;dest:string;list:string):Tcoordinate;
  //ֱ�з������һ������
function FindPath(var Matrix:Tarrays;startX,startY:integer;direct,PrePath:string):Tstringlist;

var
  Form1: TForm1;
  Matrix: Tarrays    //ģ��С�ݣ�0ͨ1��
    =((0,0,0,0,0),
      (0,0,0,0,0),
      (0,0,0,0,0),
      (0,0,0,0,0),
      (0,0,0,0,0));
  done :Boolean = false; //��ֵ�����ж�·���Ƿ����ҵ���Ϊ��ʱ������Ӧgrid�ĵ���¼�

implementation

{$R *.dfm}

//�ж�һ�����ӵĿ��з���
function judgement(Matrix:Tarrays;x,y:integer):string;   //x�����У�y������
var
  up,down,left,right:string;
begin
  if (x>4) or (y>4) then
  begin
    showmessage('��������');
    exit;
  end;
  if x = 0 then
    up := '1'
  else if Matrix[x-1,y] = 0 then
    up := '0'
  else up := '1';
  if y = 0 then
    left := '1'
  else if Matrix[x,y-1] = 0 then
    left := '0'
  else left := '1';
  if x = 4 then
    down := '1'
  else if Matrix[x+1,y] = 0 then
    down := '0'
  else down := '1';
  if y = 4 then
    right := '1'
  else if Matrix[x,y+1] = 0 then
    right := '0'
  else right := '1';

  result := up+right+down+left;
end;

//�Ӻ��������ݶ�ά����Matrix����stringgrid
function CellDraw:boolean;
var
  myrect:TRect ;
  i, j: integer;
  col: TColor;
begin
  col := clYellow;
  Result := False ;
  try
    for i := 0 to 4 do
    begin
      for j:= 0 to 4 do
      begin
        if Matrix[i,j] = 1 then
          col := clRed    //1-��ɫ
        else if Matrix[i,j] = 0 then
          col := clWhite; //0-��ɫ
        myrect := Form1.strngrd1.CellRect(j,i);
        Form1.strngrd1.Canvas.Brush.Color := col;
        Form1.strngrd1.Canvas.FillRect(myrect);
        //stringgrid�ػ�ʱ�������ǵ�Ԫ�����ݣ�Ҫ��ʾ�ַ�������textout����
        Form1.strngrd1.Canvas.TextOut(myrect.Left+15,myrect.top+15,Form1.strngrd1.cells[j,i]);
      end;
    end;
    Result := True;
  except
  end;
end;

//��ʼ
procedure TForm1.btn1Click(Sender: TObject);
var
  i,j,Knumber:integer;
  LastPath,temp:string;  //lastPathΪ����·��
begin
  if done = True then exit;
  //����mmo1��Ϊ�˱��ڵ���ʱչʾ���н�����Գ������Ǳ�Ҫ
  Knumber := 0;
  LastPath := '';
  mmo1.Lines.Clear;
  for i:=0 to 4 do
  begin
    for j:=0 to 4 do
    begin
      //ÿ�μ���ʱ����յ�ͼ�ۼ�
      ErasePath;
      if Matrix[i,j]=0 then
      begin
        Knumber := Knumber + 1;       //��ȡС�ݿո�����
        mmo1.Lines.AddStrings(FindPath(Matrix,i,j,'',''));
      end;
    end;
  end;
  //������·
  for i:=0 to mmo1.Lines.Count - 1 do
  begin
    if Length(mmo1.Lines.Strings[i])=(Knumber*2) then
    begin
      LastPath := mmo1.Lines.Strings[i];
      ErasePath;   //�����ͼ�ۼ����������ػ�gridʱ��ɫ�����
      Break;    //ֻ��һ������Ҫ���·�߾�����
    end;
  end;
  if LastPath = '' then
  begin
    MessageBox(Handle,'     δ�ҵ�·��','��Ϣ��ʾ',MB_OK or MB_ICONINFORMATION);
    ErasePath;  //�����ͼ�ۼ����������ػ�gridʱ��ɫ�����
  end
  else
  begin
    //չʾ·��
    //ShowMessage(LastPath);
    for i:=1 to Knumber do
    begin
      temp := Copy(LastPath,2*i-1,2);      //���ΰѵ�Ԫ��λ��ȡ����
      //�Ե�Ԫ��ֵ��ֱ�Ӵ���drawcell�¼������ػ�
      strngrd1.Cells[StrToInt(RightStr(temp,1)),StrToInt(LeftStr(temp,1))] := IntToStr(i);
      done := True;
    end;
  end;
end;

//�ؼ��ݹ麯����Ѱ��·��
//MatrixΪ��ͼ��startx,startyΪ��㣬derectionΪ����prepathΪ����·��
function FindPath(var Matrix:Tarrays;startX,startY:integer;direct,PrePath:string):Tstringlist;
var
  i,j:Integer;
  temp1,direction:string;
  temp3:Tcoordinate;
  tempMap:Tarrays;
begin
  Result:= TStringList.Create;
  if PrePath = '' then
  begin
    PrePath := inttostr(startX)+inttostr(startY);
  end;
  while judgement(Matrix,startX,startY)<>'1111' do
  begin
    if (GetStrCounts('0',judgement(Matrix,startX,startY))=1) or (direct <>'') then
    begin
      temp1 := judgement(Matrix,startX ,startY);        //������з����4λ�ַ�
      //���û����Ѱ·�������Զ��Ҹ�����
      if direct='' then
      begin
        for i:=1 to 4 do
        begin
          if temp1[i] = '0' then
          begin
            case i of
              1: direction := 'up';
              2: direction := 'right';
              3: direction := 'down';
              4: direction := 'left';
            end;
            //��ֱ���յ�������Ϊ���
            break;
          end;
        end;
      end
      else
      begin
        direction := direct;
        direct:= '';
      end;
      temp3 := GoWay(Matrix,startX,startY,direction,PrePath);
      startX := temp3.dateX;
      startY := temp3.dateY;
      PrePath := temp3.path;
    end
    else if GetStrCounts('0',judgement(Matrix,startX,startY))>1 then
    //�����������·����ס��ǰ��ͼ��Ȼ��ѭ���ݹ�
    begin
       tempMap := Matrix;
       j:=GetStrCounts('0',judgement(Matrix,startX,startY));
       i:=0;
       while true do
       begin
         if Copy(judgement(Matrix,startX,startY),1,1)='0' then
         begin
           i := i+1;
           result.addstrings(FindPath(Matrix,startX,startY,'up',PrePath));
           //����ҵķ���ﵽ���ҷ����˳�ѭ���������ͼ�ᱻ��ʼ��
           if i>=j then Break;
           Matrix := tempMap;
         end;
         if Copy(judgement(Matrix,startX,startY),2,1)='0' then
         begin
           i := i+1;
           result.addstrings(FindPath(Matrix,startX,startY,'right',PrePath));
           if i>=j then Break;
           Matrix := tempMap;
         end;
         if Copy(judgement(Matrix,startX,startY),3,1)='0' then
         begin
           i := i+1;
           result.addstrings(FindPath(Matrix,startX,startY,'down',PrePath));
           if i>=j then Break;
           Matrix := tempMap;
         end;
         if Copy(judgement(Matrix,startX,startY),4,1)='0' then
         begin
           i := i+1;
           result.addstrings(FindPath(Matrix,startX,startY,'left',PrePath));
           if i>=j then Break;
           Matrix := tempMap;
         end;
       end;
    end;
  end;
  Result.add(PrePath);
end;

//�����ַ����ִ���
function GetStrCounts(ASubStr, AStr: string): Integer;
var
 i: Integer;
begin
 Result := 0;
 i := 1;
 while PosEx(ASubStr, AStr, i) <> 0 do
 begin
   Inc(Result);
   i := PosEx(ASubStr, AStr, i) + 1;
 end;
end;

//�����ͼ�߹��ĺۼ�
function ErasePath;
var
  i,j:Integer;
begin
  Result := True;
  try
    for i:=0 to 4 do
    begin
      for j:=0 to 4 do
      begin
        if Matrix[i,j]=2 then
          Matrix[i,j] := 0 ;
      end;
    end;
  except
    Result:= False;
  end;
end;

//ֱ�з������һ������
function GoWay(var Matrix:Tarrays;x,y:integer;dest:string;list:string):Tcoordinate;
var
  r:integer;
  temp:Tcoordinate;
begin
  //path.Add(IntToStr(x)+IntToStr(y));
  temp.path := list;
  Matrix[x,y] := 2;
  if dest = 'up' then
  begin
    for r := 1 to 5 do
    begin
      if (Matrix[x-r,y] <> 0) or (x-r<0) then
      begin
        //����ת�۵�����
        temp.dateX := x-r+1;
        temp.dateY := y;
        result:= temp;
        break;
      end
      else if Matrix[x-r,y]=0 then
      begin
        Matrix[x-r,y]:= 2 ;  //2�������߹�
        temp.path := temp.path + (IntToStr(x-r)+IntToStr(y));
      end;
    end;
  end;
  if dest = 'down' then
  begin
    for r := 1 to 5 do
    begin
      if (Matrix[x+r,y] <> 0) or (x+r>4) then
      begin
        //����ת�۵�����
        temp.dateX := x+r-1;
        temp.dateY := y;
        result:= temp;
        break;
      end
      else if Matrix[x+r,y]=0 then
      begin
        Matrix[x+r,y]:= 2 ;  //2�������߹�
        temp.path := temp.path + (IntToStr(x+r)+IntToStr(y));
      end;
    end;
  end;
  if dest = 'left' then
  begin
    for r := 1 to 5 do
    begin
      if (Matrix[x,y-r] <> 0) or (y-r<0) then
      begin
        //����ת�۵�����
        temp.dateX := x;
        temp.dateY := y-r+1;
        result:= temp;
        break;
      end
      else if Matrix[x,y-r]=0 then
      begin
        Matrix[x,y-r]:= 2 ;  //2�������߹�
        temp.path := temp.path + (IntToStr(x)+IntToStr(y-r));
      end;
    end;
  end;
  if dest = 'right' then
  begin
    for r := 1 to 5 do
    begin
      if (Matrix[x,y+r] <> 0) or (y+r>4) then
      begin
        //����ת�۵�����
        temp.dateX := x;
        temp.dateY := y+r-1;
        result:= temp;
        break;
      end
      else if Matrix[x,y+r]=0 then
      begin
        Matrix[x,y+r]:= 2 ;  //2�������߹�
        temp.path := temp.path + (IntToStr(x)+IntToStr(y+r));
      end;
    end;
  end;
end;

//���ò���
procedure TForm1.btn2Click(Sender: TObject);
var
  i,j : integer;
begin
  //Matrix����Ϊ0��delphi���鸳ֵ�����������
  for i := 0 to 4 do
    begin
      for j:= 0 to 4 do
      begin
        Matrix[i,j]:= 0;
      end;
    end;
  //stringgrid��������
  for i:=0 to strngrd1.RowCount - 1 do
  begin
    strngrd1.Rows[i].Clear;
  end;
  CellDraw;
  done := False;
end;

//���grid�¼�
procedure TForm1.strngrd1Click(Sender: TObject);
var
  i,j: integer;
begin
  if done = False then
  begin
    i:= strngrd1.Row;
    j:= strngrd1.Col;
    if Matrix[i,j] = 1 then Matrix[i,j]:= 0
    else if Matrix[i,j] = 0 then Matrix[i,j] := 1 ;
    CellDraw;
  end;
end;

procedure TForm1.strngrd1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  CellDraw;
end;

end.
