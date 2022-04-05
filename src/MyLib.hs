module MyLib (someFunc) where
import Foreign
import Foreign.C

data Model

foreign import ccall unsafe "load_model" loadModel
  :: CString -> IO (Ptr Model)

foreign import ccall unsafe "run_pipeline_simple" runPipeline
  :: Ptr Model -> CString -> IO CString

foreign import ccall unsafe "free_cstring" freeCString
  :: CString -> IO ()

someFunc :: IO ()
someFunc = do
    -- TODO: Free data (e.g. using withCString)
    csModel <- newCString "english-lines-ud-2.5-191206.udpipe"
    mod <- loadModel csModel
    if mod == nullPtr
        then putStrLn "Failed to load model"
        else do
      input <- newCString "This is an example"
      csans <- runPipeline mod input
      ans <- peekCString csans
      putStrLn ans
      putStrLn "someFunc"

-- TODO: Handle errors in the C++ code (give back error message)
