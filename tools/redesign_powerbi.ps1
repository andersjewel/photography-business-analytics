$ErrorActionPreference = 'Stop'
$reportRoot = Join-Path $PSScriptRoot '..\powerbi\WildlightAnalytics.Report'
$definition = Join-Path $reportRoot 'definition'
$visualSchema = 'https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.9.0/schema.json'

function Lit([string]$value) { @{ expr = @{ Literal = @{ Value = $value } } } }
function Save-Json($value, [string]$path) {
    $parent = Split-Path $path -Parent
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    $json = $value | ConvertTo-Json -Depth 100
    [System.IO.File]::WriteAllText($path, $json, [System.Text.UTF8Encoding]::new($false))
}
function New-Position($x,$y,$z,$h,$w,$tab) { @{ x=$x; y=$y; z=$z; height=$h; width=$w; tabOrder=$tab } }
function New-Shape($id,$x,$y,$z,$h,$w,$color,$radius=0) {
    $shapeProps = @{ tileShape = Lit "'rectangle'" }
    if ($radius -gt 0) { $shapeProps.roundEdge = Lit "${radius}L" }
    $objects = @{
        shape=@(@{properties=$shapeProps})
        fill=@(@{properties=@{fillColor=@{solid=@{color=(Lit "'$color'")}};transparency=(Lit '0D')};selector=@{id='default'}})
        outline=@(@{properties=@{show=(Lit 'false')};selector=@{id='default'}})
    }
    $vco = @{background=@(@{properties=@{show=(Lit 'false')}});border=@(@{properties=@{show=(Lit 'false')}})}
    return @{'$schema'=$visualSchema;name=$id;position=(New-Position $x $y $z $h $w $z);visual=@{visualType='shape';objects=$objects;visualContainerObjects=$vco}}
}
function New-Text($id,$x,$y,$z,$h,$w,$text,$size,$color,$weight='Segoe UI Semibold',$align='left') {
    $paragraphs=@(@{textRuns=@(@{value=$text;textStyle=@{fontFamily=$weight;fontSize="${size}px";color=$color}});horizontalTextAlignment=$align})
    $objects=@{general=@(@{properties=@{paragraphs=$paragraphs}})}
    $vco=@{background=@(@{properties=@{show=(Lit 'false')}});border=@(@{properties=@{show=(Lit 'false')}});padding=@(@{properties=@{top=(Lit '0D');bottom=(Lit '0D');left=(Lit '0D');right=(Lit '0D')}})}
    return @{'$schema'=$visualSchema;name=$id;position=(New-Position $x $y $z $h $w $z);visual=@{visualType='textbox';objects=$objects;visualContainerObjects=$vco}}
}
function New-Slicer($id,$x,$label,$column) {
    $field=@{Column=@{Expression=@{SourceRef=@{Entity='Analytics'}};Property=$column}}
    $query=@{queryState=@{Values=@{projections=@(@{field=$field;queryRef="Analytics.$column";nativeQueryRef=$column})}}}
    $objects=@{data=@(@{properties=@{mode=(Lit "'Dropdown'")}});header=@(@{properties=@{show=(Lit 'true');text=(Lit "'$label'")}})}
    $vco=@{padding=@(@{properties=@{top=(Lit '8D');bottom=(Lit '8D');left=(Lit '8D');right=(Lit '8D')}})}
    return @{'$schema'=$visualSchema;name=$id;position=(New-Position $x 82 80 80 246 80);visual=@{visualType='slicer';query=$query;objects=$objects;visualContainerObjects=$vco}}
}
function New-FieldProjection([string]$kind,[string]$property,[string]$label) {
    if($kind -eq 'measure') {
        return @{field=@{Measure=@{Expression=@{SourceRef=@{Entity='Analytics'}};Property=$property}};queryRef="Analytics.$property";nativeQueryRef=$label}
    }
    if($kind -eq 'average') {
        return @{field=@{Aggregation=@{Expression=@{Column=@{Expression=@{SourceRef=@{Entity='Analytics'}};Property=$property}};Function=1}};queryRef="Average(Analytics.$property)";nativeQueryRef=$label}
    }
    return @{field=@{Aggregation=@{Expression=@{Column=@{Expression=@{SourceRef=@{Entity='Analytics'}};Property=$property}};Function=2}};queryRef="Count(Analytics.$property)";nativeQueryRef=$label}
}
function New-Chart($id,$type,$x,$y,$w,$h,$category,$series) {
    $categoryProjection=@{field=@{Column=@{Expression=@{SourceRef=@{Entity='Analytics'}};Property=$category}};queryRef="Analytics.$category";nativeQueryRef=$category;active=$true}
    $values=@()
    foreach($item in $series){$values += New-FieldProjection $item[0] $item[1] $item[2]}
    $query=@{queryState=@{Category=@{projections=@($categoryProjection)};Y=@{projections=$values}}}
    return @{'$schema'=$visualSchema;name=$id;position=(New-Position $x $y 100 $h $w 100);visual=@{visualType=$type;query=$query}}
}
function Add-PageSlicers([string]$page) {
    $v=Join-Path $definition "pages\$page\visuals"
    $items=@(
        (New-Slicer '90000000000000000011' 208 'Month' 'month'),
        (New-Slicer '90000000000000000012' 472 'Service' 'service_category'),
        (New-Slicer '90000000000000000013' 736 'Lead source' 'lead_source'),
        (New-Slicer '90000000000000000014' 1000 'Booking status' 'booking_status')
    )
    foreach($item in $items){Save-Json $item (Join-Path $v "$($item.name)\visual.json")}
}
function Add-ChartTitle([string]$page,[string]$id,[int]$x,[int]$y,[int]$w,[string]$title) {
    $v=Join-Path $definition "pages\$page\visuals"
    $item=New-Text $id $x $y 120 24 $w $title 12 '#183A37'
    Save-Json $item (Join-Path $v "$id\visual.json")
}
function Add-Chrome([string]$page,[string]$title,[string]$subtitle,[int]$active) {
    $v = Join-Path $definition "pages\$page\visuals"
    $items = @(
        (New-Shape 'f1000000000000000001' 0 0 1 720 184 '#183A37'),
        (New-Shape 'f1000000000000000002' 184 0 2 720 1096 '#F7F2E8'),
        (New-Text 'f1000000000000000003' 24 24 10 56 136 'WILDLIGHT' 20 '#F7F2E8'),
        (New-Text 'f1000000000000000004' 24 72 10 40 136 'BUSINESS ANALYTICS' 9 '#D6A84B'),
        (New-Text 'f1000000000000000005' 208 18 10 42 770 $title 24 '#183A37'),
        (New-Text 'f1000000000000000006' 208 55 10 26 880 $subtitle 10 '#6F756E')
    )
    $labels=@('Overview','Sales & Revenue','Marketing','Client Behavior','Operations')
    for($i=0;$i -lt 5;$i++) {
        $y=144+($i*62); $fill=if($i -eq $active){'#C66A4A'}else{'#254B47'}
        $items += New-Shape ("f10000000000000001{0:d2}" -f $i) 16 $y 5 46 152 $fill 8
        $items += New-Text ("f10000000000000002{0:d2}" -f $i) 28 ($y+11) 10 24 128 $labels[$i] 11 '#FFFDF8'
    }
    $items += New-Text 'f1000000000000000030' 24 650 10 42 138 'Updated from the portfolio dataset' 9 '#B9C9C6'
    foreach($item in $items){ Save-Json $item (Join-Path $v "$($item.name)\visual.json") }
}

$themeName='WildlightEditorial-8f31c2a4.json'
$theme=@{
    name=$themeName
    dataColors=@('#C66A4A','#183A37','#D6A84B','#6E8B84','#A94F3B','#7A6A58','#B5C5BE','#E3B8A6')
    good='#3F7D67';neutral='#D6A84B';bad='#A94F3B';maximum='#183A37';center='#D6A84B';minimum='#E8DDD0';null='#B7A99A'
    foreground='#183A37';foregroundNeutralSecondary='#6F756E';foregroundNeutralTertiary='#9AA09A';background='#FFFDF8';backgroundNeutral='#F7F2E8';backgroundLight='#E8DDD0';tableAccent='#C66A4A'
    textClasses=@{
        callout=@{fontFace='Segoe UI Semibold';fontSize=30;color='#183A37'}
        title=@{fontFace='Segoe UI Semibold';fontSize=13;color='#183A37'}
        header=@{fontFace='Segoe UI Semibold';fontSize=11;color='#183A37'}
        label=@{fontFace='Segoe UI';fontSize=10;color='#6F756E'}
    }
    visualStyles=@{
        '*'=@{'*'=@{
            background=@(@{show=$true;color=@{solid=@{color='#FFFDF8'}};transparency=0})
            border=@(@{show=$true;color=@{solid=@{color='#DED4C6'}};radius=8})
            title=@(@{show=$true;fontColor=@{solid=@{color='#183A37'}};fontFamily='Segoe UI Semibold';fontSize=12;alignment='left'})
            visualHeader=@(@{show=$false})
        }}
    }
}
$resourceDir=Join-Path $reportRoot 'StaticResources\RegisteredResources'
Save-Json $theme (Join-Path $resourceDir $themeName)
$report=Get-Content (Join-Path $definition 'report.json') -Raw | ConvertFrom-Json
$report.themeCollection | Add-Member -Force NoteProperty customTheme ([pscustomobject]@{name=$themeName;reportVersionAtImport=@{visual='3.0.0';page='3.0.0';report='3.0.0'};type='RegisteredResources'})
$report.resourcePackages=@(@{name='RegisteredResources';type='RegisteredResources';items=@(@{name=$themeName;path=$themeName;type='CustomTheme'})})
Save-Json $report (Join-Path $definition 'report.json')

Add-Chrome 'ExecutiveOverview' 'Photography Business Overview' 'Revenue, profitability, demand, and payment health at a glance' 0
Add-Chrome 'SalesRevenue' 'Sales & Revenue' 'Package performance and the mix of revenue and gross profit' 1
Add-Chrome 'MarketingPerformance' 'Marketing Performance' 'Booking volume and acquisition effectiveness by lead source' 2
Add-Chrome 'ClientBehavior' 'Client Behavior' 'Service demand and client preferences across the portfolio' 3
Add-Chrome 'OperationsPayments' 'Operations & Payments' 'Outstanding balances and workflow status requiring attention' 4
foreach($page in @('SalesRevenue','MarketingPerformance','ClientBehavior','OperationsPayments')){Add-PageSlicers $page}

$exec=Join-Path $definition 'pages\ExecutiveOverview\visuals'
$cardPositions=@(@(208,176),@(472,176),@(736,176),@(1000,176))
for($i=1;$i -le 4;$i++){
    $p=Join-Path $exec ("a000000000000000000$i\visual.json")
    $j=Get-Content $p -Raw|ConvertFrom-Json; $xy=$cardPositions[$i-1]
    $j.position=[pscustomobject](New-Position $xy[0] $xy[1] (100+$i) 98 240 (100+$i)); Save-Json $j $p
}
$linePath=Join-Path $exec 'a0000000000000000005\visual.json'
$line=Get-Content $linePath -Raw|ConvertFrom-Json
$line.position=[pscustomobject](New-Position 208 298 110 382 500 110); Save-Json $line $linePath
$salesSource=Join-Path $definition 'pages\SalesRevenue\visuals\b0000000000000000001\visual.json'
$package=Get-Content $salesSource -Raw|ConvertFrom-Json
$package.name='a0000000000000000006';$package.position=[pscustomobject](New-Position 728 298 111 382 512 111)
Save-Json $package (Join-Path $exec 'a0000000000000000006\visual.json')
$slicers=@(
    (New-Slicer 'a0000000000000000011' 208 'Month' 'month'),
    (New-Slicer 'a0000000000000000012' 472 'Service' 'service_category'),
    (New-Slicer 'a0000000000000000013' 736 'Lead source' 'lead_source'),
    (New-Slicer 'a0000000000000000014' 1000 'Booking status' 'booking_status')
)
foreach($s in $slicers){Save-Json $s (Join-Path $exec "$($s.name)\visual.json")}

$pageCharts=@{
    SalesRevenue=@(
        @('b0000000000000000001','clusteredColumnChart',208,198,504,218,'package_name',@(@('measure','Total Revenue','Revenue'),@('measure','Gross Profit','Gross Profit')),'Revenue and Profit by Package'),
        @('90000000000000000101','lineChart',728,198,512,218,'month',@(@('measure','Total Revenue','Revenue')),'Monthly Revenue Trend'),
        @('90000000000000000102','clusteredBarChart',208,466,1032,214,'booking_status',@(@('measure','Total Revenue','Revenue')),'Revenue by Booking Status')
    )
    MarketingPerformance=@(
        @('c0000000000000000001','clusteredColumnChart',208,198,504,218,'lead_source',@(@('count','booking_id','Bookings')),'Bookings by Lead Source'),
        @('90000000000000000201','clusteredBarChart',728,198,512,218,'lead_source',@(@('measure','Total Revenue','Revenue')),'Revenue by Lead Source'),
        @('90000000000000000202','clusteredBarChart',208,466,1032,214,'lead_source',@(@('average','response_hours','Average Response Hours')),'Average Response Time by Lead Source')
    )
    ClientBehavior=@(
        @('d0000000000000000001','clusteredBarChart',208,198,504,218,'service_category',@(@('count','client_id','Clients')),'Client Demand by Service'),
        @('90000000000000000301','clusteredColumnChart',728,198,512,218,'service_category',@(@('measure','Total Revenue','Revenue'),@('measure','Gross Profit','Gross Profit')),'Revenue and Profit by Service'),
        @('90000000000000000302','clusteredBarChart',208,466,1032,214,'package_name',@(@('measure','Average Booking Value','Average Booking Value')),'Average Booking Value by Package')
    )
    OperationsPayments=@(
        @('e0000000000000000001','clusteredBarChart',208,198,504,218,'booking_status',@(@('measure','Outstanding Balance','Outstanding Balance')),'Outstanding Balance by Status'),
        @('90000000000000000401','clusteredColumnChart',728,198,512,218,'booking_status',@(@('count','booking_id','Bookings')),'Booking Volume by Status'),
        @('90000000000000000402','clusteredBarChart',208,466,1032,214,'lead_source',@(@('measure','Outstanding Balance','Outstanding Balance')),'Outstanding Balance by Lead Source')
    )
}
$titleIds=@('90000000000000000901','90000000000000000902','90000000000000000903')
foreach($page in $pageCharts.Keys){
    $v=Join-Path $definition "pages\$page\visuals";$index=0
    foreach($spec in $pageCharts[$page]){
        $chart=New-Chart $spec[0] $spec[1] $spec[2] $spec[3] $spec[4] $spec[5] $spec[6] $spec[7]
        Save-Json $chart (Join-Path $v "$($chart.name)\visual.json")
        $titleY=if($index -lt 2){170}else{438}
        Add-ChartTitle $page $titleIds[$index] $spec[2] $titleY $spec[4] $spec[8]
        $index++
    }
}
