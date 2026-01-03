@echo off
:: ==========================================================
:: 1. 环境初始化 (防止路径错误和乱码)
:: ==========================================================
cd /d "%~dp0"
chcp 65001 >nul
title SimpleGatewaySwitcher 生成器
cls

echo ========================================================
echo       正在生成 SimpleGatewaySwitcher 源代码...
echo ========================================================
echo.

:: ==========================================================
:: 2. 生成 C# 源代码 (采用逐行写入模式，杜绝闪退)
:: ==========================================================

:: --- 写入头部引用 ---
echo using System; > NetSwitch.cs
echo using System.Diagnostics; >> NetSwitch.cs
echo using System.Drawing; >> NetSwitch.cs
echo using System.Security.Principal; >> NetSwitch.cs
echo using System.Windows.Forms; >> NetSwitch.cs
echo. >> NetSwitch.cs

:: --- 写入类定义 ---
echo public class NetSwitch : Form >> NetSwitch.cs
echo { >> NetSwitch.cs

:: --- 用户配置区域 (修改这里) ---
echo     // ================= 用户配置区域 ================= >> NetSwitch.cs
echo     // 1. 网卡名称 (台式机一般是 "以太网"，笔记本是 "WLAN") >> NetSwitch.cs
echo     string NIC_NAME = "以太网"; >> NetSwitch.cs
echo. >> NetSwitch.cs
echo     // 2. 静态IP设置 (旁路由模式下本机的固定IP) >> NetSwitch.cs
echo     string STATIC_IP = "192.168.1.200"; >> NetSwitch.cs
echo     string MASK = "255.255.255.0"; >> NetSwitch.cs
echo. >> NetSwitch.cs
echo     // 3. 旁路由/网关 IP (你的 OpenWrt/玩客云/N1 的IP) >> NetSwitch.cs
echo     string GATEWAY = "192.168.1.2"; >> NetSwitch.cs
echo. >> NetSwitch.cs
echo     // 4. DNS 设置 >> NetSwitch.cs
echo     string DNS1 = "192.168.1.2"; >> NetSwitch.cs
echo     string DNS2 = "223.5.5.5"; >> NetSwitch.cs
echo     // =============================================== >> NetSwitch.cs

:: --- 写入变量声明 ---
echo. >> NetSwitch.cs
echo     Button btnSideRouter; >> NetSwitch.cs
echo     Button btnDefault; >> NetSwitch.cs
echo     Label lblStatus; >> NetSwitch.cs

:: --- 构造函数 ---
echo. >> NetSwitch.cs
echo     public NetSwitch() >> NetSwitch.cs
echo     { >> NetSwitch.cs
echo         this.Text = "网络切换器 (SimpleGatewaySwitcher)"; >> NetSwitch.cs
echo         this.Size = new Size(400, 300); >> NetSwitch.cs
echo         this.StartPosition = FormStartPosition.CenterScreen; >> NetSwitch.cs
echo         this.FormBorderStyle = FormBorderStyle.FixedSingle; >> NetSwitch.cs
echo         this.MaximizeBox = false; >> NetSwitch.cs
echo         this.Icon = SystemIcons.Shield; >> NetSwitch.cs

:: --- 界面元素: 状态标签 ---
echo. >> NetSwitch.cs
echo         lblStatus = new Label(); >> NetSwitch.cs
echo         lblStatus.Text = "准备就绪"; >> NetSwitch.cs
echo         lblStatus.Location = new Point(20, 20); >> NetSwitch.cs
echo         lblStatus.AutoSize = true; >> NetSwitch.cs
echo         lblStatus.Font = new Font("微软雅黑", 10, FontStyle.Bold); >> NetSwitch.cs
echo         this.Controls.Add(lblStatus); >> NetSwitch.cs

:: --- 界面元素: 旁路由按钮 ---
echo. >> NetSwitch.cs
echo         btnSideRouter = new Button(); >> NetSwitch.cs
echo         // Unicode Emoji: 绿色圆圈 >> NetSwitch.cs
echo         btnSideRouter.Text = "\uD83D\uDFE2 开启旁路由模式 (静态IP)"; >> NetSwitch.cs
echo         btnSideRouter.Location = new Point(50, 60); >> NetSwitch.cs
echo         btnSideRouter.Size = new Size(280, 70); >> NetSwitch.cs
echo         btnSideRouter.Font = new Font("微软雅黑", 12); >> NetSwitch.cs
echo         btnSideRouter.BackColor = Color.LightGreen; >> NetSwitch.cs
:: 注意：BAT中写入大于号需要转义为 ^>
echo         btnSideRouter.Click += (o, e) =^> SwitchToSideRouter(); >> NetSwitch.cs
echo         this.Controls.Add(btnSideRouter); >> NetSwitch.cs

:: --- 界面元素: 恢复按钮 ---
echo. >> NetSwitch.cs
echo         btnDefault = new Button(); >> NetSwitch.cs
echo         // Unicode Emoji: 循环箭头 >> NetSwitch.cs
echo         btnDefault.Text = "\uD83D\uDD04 恢复默认 (自动 DHCP)"; >> NetSwitch.cs
echo         btnDefault.Location = new Point(50, 150); >> NetSwitch.cs
echo         btnDefault.Size = new Size(280, 70); >> NetSwitch.cs
echo         btnDefault.Font = new Font("微软雅黑", 12); >> NetSwitch.cs
echo         btnDefault.Click += (o, e) =^> SwitchToDHCP(); >> NetSwitch.cs
echo         this.Controls.Add(btnDefault); >> NetSwitch.cs
echo     } >> NetSwitch.cs

:: --- 逻辑函数: 切换到旁路由 ---
echo. >> NetSwitch.cs
echo     void SwitchToSideRouter() >> NetSwitch.cs
echo     { >> NetSwitch.cs
echo         lblStatus.Text = "正在应用设置..."; >> NetSwitch.cs
echo         lblStatus.ForeColor = Color.Blue; >> NetSwitch.cs
echo         Application.DoEvents(); >> NetSwitch.cs
echo         RunCMD("netsh interface ip set address \"" + NIC_NAME + "\" static " + STATIC_IP + " " + MASK + " " + GATEWAY); >> NetSwitch.cs
echo         RunCMD("netsh interface ip set dns \"" + NIC_NAME + "\" static " + DNS1 + " primary"); >> NetSwitch.cs
echo         RunCMD("netsh interface ip add dns \"" + NIC_NAME + "\" " + DNS2 + " index=2"); >> NetSwitch.cs
echo         lblStatus.Text = "\u2705 当前状态：旁路由模式"; >> NetSwitch.cs
echo         lblStatus.ForeColor = Color.Green; >> NetSwitch.cs
echo         MessageBox.Show("已切换到旁路由模式！\n流量将经过网关：" + GATEWAY, "成功"); >> NetSwitch.cs
echo     } >> NetSwitch.cs

:: --- 逻辑函数: 切换到DHCP ---
echo. >> NetSwitch.cs
echo     void SwitchToDHCP() >> NetSwitch.cs
echo     { >> NetSwitch.cs
echo         lblStatus.Text = "正在恢复默认设置..."; >> NetSwitch.cs
echo         lblStatus.ForeColor = Color.Blue; >> NetSwitch.cs
echo         Application.DoEvents(); >> NetSwitch.cs
echo         RunCMD("netsh interface ip set address \"" + NIC_NAME + "\" source=dhcp"); >> NetSwitch.cs
echo         RunCMD("netsh interface ip set dns \"" + NIC_NAME + "\" source=dhcp"); >> NetSwitch.cs
echo         lblStatus.Text = "\uD83D\uDD35 当前状态：默认模式"; >> NetSwitch.cs
echo         lblStatus.ForeColor = Color.Black; >> NetSwitch.cs
echo         MessageBox.Show("已恢复自动获取 IP (DHCP)！", "成功"); >> NetSwitch.cs
echo     } >> NetSwitch.cs

:: --- 工具函数: 运行CMD ---
echo. >> NetSwitch.cs
echo     void RunCMD(string command) >> NetSwitch.cs
echo     { >> NetSwitch.cs
echo         Process p = new Process(); >> NetSwitch.cs
echo         p.StartInfo.FileName = "cmd.exe"; >> NetSwitch.cs
echo         p.StartInfo.Arguments = "/c " + command; >> NetSwitch.cs
echo         p.StartInfo.WindowStyle = ProcessWindowStyle.Hidden; >> NetSwitch.cs
echo         p.StartInfo.CreateNoWindow = true; >> NetSwitch.cs
echo         p.Start(); >> NetSwitch.cs
echo         p.WaitForExit(); >> NetSwitch.cs
echo     } >> NetSwitch.cs

:: --- 权限检查逻辑 ---
echo. >> NetSwitch.cs
echo     static bool IsAdmin() >> NetSwitch.cs
echo     { >> NetSwitch.cs
echo         WindowsIdentity id = WindowsIdentity.GetCurrent(); >> NetSwitch.cs
echo         WindowsPrincipal principal = new WindowsPrincipal(id); >> NetSwitch.cs
echo         return principal.IsInRole(WindowsBuiltInRole.Administrator); >> NetSwitch.cs
echo     } >> NetSwitch.cs

echo. >> NetSwitch.cs
echo     static void RestartAsAdmin() >> NetSwitch.cs
echo     { >> NetSwitch.cs
echo         ProcessStartInfo proc = new ProcessStartInfo(); >> NetSwitch.cs
echo         proc.UseShellExecute = true; >> NetSwitch.cs
echo         proc.WorkingDirectory = Environment.CurrentDirectory; >> NetSwitch.cs
echo         proc.FileName = Application.ExecutablePath; >> NetSwitch.cs
echo         proc.Verb = "runas"; >> NetSwitch.cs
echo         try { Process.Start(proc); } catch { } >> NetSwitch.cs
echo     } >> NetSwitch.cs

:: --- 入口函数 Main ---
echo. >> NetSwitch.cs
echo     [STAThread] >> NetSwitch.cs
echo     static void Main() >> NetSwitch.cs
echo     { >> NetSwitch.cs
echo         if (!IsAdmin()) >> NetSwitch.cs
echo         { >> NetSwitch.cs
echo             if (MessageBox.Show("需要管理员权限修改网络设置。\n点击确定重启软件。", "权限提示", MessageBoxButtons.OKCancel) == DialogResult.OK) >> NetSwitch.cs
echo             { >> NetSwitch.cs
echo                 RestartAsAdmin(); >> NetSwitch.cs
echo             } >> NetSwitch.cs
echo             return; >> NetSwitch.cs
echo         } >> NetSwitch.cs
echo. >> NetSwitch.cs
echo         Application.EnableVisualStyles(); >> NetSwitch.cs
echo         Application.Run(new NetSwitch()); >> NetSwitch.cs
echo     } >> NetSwitch.cs
echo } >> NetSwitch.cs

echo 源代码 NetSwitch.cs 生成完毕！

:: ==========================================================
:: 3. 编译代码 (优化了引用库)
:: ==========================================================
echo 正在编译...
echo.

set COMPILER=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe

if not exist "%COMPILER%" (
    echo [错误] 找不到 C# 编译器，请确认你使用的是 Windows 系统。
    pause
    exit
)

:: 添加了引用库 /r:System.Windows.Forms.dll /r:System.Drawing.dll 以防止兼容性问题
"%COMPILER%" /target:winexe /out:NetSwitch.exe /r:System.Windows.Forms.dll /r:System.Drawing.dll NetSwitch.cs

if exist "NetSwitch.exe" (
    echo.
    echo --------------------------------------------------------
    echo ?? 编译成功！文件名为：NetSwitch.exe
    echo --------------------------------------------------------
    echo.
    echo 正在清理临时源代码...
    del NetSwitch.cs
    echo 清理完成。
) else (
    echo.
    echo ? 编译失败！请查看上方的错误信息。
)

:: 无论成功失败，都暂停一下，让你能看清结果
pause