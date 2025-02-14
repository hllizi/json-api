{- |
Module representing a JSON-API meta object.

Specification: <http://jsonapi.org/format/#document-meta>
-}
module Network.JSONApi.Meta
( Meta
, MetaObject (..)
, mkMeta
)where

import Data.Aeson (ToJSON, FromJSON, Object, toJSON)
import Data.Aeson.KeyMap as KM
import Data.Aeson.Key
import Data.Text (Text)
import qualified GHC.Generics as G
import Control.DeepSeq (NFData)

{- |
Type representing a JSON-API meta object.

Meta is an abstraction around an underlying Map consisting of
resource-specific metadata.

Example JSON:
@
  "meta": {
    "copyright": "Copyright 2015 Example Corp.",
    "authors": [
      "Andre Dawson",
      "Kirby Puckett",
      "Don Mattingly",
      "Ozzie Guillen"
    ]
  }
@

Specification: <http://jsonapi.org/format/#document-meta>
-}
data Meta = Meta Object
  deriving (Show, Eq, G.Generic)

instance NFData Meta
instance ToJSON Meta
instance FromJSON Meta

instance Semigroup Meta where
  (<>) (Meta a) (Meta b) = Meta $ KM.union a b

instance Monoid Meta where
  mempty = Meta $ KM.empty

{- |
Convienience class for constructing a Meta type

Example usage:
@
  data Pagination = Pagination
    { currentPage :: Int
    , totalPages :: Int
    } deriving (Show, Generic)

  instance ToJSON Pagination
  instance MetaObject Pagination where
    typeName _ = "pagination"
@
-}
class (ToJSON a) => MetaObject a where
  typeName :: a -> Data.Aeson.Key.Key 

{- |
Convienience constructor function for the Meta type

Useful on its own or in combination with Meta's monoid instance

Example usage:
See MetaSpec.hs for an example
-}
mkMeta :: (MetaObject a) => a -> Meta
mkMeta obj = Meta $ KM.singleton (typeName obj) (toJSON obj)
