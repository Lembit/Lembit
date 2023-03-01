# Disable extraneous services on Server 2016 Desktop Experience
# https://blogs.technet.microsoft.com/secguide/2017/05/29/guidance-on-disabling-system-services-on-windows-server-2016-with-desktop-experience/
Configuration DisablingServicesOnServer2016wDE
{
    param(
        [String]$ComputerName = "localhost",
        [ValidateSet('ShouldBeDisabledOnly','ShouldBeDisabledAndDefaultOnly','OKToDisable','OKToDisablePrinter','OKToDisableDC')]
        [String]$Level = 'OKToDisable'
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    [String[]]$DisabledByDefault = @(
                                        "tzautoupdate",
                                        "Browser",
                                        "AppVClient",
                                        "NetTcpPortSharing",
                                        "CscService",
                                        "RemoteAccess",
                                        "SCardSvr",
                                        "UevAgentService",
                                        "WSearch"
                                    )
    [String[]]$ShouldBeDisabled = @(
                                        "XblAuthManager",
                                        "XblGameSave"
                                    )
    [String[]]$OKToDisable = @(
                                        "AxInstSV",
                                        "bthserv",
                                        "CDPUserSvc",
                                        "PimIndexMaintenanceSvc"
                                        "dmwappushservice",
                                        "MapsBroker",
                                        "lfsvc",
                                        "SharedAccess",
                                        "lltdsvc",
                                        "wlidsvc",
                                        "NgcSvc",
                                        "NgcCtnrSvc",
                                        "NcbService",
                                        "PhoneSvc",
                                        "PcaSvc",
                                        "QWAVE",
                                        "RmSvc",
                                        "SensorDataService",
                                        "SensrSvc",
                                        "SensorService",
                                        "ShellHWDetection",
                                        "ScDeviceEnum",
                                        "SSDPSRV",
                                        "WiaRpc",
                                        "OneSyncSvc",
                                        "TabletInputService",
                                        "upnphost",
                                        "UserDataSvc",
                                        "UnistoreSvc",
                                        "WalletService",
                                        "Audiosrv",
                                        "AudioEndpointBuilder",
                                        "FrameServer",
                                        "stisvc",
                                        "wisvc",
                                        "icssvc",
                                        "WpnService",
                                        "WpnUserService"
                                )
    [String[]]$OKToDisableNotDCorPrint = @('Spooler')
    [String[]]$OKToDisableNotPrint = @('PrintNotify')
    [String[]]$ServicesToDisable = @()

    switch($Level)
    {
        'ShouldBeDisabledOnly'           { $ServicesToDisable += $ShouldBeDisabled }
        'ShouldBeDisabledAndDefaultOnly' { $ServicesToDisable += $ShouldBeDisabled + $DisabledByDefault }
        'OKToDisablePrinter'             { $ServicesToDisable += $ShouldBeDisabled + $DisabledByDefault + $OKToDisable }
        'OKToDisableDC'                  { $ServicesToDisable += $ShouldBeDisabled + $DisabledByDefault + $OKToDisable + $OKToDisableNotDCorPrint }
        'OKToDisable'                    { $ServicesToDisable += $ShouldBeDisabled + $DisabledByDefault + $OKToDisable + $OKToDisableNotDCorPrint + $OKToDisableNotPrint }
    }

    $InstalledServices = Get-Service

    Node $ComputerName
    {   
        foreach($Service in $ServicesToDisable)
        {
            if($InstalledServices.Name -contains $Service)
            { 
                Service $( 'DisabledService_' + $Service )
                {
                    Name = $Service
                    StartupType = "Disabled"
                    State = "Stopped"
                }
            }
        }
    }
}
DisablingServicesOnServer2016wDE
