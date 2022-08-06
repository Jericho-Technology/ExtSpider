$url = Read-Host 'Type in the URL that you would like to spider (e.g. http://testphp.vulnweb.com)'
if ($url -eq "")
	{
		write-host "No URL is entered!" -ForegroundColor Red
		Return
	}
else
	{
		write-host "URL is set to $url" -ForegroundColor Green
	}

[int]$depth = Read-Host "Enter the recursion depth of the visited URL (max 20) (default 1)"
if ([int]$depth -eq "")
	{
		$depth = 1
		write-host "Depth is set to default value of $depth" -ForegroundColor Green
	}
elseif ([int]$depth -le 20 -AND [int]$depth -ge 1)
	{
		write-host "Depth is set to $depth" -ForegroundColor Green
	}
elseif ([int]$depth -gt 20 -OR [int]$depth -lt 0)
	{
		write-host "Depth value cannot be $depth!" -ForegroundColor Red
		Return
	}
	
[int]$threads = Read-Host 'Enter the number of threads (Run sites in parallel) (max 100) (default 1)'
if ([int]$threads -gt 100)
	{
		write-host "Threads value is more than 100!" -ForegroundColor Red
		Return
	}
elseif ([int]$threads -eq 0)
	{
		$threads=1
		write-host "Threads value is set to $threads" -ForegroundColor Green
	}
elseif ([int]$threads -ge 1 -AND [int]$threads -le 100)
	{
		write-host "Threads value is set to $threads" -ForegroundColor Green
	}
elseif ([int]$threads -lt 0)
	{
		write-host "Threads value cannot be $threads!" -ForegroundColor Red
		Return
	}

[int]$concurrent = Read-Host 'Enter the number of the maximum allowed concurrent requests of the matching domain (max 50) (default 5)'
if ([int]$concurrent -gt 50)
	{
		write-host "Concurrent value is more than 50!" -ForegroundColor Red
		Return
	}
elseif ([int]$concurrent -eq 0)
	{
		$concurrent=5
		write-host "Concurrent value is set to $concurrent" -ForegroundColor Green
	}
elseif ([int]$concurrent -ge 1 -AND [int]$concurrent -le 50)
	{
		write-host "Concurrent value is set to $concurrent" -ForegroundColor Green
	}
elseif ([int]$concurrent -lt 0)
	{
		write-host "Concurrent cannot be $concurrent!" -ForegroundColor Red
		Return
	}

$agent = Read-Host 'Enter User Agent (default: curl/7.83.1)'
if ($agent -eq "")
	{
		$agent="curl/7.83.1"
		write-host "Default User Agent will be used." -ForegroundColor Green
	}
else
	{
		write-host "User Agent is set to $agent" -ForegroundColor Green
	}

$cookie = Read-Host 'Enter cookie(s) value (default = no cookie) (testA=a; testB=b)'
if ($cookie -eq "")
	{
		write-host "No cookie will be used." -ForegroundColor Green
	}
elseif ($cookie -ne "")
	{
		write-host "Your cookie(s) will be used." -ForegroundColor Green
	}
else
	{
		write-host "Invalid input, try again!" -ForegroundColor Red
		Return
	}

$custom_header = Read-Host 'Enter custom header (default = no custom header) (e.g. -H Header1 -H Header2)'
if ($custom_header -eq "")
	{
		write-host "No custom header will be used." -ForegroundColor Green
	}
elseif ($custom_header -ne "")
	{
		write-host "Custom header(s) will be used." -ForegroundColor Green
	}
else
	{
		write-host "Invalid input, try again!" -ForegroundColor Red
		Return
	}


New-Item "C:\path\to\urls3.txt";


# Create a conditional check if cookie and/or custom header is/are used in scan:

cd "C:\path\to\gospider_v1.1.6_windows_x86_64\";.\gospider.exe --site $url -d $depth -t $threads -c $concurrent -v $agent > "C:\path\to\temp.txt";

foreach($line in Get-Content -path "C:\path\to\temp.txt" |findstr "http")
{
    if($line -match 'href')
    {
        $line=$line.substring(9)
	$line >> "C:\path\to\urls3.txt"
    }
    elseif($line -match 'url')
    {
        $line=$line.TrimStart("[url] - [code-200] -")
	$line >> "C:\path\to\urls3.txt"
    }
    elseif($line -match 'form')
    {
        $line=$line.TrimStart("[form] -")
	$line >> "C:\path\to\urls3.txt"
    }
}

rm "C:\path\to\temp.txt" # edit this

type "C:\path\to\urls.txt" |findstr "testphp" |sort |get-unique  > "C:\path\to\urls.txt" # edit this line for path

rm "C:\path\to\urls3.txt"

foreach($line in Get-Content -path "C:\path\to\urls.txt" |findstr "testphp" |where{$_ -ne ""}) # edit this line for path
{
	curl.exe $line -x http://127.0.0.1:8080 -o NULL -s -A $agent
	write-host "Sending HTTP GET Request for $line to Proxy"
}

rm "C:\path\to\urls.txt"

cd ..
