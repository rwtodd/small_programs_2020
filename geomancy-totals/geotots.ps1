# the script runs through every geomantic figure (65536 of them)
# and counts up the number of times the nephews, witnesses, and
# the judge take on each figure.  The judge table is printed at
# the end.

# this is pretty slow compared to the elisp version, but
# there could be some easy optimizations that I don't see
# at present.

$fig_names = @{
    15="Via";
    14="Cauda Draconis";
    13="Puer";
    12="Fortuna Minor";
    11="Puella";
    10="Amissio";
    9 ="Carcer";
    8 ="Laetitia";
    7 ="Caput Draconis";
    6 ="Conjunctio";
    5 ="Acquisitio";
    4 ="Rubeus";
    3 ="Fortuna Major";
    2 ="Albus";
    1 ="Tristitia";
    0 ="Populus"
}

function add-figures([int]$one,[int]$two) { $one -bxor $two }
function get-lineof([int]$fig,[int]$ln) { 1 -band ($fig -shr (4-$ln)) }

function new-figure([int[]] $lns) {
    (($lns[0] -shl 3) -bor ($lns[1] -shl 2) -bor
        ($lns[2] -shl 1) -bor $lns[3])
}

function new-sisters([int[]]$moms) {
    (new-figure ($moms | %{ get-lineof $_ 1 })),
    (new-figure ($moms | %{ get-lineof $_ 2 })),
    (new-figure ($moms | %{ get-lineof $_ 3 })),
    (new-figure ($moms | %{ get-lineof $_ 4 }))
}

function new-shield([int[]]$moms) {
    $sis = new-sisters $moms
    $nephs = (add-figures $moms[0] $moms[1]), 
             (add-figures $moms[2] $moms[3]),
             (add-figures $sis[0] $sis[1]),
             (add-figures $sis[2] $sis[3])
    $wits = (add-figures $nephs[2] $nephs[3]),
            (add-figures $nephs[0] $nephs[1])
    $j = add-figures $wits[0] $wits[1]
    $script:judge[$fig_names[$j]]++
}

$judge = @{ }
foreach($m1 in 0..15) {
    foreach($m2 in 0..15) {
        Write-Host "on level $m1 $m2 xx xx"
        foreach($m3 in 0..15) {
            foreach($m4 in 0..15) {
                new-shield $m1,$m2,$m3,$m4
            }
        }
    }
}

$judge