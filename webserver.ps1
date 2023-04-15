$url = "http://localhost:8080/"

Write-Host "Starting..."

Add-Type -AssemblyName System.Web

$server = [System.Net.HttpListener]::new() 
$server.Prefixes.Add($url)
$server.Start()

Write-Host "Started." -ForegroundColor Green
Write-Host "Url: $url"
Write-Host "Path: $(Get-Location)"
Write-Host "Go to $($url)quit to quit."

while ($server.IsListening) {
	$context = $server.GetContext()
	$file = $context.Request.Url.LocalPath

    if ($file -eq "/quit") {
        $context.Response.Close()
		$server.Close()
		break
    } elseif ($file -eq "/") {
		$file = "/index.html"
	}

	try {
		$data = [IO.File]::ReadAllBytes(".$file")
		$context.Response.OutputStream.Write($data, 0, $data.Length)
		Write-Host $file -ForegroundColor Green
	} catch {
		Write-Host "$file - $_" -ForegroundColor Red
		$error.Clear()
	}
	
	$context.Response.Close()
}

Write-Host "Quit."
Read-Host