module Syntax.Parser.Term
    ( Term(..), Type(..)
    , Level(..), getAttr
    , Explicit(..), PatternC
    , module Syntax.Scope, module Syntax.Pattern
    
    , Posn, PIdent(..)
    , Clause(..), Con(..)
    , Import, ConTele(..)
    , Def(..)
    ) where

import Syntax.Scope
import Syntax.Pattern

type Posn = (Int, Int)
data PIdent = PIdent { getPos :: Posn, getName :: String }
data Clause = Clause PIdent [PatternC Posn PIdent] (Term Posn PIdent)
type Import = [String]
data ConTele = VarsTele (Term Posn PIdent) (Term Posn PIdent) | TypeTele (Term Posn PIdent)
data Con = ConDef PIdent [ConTele]

data Def
    = DefType PIdent (Term Posn PIdent)
    | DefFun PIdent [PatternC Posn PIdent] (Maybe (Term Posn PIdent))
    | DefData PIdent [(Term Posn PIdent, Term Posn PIdent)] [Con] [Clause]
    | DefImport Import

data Term p a
    = Var a
    | App (Term p a) (Term p a)
    | Lam p (Scope1 String (Term p) a)
    | Pi p (Type p a) (Scope String (Term p) a) Level
    | Con p Int String [([PatternC p String], Closed (Scope String (Term p)))] [Term p a]
    | FunCall p String [([PatternC p String], Closed (Scope String (Term p)))]
    | FunSyn p String (Term p a)
    | Universe p Level
    | DataType p String Int [Term p a]
    | Interval p
    | ICon p ICon
    | Path p Explicit (Maybe (Term p a)) [Term p a]
    | PCon p (Maybe (Term p a))
    | At (Maybe (Term p a, Term p a)) (Term p a) (Term p a)
    | Coe p [Term p a]
    | Iso p [Term p a]
    | Squeeze p [Term p a]

data Level = Level Int | NoLevel
data Type p a = Type (Term p a) Level
data Explicit = Explicit | Implicit
type PatternC p = Pattern p (Closed (Scope String (Term p)))

getAttr :: (a -> p) -> Term p a -> p
getAttr f (Var a) = f a
getAttr f (App t _) = getAttr f t
getAttr _ (Lam p _) = p
getAttr _ (Pi p _ _ _) = p
getAttr _ (Con p _ _ _ _) = p
getAttr _ (FunCall p _ _) = p
getAttr _ (FunSyn p _ _) = p
getAttr _ (Universe p _) = p
getAttr _ (DataType p _ _ _) = p
getAttr _ (Interval p) = p
getAttr _ (ICon p _) = p
getAttr _ (Path p _ _ _) = p
getAttr _ (PCon p _) = p
getAttr f (At _ t _) = getAttr f t
getAttr _ (Coe p _) = p
getAttr _ (Iso p _) = p
getAttr _ (Squeeze p _) = p
