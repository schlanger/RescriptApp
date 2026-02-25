/* Type représentant une crypto */
type crypto = {
  id: string,
  name: string,
  symbol: string,
  image: string,
  image2: string,
  price: float,
}

/* Hook personnalisé */
let useApiCrypto: unit => (array<crypto>, bool)
