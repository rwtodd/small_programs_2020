# the script runs through every geomantic figure (65536 of them)
# and counts up the number of times the nephews, witnesses, and
# the judge take on each figure.  The judge table is printed at
# the end.

# this is pretty slow compared to the elisp version, but
# there could be some easy optimizations that I don't see
# at present.

$fig_names = @{
    15 = "Via";
    14 = "Cauda Draconis";
    13 = "Puer";
    12 = "Fortuna Minor";
    11 = "Puella";
    10 = "Amissio";
    9  = "Carcer";
    8  = "Laetitia";
    7  = "Caput Draconis";
    6  = "Conjunctio";
    5  = "Acquisitio";
    4  = "Rubeus";
    3  = "Fortuna Major";
    2  = "Albus";
    1  = "Tristitia";
    0  = "Populus"
}

class GeomanticTotals {
    static [int] AddFigures([int]$one, [int]$two) { return ($one -bxor $two) }
    static [int] LineOf([int]$fig, [int]$ln) { return (1 -band ($fig -shr (4 - $ln))) }

    static [int] NewFigure([int[]] $lns) {
        return (($lns[0] -shl 3) -bor ($lns[1] -shl 2) -bor
            ($lns[2] -shl 1) -bor $lns[3])
    }

    static [int[]] NewSisters([int[]]$moms) {
        $ans = [int[]]::new(4)
        $tmp = [int[]]::new(4)
        for($idx = 0; $idx -lt 4; $idx++) {
            $tmp[0] = [GeomanticTotals]::LineOf($moms[0], $idx+1)
            $tmp[1] = [GeomanticTotals]::LineOf($moms[1], $idx+1)
            $tmp[2] = [GeomanticTotals]::LineOf($moms[2], $idx+1)
            $tmp[3] = [GeomanticTotals]::LineOf($moms[3], $idx+1)
            $ans[$idx] = [GeomanticTotals]::NewFigure($tmp)
        }
        return $ans
    }

    static [void] NewShield([int[]]$moms) {
        $sis = [GeomanticTotals]::NewSisters($moms)
        $n1 = [GeomanticTotals]::AddFigures($moms[0], $moms[1])
        $n2 = [GeomanticTotals]::AddFigures($moms[2], $moms[3])
        $n3 = [GeomanticTotals]::AddFigures($sis[0], $sis[1])
        $n4 = [GeomanticTotals]::AddFigures($sis[2], $sis[3])
        $wr = [GeomanticTotals]::AddFigures($n3, $n4)
        $wl = [GeomanticTotals]::AddFigures($n1, $n2)
        $j = [GeomanticTotals]::AddFigures($wr,$wl)
        $script:judge[$script:fig_names[$j]]++
    }
}

$judge = @{ }
$mothers = [int[]]::new(4)
foreach ($m1 in 0..15) {
    $mothers[0] = $m1
    foreach ($m2 in 0..15) {
        Write-Host "on level $m1 $m2 xx xx"
        $mothers[1] = $m2
        foreach ($m3 in 0..15) {
            $mothers[2] = $m3
            foreach ($m4 in 0..15) {
                $mothers[3] = $m4
                [GeomanticTotals]::NewShield($mothers)
            }
        }
    }
}

$judge