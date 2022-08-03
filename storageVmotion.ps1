write-host -ForegroundColor Green "Conectando a vcenter.contoso.com..."

Connect-VIServer -Server "vcenter.consoso.com"

Start-Sleep -s 3

function showMenu {
    Clear-Host
    Write-Host "Storage tools for VMware | fjuan"
    Write-Host ""
    Write-Host "================ Menu ================"
    Write-Host "1. Mostrar listado VMs"
    Write-Host "2. Mostrar listado Datastores"
    Write-Host "3. Realizar migracion"
    Write-Host "0. Exit"
    Write-Host ""
}

function showVMs {
   Get-VM | Select-Object Name,@{N="Datastore";E={[string]::Join(',',(Get-Datastore -Id $_.DatastoreIdList | Select -ExpandProperty Name))}}
}
        
function showDS {
    Get-Datastore | select name, capacityGB, FreespaceGB
}		
        
function migrateVMs {
    $VMName= Read-Host -Prompt "Escribe el nombre de la VM que quieres migrar."
    $VM=Get-VM -Name $VMName
    Get-Datastore | select name
    Write-Host "Escribe el nombre de el datastore de destino tal y como se muestra arriba:"
    write-host ""
    $datastore = read-host;
    $OriginalState= $vm.PowerState
    
	if ($OriginalState -eq "PoweredOn") {
        Write-Host "Apagando VM..." $VM.Name
        Shutdown-VMGuest -VM $VM -Confirm:$false
	
	do {
	Start-Sleep -s 5
	$VM = Get-VM -Name $VMName
	$status = $vm.PowerState
	   }
	until($status -eq "PoweredOff")
	}

	Write-Host $VM.Name "apagada, procediendo a la migracion..."
	Move-VM -Datastore $datastore -VM $VM -DiskStorageFormat Thin
	if ($OriginalState -eq "PoweredOn") {
	Write-Host "Arrancando" $VM.Name
	Start-VM -VM $VM
	}  

	Write-Host "Migracion completada"
	Write-Host "Recuerda revisar que los servicios hayanb arrancado correctamente"
}
                       
        showmenu
while(($inp = Read-Host -Prompt "Selecciona una opcion") -ne "0"){

  switch($inp){
        1 {
            Clear-Host
            Write-Host "------------------------------";
            Write-Host "Mostrar listado VMs"; 
            Write-Host "------------------------------";
            showVMs;
            pause;
            showMenu
        }
        2 {
            Clear-Host
            Write-Host "------------------------------";
            Write-Host "Mostrar listado Datastores";
            Write-Host "------------------------------";
            showDS;
            pause; 
            showMenu
        }
        3 {
            Clear-Host
            Write-Host "------------------------------";
            Write-Host "Realizar migración";
            Write-Host "------------------------------";
            migrateVMs;
            pause; 
            showMenu
        }
    }
}
	
	
