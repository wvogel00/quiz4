{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators   #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
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
import Network.Wai.Middleware.Cors (simpleCors, cors, simpleCorsResourcePolicy, corsRequestHeaders)
import Control.Monad.IO.Class (liftIO)
import Debug.Trace (trace)

type Explanation = String

data Quiz = Quiz
    { statement     :: T.Text
    , a,b,c,d       :: T.Text
    , answer        :: T.Text
    , explanation   :: T.Text
    } deriving (Eq, Show)

$(deriveJSON defaultOptions ''Quiz)

data HTML

data FileType = HTMLFile | CSSFile | JSFile | IMGFile deriving Eq

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
    :<|> "quiz4" :> "make" :> ReqBody '[JSON] Quiz :> Post '[PlainText] String
    -- answerは本質的に不要API．get APIの他に，getWithoutAnswer APIが実装されれば必要となる
    :<|> "quiz4" :> "answer" :> ReqBody '[JSON] String :> Post '[PlainText] String

quizServer :: BS.ByteString -> Server API
quizServer top = getHtml top
        :<|> getStatics HTMLFile
        :<|> getStatics CSSFile
        :<|> getStatics JSFile
        :<|> getStatics IMGFile
        :<|> getQuiz
        :<|> postMake
        :<|> postAnswer

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

postAnswer :: String -> Handler String
postAnswer msg = do
    liftIO $ putStrLn ("receiveddata = " ++ msg)
    -- 正解判定
    return $ if msg == "A" then "O" else "X"

postMake :: Quiz -> Handler String
postMake q = do
    liftIO $ TIO.putStrLn $ T.append "post 'make' request = " (statement q)
    liftIO $ registerDB q
    return "success"

registerDB :: Quiz -> IO ()
registerDB quiz = return ()

getQuiz :: Handler Quiz
getQuiz = do
    liftIO $ TIO.putStrLn "get 'get' request . 新しいクイズを送信します"
    return $ Quiz
        { statement  = "curry"
        , a = "a"
        , b = "b"
        , c = "c"
        , d = "d"
        , answer = "haskell"
        , explanation = "functional programming language"
        }