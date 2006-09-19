module GF.FCFG.AbsFCFG where

-- Haskell module generated by the BNF converter

newtype Ident = Ident String deriving (Eq,Ord,Show)
data FGrammar =
   FGr [FRule]
  deriving (Eq,Ord,Show)

data FRule =
   FR Abstract [[FSymbol]]
  deriving (Eq,Ord,Show)

data Abstract =
   Abs FCat [FCat] Name
  deriving (Eq,Ord,Show)

data FSymbol =
   FSymCat FCat Integer Integer
 | FSymTok String
  deriving (Eq,Ord,Show)

data FCat =
   FC Integer Ident [[PathEl]] [PathTerm]
  deriving (Eq,Ord,Show)

data PathEl =
   PLabel Label
 | PTerm Term
  deriving (Eq,Ord,Show)

data PathTerm =
   PtT [PathEl] Term
  deriving (Eq,Ord,Show)

data Name =
   Nm Ident [Profile]
  deriving (Eq,Ord,Show)

data Profile =
   Unify [Integer]
 | Const Forest
  deriving (Eq,Ord,Show)

data Forest =
   FMeta
 | FNode Ident [[Forest]]
 | FString String
 | FInt Integer
 | FFloat Double
  deriving (Eq,Ord,Show)

data Term =
   Arg Integer Ident [PathEl]
 | Constr CIdent [Term]
 | Rec [Assoc]
 | Proj Term Label
 | Tbl [Case]
 | Select Term Term
 | Vars [Term]
 | Concat Term Term
 | Tok String
 | Empty
  deriving (Eq,Ord,Show)

data Case =
   Cas Term Term
  deriving (Eq,Ord,Show)

data Assoc =
   Ass Label Term
  deriving (Eq,Ord,Show)

data Label =
   L Ident
 | LV Integer
  deriving (Eq,Ord,Show)

data CIdent =
   CIQ Ident Ident
  deriving (Eq,Ord,Show)

