
@module("./assets/image/steth.png")
external stethImg: string = "default"


/* =========================
   Type représentant une crypto
   ========================= */
type crypto = {
  id: string,      /* identifiant (bitcoin, ethereum, etc.) */
  name: string,    /* nom lisible */
  symbol: string,  /* symbole (BTC, ETH…) */
  image: string,   /* URL de l'icône */
  image2: string,  /* URL de l'icône (fallback pour steth) */
  price: float,    /* prix en USD */
}

/* =========================
   Fonction d'appel API Coinlore
   ========================= */
let fetchCrypto = async (~ids: array<string>) => {
  let url =
    "https://api.coinlore.net/api/ticker/?id=" ++ ids->Array.map(String.trim)->Array.joinWith(",")
  let res = await Fetch.fetch(url, {})
  let result = await Fetch.Response.json(res)
  result
}

let fetchallCrypto = async () => {
  let url = "https://api.coinlore.net/api/tickers/"
  let res = await Fetch.fetch(url, {})
  let result = await Fetch.Response.json(res)
  result
}

fetchallCrypto()->ignore

/* =========================
   Composant principal
   ========================= */
@react.component
let make = () => {
  /* State contenant la liste des cryptos */
  let (cryptos, setCryptos) = React.useState((): array<crypto> => [])

  /* State de chargement */
  let (loading, setLoading) = React.useState(() => true)

  /* =========================
     useEffect : appelé une seule fois au montage
     ========================= */
  React.useEffect(() => {
    let getData = async () => {
      try {
        let json = await fetchallCrypto()/* Récupère tous les cryptos */
        let objOpt = json->Js.Json.decodeObject
        
        switch objOpt {
        | Some(obj) =>
          let dataArrayOpt = obj->Js.Dict.get("data")->Belt.Option.flatMap(Js.Json.decodeArray)
          
          switch dataArrayOpt {
          | Some(dataArray) =>
            let cryptoList: array<crypto> = 
              dataArray
              ->Array.slice(~start=0, ~end=12) /* Prendre les 10 premières cryptos */
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
     
        | None =>
          Js.log("Erreur: pas un array dans 'data'")
          setLoading(_ => false)
        }
        
        | None =>
          Js.log("Erreur: pas un objet JSON")
          setLoading(_ => false)
        }
      } catch {
      | _ => 
        Js.log("Erreur try/catch")
        setLoading(_ => false)
      }
    }
    
    let _ = getData()->ignore
    None
  }, [])

  /* =========================
     Rendu JSX
     ========================= */
  <div className="p-6 bg-slate-900 min-h-screen rounded-lg mt-20">
    <h1 className="text-4xl font-bold text-white mb-8">
      {React.string("💰 Crypto Dashboard")}
    </h1>

    {loading
      ? <p className="text-white text-xl">
          {React.string("Chargement des données...")}
        </p>

      : <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {cryptos
          ->Array.map(c =>
            <div
              key={c.id}
              className="bg-slate-800 rounded-lg p-6 shadow"
            >
              <div className="flex items-center gap-4 mb-4">
                <img
                  src={c.image2}
                  alt={c.name}
                  className="w-12 h-12"
                />
                <div>
                  <h3 className="text-white text-xl font-bold">
                    {React.string(c.name)}
                  </h3>
                  <p className="text-slate-400">
                    {React.string(c.symbol)}
                  </p>
                </div>
              </div>

              <p className="text-slate-400 text-sm">{React.string("Prix actuel")}</p>
              <p className="text-3xl font-bold text-cyan-400">
                {React.string("$" ++ Float.toString(c.price))}
              </p>
            </div>
          )
          ->React.array}
        </div>
    }
  </div>
}
