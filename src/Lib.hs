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
import qualified Data.Text.IO as TIO
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

data Quiz = Quiz
    { statement     :: T.Text
    , a,b,c,d       :: T.Text
    , answer        :: T.Text
    , explanation   :: T.Text
    } deriving (Eq, Show)

database = "db/quizfile"

$(deriveJSON defaultOptions ''Quiz)

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
    :<|> "quiz4" :> "get" :> Get '[JSON] Quiz
    :<|> "quiz4" :> "make" :> ReqBody '[JSON] Quiz :> Post '[PlainText] T.Text

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

postMake :: Quiz -> Handler T.Text
postMake q = do
    liftIO $ TIO.putStrLn $ T.append "post 'make' request = " (statement q)
    result <- liftIO $ registerDB q
    case result of
        Done -> return "success"
        AlreadyExist -> return "すでに同じ問題が存在します"
        ValueLack v -> return $ T.append v "は必須項目です"
        Fail -> return "fail. please report to developer."

registerDB :: Quiz -> IO RegisterResult
registerDB q = do
    qs <- T.lines <$> TIO.readFile database
    if any (T.isInfixOf $ statement q) qs
        then return AlreadyExist
        else case lackAnyValue q of
            Nothing -> do
                TIO.appendFile database $ decodeQ q
                return Done
            Just x  -> return $ ValueLack x

lackAnyValue :: Quiz -> Maybe T.Text
lackAnyValue q
    | T.null (statement q) = Just "問題文"
    | T.null (a q) = Just "選択肢A"
    | T.null (b q) = Just "選択肢B"
    | T.null (c q) = Just "選択肢C"
    | T.null (d q) = Just "選択肢D"
    | T.null (answer q) = Just "解答"
    | otherwise = Nothing

getQuiz :: Handler Quiz
getQuiz = do
    liftIO $ TIO.putStrLn "get 'get' request . 新しいクイズを送信します"
    qs <- liftIO $ T.lines <$> TIO.readFile database
    now <- liftIO $ floor . utctDayTime <$> getCurrentTime :: Handler Int
    liftIO $ putStrLn $ "time == " ++ show now
    let i = mod now $ length qs
    return $ encodeQ $ qs !! i

encodeQ :: T.Text -> Quiz
encodeQ = genQuiz . T.words
    where
        genQuiz [state,a,b,c,d,ans] = genQuiz [state,a,b,c,d,ans,""]
        genQuiz [state,a,b,c,d,ans,ex] = Quiz
            { statement = state
            , a = a
            , b = b
            , c = c
            , d = d
            , answer = ans
            , explanation = ex
            }

decodeQ :: Quiz -> T.Text
decodeQ q = flip T.append "\n" . T.concat
    $ map format [statement, a, b, c, d , answer, explanation]
    where
        format f = flip T.append " " . T.filter (/='\n') $ f q