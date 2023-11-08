function checkCompatible(){

    ################################################################################################
    # This script can be used to check if your computer is compatible with Windows 11              #
    # Editor : Christopher Mogis                                                                   #
    # Date : 06/30/2022                                                                            #
    # Version 1.0                                                                                  #
    ################################################################################################

    $output = @()

    #Architecture x64
        $Arch = (Get-CimInstance -Class CIM_ComputerSystem).SystemType
        $ArchValue = "x64-based PC"
        if ($Arch -ne $ArchValue){
                $r = New-Object psobject
                    $r | Add-Member NoteProperty -Name status -Value "Failure"
                    $r | Add-Member NoteProperty -Name check -Value "Architecture x64"
                $output += $r
            }else{
                $r = New-Object psobject
                    $r | Add-Member NoteProperty -Name status -Value "Success"
                    $r | Add-Member NoteProperty -Name check -Value "Architecture x64"
                $output += $r
            }

    #Screen Resolution
        $ScreenInfo = (Get-CimInstance -ClassName Win32_VideoController).CurrentVerticalResolution
        $ValueMin = 720 
        if ($ScreenInfo -le $ValueMin){
                $r = New-Object psobject
                    $r | Add-Member NoteProperty -Name status -Value "Failure"
                    $r | Add-Member NoteProperty -Name check -Value "Screen resolution support"
                $output += $r
            } else { 
                 $r = New-Object psobject
                    $r | Add-Member NoteProperty -Name status -Value "Success"
                    $r | Add-Member NoteProperty -Name check -Value "Screen resolution support"
                $output += $r
            }
    
    #CPU composition
        $Core = (Get-CimInstance -Class CIM_Processor | Select-Object *).NumberOfCores
        $CoreValue = 2
        $Frequency = (Get-CimInstance -Class CIM_Processor | Select-Object *).MaxClockSpeed
        $FrequencyValue = 1000
        if (($Core -ge $CoreValue) -and ($Frequency -ge $FrequencyValue)){
                $r = New-Object psobject
                    $r | Add-Member NoteProperty -Name status -Value "Success"
                    $r | Add-Member NoteProperty -Name check -Value "Processor is compatible with Windows 11"
                $output += $r
        }else{
               $r = New-Object psobject
                    $r | Add-Member NoteProperty -Name status -Value "Faulure"
                    $r | Add-Member NoteProperty -Name check -Value "Processor is not compatible with Windows 11"
                $output += $r
        }

    #TPM
        if ((Get-Tpm).ManufacturerVersionFull20) {
            $TPM2 = -not (Get-Tpm).ManufacturerVersionFull20.Contains(“not supported”) 
         }

        if ($TPM2 -contains $False){
            $r = New-Object psobject
                $r | Add-Member NoteProperty -Name status -Value "Failure"
                $r | Add-Member NoteProperty -Name check -Value "TPM module is not compatible with Windows 11."
            $output += $r
        }else{
            $r = New-Object psobject
                $r | Add-Member NoteProperty -Name status -Value "Success"
                $r | Add-Member NoteProperty -Name check -Value "TPM module is not compatible with Windows 11."
            $output += $r
        }

    #Secure boot available and activated
        try{
            $SecureBoot = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue
        }catch{}

        if ($SecureBoot -ne $True){
            $r = New-Object psobject
                $r | Add-Member NoteProperty -Name status -Value "Failure"
                $r | Add-Member NoteProperty -Name check -Value "Secure boot"
            $output += $r
         }else{
            $r = New-Object psobject
                $r | Add-Member NoteProperty -Name status -Value "Success"
                $r | Add-Member NoteProperty -Name check -Value "Secure boot"
            $output += $r
         }

    #RAM available
        $Memory = (Get-CimInstance -Class CIM_ComputerSystem).TotalPhysicalMemory
        $SetMinMemory = 4294967296
        if ($Memory -lt $SetMinMemory){
             $r = New-Object psobject
                $r | Add-Member NoteProperty -Name status -Value "Failure"
                $r | Add-Member NoteProperty -Name check -Value "RAM below minimum requirement"
            $output += $r
        }else{
             $r = New-Object psobject
                $r | Add-Member NoteProperty -Name status -Value "Success"
                $r | Add-Member NoteProperty -Name check -Value "RAM above minimum requirement"
            $output += $r
        }

    #Storage available
        $ListDisk = Get-CimInstance -Class Win32_LogicalDisk | where {$_.DriveType -eq "3"}
        $SetMinSizeLimit = 64GB;
            #Scan Free Hard Drive Space
        foreach($Disk in $ListDisk){
           $DiskFreeSpace = ($Disk.freespace/1GB).ToString('F2')
        }

        if ($disk.FreeSpace -lt $SetMinSizeLimit) {
            $r = New-Object psobject
                $r | Add-Member NoteProperty -Name status -Value "Failure"
                $r | Add-Member NoteProperty -Name check -Value "Disk free space below minimum"
            $output += $r
        }else {
            $r = New-Object psobject
                $r | Add-Member NoteProperty -Name status -Value "Success"
                $r | Add-Member NoteProperty -Name check -Value "Disk free space above minimum"
            $output += $r
        }

    return $output
}
