# Servidor local do Jump Battle (necessario para o YouTube tocar)
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$porta = 8643
$l = New-Object System.Net.HttpListener
$l.Prefixes.Add("http://localhost:$porta/")
try { $l.Start() } catch { Write-Host "Servidor ja esta rodando."; exit }
Write-Host "Jump Battle rodando em http://localhost:$porta  (pode minimizar, nao feche)"
$tipos = @{ '.html'='text/html; charset=utf-8'; '.js'='text/javascript'; '.css'='text/css'; '.mp4'='video/mp4'; '.png'='image/png'; '.json'='application/json' }
while ($l.IsListening) {
  try {
    $c = $l.GetContext()
    $p = [Uri]::UnescapeDataString($c.Request.Url.AbsolutePath.TrimStart('/'))
    if ($p -eq '') { $p = 'index.html' }
    $f = Join-Path $root $p
    if (Test-Path -LiteralPath $f -PathType Leaf) {
      $b = [IO.File]::ReadAllBytes($f)
      $ext = [IO.Path]::GetExtension($f).ToLower()
      if ($tipos.ContainsKey($ext)) { $c.Response.ContentType = $tipos[$ext] }
      $c.Response.Headers.Add('Cache-Control','no-store')
      $c.Response.OutputStream.Write($b, 0, $b.Length)
    } else { $c.Response.StatusCode = 404 }
    $c.Response.Close()
  } catch { }
}
