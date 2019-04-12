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

function GetStrCounts(ASubStr, AStr: string): Integer;    //查找字符出现次数
function ErasePath:Boolean;   //擦去轨迹，恢复小屋原始状态
function CellDraw:boolean;  //根据矩阵绘制grid
function GoWay(var Matrix:Tarrays;x,y:integer;dest:string;list:string):Tcoordinate;
  //直行返回最后一格坐标
function FindPath(var Matrix:Tarrays;startX,startY:integer;direct,PrePath:string):Tstringlist;

var
  Form1: TForm1;
  Matrix: Tarrays    //模拟小屋，0通1阻
    =((0,0,0,0,0),
      (0,0,0,0,0),
      (0,0,0,0,0),
      (0,0,0,0,0),
      (0,0,0,0,0));
  done :Boolean = false; //此值用来判断路线是否已找到，为真时，不响应grid的点击事件

implementation

{$R *.dfm}

//判断一个格子的可行方向
function judgement(Matrix:Tarrays;x,y:integer):string;   //x代表行，y代表列
var
  up,down,left,right:string;
begin
  if (x>4) or (y>4) then
  begin
    showmessage('参数超限');
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

//子函数：根据二维数组Matrix绘制stringgrid
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
          col := clRed    //1-红色
        else if Matrix[i,j] = 0 then
          col := clWhite; //0-白色
        myrect := Form1.strngrd1.CellRect(j,i);
        Form1.strngrd1.Canvas.Brush.Color := col;
        Form1.strngrd1.Canvas.FillRect(myrect);
        //stringgrid重绘时画布覆盖单元格内容，要显示字符串需用textout方法
        Form1.strngrd1.Canvas.TextOut(myrect.Left+15,myrect.top+15,Form1.strngrd1.cells[j,i]);
      end;
    end;
    Result := True;
  except
  end;
end;

//开始
procedure TForm1.btn1Click(Sender: TObject);
var
  i,j,Knumber:integer;
  LastPath,temp:string;  //lastPath为最终路线
begin
  if done = True then exit;
  //创建mmo1是为了便于调试时展示运行结果，对程序本身并非必要
  Knumber := 0;
  LastPath := '';
  mmo1.Lines.Clear;
  for i:=0 to 4 do
  begin
    for j:=0 to 4 do
    begin
      //每次计算时需清空地图痕迹
      ErasePath;
      if Matrix[i,j]=0 then
      begin
        Knumber := Knumber + 1;       //获取小屋空格数量
        mmo1.Lines.AddStrings(FindPath(Matrix,i,j,'',''));
      end;
    end;
  end;
  //绘制线路
  for i:=0 to mmo1.Lines.Count - 1 do
  begin
    if Length(mmo1.Lines.Strings[i])=(Knumber*2) then
    begin
      LastPath := mmo1.Lines.Strings[i];
      ErasePath;   //清除地图痕迹，否则在重绘grid时颜色会混乱
      Break;    //只找一条满足要求的路线就行了
    end;
  end;
  if LastPath = '' then
  begin
    MessageBox(Handle,'     未找到路线','信息提示',MB_OK or MB_ICONINFORMATION);
    ErasePath;  //清除地图痕迹，否则在重绘grid时颜色会混乱
  end
  else
  begin
    //展示路线
    //ShowMessage(LastPath);
    for i:=1 to Knumber do
    begin
      temp := Copy(LastPath,2*i-1,2);      //依次把单元格位置取出来
      //对单元格赋值会直接触发drawcell事件进行重绘
      strngrd1.Cells[StrToInt(RightStr(temp,1)),StrToInt(LeftStr(temp,1))] := IntToStr(i);
      done := True;
    end;
  end;
end;

//关键递归函数：寻找路线
//Matrix为地图，startx,starty为起点，derection为方向，prepath为已走路线
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
      temp1 := judgement(Matrix,startX ,startY);        //代表可行方向的4位字符
      //如果没声明寻路方向，则自动找个方向
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
            //把直行终点重新设为起点
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
    //如果遇到三岔路，记住当前地图，然后循环递归
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
           //如果找的方向达到可找方向，退出循环，否则地图会被初始化
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

//查找字符出现次数
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

//清除地图走过的痕迹
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

//直行返回最后一格坐标
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
        //返回转折点坐标
        temp.dateX := x-r+1;
        temp.dateY := y;
        result:= temp;
        break;
      end
      else if Matrix[x-r,y]=0 then
      begin
        Matrix[x-r,y]:= 2 ;  //2代表已走过
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
        //返回转折点坐标
        temp.dateX := x+r-1;
        temp.dateY := y;
        result:= temp;
        break;
      end
      else if Matrix[x+r,y]=0 then
      begin
        Matrix[x+r,y]:= 2 ;  //2代表已走过
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
        //返回转折点坐标
        temp.dateX := x;
        temp.dateY := y-r+1;
        result:= temp;
        break;
      end
      else if Matrix[x,y-r]=0 then
      begin
        Matrix[x,y-r]:= 2 ;  //2代表已走过
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
        //返回转折点坐标
        temp.dateX := x;
        temp.dateY := y+r-1;
        result:= temp;
        break;
      end
      else if Matrix[x,y+r]=0 then
      begin
        Matrix[x,y+r]:= 2 ;  //2代表已走过
        temp.path := temp.path + (IntToStr(x)+IntToStr(y+r));
      end;
    end;
  end;
end;

//重置布局
procedure TForm1.btn2Click(Sender: TObject);
var
  i,j : integer;
begin
  //Matrix重置为0，delphi数组赋值不能整体进行
  for i := 0 to 4 do
    begin
      for j:= 0 to 4 do
      begin
        Matrix[i,j]:= 0;
      end;
    end;
  //stringgrid数据清零
  for i:=0 to strngrd1.RowCount - 1 do
  begin
    strngrd1.Rows[i].Clear;
  end;
  CellDraw;
  done := False;
end;

//点击grid事件
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
