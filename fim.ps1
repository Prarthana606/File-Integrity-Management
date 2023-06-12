
Write-Host ""
Write-Host "what would you like to do?"
Write-Host "A)Collect new Baseline?"
Write-Host "B)Begin monitoring files with saved Baseline"

$response = Read-Host -Prompt "Please enter 'A' or 'B'"

Function Calculate-File-Hash($filepath){
   $filehash=Get-FileHash -Path $filepath -Algorithm SHA512
   return $filehash
}
$hash=Calculate-File-Hash "C:\Users\HP\Desktop\CyberProjects\files"
function Erase-Baseline-If-Already-Exists(){
  $baselineExists = Test-Path -Path .\baseline.txt
  if($baselineExists)
  {
    #delete it
    Remove-Item -Path .\baseline.txt
  }
}

if($response -eq "A".ToUpper()){
  #calculate hash from the target files and store in baseline.txt
   #collect all the files in the target folder 
   #Delete Baseline if already exists
   Erase-Baseline-If-Already-Exists
   $files=Get-ChildItem -Path .\files
   #For each file Calculate the hash and write to baseline.txt 
   foreach($f in $files){
      $hash=Calculate-File-Hash $f.FullName
      "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
      
   }
}


elseif ($response -eq "B".ToUpper()){
  #begin monitoring files with saved baseline
  #Load file hash from baseline.txt and store them in a dictionary
  $fileHashDictionary=@{}

  $filePathsAndHashes= Get-Content -Path .\baseline.txt
   foreach($f in  $filePathsAndHashes){
   $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
      
   }
   $fileHashDictionary
  
  $fileHashDictionary.add("path","hash")
  $fileHashDictionary
  $fileHashDictionary["dfg"] -eq $null
  
  #Begin(continuosly) monitoring files with saved Baseline
  while($true){
     Start-Sleep -Seconds 1
     $files=Get-ChildItem -Path .\files
   #For each file Calculate the hash and write to baseline.txt 
   foreach($f in $files){
      $hash=Calculate-File-Hash $f.FullName
      "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
       if($fileHashDictionary[$hash.Path] -eq $null){
        #A file has been created
        Write-Host "$($hash.Path) has been created!" -Foreground Yellow 

       }
       #Notify if a new file has been changed
       if($fileHashDictionary[$hash.Path] -eq $hash.Hash){
          #this file has not been changed
       }
       else{
         #this file has been changed
         Write-Host "$($hash.Path) has changed" -ForegroundColor Red
       }
   }
  }
}

foreach($key in $fileHashDictionary.keys){
  $baselineFileStillExists= Test-Path -Path $key
  if(-Not $baselineFileStillExists){
     #one of the baseline file must have been deleted
     Write-Host "$($key) has been deleted!" -ForegroundColor White
  }
}