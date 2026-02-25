
@module("../assets/image/steth.png")
external stethImg: string = "default"

type crypto = {
  id: string,
  name: string,
  symbol: string,
  image: string,
  image2: string,
  price: float,
}

let useApiCrypto = () => {
  let (cryptos, setCryptos) = React.useState((): array<crypto> => [])
  let (loading, setLoading) = React.useState(() => true)

  React.useEffect(() => {
    let getData = async () => {
      try {
        /* L'appel API est directement dans le hook */
        let url = "https://api.coinlore.net/api/tickers/"
        let res = await Fetch.fetch(url, {})
        let json = await Fetch.Response.json(res)
        
        /* Le traitement des données aussi */
        let objOpt = json->Js.Json.decodeObject

        Js.log(objOpt)
        
        switch objOpt {
        | Some(obj) =>
          let dataArrayOpt = obj->Js.Dict.get("data")->Belt.Option.flatMap(Js.Json.decodeArray)
          
          switch dataArrayOpt {
          | Some(dataArray) =>
            let cryptoList: array<crypto> = 
              dataArray
              ->Array.slice(~start=0, ~end=12)
              ->Array.filterMap(item => {
                let objOpt = item->Js.Json.decodeObject
              switch objOpt {
              | Some(obj) =>
                let id = obj->Js.Dict.get("id")->Belt.Option.flatMap(Js.Json.decodeString)->Belt.Option.getWithDefault("")
                let name = obj->Js.Dict.get("name")->Belt.Option.flatMap(Js.Json.decodeString)->Belt.Option.getWithDefault("")
                let symbol = obj->Js.Dict.get("symbol")->Belt.Option.flatMap(Js.Json.decodeString)->Belt.Option.getWithDefault("")->String.toLowerCase
                let price = obj->Js.Dict.get("price_usd")->Belt.Option.flatMap(Js.Json.decodeString)->Belt.Option.flatMap(Float.fromString)->Belt.Option.getWithDefault(0.0)
                
                /* Logo dynamique depuis CDN - aucun fichier à télécharger */
                let image = "https://cdn.jsdelivr.net/npm/cryptocurrency-icons/32/color/" ++ symbol ++ ".png"

                let image2 = if symbol === "steth" {
                  stethImg
                } else {
                  image
                }
                
                Some({
                  id,
                  name,
                  symbol,
                  image,
                  image2,
                  price,
                })
              | None => None
              }
            })
            
            setCryptos(_ => cryptoList)
            setLoading(_ => false)
          | None => setLoading(_ => false)
          }
        | None => setLoading(_ => false)
        }
      } catch {
      | _ => setLoading(_ => false)
      }
    }
    
    let _ = getData()->ignore
    None
  }, [])

  (cryptos, loading)
}