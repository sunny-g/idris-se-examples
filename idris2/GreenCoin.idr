module Main

import Effects
import Effect.State
import Effect.StdIO
import Map
import Serialize
import Data.Vect
import Data.HVect

data Field = EInt | EString 
data EVar = ES String | EI Int

instance Show EVar where
  show (ES x) = x
  show (EI x) = show x

interpField : Field -> Type
interpField EInt = Int
interpField EString = String

--Schema definition
Store : Nat -> Type
Store k = Vect k Field

-- Interpretation function: takes Store and creates type
interp : Store k -> Type
interp store = HVect (map interpField store)

-- The schema definition and field names (names probably not needed)
test : Store 2
test = [EString, EInt]

-- Example instantiated store
intest : HVect [String, Int]
intest = ["hejje", 123]

--Should give a vector of functions to access fields from a given state
-- Given a Store, return a vector with functions to access each field in an instance of the store
-- funcs : Store k -> Vect k ((HVect {k = k} a) -> EVar)
-- funcs : (s: Vect n Field) -> Vect n ((interp s) -> )

funcs1 : (fs : Vect 1 Field) -> HVect [HVect [interpField (head fs)] -> interpField (head fs)]
funcs1 [EInt]    = [\[x] => x]
funcs1 [EString] = [\[x] => x]

funcs2 : (fs : Vect 2 Field) -> HVect [
  (HVect [interpField (head fs), interpField (head (tail fs))] -> (interpField (head fs))),
  (HVect [interpField (head fs), interpField (head (tail fs))] -> (interpField (head (tail fs))))]
funcs2 [t1,t2] = [
  case t1 of
       EInt =>    (\[x,y] => x)
       EString => (\[x,y] => x)
  , case t2 of
       EInt    => (\[x,y] => y)
       EString => (\[x,y] => y)
  ]
        
head : HVect (t::ts) -> t
head (x::xs) = x

tail : HVect (t::ts) -> HVect ts
tail (x::xs) = xs

main : IO ()
main = putStrLn (show ((head (tail (funcs2 test))) intest))
-- main = putStrLn "lol"


