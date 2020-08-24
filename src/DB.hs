{-# LANGUAGE DataKinds              #-}
{-# LANGUAGE DeriveGeneric          #-}
{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE TemplateHaskell        #-}
{-# LANGUAGE TypeOperators          #-}
{-# LANGUAGE MultiParamTypeClasses  #-}
{-# LANGUAGE OverloadedStrings      #-}

module DB where

import Database.HDBC.PostgreSQL (Connection, connectPostgreSQL)

connectDB :: IO Connection
connectDB = connectPostgreSQL $
    "host = localhost"
    ++ " port=5432"
    ++ " user=test"
    ++ " dbname=testdb"
    ++ " password=test"
    ++ " sslmode=disable"