#requires -Version 5.1

Param(
	[string]$FilePath,
	[string]$Algorithm = "MD5",
	[string]$Sum,
	[switch]$Verify = $False
)

$Supported = "SHA1","SHA256","SHA384","SHA512","MACTripleDES","MD5","RIPEMD160"

Function Hash {
Param(
	[string]$file,
	[string]$alg
)	
	Return Get-FileHash $file -Algorithm $alg
}

Function Verify {
Param(
	[string]$file,
	[string]$alg,
	[string]$sum
)
	$hash = Hash $file $alg
	if ($sum.ToUpper() -eq $hash.Hash) {
		Return "$FileName OK"
	} else {
		Return "Verification failed"
	}
}

if (-not $FilePath -or (-not (Test-Path $FilePath))) {
	Write-Host -ForegroundColor Red "A valid file argument is required"
    Return
}

$FileName = (Get-Item $FilePath).Name

if ($Algorithm) {
	$Algorithm = $Algorithm.ToUpper()
	if ($Algorithm -in $Supported) {
		if ($Verify) {
			if ($Sum) {
				Verify $FilePath $Algorithm $Sum
			} else {
				Write-Host -ForegroundColor Red "A checksum value is required for verification"
				Return
			}
		} else {
			$ret = Hash $FilePath $Algorithm
			Return "$($ret.Hash) *$FileName"
		}
	} else {
		Write-Host -ForegroundColor Red "Algorithm '$Algorithm' is not supported"
		Return
	}
} else {
	Write-Host -ForegroundColor Red "Algorithm must be specified"
	Return
}