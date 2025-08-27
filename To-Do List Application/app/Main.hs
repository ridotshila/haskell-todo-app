import System.IO
import Data.Maybe

-- Task type
data Task = Task Int String Bool deriving Show

-- Semigroup / Monoid
newtype TaskList = TL [Task] deriving Show
instance Semigroup TaskList where (TL a) <> (TL b) = TL (a ++ b)
instance Monoid TaskList where mempty = TL []

-- Pure helpers
addTask :: String -> [Task] -> [Task]
addTask t ts = ts ++ [Task (length ts+1) t False]

markDone :: Int -> [Task] -> [Task]
markDone i = map (\(Task n s c) -> if n==i then Task n s True else Task n s c)

-- Functor / Applicative / Monad (Maybe)
parseInt :: String -> Maybe Int
parseInt s = case reads s of [(n,"")] -> Just n; _ -> Nothing

-- side effects (IO)
loop :: [Task] -> IO ()
loop ts = do
  putStr "cmd> " >> hFlush stdout
  cmd <- words <$> getLine
  case cmd of
    ("add":rest) -> 
      let title = unwords rest
          ts' = addTask title ts
      in print ts' >> loop ts'
    ["done",n]  -> case parseInt n of
                     Just k -> let ts' = markDone k ts in print ts' >> loop ts'
                     Nothing -> putStrLn "Bad id" >> loop ts
    ["list"]    -> print ts >> loop ts
    ["quit"]    -> putStrLn "Bye!"
    _           -> putStrLn "?" >> loop ts

main :: IO ()
main = loop []
