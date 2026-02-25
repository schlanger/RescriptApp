
@module("./assets/image/steth.png")
external stethImg: string = "default"

/* =========================
   Fonction d'appel API Coinlore
   ========================= 
let fetchCrypto = async (~ids: array<string>) => {
  let url =
    "https://api.coinlore.net/api/ticker/?id=" ++ ids->Array.map(String.trim)->Array.joinWith(",")
  let res = await Fetch.fetch(url, {})
  let result = await Fetch.Response.json(res)
  result
} */

/* =========================
   Composant principal
   ========================= */
@react.component
let make = () => {
  // Appel au Hook personnalisé pour récupérer les données des cryptos
  let (cryptos, loading) = UseApiCrypto.useApiCrypto()  
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
