module Transactions

import Effects
import Ethereum

%default total

playerCount : Field
playerCount = EInt "playerCount"

players : MapField
players = EMIntInt "players"

moves : MapField
moves = EMIntInt "moves"

winner : Int -> Int -> Int
winner 2 1 = 0
winner 1 2 = 1

winner 0 2 = 0
winner 2 0 = 1

winner 1 0 = 0
winner 0 1 = 1

winner _ _ = 2

namespace TestContract
  init : Eff () [STORE]
  init = write playerCount 2

  playerChoice : {s : Address} -> {v : Nat} -> {b : Nat} -> { auto p : LTE 10 v } -> 
                 Int ->
                 Eff Bool
                 [STORE, ETH_IN v b, ENV c s o]
                 (\succ => if succ
                              then [STORE, ETH_OUT v b (v-10) 10, ENV c s o]
                              else [STORE, ETH_OUT v b v 0      , ENV c s o])
  playerChoice {v} {s} c = do
    pc <- read playerCount
    if pc < 2
     then do
        write players pc s
        write moves pc c
        write playerCount (pc+1)
        save 10
        send (v-10) s
        pureM True
      else do
        send v s
        pureM False

  --0 : not enough players joined, or invalid value
  --1 : player 1
  --2 : player 2
  --3 : draw
  check : {b : Nat} -> {auto p: LTE 20 b} -> Eff Int
          [STORE, ETH_IN 0 b]
          (\winner => if winner == 0
                         then [STORE, ETH_OUT 0 b 0 0]
                         else [STORE, ETH_OUT 0 b 20 0])
  check = if !(read playerCount) == 2
             then do
               let w = winner !(read moves 0) !(read moves 1)
               case w of 
                  0 => do --player 1 wins
                    send 20 !(read players 0)
                    pureM 1
                  1 => do --player 2 wins
                    send 20 !(read players 1)
                    pureM 2
                  otherwise => do --draw
                    send 10 !(read players 0)
                    send 10 !(read players 1)
                    pureM 3
            else do
              pureM 0

