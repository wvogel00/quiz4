{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators   #-}
{-# LANGUAGE OverloadedStrings #-}
module Lib
    ( startApp
    , app
    ) where

import Data.Aeson
import Data.Aeson.TH
import Data.Text
import Network.Wai
import Network.Wai.Handler.Warp
import Network.HTTP.Types.Status (status200)
import Servant
import Control.Monad.IO.Class (liftIO)
import Debug.Trace (trace)

data User = User
    { userId    :: Int
    , userName  :: String
    , userScore :: Int
    } deriving (Eq, Show)

data Choice = A | B | C | D deriving (Eq, Show)
type Explanation = String

data Quiz = Quiz
    { sentence  :: String
    , choices   :: [(Choice, String)]
    , answer    :: (Choice, Explanation)
    } deriving (Eq, Show)

data QuizTable = QuizTable
    { quizId :: String
    , quizes :: [Quiz]
    }

$(deriveJSON defaultOptions ''User)

type API = "question" :> Get '[JSON] String
    :<|> "make" :> ReqBody '[JSON] String :> Post '[JSON] [String]
    :<|> "answer" :> ReqBody '[PlainText] String :> Post '[JSON] String


startApp :: IO ()
startApp = run 8080 app

app :: Application
-- app = serve api userServer
app req respond = do
    case pathInfo req of
        [] -> respond $ serveFile "text/html" "html/index.html"
        ["js", js] -> respond.serveFile "text/javascript" $ "js/" ++ unpack js
        ["css", css] -> respond.serveFile "text/css" $ "css/" ++ unpack css
        ["img", img] -> respond.serveFile "image/png" $ "img/" ++ unpack img
        x -> print x >> return undefined

serveFile mime filePath = responseFile status200 [("Content-Type",mime)] filePath Nothing

quizServer :: Server API
quizServer = getQuiz
        :<|> postNewQuiz
        :<|> postAnswer

postAnswer :: String -> Handler String
postAnswer msg = return $ trace msg "received"

postNewQuiz :: String -> Handler [String]
postNewQuiz str = return []

getQuiz :: Handler String
getQuiz = return []

-- 作問
posingQServer :: Quiz
posingQServer = Quiz {sentence="?", answer=(A,"the sun"), choices = []}