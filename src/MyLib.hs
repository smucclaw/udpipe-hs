module MyLib (someFunc) where
import Foreign
import Foreign.C

data Model

foreign import ccall unsafe "load_model" loadModel
  :: CString -> IO (Ptr Model)

someFunc :: IO ()
someFunc = do
    csModel <- newCString "model.fake"
    loadModel csModel
    putStrLn "someFunc"
