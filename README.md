# udpipe-hs
Basic haskell bindings for [udpipe](https://github.com/ufal/udpipe)

## Example

```haskell
runExample = do
    let modelName = "models/english-lines-ud-2.5-191206.udpipe"
    mod <- loadModel modelName
    case mod of
      Left msg -> putStrLn msg
      Right mod -> do
        let input = "This is an example"
        ans <- runPipeline mod input
        putStrLn ans
```

output

```
# newdoc
# newpar
# sent_id = 1
# text = This is an example
1       This    this    PRON    DEM-SG  Number=Sing|PronType=Dem        4       nsubj   _       _
2       is      be      AUX     PRES    Mood=Ind|Number=Sing|Person=3|Tense=Pres|VerbForm=Fin   4       cop     _       _
3       an      an      DET     IND-SG  Definite=Ind|PronType=Art       4       det     _       _
4       example example NOUN    SG-NOM  Number=Sing     0       root    _       SpacesAfter=\n
```
