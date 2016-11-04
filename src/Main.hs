{-# LANGUAGE OverloadedStrings #-}
module Main where

import qualified Control.Monad          as M
import qualified Network.Haskoin.Block  as HB
import qualified System.ZMQ4            as ZMQ
import qualified Data.Serialize         as Bin
import qualified Data.ByteString        as BS



sockAddr = "ipc:///home/runesvend/.bitcoin/zmq-blockhash.sock"

main :: IO ()
main = ZMQ.withContext $ \ctx ->
    ZMQ.withSocket ctx ZMQ.Sub $ \sock -> do
        ZMQ.setLinger (ZMQ.restrict (0 :: Int)) sock
        putStrLn $ "Connecting to " ++ show sockAddr
        ZMQ.connect sock sockAddr
        ZMQ.subscribe sock "rawblock"
        putStrLn "NOTIFY: Connected. Subscribed to new blocks."
        M.forever $ do
            bs <- ZMQ.receive sock
            print bs
            let block = decodeBlock bs
            putStrLn "Received block!"
            print (HB.blockHeader block)
  where
    decodeBlock :: BS.ByteString -> HB.Block
    decodeBlock bs = either (\e -> error $ "Failed to decode block: " ++ e)
            id (Bin.decode bs)

