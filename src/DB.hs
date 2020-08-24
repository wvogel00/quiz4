{-# LANGUAGE DataKinds              #-}
{-# LANGUAGE DeriveGeneric          #-}
{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE TemplateHaskell        #-}
{-# LANGUAGE TypeOperators          #-}
{-# LANGUAGE MultiParamTypeClasses  #-}
{-# LANGUAGE OverloadedStrings      #-}

module DB where

import qualified Data.Text as T
import Database.HDBC.PostgreSQL (Connection, connectPostgreSQL)
import Database.HDBC.Schema.PostgreSQL (driverPostgreSQL)
import Database.HDBC.Query.TH (defineTableFromDB)
import GHC.Generics (Generic)

connectDB :: IO Connection
connectDB = connectPostgreSQL $
    "host = localhost"
    ++ "port=5432"
    ++ "user=test"
    ++ "dbname=testdb"
    ++ "password=test"
    ++ "sslmode=disable"

($defineTableFromDB
    connectDB
    driverPostgreSQL
    "public"
    "quiz"
    [''Show, ''Generic]
    )

showAllQuiz :: IO ()
showAllQuiz = do
    conn <- connectDB
    qs <- runQuery' conn (relationalQuery quiz) ()
    mapM_ print qs

insertQuiz q = do
    conn <- connectDB
    runInsert conn (insert insertQuiz) q
    commit conn