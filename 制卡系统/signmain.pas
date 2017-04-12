unit signmain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, superobject, StrUtils, ExtCtrls, Rc4_Unit, InputBox, IDHttp;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Label4: TLabel;
    Edit4: TEdit;
    Edit5: TEdit;
    Label5: TLabel;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  TMyThread = class(TThread)
  private
     { Private declarations }
  protected
    procedure Execute; override; {执行}
    procedure Run; {声明多一个过程，把功能代码写在这里再给Execute调用}
  end;

var
  Form1: TForm1; icdev: longint; st, sector, block, loadmode: smallint; snr: longint; nkey, wdata, sendblock: pchar;
  status: array[0..18] of Char;
  databuff: array[0..15] of Char;
  ack: array[0..255] of Char;
  HttpClient: TIdHttp;
  ParamList: TStringList;

  {a example for your to try using .dll. add_s return i+1}
function add_s(i: smallint): smallint; stdcall;
far; external 'mwrf32.dll' name 'add_s';
  {comm function.}
function rf_init(port: smallint; baud: longint): longint; stdcall;
far; external 'mwrf32.dll' name 'rf_init';
function rf_exit(icdev: longint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_exit';
function rf_encrypt(key: pchar; ptrsource: pchar; msglen: smallint; ptrdest: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_encrypt';
function rf_decrypt(key: pchar; ptrsource: pchar; msglen: smallint; ptrdest: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_decrypt';
  //
function rf_card(icdev: longint; mode: smallint; snr: pChar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_card';
function rf_load_key(icdev: longint; mode, secnr: smallint; nkey: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_load_key';
function rf_load_key_hex(icdev: longint; mode, secnr: smallint; nkey: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_load_key_hex';
function rf_authentication(icdev: longint; mode, secnr: smallint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_authentication';
  //
function rf_read(icdev: longint; adr: smallint; data: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_read';
function rf_read_hex(icdev: longint; adr: smallint; data: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_read_hex';
function rf_write(icdev: longint; adr: smallint; data: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_write';
function rf_write_hex(icdev: longint; adr: smallint; data: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_write_hex';
function rf_halt(icdev: longint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_halt';
function rf_reset(icdev: longint; msec: smallint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_reset';
  //M1 CARD
function rf_initval(icdev: longint; adr: smallint; value: longint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_initval';
function rf_readval(icdev: longint; adr: smallint; value: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_readval';
function rf_increment(icdev: longint; adr: smallint; value: longint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_increment';
function rf_decrement(icdev: longint; adr: smallint; value: longint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_decrement';
function rf_restore(icdev: longint; adr: smallint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_restore';
function rf_transfer(icdev: longint; adr: smallint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_transfer';
function rf_check_write(icdev, snr: longint; adr, authmode: smallint; data: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_check_write';
function rf_check_writehex(icdev, snr: longint; adr, authmode: smallint; data: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_check_writehex';

    //M1 CARD HIGH FUNCTION
function rf_HL_initval(icdev: longint; mode: smallint; secnr: smallint; value: longint; snr: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_HL_initval';
function rf_HL_increment(icdev: longint; mode: smallint; secnr: smallint; value, snr: longint; svalue, ssnr: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_HL_increment';
function rf_HL_decrement(icdev: longint; mode: smallint; secnr: smallint; value: longint; snr: longint; svalue, ssnr: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_HL_decrement';
function rf_HL_write(icdev: longint; mode, adr: smallint; ssnr, sdata: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_HL_write';
function rf_HL_read(icdev: longint; mode, adr: smallint; snr: longint; sdata, ssnr: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_HL_read';
function rf_changeb3(Adr: pchar; keyA: pchar; B0: pchar; B1: pchar; B2: pchar; B3: pchar; Bk: pchar; KeyB: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_changeb3';
  //DEVICE
function rf_get_status(icdev: longint; status: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_get_status';
function rf_beep(icdev: longint; time: smallint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_beep';
function rf_ctl_mode(icdev: longint; ctlmode: smallint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_ctl_mode';
function rf_disp_mode(icdev: longint; mode: smallint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_disp_mode';
function rf_disp8(icdev: longint; len: longint; disp: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_disp8';
function rf_disp(icdev: longint; pt_mode: smallint; disp: longint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_disp';
  //
function rf_settimehex(icdev: longint; dis_time: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_settimehex';
function rf_gettimehex(icdev: longint; dis_time: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_gettimehex';
function rf_swr_eeprom(icdev: longint; offset, len: smallint; data: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_swr_eeprom';
function rf_srd_eeprom(icdev: longint; offset, len: smallint; data: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_srd_eeprom';
  //ML CARD
function rf_authentication_2(icdev: longint; mode, keyNum, secnr: smallint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_authentication_2';
function rf_initval_ml(icdev: longint; value: longint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_initval_ml';
function rf_readval_ml(icdev: longint; rvalue: pchar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_readval_ml';
function rf_decrement_transfer(icdev: longint; adr: smallint; value: longint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_decrement_transfer';
function rf_sam_rst(icdev: longint; baud: smallint; samack: pChar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_sam_rst';
function rf_sam_trn(icdev: longint; samblock, recv: pChar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_sam_trn';
function rf_sam_off(icdev: longint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_sam_off';
function rf_cpu_rst(icdev: longint; baud: smallint; cpuack: pChar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_cpu_rst';
function rf_cpu_trn(icdev: longint; cpublock, recv: pChar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_cpu_trn';
function rf_pro_rst(icdev: longint; _Data: pChar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_pro_rst';
function rf_pro_trn(icdev: longint; problock, recv: pChar): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_pro_trn';
function rf_pro_halt(icdev: longint): smallint; stdcall;
far; external 'mwrf32.dll' name 'rf_pro_halt';
function hex_a(hex, a: pChar; length: smallint): smallint; stdcall;
far; external 'mwrf32.dll' name 'hex_a';
function a_hex(a, hex: pChar; length: smallint): smallint; stdcall;
far; external 'mwrf32.dll' name 'a_hex';
implementation

{$R *.dfm}

var MyThread: TMyThread;

procedure TMyThread.Execute;
begin
  { Place thread code here }
  FreeOnTerminate := True; {加上这句线程用完了会自动注释}
  Run;
end;

procedure TMyThread.Run;
begin
  while true do
  try
    Sleep(100);
  except
  end;
end;

(*
 * 读卡代码
 *
 * @date  2016/12/14
 * @author cnbbx
 * @param TObject Sender
 * @version 1.0
 * @return word
 *)

procedure TForm1.Button1Click(Sender: TObject);
begin
  st := rf_card(icdev, 1, @snr);
  if st <> 0 then
  begin
    ShowMessage('找不到卡！');
  end
  else
  begin
    st := rf_authentication(icdev, loadmode, sector);
    st := rf_read(icdev, block, @databuff);
    if st <> 0 then
    begin
      ShowMessage('读取失败！');
    end
    else
    begin
      st := rf_beep(icdev, 10);
      ShowMessage('会员卡号：' + databuff);
    end; end;
end;

(*
 * 写卡代码
 *
 * @date  2016/12/14
 * @author cnbbx
 * @param TObject Sender
 * @version 1.0
 * @return word
 *)

procedure TForm1.Button2Click(Sender: TObject);
begin
  nkey := 'FFFFFFFFFFFF';
  st := rf_load_key_hex(icdev, loadmode, sector, nkey);
  st := rf_card(icdev, 1, @snr);
  st := rf_authentication(icdev, loadmode, sector);
  wdata := '00049BE2CD22ff07806900049BE2CD22';
  st := rf_write_hex(icdev, (sector * 4 + 3), wdata);
  nkey := '00049BE2CD22';
  st := rf_load_key_hex(icdev, loadmode, sector, nkey);
  st := rf_card(icdev, 1, @snr);
  if st <> 0 then
  begin
    ShowMessage('找不到卡！');
  end
  else
  begin
    st := rf_authentication(icdev, loadmode, sector);
    wdata := PAnsiChar(Edit1.Text);
    st := rf_write(icdev, block, wdata);
    if st <> 0 then
    begin
      ShowMessage('写入失败！');
    end
    else
    begin
      st := rf_beep(icdev, 10);
      ShowMessage('会员卡号：' + Edit1.Text + '写入成功！');
      Edit1.Text := IntToStr(StrToInt(Edit1.Text) + 1);
      Edit2.Text := IntToStr(StrToInt(Edit2.Text) + 1);
    end;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var vJson, vItem: ISuperObject; str, msg: string;
begin
  nkey := 'FFFFFFFFFFFF';
  st := rf_load_key_hex(icdev, loadmode, sector, nkey);
  st := rf_card(icdev, 1, @snr);
  st := rf_authentication(icdev, loadmode, sector);
  wdata := '00049BE2CD22ff07806900049BE2CD22';
  st := rf_write_hex(icdev, (sector * 4 + 3), wdata);
  nkey := '00049BE2CD22';
  st := rf_load_key_hex(icdev, loadmode, sector, nkey);
  st := rf_card(icdev, 1, @snr);
  if st <> 0 then
  begin
    ShowMessage('找不到卡！');
  end
  else
  begin
    st := rf_authentication(icdev, loadmode, sector);
    wdata := PAnsiChar(Edit1.Text);
    st := rf_write(icdev, block, wdata);
    if st <> 0 then
    begin
      ShowMessage('写入失败！');
    end
    else
    begin
      st := rf_beep(icdev, 10);
      try
        HttpClient := TIdHTTP.Create(nil);
        ParamList := TStringList.Create;
        ParamList.Add('item_no=2');
        ParamList.Add('sign_card=' + AnsiToUtf8(Edit1.Text));
        ParamList.Add('sign_no=' + AnsiToUtf8(Edit2.Text));
        ParamList.Add('sign_name=' + AnsiToUtf8(Edit3.Text));
        ParamList.Add('sign_store=' + AnsiToUtf8(Edit4.Text));
        ParamList.Add('sign_company=' + AnsiToUtf8(Edit5.Text));
        str := Utf8ToAnsi(HttpClient.Post('http://web.amyun.cn/api/sign/saveblock', ParamList));
        vJson := SO(str);
        if StrToInt(vJson['code'].AsString) = 1 then
        begin
          ShowMessage('会员卡号：' + Edit1.Text + '写入成功！');   
          Edit1.Text := IntToStr(StrToInt(Edit1.Text) + 1);
          Edit2.Text := IntToStr(StrToInt(Edit2.Text) + 1);
        end;
        if vJson['code'].AsString = '0' then
        begin
          case StrToInt(vJson['msg'].AsString) of
            0: msg := '服务器繁忙！';
            210: msg := '签到未开启或已结束！';
            211: msg := '刚刚已经签过到了！';
            213: msg := '机器卡无效！';
            214: msg := '机器卡已经存在！';
          else msg := '系统异常错误！error:' + vJson['msg'].AsString;
          end;
          ShowMessage(msg);
          wdata := PAnsiChar('');
          st := rf_write(icdev, block, wdata);
        end;
      except
        ShowMessage('服务器异常！');
      end;
    end;
  end;
end;

(*
 * 启动初始化
 *
 * @date  2016/12/14
 * @author cnbbx
 * @param TObject Sender
 * @version 1.0
 * @return string
 *)

procedure TForm1.FormCreate(Sender: TObject);
var str: string;
begin
  icdev := rf_init(0, 115200);
  snr := 0;
  sector := 1;
  block := 4;
  loadmode := 0;
  nkey := '00049BE2CD22';
  st := rf_load_key_hex(icdev, loadmode, sector, nkey);
  if st <> 0 then
  begin
    ShowMessage('找不到艾美e族签到设备！');
    ExitProcess(0); Application.Terminate;
  end;
  str := InputBoxEx('艾美e族实体会员卡制卡系统', '请输入6-8位密码：　　', '', '*');
  if Rc4_StrEncrypt(1, str, 'jinge') = '94E1C0F04BDF4AB2363222D7AF468DB2' then
  begin
    MyThread := TMyThread.Create(False);
  end
  else
  begin
    ExitProcess(0); Application.Terminate;
  end;
end;

end.

