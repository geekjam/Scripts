$download_url = "https://github.com/golangci/golangci-lint/releases/download/v1.28.0/golangci-lint-1.28.0-windows-amd64.zip"

Function Get-Webfile ($url, $toFile)
{
    Write-Host "Downloading $url`n" -ForegroundColor DarkGreen;
    $uri=New-Object "System.Uri" "$url"
    $request=[System.Net.HttpWebRequest]::Create($uri)
    $request.set_Timeout(5000)
    $response=$request.GetResponse()
    $totalLength=[System.Math]::Floor($response.get_ContentLength()/1024)
    $length=$response.get_ContentLength()
    $responseStream=$response.GetResponseStream()
    $toStream=New-Object -TypeName System.IO.FileStream -ArgumentList $toFile, Create
    $buffer=New-Object byte[] 10KB
    $count=$responseStream.Read($buffer,0,$buffer.length)
    $downloadedBytes=$count
    while ($count -gt 0)
    {
        [System.Console]::CursorLeft=0
        [System.Console]::Write("Downloaded {0}K of {1}K ({2}%)", [System.Math]::Floor($downloadedBytes/1024), $totalLength, [System.Math]::Round(($downloadedBytes / $length) * 100,0))
        $toStream.Write($buffer, 0, $count)
        $count=$responseStream.Read($buffer,0,$buffer.length)
        $downloadedBytes+=$count
    }
    Write-Host ""
    Write-Host "`nDownload of `"$toFile`" finished." -ForegroundColor DarkGreen;
    $toStream.Flush()
    $toStream.Close()
    $toStream.Dispose()
    $responseStream.Dispose()
}

Get-Webfile $download_url "$env:temp\golangci-lint.zip"
Expand-Archive -ErrorAction SilentlyContinue "$env:temp\golangci-lint.zip" "$env:temp\"
$goPath=$(go env GOPATH)
Copy-Item "$env:temp\golangci-lint-1.28.0-windows-amd64\golangci-lint.exe" "$goPath\bin\"
Remove-Item -Recurse -Force "$env:temp\golangci-lint-1.28.0-windows-amd64\"
Remove-Item -Force "$env:temp\golangci-lint.zip"
Write-Host "Complete."