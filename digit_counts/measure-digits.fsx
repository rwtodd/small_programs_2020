let histo n =
 n |> string |> Seq.groupBy id |> Seq.map (fun (ch,chs) -> (ch, Seq.length chs))
 ;;

(1127I ** 3921) |> histo |> Seq.iter (printfn "%A")
