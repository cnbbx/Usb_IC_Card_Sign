# Usb_IC_Card_Sign
USB M1 IC卡签到和制卡系统（Delphi）

> 需要Delphi7以上环境二次开发。

~~~
Rc4_Unit.pas
 函数名:   Rc4_StrEncrypt()
 描  述:   RC4 Based string encryption
 参  数:   i_Encrypt ——为 1 是加密, 0 是解密（integer类型）；
           s_EncryptText ——待加密（解密）的字符串（string类型）；
           s_EncryptPassword ——加密（解密）的密码（string类型）；
           i_EncryptLevel ——加密级别（范围：1－－10；integer类型））
           
InputBox.pas
 函数名:    InputBoxEx()
 描  述:    输入对话框
 参  数:    ACaption ——为对话框标题内容
           APrompt ——为对话框正文内容
           ADefault ——为对话框默认内容
           PassWordChar ——如果是密文填写“*”
           
superobject.pas
 函数名：    SO()
 描  述:    json文本转数组
 参  数:    value ——为文本json
~~~
更多细节参阅 [LICENSE](LICENSE)