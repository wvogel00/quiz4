{-# LANGUAGE DataKinds              #-}
{-# LANGUAGE DeriveGeneric          #-}
{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE TemplateHaskell        #-}
{-# LANGUAGE TypeOperators          #-}
{-# LANGUAGE MultiParamTypeClasses  #-}
{-# LANGUAGE OverloadedStrings      #-}

module Lib where

import Data.Aeson
import Data.Aeson.TH
import qualified Data.Text as T
import Network.HTTP.Media ( (//), (/:) )
import qualified Data.ByteString.Lazy as BS
import Network.Wai
import Network.Wai.Handler.Warp
import Network.HTTP.Types.Status (status200)
import Servant
import Network.Wai.Middleware.Cors (cors, simpleCorsResourcePolicy, corsRequestHeaders)
import Control.Monad.IO.Class (liftIO)
import System.Random
import Data.Time.Clock
import qualified QuizDB as DB
import Data.Maybe (Maybe(..), fromJust)
import Data.List (isInfixOf, permutations, lookup)
import Data.Functor

database = "db/quizfile"

$(deriveJSON defaultOptions ''DB.Quiz4)

data FileType = HTMLFile | CSSFile | JSFile | IMGFile deriving Eq

data HTML
instance Accept HTML where
    contentType _ = "text" // "html" /: ("charset", "utf-8")

instance MimeRender HTML BS.ByteString where
    mimeRender _ bs = bs

type API = "quiz4" :> Get '[HTML] BS.ByteString
    :<|> "quiz4" :> "html" :> Raw
    :<|> "quiz4" :> "css" :> Raw
    :<|> "quiz4" :> "js" :> Raw
    :<|> "quiz4" :> "img" :> Raw
    :<|> "quiz4" :> "get" :> Get '[JSON] DB.Quiz4
    :<|> "quiz4" :> "make" :> ReqBody '[JSON] DB.Quiz4 :> Post '[PlainText] T.Text

quizServer :: BS.ByteString -> Server API
quizServer top = getHtml top
        :<|> getStatics HTMLFile
        :<|> getStatics CSSFile
        :<|> getStatics JSFile
        :<|> getStatics IMGFile
        :<|> getQuiz
        :<|> postMake

api :: Proxy API
api = Proxy

startApp :: IO ()
startApp = do
    top <- BS.readFile "html/index.html"
    run 8080
        $ cors (const $ Just policy)
        $ serve api
        $ quizServer top

policy = simpleCorsResourcePolicy
        {corsRequestHeaders = ["Content-Type"]}

getHtml html = liftIO $ return html

getStatics HTMLFile = serveDirectoryWebApp "html"
getStatics CSSFile = serveDirectoryWebApp "css"
getStatics JSFile = serveDirectoryWebApp "js"
getStatics IMGFile = serveDirectoryWebApp "img"

data RegisterResult = Done | AlreadyExist | ValueLack T.Text | Fail deriving Eq

postMake :: DB.Quiz4 -> Handler T.Text
postMake q = do
    result <- liftIO $ registerDB q
    case result of
        Done -> return "success"
        AlreadyExist -> return "すでに同じ問題が存在します"
        ValueLack v -> return $ T.append v "は必須項目です"
        Fail -> return "fail. please report to developer."

registerDB :: DB.Quiz4 -> IO RegisterResult
registerDB q = do
    qs <- DB.getAllQuiz
    double <- DB.findDuplicate q
    if double /= Nothing
        then return AlreadyExist
        else case lackAnyValue q of
            Nothing -> DB.insertQuiz q $> Done
            Just x  -> return $ ValueLack x

lackAnyValue :: DB.Quiz4 -> Maybe T.Text
lackAnyValue q
    | DB.statement q == Nothing = Just "問題文"
    | DB.a q         == Nothing = Just "選択肢A"
    | DB.b q         == Nothing = Just "選択肢B"
    | DB.c q         == Nothing = Just "選択肢C"
    | DB.d q         == Nothing = Just "選択肢D"
    | DB.answer q    == Nothing = Just "解答"
    | otherwise                 = Nothing

data Choise = A | B | C | D deriving (Eq, Show, Enum)

getQuiz :: Handler DB.Quiz4
getQuiz = do
    qs <- liftIO $ DB.getAllQuiz
    now <- liftIO $ floor . utctDayTime <$> getCurrentTime :: Handler Int
    let i = mod now $ length qs
    return $ rearrange now $ qs !! i
    where
        -- 問題の並び替え
        rearrange r q = let [l,m,n,o] = (!!) (permutations [A .. D]) . mod r $ product [1..4]
            in q {DB.a = pick l q, DB.b = pick m q, DB.c = pick n q, DB.d = pick o q}
        pick choice = fromJust . lookup choice $ zip [A ..] [DB.a, DB.b, DB.c, DB.d]

-- txtファイルに保存していたクイズをDBに移行する際に使用する
registerFromTxt :: FilePath -> IO ()
registerFromTxt filepath = do
    xs <- map toQuiz4 . zip [1..] . lines <$> readFile filepath
    mapM_ DB.insertQuiz xs
    qs <- DB.getAllQuiz
    putStrLn "以下が登録されています"
    mapM_ (putStrLn . fromJust . DB.statement) qs
    where
        toQuiz4 (i, str) = DB.Quiz4
            { DB.id = Just i
            , DB.statement = Just s
            , DB.a = Just a'
            , DB.b = Just b'
            , DB.c = Just c'
            , DB.d = Just d'
            , DB.answer = Just ans
            , DB.explanation = Just ex
            } where
                [s,a',b',c',d',ans,ex] = words str