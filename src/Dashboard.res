/* =========================
   Type représentant une crypto
   ========================= */
type crypto = {
  id: string,      /* identifiant (bitcoin, ethereum, etc.) */
  name: string,    /* nom lisible */
  symbol: string,  /* symbole (BTC, ETH…) */
  image: string,   /* URL de l'icône */
  price: float,    /* prix en USD */
}

/* =========================
   Fonction d'appel API CoinGecko avec async/await
   ========================= */
let fetchCrypto = async (~id: float) => {
  let url =
    "https://api.coinlore.net/api/ticker/?id=" ++ id->Float.toString

  let res = await Fetch.fetch(url,{})
  let result = await Fetch.Response.json(res)
  Js.Json.stringifyAny(result)->Js.log
  result
}

open React

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
        let json = await fetchCrypto(~id=90.0)
        
        /* On s'assure que le JSON est bien un objet */
        let data =
          json
          ->Js.Json.decodeObject
          ->Belt.Option.getExn

        /* Fonction utilitaire pour extraire le prix */
        let getPrice = coin =>
          data
          ->Js.Dict.get(coin)
          ->Belt.Option.flatMap(Js.Json.decodeObject)
          ->Belt.Option.flatMap(obj => obj->Js.Dict.get("usd"))
          ->Belt.Option.flatMap(Js.Json.decodeNumber)
          ->Belt.Option.getWithDefault(0.0)

        /* Création de la liste typée de cryptos */
        let cryptoList: array<crypto> = [
          {
            id: "bitcoin",
            name: "Bitcoin",
            symbol: "BTC",
            image:
              "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
            price: getPrice("bitcoin"),
          },
          {
            id: "ethereum",
            name: "Ethereum",
            symbol: "ETH",
            image:
              "https://assets.coingecko.com/coins/images/279/large/ethereum.png",
            price: getPrice("ethereum"),
          },
          {
            id: "cardano",
            name: "Cardano",
            symbol: "ADA",
            image:
              "https://assets.coingecko.com/coins/images/975/large/cardano.png",
            price: getPrice("cardano"),
          },
        ]

        /* Mise à jour du state */
        setCryptos(_ => cryptoList)
        setLoading(_ => false)
      } catch {
      | _ => setLoading(_ => false)
      }
    }
    let _ = getData()
    None
  }, [])

  /* =========================
     Rendu JSX
     ========================= */
  <div className="p-6 bg-slate-900 min-h-screen">
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
                  src={c.image}
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
