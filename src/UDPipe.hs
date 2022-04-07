{- |
A very simple binding for udpipe.

Example usage:

> import UDPipe
>
> main = do
>   let sentence = "The quick brown fox jumps over the lazy dog."
>   let modelFile = "models/english-lines-ud-2.5-191206.udpipe"
>   model' <- loadModel modelFile
>   let model = case model' of
>                 Left err -> error err
>                 Right m -> m
>   result <- runPipe model sentence
>   putStrLn result


-}
module UDPipe (runExample, runPipeline, loadModel, ModelPtr) where
import Foreign
import Foreign.C
import Control.Exception (bracket)

-- | A loaded udpipe model.
type ModelPtr = Ptr Model

data Model

foreign import ccall unsafe "load_model" cLoadModel
  :: CString -> IO ModelPtr

foreign import ccall unsafe "run_pipeline_simple" cRunPipeline
  :: ModelPtr -> CString -> IO CString

foreign import ccall unsafe "free_cstr" freeCString
  :: CString -> IO ()

-- | Run the default ud pipeline on an input string.
runPipeline :: ModelPtr -> String -> IO String
runPipeline model input = do
  withCString input $ \cInput -> do
    bracket (cRunPipeline model cInput) freeCString peekCString

-- | Load a model from a file.
loadModel :: FilePath -> IO (Either String ModelPtr)
loadModel path = do
  withCString path $ \cPath -> do
    model <- cLoadModel cPath
    if model == nullPtr
      then return $ Left $ "Failed to load model from " ++ path
      else return $ Right model

-- | An example of how to use the library.
runExample :: IO ()
runExample = do
    let modelName = "models/english-lines-ud-2.5-191206.udpipe"
    mod <- loadModel modelName
    case mod of
      Left msg -> putStrLn msg
      Right mod -> do
        let input = "This is an example"
        ans <- runPipeline mod input
        putStrLn ans

{- TODO: 
 - * Handle errors in the C++ code (give back error message)
 - * Automatically free unused models using ForeignPtr
-} 