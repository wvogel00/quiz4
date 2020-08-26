{-# LANGUAGE DataKinds              #-}
{-# LANGUAGE DeriveGeneric          #-}
{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE TemplateHaskell        #-}
{-# LANGUAGE TypeOperators          #-}
{-# LANGUAGE MultiParamTypeClasses  #-}
{-# LANGUAGE OverloadedStrings      #-}

module QuizDB where

import Data.Maybe (Maybe)
import Data.List (find)
import Database.HDBC (commit)
import Database.HDBC.Schema.PostgreSQL (driverPostgreSQL)
import Database.HDBC.Query.TH (defineTableFromDB)
import Database.HDBC.Record.Query (runQuery')
import Database.HDBC.Record.Insert (runInsert)
import Database.Relational.Type (relationalQuery)
import GHC.Generics (Generic)
import DB

$(defineTableFromDB
    connectDB
    driverPostgreSQL
    "public"
    "quiz4"
    [''Show, ''Eq, ''Generic]
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

findDuplicate :: Quiz4 -> IO (Maybe Quiz4)
findDuplicate q = do
    qs <- getAllQuiz
    return $ find (isSame statement) qs
    where
        isSame f x = f x == f q && f q /= Nothing