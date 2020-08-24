{-# LANGUAGE DataKinds              #-}
{-# LANGUAGE DeriveGeneric          #-}
{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE TemplateHaskell        #-}
{-# LANGUAGE TypeOperators          #-}
{-# LANGUAGE MultiParamTypeClasses  #-}
{-# LANGUAGE OverloadedStrings      #-}

module QuizDB where

-- import qualified Data.Text as T
-- import Data.ByteString (ByteString)
import Database.HDBC (commit)
import Database.HDBC.PostgreSQL (Connection, connectPostgreSQL)
import Database.HDBC.Schema.PostgreSQL (driverPostgreSQL)
import Database.HDBC.Query.TH (defineTableFromDB)
import Database.HDBC.Record.Query      (runQuery')
import Database.HDBC.Record.Insert      (runInsert)
import Database.Relational.Type        (insert, relationalQuery)
import GHC.Generics (Generic)
import DB

$(defineTableFromDB
    connectDB
    driverPostgreSQL
    "public"
    "quiz4"
    [''Show]
    )

getAllQuiz :: IO [Quiz4]
getAllQuiz = do
    conn <- connectDB
    qs <- runQuery' conn (relationalQuery quiz4) ()
    return qs

insertQuiz q = do
    conn <- connectDB
    runInsert conn insertQuiz4 q
    commit conn
