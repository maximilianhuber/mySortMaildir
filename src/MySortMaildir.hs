{-# LANGUAGE CPP #-}
{-# OPTIONS -fno-warn-unused-imports #-}
--------------------------------------------------------------------------------
-- |
-- Module      : MySortMaildir
-- Note        : A small programm to sort maildirs
--
--
--
--------------------------------------------------------------------------------
module MySortMaildir
  ( runMySortMaildir
  , module X
  ) where

import           MySortMaildir.Common
import           MySortMaildir.Common as X hiding (emptyMail)
import           MySortMaildir.GetMails
import           MySortMaildir.Actions
import           MySortMaildir.Helpers as X

--------------------------------------------------------------------------------
--  Main function to call

runMySortMaildir :: [Config] -> IO ()
runMySortMaildir cfgs = do
    line >> putStrLn "Start"
    mapM_ (\cfg -> do
      line >> putStrLn ("work on: " ++ inbox cfg ++ " ...")
      (curMails,newMails) <- getMails (inbox cfg)
      putStrLn $ "   " ++ show (length curMails) ++ " current mails found"
      putStrLn $ "   " ++ show (length newMails) ++ " new mails found"
      mapM_ (applyRules $ rules cfg) (curMails ++ newMails)
      ) cfgs
    line >> putStrLn "Done"
  where
    line = putStrLn $ replicate 60 '='
    --------------------------------------------------------------------------------
    -- Takes
    --      a list of rules and
    --      a mail
    -- and applies the first rule, whose condition is satisfied
    applyRules :: [Rule] -> Mail -> IO()
    applyRules [] _ = return ()
      -- putStrLn $ "no rule found (From: " ++ from m ++ ")"
    applyRules (r:rs) m = if rule r m
      then do
        putStr $ "apply rule " ++ show r ++ " ... "
        applyAction m (action r)
      else applyRules rs m
