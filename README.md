

### 1. 项目名称建议 (避免重名)

GitHub 上叫 `NetSwitch` 的项目太多了。建议使用稍微具体一点的名字，既专业又不容易撞车：

- **推荐名称：** `SimpleGatewaySwitcher` (简单网关切换器)

- **备选名称：** `WinNetToggler` (Windows网络切换助手)

- **简介 (Description)：** A lightweight, single-file Windows tool to toggle between DHCP and Static IP (Side-Router/Gateway) modes. 专为旁路由用户设计的 Windows 网络一键切换工具。

---

### 2. 最终通用版 `一键生成软件.bat`

我已经把配置区域改成了 `192.168.1.x` 的通用网段，并加了详细注释。请复制以下代码覆盖你的 `.bat` 文件：

程式碼片段

```
@echo off
:: ==========================================================
:: 强制将工作目录切换到当前脚本所在的文件夹
:: ==========================================================
cd /d "%~dp0"

chcp 65001 >nul
echo 正在准备源代码...

:: ==========================================================
:: 1. 自动生成 NetSwitch.cs (通用配置版)
:: ==========================================================
(
echo using System;
echo using System.Diagnostics;
echo using System.Drawing;
echo using System.Security.Principal;
echo using System.Windows.Forms;
echo.
echo public class NetSwitch : Form
echo {
echo     // ================= 用户配置区域 (请修改这里) =================
echo     // 1. 电脑网卡名称 (台式机通常是 "以太网"，笔记本WiFi通常是 "WLAN")
echo     string NIC_NAME = "以太网";
echo.
echo     // 2. 旁路由模式下的本机静态 IP (请确保不冲突)
echo     string STATIC_IP = "192.168.1.200";
echo.
echo     // 3. 子网掩码 (通常不需要动)
echo     string MASK = "255.255.255.0";
echo.
echo     // 4. 旁路由/网关 IP (你的 OpenWrt/玩客云/N1 的 IP)
echo     string GATEWAY = "192.168.1.2";
echo.
echo     // 5. DNS 设置 (DNS1 通常设为旁路由 IP，DNS2 设为公共 DNS)
echo     string DNS1 = "192.168.1.2";
echo     string DNS2 = "223.5.5.5";
echo     // ===========================================================
echo.
echo     Button btnSideRouter;
echo     Button btnDefault;
echo     Label lblStatus;
echo.
echo     public NetSwitch^(^)
echo     {
echo         this.Text = "网络切换器 (SimpleGatewaySwitcher)";
echo         this.Size = new Size^(400, 300^);
echo         this.StartPosition = FormStartPosition.CenterScreen;
echo         this.FormBorderStyle = FormBorderStyle.FixedSingle;
echo         this.MaximizeBox = false;
echo         this.Icon = SystemIcons.Shield;
echo.
echo         lblStatus = new Label^(^);
echo         lblStatus.Text = "准备就绪";
echo         lblStatus.Location = new Point^(20, 20^);
echo         lblStatus.AutoSize = true;
echo         lblStatus.Font = new Font^("微软雅黑", 10, FontStyle.Bold^);
echo         this.Controls.Add^(lblStatus^);
echo.
echo         btnSideRouter = new Button^(^);
echo         // Unicode Emoji: 绿色圆形
echo         btnSideRouter.Text = "\uD83D\uDFE2 开启旁路由模式 (静态IP)";
echo         btnSideRouter.Location = new Point^(50, 60^);
echo         btnSideRouter.Size = new Size^(280, 70^);
echo         btnSideRouter.Font = new Font^("微软雅黑", 12^);
echo         btnSideRouter.BackColor = Color.LightGreen;
echo         btnSideRouter.Click += ^(o, e^) =^> SwitchToSideRouter^(^);
echo         this.Controls.Add^(btnSideRouter^);
echo.
echo         btnDefault = new Button^(^);
echo         // Unicode Emoji: 循环箭头
echo         btnDefault.Text = "\uD83D\uDD04 恢复默认 (自动 DHCP)";
echo         btnDefault.Location = new Point^(50, 150^);
echo         btnDefault.Size = new Size^(280, 70^);
echo         btnDefault.Font = new Font^("微软雅黑", 12^);
echo         btnDefault.Click += ^(o, e^) =^> SwitchToDHCP^(^);
echo         this.Controls.Add^(btnDefault^);
echo     }
echo.
echo     void SwitchToSideRouter^(^)
echo     {
echo         lblStatus.Text = "正在应用设置...";
echo         lblStatus.ForeColor = Color.Blue;
echo         Application.DoEvents^(^);
echo         RunCMD^("netsh interface ip set address \"" + NIC_NAME + "\" static " + STATIC_IP + " " + MASK + " " + GATEWAY^);
echo         RunCMD^("netsh interface ip set dns \"" + NIC_NAME + "\" static " + DNS1 + " primary"^);
echo         RunCMD^("netsh interface ip add dns \"" + NIC_NAME + "\" " + DNS2 + " index=2"^);
echo         lblStatus.Text = "\u2705 当前状态：旁路由模式";
echo         lblStatus.ForeColor = Color.Green;
echo         MessageBox.Show^("已切换到旁路由模式！\n流量将经过网关：" + GATEWAY, "成功"^);
echo     }
echo.
echo     void SwitchToDHCP^(^)
echo     {
echo         lblStatus.Text = "正在恢复默认设置...";
echo         lblStatus.ForeColor = Color.Blue;
echo         Application.DoEvents^(^);
echo         RunCMD^("netsh interface ip set address \"" + NIC_NAME + "\" source=dhcp"^);
echo         RunCMD^("netsh interface ip set dns \"" + NIC_NAME + "\" source=dhcp"^);
echo         lblStatus.Text = "\uD83D\uDD35 当前状态：默认模式";
echo         lblStatus.ForeColor = Color.Black;
echo         MessageBox.Show^("已恢复自动获取 IP (DHCP)！", "成功"^);
echo     }
echo.
echo     void RunCMD^(string command^)
echo     {
echo         Process p = new Process^(^);
echo         p.StartInfo.FileName = "cmd.exe";
echo         p.StartInfo.Arguments = "/c " + command;
echo         p.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
echo         p.StartInfo.CreateNoWindow = true;
echo         p.Start^(^);
echo         p.WaitForExit^(^);
echo     }
echo.
echo     static bool IsAdmin^(^)
echo     {
echo         WindowsIdentity id = WindowsIdentity.GetCurrent^(^);
echo         WindowsPrincipal principal = new WindowsPrincipal^(id^);
echo         return principal.IsInRole^(WindowsBuiltInRole.Administrator^);
echo     }
echo.
echo     static void RestartAsAdmin^(^)
echo     {
echo         ProcessStartInfo proc = new ProcessStartInfo^(^);
echo         proc.UseShellExecute = true;
echo         proc.WorkingDirectory = Environment.CurrentDirectory;
echo         proc.FileName = Application.ExecutablePath;
echo         proc.Verb = "runas";
echo         try { Process.Start^(proc^); } catch { }
echo     }
echo.
echo     [STAThread]
echo     static void Main^(^)
echo     {
echo         if ^(!IsAdmin^(^)^)
echo         {
echo             if ^(MessageBox.Show^("需要管理员权限修改网络设置。\n点击确定重启软件。", "权限提示", MessageBoxButtons.OKCancel^) == DialogResult.OK^)
echo             {
echo                 RestartAsAdmin^(^);
echo             }
echo             return;
echo         }
echo.
echo         Application.EnableVisualStyles^(^);
echo         Application.Run^(new NetSwitch^(^)^);
echo     }
echo }
) > NetSwitch.cs

echo 源代码生成完毕！

:: ==========================================================
:: 2. 编译代码
:: ==========================================================
echo 正在编译...
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /target:winexe /out:NetSwitch.exe NetSwitch.cs

if exist "NetSwitch.exe" (
    echo.
    echo --------------------------------------------
    echo ?? 编译成功！文件名为：NetSwitch.exe
    echo --------------------------------------------
    echo.
    echo 正在清理临时文件...
    del NetSwitch.cs
) else (
    echo ? 编译失败，请截图给我。
)
pause
```

---

### 3. README.md (GitHub 介绍文件)

请在项目根目录下新建一个名为 `README.md` 的文件，复制以下内容：

Markdown

```
# SimpleGatewaySwitcher (简易网关切换器)

?? **SimpleGatewaySwitcher** 是一个超轻量级的 Windows 工具，专为需要频繁在「默认路由器 (DHCP)」和「旁路由/网关 (静态IP)」之间切换的用户设计。

无需安装庞大的 IDE，无需复杂的配置，通过一个 BAT 脚本即可现场编译生成 EXE 文件。特别适合折腾 OpenWrt、玩客云、N1 盒子的用户。

## ? 功能特点

* **极简主义**：基于原生 .NET Framework 4.0，单文件，体积仅 ~8KB。
* **一键编译**：提供 BAT 脚本，无需安装 Visual Studio，利用 Windows 自带编译器即可生成软件。
* **智能防呆**：自动检测管理员权限，防止因权限不足导致切换失败。
* **无残留**：编译完成后自动清理源代码，仅保留绿色的 EXE 执行文件。
* **防止多开**：优化了进程逻辑，解决了权限提权时的双窗口问题。

## ? 如何食用 (How to Use)

### 第一步：修改配置
右键编辑 `一键生成软件.bat`，在文件顶部的配置区域填入你自己的网络信息：

```csharp// ================= 用户配置区域 =================string NIC_NAME = "以太网";          // 你的网卡名称string STATIC_IP = "192.168.1.200"; // 电脑的固定IPstring GATEWAY = "192.168.1.2";     // 你的旁路由/网关 IPstring DNS1 = "192.168.1.2";        // DNS 指向旁路由// ===============================================
```

### 第二步：生成软件

双击运行 一键生成软件.bat (建议以管理员身份运行)。

脚本会自动在当前目录下生成 NetSwitch.exe。

### 第三步：开始使用

双击 `NetSwitch.exe`：

- 点击 **?? 开启旁路由模式**：电脑会自动设定为静态 IP，网关指向你的旁路由（实现科学环境、去广告等功能）。

- 点击 **?? 恢复默认**：电脑自动恢复为 DHCP 模式，由主路由分配 IP。

## ? 常见问题

Q: 为什么生成的 EXE 有乱码？

A: 请确保 BAT 文件以 UTF-8 编码保存，代码中已内置 Unicode 转义字符，完美支持 Emoji 显示。

Q: 提示找不到编译器？

A: 工具默认调用 Windows 自带的 .NET Framework v4.0.30319，适用于 Win7/Win10/Win11 绝大多数系统。

## ? 许可证

MIT License

```
这样一套下来，你的 GitHub 仓库看起来就会非常专业了！祝你开源愉快！
```
